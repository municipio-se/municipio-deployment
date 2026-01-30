#!/bin/php
<?php

declare(strict_types=1);

/**
 * Composer Local Merge Handler
 * 
 * Replaces Wikimedia Composer Merge plugin with a deterministic, script-based workflow.
 * This script temporarily injects local composer requirements only when needed.
 * 
 * Workflow:
 * 1. pre-install: Detect local overrides, backup, merge, and prepare for install
 * 2. post-install: Restore original files and clean up backups
 */

class ComposerLocalMerge
{
    private const COMPOSER_JSON = 'composer.json';
    private const COMPOSER_LOCAL_JSON = 'composer.local.json';
    private const COMPOSER_LOCK = 'composer.lock';
    private const BACKUP_SUFFIX = '.bkup';

    private string $rootPath;
    private bool $hasMerged = false;
    private string $flagFile;

    public function __construct(string $rootPath)
    {
        $this->rootPath = rtrim($rootPath, '/');
        $this->flagFile = $this->rootPath . '/.composer-merge-active';
    }

    /**
     * Pre-install hook: Backup and merge local requirements if present
     */
    public function preInstall(): void
    {
        echo "=== Composer Local Merge: Pre-Install ===\n";

        $localPath = $this->getPath(self::COMPOSER_LOCAL_JSON);
        
        if (!file_exists($localPath)) {
            echo "No composer.local.json found - skipping merge\n";
            return;
        }

        $localRequirements = $this->getLocalRequirements($localPath);
        
        if (empty($localRequirements['require']) && empty($localRequirements['require-dev'])) {
            echo "composer.local.json has no requirements - skipping merge\n";
            return;
        }

        try {
            $this->performMerge($localRequirements);
            echo "Successfully merged local requirements\n";
        } catch (Exception $e) {
            echo "ERROR: " . $e->getMessage() . "\n";
            $this->rollback();
            exit(1);
        }
    }

    /**
     * Post-install hook: Restore original files and clean up
     */
    public function postInstall(): void
    {
        echo "=== Composer Local Merge: Post-Install ===\n";

        if (!file_exists($this->flagFile)) {
            echo "No merge was performed - skipping restore\n";
            return;
        }

        try {
            $this->restore();
            echo "Successfully restored original files\n";
        } catch (Exception $e) {
            echo "ERROR during restore: " . $e->getMessage() . "\n";
            exit(1);
        }
    }

    /**
     * Perform the merge operation
     */
    private function performMerge(array $localRequirements): void
    {
        $composerPath = $this->getPath(self::COMPOSER_JSON);
        $lockPath = $this->getPath(self::COMPOSER_LOCK);

        // Step 1: Backup composer.json
        $this->backup($composerPath);
        echo "✓ Backed up composer.json\n";

        // Step 2: Backup composer.lock if it exists
        if (file_exists($lockPath)) {
            $this->backup($lockPath);
            echo "✓ Backed up composer.lock\n";
            
            // Step 3: Remove composer.lock to force fresh resolution
            if (!unlink($lockPath)) {
                throw new Exception("Failed to remove composer.lock");
            }
            echo "✓ Removed composer.lock\n";
        }

        // Step 4: Merge requirements into composer.json
        // Note: Local requirements override existing ones - this allows developers
        // to test specific versions or patches during development
        $composer = $this->readJson($composerPath);
        
        if (!empty($localRequirements['require'])) {
            $composer['require'] = array_merge(
                $composer['require'] ?? [],
                $localRequirements['require']
            );
            echo "✓ Merged " . count($localRequirements['require']) . " require dependencies\n";
        }
        
        if (!empty($localRequirements['require-dev'])) {
            $composer['require-dev'] = array_merge(
                $composer['require-dev'] ?? [],
                $localRequirements['require-dev']
            );
            echo "✓ Merged " . count($localRequirements['require-dev']) . " require-dev dependencies\n";
        }

        $this->writeJson($composerPath, $composer);
        
        // Create flag file to indicate merge was performed
        if (file_put_contents($this->flagFile, time()) === false) {
            throw new Exception("Failed to create merge flag file");
        }
        
        $this->hasMerged = true;
    }

    /**
     * Restore original files from backups
     */
    private function restore(): void
    {
        $composerPath = $this->getPath(self::COMPOSER_JSON);
        $lockPath = $this->getPath(self::COMPOSER_LOCK);
        
        // Restore composer.json
        $this->restoreFromBackup($composerPath);
        echo "✓ Restored composer.json\n";

        // Restore composer.lock if backup exists
        $lockBackup = $lockPath . self::BACKUP_SUFFIX;
        if (file_exists($lockBackup)) {
            $this->restoreFromBackup($lockPath);
            echo "✓ Restored composer.lock\n";
        }

        // Clean up flag file
        if (file_exists($this->flagFile)) {
            unlink($this->flagFile);
        }
    }

    /**
     * Rollback changes in case of error
     */
    private function rollback(): void
    {
        echo "Rolling back changes...\n";
        
        try {
            $composerPath = $this->getPath(self::COMPOSER_JSON);
            $composerBackup = $composerPath . self::BACKUP_SUFFIX;
            
            if (file_exists($composerBackup)) {
                $this->restoreFromBackup($composerPath);
                echo "✓ Rolled back composer.json\n";
            }

            $lockPath = $this->getPath(self::COMPOSER_LOCK);
            $lockBackup = $lockPath . self::BACKUP_SUFFIX;
            
            if (file_exists($lockBackup)) {
                $this->restoreFromBackup($lockPath);
                echo "✓ Rolled back composer.lock\n";
            }

            if (file_exists($this->flagFile)) {
                unlink($this->flagFile);
            }
        } catch (Exception $e) {
            echo "ERROR during rollback: " . $e->getMessage() . "\n";
        }
    }

    /**
     * Get local requirements from composer.local.json
     */
    private function getLocalRequirements(string $path): array
    {
        $data = $this->readJson($path);
        
        return [
            'require' => $data['require'] ?? [],
            'require-dev' => $data['require-dev'] ?? []
        ];
    }

    /**
     * Create backup of a file
     */
    private function backup(string $path): void
    {
        $backup = $path . self::BACKUP_SUFFIX;
        
        if (!copy($path, $backup)) {
            throw new Exception("Failed to backup: {$path}");
        }
    }

    /**
     * Restore file from backup
     */
    private function restoreFromBackup(string $path): void
    {
        $backup = $path . self::BACKUP_SUFFIX;
        
        if (!file_exists($backup)) {
            throw new Exception("Backup not found: {$backup}");
        }
        
        if (!copy($backup, $path)) {
            throw new Exception("Failed to restore: {$path}");
        }
        
        unlink($backup);
    }

    /**
     * Read and decode JSON file
     */
    private function readJson(string $path): array
    {
        if (!file_exists($path)) {
            throw new Exception("File not found: {$path}");
        }
        
        $content = file_get_contents($path);
        $data = json_decode($content, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new Exception("Invalid JSON in {$path}: " . json_last_error_msg());
        }
        
        return $data;
    }

    /**
     * Encode and write JSON file
     */
    private function writeJson(string $path, array $data): void
    {
        $json = json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
        
        if ($json === false) {
            throw new Exception("Failed to encode JSON: " . json_last_error_msg());
        }
        
        // Add newline at end of file to match standard formatting
        $json .= "\n";
        
        if (file_put_contents($path, $json) === false) {
            throw new Exception("Failed to write file: {$path}");
        }
    }

    /**
     * Get full path for a file
     */
    private function getPath(string $filename): string
    {
        return $this->rootPath . '/' . $filename;
    }
}

// Main execution
if (PHP_SAPI !== 'cli') {
    echo "This script must be run from the command line\n";
    exit(1);
}

$action = $argv[1] ?? '';
$rootPath = getcwd();

$merger = new ComposerLocalMerge($rootPath);

switch ($action) {
    case 'pre-install':
        $merger->preInstall();
        break;
    case 'post-install':
        $merger->postInstall();
        break;
    default:
        echo "Usage: php composer-local-merge.php [pre-install|post-install]\n";
        exit(1);
}
