#!/bin/php
<?php

declare(strict_types = 1);

/**
 * This script is meant to be run from github actions and not locally.
 * It prepares the environment before running the main build.php script.
 * This script will check if there are any modifications to the 
 * composer.local.json file and if so, it will remove the composer.lock 
 * file to ensure a fresh install of dependencies without collisions.
 * 
 * This script takes no arguments.
 * 
 */

Class ComposerLocalHandler {

    /**
     * Path to composer.local.json
     * 
     * @var string
     */
    private $composerLocalPath;

    /**
     * Path to composer.lock
     * 
     * @var string
     */
    private $composerLockPath;

    /**
     * Constructor
     * 
     * @param string $rootPath
     */
    public function __construct(string $rootPath) {
      $this->composerLocalPath = $rootPath . '/composer.local.json';
      $this->composerLockPath  = $rootPath . '/composer.lock';

      if (file_exists($this->composerLocalPath) && $this->hasModifications()) {
        $removed = $this->removeComposerLock();
        if ($removed) {
          echo "Removed composer.lock due to composer.local.json modification.\n";
        } else {
          echo "Failed to remove composer.lock despite modifications in composer.local.json.\n";
        }
      } else {
        echo "No modifications detected in composer.local.json.\n";
      }
    }

    /**
     * Check if composer.local.json has modifications, (check for diff between main origin and fork).
     * 
     * @return bool
     */
    public function hasModifications(): bool {
      $expectedJson = $this->getExpectedJson();
      $currentJson  = $this->getCurrentJson($this->composerLocalPath);
      return $expectedJson !== $currentJson;
    }

    /**
     * Get the expected composer.local.json content.
     * 
     * @return array
     */
    public function getExpectedJson(): array {
      $expectedJson = '{
        "name": "municipio-se/municipio-deployment-custom",
        "license": "MIT",
        "description": "Additions for you own install of municipo.",
        "require": {}
      }';
      return $this->jsonDecode($expectedJson);
    }

    /**
     * Get the current composer.local.json content.
     * 
     * @param string $path
     * @return array
     */
    private function getCurrentJson(string $path): array
    {
      return $this->jsonDecode(
        file_get_contents($path)
      );
    }

    /**
     * Decode json string to array.
     * 
     * @param string $json
     * @return array
     */
    private function jsonDecode(string $json): array {
      return json_decode($json, true);
    }
    
    /**
     * Remove composer.lock file.
     * 
     * @return void
     */
    public function removeComposerLock(): bool {
      if (file_exists($this->composerLockPath)) {
        return unlink($this->composerLockPath);
      }
      return false;
    }
}

new ComposerLocalHandler(getcwd());