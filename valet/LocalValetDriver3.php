<?php

/**
 * Put this file in the root of your Wordpress site if you have Wordpress core
 * files installed inside a subdirectory. This helps valet rewrite the urls so
 * that you can access wp-admin for the main site and all subsites of a
 * multisite install.
 */

class LocalValetDriver extends BasicValetDriver {
  public $wp_root = "/wp";

  public function serves($sitePath, $siteName, $uri) {
    return is_dir($sitePath . $this->wp_root . "/") &&
      file_exists($sitePath . "/wp-config.php") &&
      (is_dir($sitePath . "/config/") || file_exists($sitePath . "/.env"));
  }

  public function frontControllerPath($sitePath, $siteName, $uri) {
    $_SERVER["PHP_SELF"] = $uri;
    $_SERVER["SERVER_ADDR"] = "127.0.0.1";
    $_SERVER["SERVER_NAME"] = $_SERVER["HTTP_HOST"];

    $uri = $this->stripMultisiteSubdir($uri);

    if (preg_match('/^\/.+(\/wp-admin\/.*)$/', $uri, $matches)) {
      $uri = $matches[1];
    }

    $uri = $this->forceTrailingSlash($uri);

    $candidates = [
      $this->asActualWordpressRootFile($sitePath, $uri),
      $this->asWordpressRootPhpIndexFileInDirectory($sitePath, $uri),
      $this->asWordpressRootHtmlIndexFileInDirectory($sitePath, $uri),
    ];

    foreach ($candidates as $candidate) {
      if ($this->isActualFile($candidate)) {
        $_SERVER["SCRIPT_FILENAME"] = $candidate;
        $_SERVER["SCRIPT_NAME"] = str_replace($sitePath, "", $candidate);
        $_SERVER["DOCUMENT_ROOT"] = $sitePath;
        return $candidate;
      }
    }

    return parent::frontControllerPath($sitePath, $siteName, $uri);
  }

  public function isStaticFile($sitePath, $siteName, $uri) {
    $uri = $this->stripMultisiteSubdir($uri);
    if (
      $this->isActualFile($staticFilePath = $sitePath . $this->wp_root . $uri)
    ) {
      return $staticFilePath;
    } elseif ($this->isActualFile($staticFilePath = $sitePath . $uri)) {
      return $staticFilePath;
    }
    return false;
  }

  public function stripMultisiteSubdir($uri) {
    if (preg_match('/^(.*?)(\/wp-[a-z-]+(\/.*|\.php))$/', $uri, $matches)) {
      $uri = $matches[2];
    }
    return $uri;
  }

  private function forceTrailingSlash($uri) {
    if (substr($uri, -1 * strlen("/wp-admin")) == "/wp-admin") {
      header("Location: " . $uri . "/");
      die();
    }
    return $uri;
  }

  protected function asActualWordpressRootFile($sitePath, $uri) {
    return $sitePath . $this->wp_root . $uri;
  }

  protected function asWordpressRootPhpIndexFileInDirectory($sitePath, $uri) {
    return $sitePath . $this->wp_root . rtrim($uri, "/") . "/index.php";
  }

  protected function asWordpressRootHtmlIndexFileInDirectory($sitePath, $uri) {
    return $sitePath . $this->wp_root . rtrim($uri, "/") . "/index.html";
  }
}
