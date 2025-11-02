<?php

/**
 * Plugin Name:       Säter Alt Text Injector
 * Plugin URI:
 * Description:       Automatically injects alt text for images missing it by using filename, title, caption, or contextual information.
 * Version:           1.0.0
 * Author:            Jovica Bumbulovic
 * License:           MIT
 * License URI:       https://opensource.org/licenses/MIT
 * Text Domain:       sater-alt-text-injector
 * Domain Path:       /languages
 */

// Protect against direct file access
if (! defined('WPINC')) {
    die;
}

// Start the plugin after WordPress is loaded
add_action('init', function() {
    new AutoAltTextInjector();
}, 1);

/**
 * Main plugin class
 */
class AutoAltTextInjector
{
    /**
     * Constructor
     */
    public function __construct()
    {
        // PHP processing - reads WordPress alt text from database
        add_action('template_redirect', array($this, 'startOutputBuffer'), PHP_INT_MAX);
        add_filter('the_content', array($this, 'fixRenderedImages'), 998);
        add_filter('widget_text', array($this, 'fixRenderedImages'), 999);
        add_filter('the_excerpt', array($this, 'fixRenderedImages'), 999);
        add_filter('acf/format_value', array($this, 'injectAltTextInAcf'), 999, 3);
    }
    
    /**
     * Start output buffering to catch final HTML
     */
    public function startOutputBuffer()
    {
        // Only on frontend, not admin/ajax/cron
        if (is_admin() || wp_doing_ajax() || wp_doing_cron() || is_feed()) {
            return;
        }
        
        // Start output buffering with callback - callback will be called automatically when buffer is flushed
        ob_start(array($this, 'processFinalOutput'));
    }
    
    /**
     * Process final output buffer
     *
     * @param string $buffer The output buffer
     * @return string Modified buffer
     */
    public function processFinalOutput($buffer)
    {
        if (empty($buffer) || !is_string($buffer)) {
            return $buffer;
        }
        
        // Only process HTML pages
        if (strpos($buffer, '<html') === false && strpos($buffer, '<body') === false) {
            return $buffer;
        }
        
        // Process the buffer to fix any remaining images
        return $this->fixRenderedImages($buffer);
    }
    
    /**
     * Fix rendered images after Blade template processing
     * This catches images that were rendered without alt text
     * Uses regex for reliable and fast matching
     *
     * @param string $content The content to process
     * @return string Modified content
     */
    public function fixRenderedImages($content)
    {
        if (empty($content) || !is_string($content)) {
            return $content;
        }

        // Only process if content contains images or figures with data-a11y-error
        if (strpos($content, '<img') === false && strpos($content, 'data-a11y-error') === false && strpos($content, 'data-ally-error') === false) {
            return $content;
        }
        
        // Step 1: Find all figures with data-a11y-error (handle any order of attributes)
        // Match figure tag that contains data-a11y-error attribute anywhere
        $figurePattern = '/<figure\s+[^>]*?data-a11y-error=["\'][^"\']*["\'][^>]*>.*?<\/figure>/is';
        
        $content = preg_replace_callback($figurePattern, function($matches) {
            $figureHtml = $matches[0];
            
            // Extract src from any img tag inside the figure
            if (preg_match('/<img[^>]*?\ssrc=["\']([^"\']+)["\']/', $figureHtml, $srcMatch)) {
                $src = $srcMatch[1];
                $altText = $this->generateAltTextFromSrc($src);
                
                // Find and fix the img tag - handle both alt="" and missing alt
                // Replace alt="" with our generated alt
                $figureHtml = preg_replace(
                    '/(<img[^>]*?\s)(alt=["\']\s*["\'])/',
                    '$1alt="' . esc_attr($altText) . '"',
                    $figureHtml
                );
                
                // If img doesn't have alt attribute at all, add it before the closing >
                if (!preg_match('/alt=["\']/', $figureHtml)) {
                    $figureHtml = preg_replace(
                        '/(<img[^>]*?)(\s*>)/',
                        '$1 alt="' . esc_attr($altText) . '"$2',
                        $figureHtml
                    );
                }
                
                // Remove data-a11y-error attribute from figure tag
                $figureHtml = preg_replace('/\s+data-a11y-error=["\'][^"\']*["\']/', '', $figureHtml);
                $figureHtml = preg_replace('/\s+data-ally-error=["\'][^"\']*["\']/', '', $figureHtml);
                
                return $figureHtml;
            }
            
            return $matches[0];
        }, $content);
        
        // Step 2: Also fix standalone img tags with empty alt (outside figures)
        $content = preg_replace_callback('/<img((?:(?!>).)*?)>/is', function($matches) {
            $imgAttributes = $matches[1];
            
            // Check if alt is empty or missing
            if (preg_match('/alt=["\']\s*["\']/', $imgAttributes) || 
                preg_match('/alt=["\']parsed=1["\']/', $imgAttributes) ||
                !preg_match('/alt=["\']/', $imgAttributes)) {
                
                // Extract src
                $src = '';
                if (preg_match('/src=["\']([^"\']+)["\']/', $imgAttributes, $srcMatches)) {
                    $src = $srcMatches[1];
                }
                
                // Generate alt text
                $altText = $this->generateAltTextFromSrc($src);
                
                // Fix img tag
                if (preg_match('/alt=["\']/', $imgAttributes)) {
                    $imgAttributes = preg_replace('/alt=["\'][^"\']*["\']/', 'alt="' . esc_attr($altText) . '"', $imgAttributes);
                } else {
                    $imgAttributes = trim($imgAttributes) . ' alt="' . esc_attr($altText) . '"';
                }
                
                return '<img' . $imgAttributes . '>';
            }
            
            return $matches[0];
        }, $content);
        
        // Step 3: Use DOM as fallback only if we still have data-a11y-error (regex might have missed something)
        if (strpos($content, 'data-a11y-error') !== false || strpos($content, 'data-ally-error') !== false) {
            return $this->fixRenderedImagesWithDom($content);
        }
        
        return $content;
    }
    
    /**
     * Fix images using DOMDocument (more precise but slower)
     *
     * @param string $content The content to process
     * @return string Modified content
     */
    private function fixRenderedImagesWithDom($content)
    {
        if (empty($content) || !is_string($content)) {
            return $content;
        }

        // Use DOMDocument to parse and modify HTML
        $encoding = '<?xml encoding="utf-8" ?>';
        $dom = new \DOMDocument();
        
        libxml_use_internal_errors(true);
        $wrappedContent = $encoding . '<html><body>' . $content . '</body></html>';
        @$dom->loadHTML($wrappedContent, LIBXML_NOERROR | LIBXML_HTML_NODEFDTD);
        libxml_clear_errors();

        $xpath = new \DOMXPath($dom);
        
        // Find all images with missing alt or inside figures with data-a11y-error
        $images = $xpath->query('//img[@alt="" or not(@alt) or @alt="parsed=1" or @alt="parsed=\"1\""] | //figure[@data-a11y-error]//img | //figure[@data-ally-error]//img');

        if ($images && $images->length > 0) {
            foreach ($images as $img) {
                $currentAlt = $img->getAttribute('alt');
                
                // Skip if alt text already exists and is meaningful
                if (!empty($currentAlt) && $currentAlt !== 'parsed=1' && $currentAlt !== 'parsed="1"') {
                    continue;
                }

                // Generate alt text
                $altText = $this->generateAltTextFromDom($img, $dom);
                
                if (!empty($altText)) {
                    $img->setAttribute('alt', $altText);
                    
                    // Remove data-a11y-error from parent figure
                    $figure = $img->parentNode;
                    while ($figure && $figure instanceof \DOMElement) {
                        if ($figure->nodeName === 'figure') {
                            if ($figure->hasAttribute('data-a11y-error')) {
                                $figure->removeAttribute('data-a11y-error');
                            }
                            if ($figure->hasAttribute('data-ally-error')) {
                                $figure->removeAttribute('data-ally-error');
                            }
                            break;
                        }
                        $figure = $figure->parentNode;
                    }
                }
            }
        }

        // Extract body content
        $body = $dom->getElementsByTagName('body')->item(0);
        if ($body) {
            $content = '';
            foreach ($body->childNodes as $child) {
                $content .= $dom->saveHTML($child);
            }
        } else {
            $content = $dom->saveHTML();
            $content = preg_replace('/^.*?<body[^>]*>/is', '', $content);
            $content = preg_replace('/<\/body>.*?$/is', '', $content);
            $content = str_replace([$encoding, '<html>', '</html>'], '', $content);
        }
        
        return $content;
    }
    
    /**
     * Generate alt text from image src URL
     *
     * @param string $src The image src URL
     * @return string Generated alt text
     */
    private function generateAltTextFromSrc($src)
    {
        if (empty($src)) {
            return __('Image', 'sater-alt-text-injector');
        }
        
        // Try to get from WordPress attachment if available
        $cleanSrc = preg_replace('/\?.*$/', '', $src);
        $attachmentId = attachment_url_to_postid($cleanSrc);
        
        if ($attachmentId) {
            // Get alt text from attachment meta (fastest - direct meta query)
            $attachmentAlt = get_post_meta($attachmentId, '_wp_attachment_image_alt', true);
            if (!empty($attachmentAlt)) {
                return sanitize_text_field($attachmentAlt);
            }
            
            // Get title from attachment (fallback)
            $attachmentTitle = get_the_title($attachmentId);
            if (!empty($attachmentTitle) && $attachmentTitle !== 'Attachment' && $attachmentTitle !== 'Auto Draft') {
                return sanitize_text_field($attachmentTitle);
            }
        }
        
        // Generate from filename
        $filename = basename(parse_url($src, PHP_URL_PATH));
        $filename = preg_replace('/\?.*$/', '', $filename);
        $altText = $this->generateAltFromFilename($filename);
        
        if (!empty($altText)) {
            return $altText;
        }
        
        return __('Image', 'sater-alt-text-injector');
    }
    
    /**
     * Generate alt text from DOM element (used by DOM fallback only)
     *
     * @param \DOMElement $img The image element
     * @param \DOMDocument $dom The DOM document
     * @return string Generated alt text
     */
    private function generateAltTextFromDom(\DOMElement $img, \DOMDocument $dom)
    {
        // 1. Try to get caption from figcaption
        $caption = $this->getCaption($img);
        if (!empty($caption)) {
            return sanitize_text_field($caption);
        }
        
        // 2. Try to get title attribute
        $title = $img->getAttribute('title');
        if (!empty($title)) {
            return sanitize_text_field($title);
        }
        
        // 3. Get src and use shared function
        $src = $img->getAttribute('src');
        if (!empty($src)) {
            $altText = $this->generateAltTextFromSrc($src);
            
            // 4. Try context if filename didn't work and we got generic fallback
            if ($altText === __('Image', 'sater-alt-text-injector')) {
                $context = $this->getImageContext($img, $dom);
                if (!empty($context)) {
                    return sanitize_text_field($context);
                }
            }
            
            return $altText;
        }
        
        return __('Image', 'sater-alt-text-injector');
    }

    /**
     * Inject alt text in ACF fields (for flexible content, etc.)
     *
     * @param mixed $value The field value
     * @param int $post_id Post ID
     * @param array $field Field array
     * @return mixed Modified value
     */
    public function injectAltTextInAcf($value, $post_id, $field)
    {
        // Only process if value is a string (HTML content)
        if (is_string($value) && (strpos($value, '<img') !== false || strpos($value, '<figure') !== false)) {
            return $this->fixRenderedImages($value);
        }
        
        return $value;
    }

    /**
     * Get caption from figcaption element
     *
     * @param \DOMElement $img The image element
     * @return string Caption text
     */
    private function getCaption(\DOMElement $img)
    {
        // Check if image is inside a figure with figcaption
        $parent = $img->parentNode;
        
        while ($parent && $parent instanceof \DOMElement) {
            if ($parent->nodeName === 'figure') {
                $figcaptions = $parent->getElementsByTagName('figcaption');
                if ($figcaptions->length > 0) {
                    $caption = wp_strip_all_tags($figcaptions->item(0)->textContent);
                    return trim($caption);
                }
            }
            $parent = $parent->parentNode;
        }
        
        return '';
    }

    /**
     * Generate alt text from filename
     *
     * @param string $filename The filename
     * @return string Generated alt text
     */
    private function generateAltFromFilename($filename)
    {
        if (empty($filename)) {
            return '';
        }
        
        // Remove extension
        $name = pathinfo($filename, PATHINFO_FILENAME);
        
        // Remove common WordPress image suffixes
        $name = preg_replace('/-(\d+x\d+|scaled|rotated)$/', '', $name);
        
        // Replace hyphens and underscores with spaces
        $name = str_replace(['-', '_'], ' ', $name);
        
        // Clean up multiple spaces
        $name = preg_replace('/\s+/', ' ', $name);
        
        // Capitalize first letter of the string (preserve international characters)
        $name = mb_strtolower($name, 'UTF-8');
        $name = mb_strtoupper(mb_substr($name, 0, 1, 'UTF-8'), 'UTF-8') . mb_substr($name, 1, null, 'UTF-8');
        
        // Capitalize first letter of each word (for better readability)
        $words = explode(' ', $name);
        $words = array_map(function($word) {
            if (mb_strlen($word, 'UTF-8') > 0) {
                return mb_strtoupper(mb_substr($word, 0, 1, 'UTF-8'), 'UTF-8') . mb_substr($word, 1, null, 'UTF-8');
            }
            return $word;
        }, $words);
        $name = implode(' ', $words);
        
        // Remove common prefix patterns
        $name = preg_replace('/^(Wp|Image|Img|Pic|Photo)\s+/i', '', $name);
        
        return trim($name);
    }

    /**
     * Get contextual information from surrounding content
     *
     * @param \DOMElement $img The image element
     * @param \DOMDocument $dom The DOM document
     * @return string Contextual text
     */
    private function getImageContext(\DOMElement $img, \DOMDocument $dom)
    {
        // Get parent paragraph or heading
        $parent = $img->parentNode;
        
        while ($parent && $parent instanceof \DOMElement) {
            if (in_array($parent->nodeName, ['p', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'div', 'article', 'section'])) {
                // Get text content from parent, excluding image alt text
                $text = $parent->textContent;
                
                // Clean up the text
                $text = wp_strip_all_tags($text);
                $text = preg_replace('/\s+/', ' ', $text);
                $text = trim($text);
                
                // Return first sentence or first 100 characters
                if (!empty($text)) {
                    $sentences = preg_split('/([.!?]+)/', $text, 2, PREG_SPLIT_DELIM_CAPTURE);
                    if (!empty($sentences[0])) {
                        $context = trim($sentences[0]) . (!empty($sentences[1]) ? $sentences[1] : '');
                        if (strlen($context) > 100) {
                            $context = substr($context, 0, 97) . '...';
                        }
                        return $context;
                    }
                }
            }
            $parent = $parent->parentNode;
        }
        
        return '';
    }
}

