#!/usr/bin/env php
<?php

declare(strict_types=1);

/**
 * Runs Composer with a manifest containing this deployment's local dependencies.
 */
final class ComposerLocalMerge
{
    private const GENERATED_MANIFEST = '.composer-local.generated.json';
    private const GENERATED_LOCK = '.composer-local.generated.lock';

    /**
     * @param string $rootPath Directory containing the root Composer manifest.
     */
    public function __construct(private string $rootPath)
    {
    }

    /**
     * Run a supported Composer command or check a Composer event hook.
     *
     * @param list<string> $arguments Arguments following the script name.
     * @return int Process exit status.
     * @throws RuntimeException If a manifest is invalid or Composer cannot be started.
     */
    public function run(array $arguments): int
    {
        $command = $arguments[0] ?? '';
        foreach (['.composer-merge-active', 'composer.json.bkup', 'composer.lock.bkup'] as $legacyFile) {
            if (file_exists($this->rootPath . '/' . $legacyFile)) {
                throw new RuntimeException("Found {$legacyFile} from an interrupted legacy merge. Restore the original files before continuing.");
            }
        }
        $local = $this->readLocal();

        if ($command === 'post-install') {
            $this->writeGithubEnvironment('COMPOSER=');
            return 0;
        }

        if ($command === 'guard') {
            if ($this->hasOverrides($local) && getenv('COMPOSER') !== self::GENERATED_MANIFEST) {
                throw new RuntimeException(
                    'Local Composer overrides require php composer-local-merge.php install or update.'
                );
            }
            return 0;
        }

        if (!in_array($command, ['install', 'update', 'validate', 'show', 'reinstall', 'prohibits', 'config', 'manifest', 'pre-install'], true)) {
            throw new RuntimeException('Usage: php composer-local-merge.php [install|update|validate|show|reinstall|prohibits|config|manifest] [options]');
        }

        foreach (array_slice($arguments, 1) as $argument) {
            if (str_starts_with($argument, '-d') || str_starts_with($argument, '--working-dir')) {
                throw new RuntimeException('The Composer working directory cannot be changed through this wrapper.');
            }
        }

        if (getenv('COMPOSER') !== false && getenv('COMPOSER') !== '') {
            throw new RuntimeException('Unset COMPOSER before running the local Composer wrapper.');
        }

        if ($this->hasOverrides($local)) {
            $manifest = $this->merge($this->readJson($this->rootPath . '/composer.json'), $local);
            $encoded = json_encode($manifest, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR);
            if (file_put_contents($this->rootPath . '/' . self::GENERATED_MANIFEST, $encoded . "\n", LOCK_EX) === false) {
                throw new RuntimeException('Could not write the generated Composer manifest.');
            }
            if (in_array($command, ['install', 'reinstall', 'prohibits', 'validate', 'pre-install'], true) &&
                !is_file($this->rootPath . '/' . self::GENERATED_LOCK)) {
                throw new RuntimeException(
                    'The local lock file is missing. Run php composer-local-merge.php update and commit ' .
                    self::GENERATED_LOCK . ' before installing.'
                );
            }
            putenv('COMPOSER=' . self::GENERATED_MANIFEST);
            if (in_array($command, ['install', 'reinstall', 'prohibits', 'pre-install'], true)) {
                $status = $this->runComposer(['validate', '--no-check-publish', '--no-check-all', '--check-lock', '--no-plugins', '--no-scripts']);
                if ($status !== 0) {
                    throw new RuntimeException('The local lock file is invalid or out of date. Run php composer-local-merge.php update.');
                }
            }
        }

        if ($command === 'manifest') {
            if (count($arguments) !== 1) {
                throw new RuntimeException('The manifest command does not accept arguments.');
            }
            echo $this->hasOverrides($local) ? self::GENERATED_MANIFEST . "\n" : "composer.json\n";
            return 0;
        }

        if ($command === 'pre-install') {
            if ($this->hasOverrides($local)) {
                $this->writeGithubEnvironment('COMPOSER=' . self::GENERATED_MANIFEST);
            } elseif (!getenv('GITHUB_ENV')) {
                throw new RuntimeException('pre-install is only supported by the GitHub deployment action. Use install instead.');
            }
            return 0;
        }

        return $this->runComposer($arguments);
    }

    /**
     * Run Composer in the project directory.
     *
     * @param list<string> $arguments Composer arguments.
     * @return int Composer exit status.
     * @throws RuntimeException If Composer cannot be started.
     */
    private function runComposer(array $arguments): int
    {
        $process = proc_open(
            array_merge(['composer'], $arguments),
            [STDIN, STDOUT, STDERR],
            $pipes,
            $this->rootPath
        );
        if (!is_resource($process)) {
            throw new RuntimeException('Could not start Composer.');
        }

        return proc_close($process);
    }

    /**
     * Pass the selected manifest to subsequent steps in the shared deployment action.
     *
     * @param string $entry GitHub Actions environment entry.
     * @return void
     * @throws RuntimeException If the GitHub environment file is unavailable.
     */
    private function writeGithubEnvironment(string $entry): void
    {
        $path = getenv('GITHUB_ENV');
        if (!$path || file_put_contents($path, $entry . "\n", FILE_APPEND | LOCK_EX) === false) {
            throw new RuntimeException('The legacy pre-install and post-install commands require GITHUB_ENV.');
        }
    }

    /**
     * Read the optional local manifest.
     *
     * @return stdClass Local configuration.
     * @throws RuntimeException If the manifest cannot be read or is invalid.
     */
    private function readLocal(): stdClass
    {
        $path = $this->rootPath . '/composer.local.json';
        return is_file($path) ? $this->readJson($path) : new stdClass();
    }

    /**
     * Read a JSON object from disk.
     *
     * @param string $path Manifest path.
     * @return stdClass Decoded manifest.
     * @throws RuntimeException If the manifest cannot be read or is not an object.
     * @throws JsonException If JSON is malformed.
     */
    private function readJson(string $path): stdClass
    {
        $content = file_get_contents($path);
        if ($content === false) {
            throw new RuntimeException("Could not read {$path}.");
        }
        $data = json_decode($content, false, 512, JSON_THROW_ON_ERROR);
        if (!$data instanceof stdClass) {
            throw new RuntimeException("Expected a JSON object in {$path}.");
        }
        return $data;
    }

    /**
     * Validate supported sections and determine whether any local overrides exist.
     *
     * @param stdClass $local Local configuration.
     * @return bool Whether local overrides exist.
     * @throws RuntimeException If a supported section has an invalid shape.
     */
    private function hasOverrides(stdClass $local): bool
    {
        $hasOverrides = false;
        foreach (['require', 'require-dev'] as $section) {
            if (property_exists($local, $section) && !$local->{$section} instanceof stdClass) {
                throw new RuntimeException("Local {$section} must be a JSON object.");
            }
            $hasOverrides = $hasOverrides || !empty((array) ($local->{$section} ?? new stdClass()));
        }
        if (property_exists($local, 'repositories') && !is_array($local->repositories) && !$local->repositories instanceof stdClass) {
            throw new RuntimeException('Local repositories must be a JSON array or object.');
        }
        return $hasOverrides || !empty((array) ($local->repositories ?? []));
    }

    /**
     * Merge dependency constraints and prioritise local repositories.
     *
     * @param stdClass $root Root Composer manifest.
     * @param stdClass $local Local configuration.
     * @return stdClass Combined manifest.
     * @throws RuntimeException If a root section has an invalid shape.
     */
    private function merge(stdClass $root, stdClass $local): stdClass
    {
        foreach (['require', 'require-dev'] as $section) {
            if (isset($root->{$section}) && !$root->{$section} instanceof stdClass) {
                throw new RuntimeException("Root {$section} must be a JSON object.");
            }
            if (isset($local->{$section})) {
                $root->{$section} = (object) array_merge(
                    (array) ($root->{$section} ?? new stdClass()),
                    (array) $local->{$section}
                );
            }
        }

        if (!empty((array) ($local->repositories ?? []))) {
            $existing = $root->repositories ?? [];
            if (!is_array($existing) && !$existing instanceof stdClass) {
                throw new RuntimeException('Root repositories must be a JSON array or object.');
            }
            $repositories = new stdClass();
            $sources = ['local' => $local->repositories, 'root' => $existing];
            $namedRepositories = [];
            foreach ($sources as $entries) {
                foreach ($entries as $key => $_repository) {
                    if (is_string($key)) {
                        $namedRepositories[$key] = true;
                    }
                }
            }
            foreach ($sources as $source => $entries) {
                foreach ($entries as $key => $repository) {
                    if (is_int($key) && $repository instanceof stdClass &&
                        count((array) $repository) === 1 &&
                        (property_exists($repository, 'packagist.org') || property_exists($repository, 'packagist'))) {
                        $key = property_exists($repository, 'packagist.org') ? 'packagist.org' : 'packagist';
                        $repository = $repository->{$key};
                    }
                    $name = is_int($key) ? $source . '-' . $key : $key;
                    if (is_int($key)) {
                        while (isset($namedRepositories[$name]) || property_exists($repositories, $name)) {
                            $name = '_' . $name;
                        }
                    }
                    if (!property_exists($repositories, (string) $name)) {
                        $repositories->{(string) $name} = $repository;
                    }
                }
            }
            $root->repositories = $repositories;
        }
        return $root;
    }
}

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This script must be run from the command line.\n");
    exit(1);
}

try {
    exit((new ComposerLocalMerge(__DIR__))->run(array_slice($argv, 1)));
} catch (RuntimeException | JsonException $exception) {
    fwrite(STDERR, 'Composer local error: ' . $exception->getMessage() . "\n");
    exit(1);
}
