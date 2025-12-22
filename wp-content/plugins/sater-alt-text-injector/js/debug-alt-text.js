/**
 * Alt Text Debugger - Console logger for debugging alt text issues
 */
(function() {
    'use strict';

    console.log('%c🔍 ALT TEXT DEBUGGER STARTED', 'color: #2b356c; font-size: 16px; font-weight: bold;');
    
    function debugImages() {
        console.log('\n%c=== SCANNING ALL IMAGES ===', 'color: #2b356c; font-weight: bold;');
        
        const allImages = document.querySelectorAll('img');
        const imagesWithoutAlt = [];
        const imagesWithEmptyAlt = [];
        const imagesWithAlt = [];
        const figuresWithError = [];
        
        allImages.forEach((img, index) => {
            const alt = img.getAttribute('alt');
            const src = img.src;
            const title = img.getAttribute('title');
            const attachmentId = getAttachmentId(img);
            
            const imageInfo = {
                index: index + 1,
                src: src.substring(src.lastIndexOf('/') + 1),
                fullSrc: src,
                alt: alt,
                title: title,
                attachmentId: attachmentId,
                classes: img.className,
                parentTag: img.parentElement?.tagName
            };
            
            if (alt === null || alt === undefined) {
                imagesWithoutAlt.push(imageInfo);
            } else if (alt === '' || alt === 'parsed=1' || alt === 'parsed="1"') {
                imagesWithEmptyAlt.push(imageInfo);
            } else {
                imagesWithAlt.push(imageInfo);
            }
            
            // Check if image is inside figure with error
            let parent = img.parentElement;
            while (parent) {
                if (parent.tagName === 'FIGURE' && 
                    (parent.hasAttribute('data-a11y-error') || parent.hasAttribute('data-ally-error'))) {
                    figuresWithError.push({
                        ...imageInfo,
                        errorAttr: parent.getAttribute('data-a11y-error') || parent.getAttribute('data-ally-error')
                    });
                    break;
                }
                parent = parent.parentElement;
            }
        });
        
        console.log(`%c📊 SUMMARY`, 'color: #2b356c; font-weight: bold;');
        console.log(`Total images: ${allImages.length}`);
        console.log(`✅ Images WITH alt text: ${imagesWithAlt.length}`);
        console.log(`⚠️  Images with EMPTY alt: ${imagesWithEmptyAlt.length}`);
        console.log(`❌ Images WITHOUT alt attribute: ${imagesWithoutAlt.length}`);
        console.log(`🚨 Figures with a11y errors: ${figuresWithError.length}`);
        
        if (imagesWithoutAlt.length > 0) {
            console.log('\n%c❌ IMAGES WITHOUT ALT ATTRIBUTE:', 'color: red; font-weight: bold;');
            console.table(imagesWithoutAlt);
        }
        
        if (imagesWithEmptyAlt.length > 0) {
            console.log('\n%c⚠️  IMAGES WITH EMPTY ALT:', 'color: orange; font-weight: bold;');
            console.table(imagesWithEmptyAlt);
        }
        
        if (figuresWithError.length > 0) {
            console.log('\n%c🚨 FIGURES WITH A11Y ERRORS:', 'color: red; font-weight: bold;');
            console.table(figuresWithError);
        }
        
        if (imagesWithAlt.length > 0 && imagesWithAlt.length <= 10) {
            console.log('\n%c✅ IMAGES WITH ALT TEXT (showing first 10):', 'color: green; font-weight: bold;');
            console.table(imagesWithAlt.slice(0, 10));
        }
        
        // Test if filter is working by checking database
        console.log('\n%c🔬 TESTING ALT TEXT RETRIEVAL:', 'color: #2b356c; font-weight: bold;');
        figuresWithError.forEach(img => {
            if (img.attachmentId) {
                console.log(`Image: ${img.src}`);
                console.log(`  Attachment ID: ${img.attachmentId}`);
                console.log(`  Current alt: "${img.alt}"`);
                console.log(`  Error: ${img.errorAttr}`);
            }
        });
    }
    
    function getAttachmentId(img) {
        // Try data-id attribute
        const dataId = img.getAttribute('data-id') || img.getAttribute('data-attachment-id');
        if (dataId) return parseInt(dataId, 10);
        
        // Try class name (WordPress uses wp-image-{ID})
        const classes = img.className || '';
        const match = classes.match(/wp-image-(\d+)/);
        if (match) return parseInt(match[1], 10);
        
        return null;
    }
    
    // Run on page load
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', debugImages);
    } else {
        debugImages();
    }
    
    // Also run after a delay to catch dynamically loaded images
    setTimeout(() => {
        console.log('\n%c🔄 RE-SCANNING AFTER 2 SECONDS...', 'color: #2b356c; font-weight: bold;');
        debugImages();
    }, 2000);
    
    // Make debugImages available globally
    window.debugAltText = debugImages;
    console.log('\n%c💡 TIP: Run window.debugAltText() to re-scan images', 'color: #666; font-style: italic;');
    
})();

