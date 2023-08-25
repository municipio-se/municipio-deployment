<?php

/**
 * Class DependecyChecker handles dependency checks for Municipio.
 */
class DependecyChecker
{
    /**
     * Directories to search for build script in.
     *
     * @var array
     */
    private $contentDirectories = [
        'wp-content/themes',
        'wp-content/plugins',
        'wp-content/mu-plugins'
    ];

    /**
     * The location of the main composer.json file.
     */
    private $composerDirectory = "./"; 

    /**
     * Run the installation process.
     */
    public function run()
    {

        if (php_sapi_name() !== 'cli') {
            $this->abortInstall();
        }

        //Get all dependencies in project
        $subDependencies = $this->getSubDependencies(
          $this->contentDirectories
        );

        //Get main dependencies
        $mainDependencies = $this->getComposerDependencies(
          $this->composerDirectory
        );

        //Find out if we are missing some dependencies in main.
        if ($missingRequirements = $this->determineMissingRequirements($subDependencies, $mainDependencies)) {
            $this->printMissingRequirements($missingRequirements);
            $this->abortInstall();
        }
    }

    /**
     * Get sub-dependencies from specified content directories.
     *
     * @return array
     */
    private function getSubDependencies($contentDirectories)
    {
        $requirementsStack = array();

        foreach ($contentDirectories as $directory) {
            $directoryContents = $this->getFoldersInDirectory($directory);
            foreach ($directoryContents as $dir) {
                $requirements = $this->getComposerDependencies($dir);
                if ($requirements) {
                    $requirementsStack = array_merge($requirementsStack, (array)$requirements);
                }
            }
        }

        return (array)$requirementsStack;
    }

    /**
     * Get Composer dependencies from a given path.
     *
     * @param string $path The path to the directory.
     * @return array|false
     */
    private function getComposerDependencies($path)
    {

        $path = $path . "/composer.json"; 

        if (!file_exists($path)) {
            return false;
        }

        $contents = file_get_contents($path);
        if ($contents = json_decode($contents)) {
            if (isset($contents->require)) {
                return (array)$contents->require;
            }
        }

        return false;
    }

    /**
     * Get sub-folders in a directory.
     *
     * @param string $directory The directory path.
     * @return array
     */
    private function getFoldersInDirectory($directory)
    {
        return glob(__DIR__ . "/" . $directory . "/*", GLOB_ONLYDIR);
    }

    /**
     * Determine missing requirements by comparing sub-dependencies and main dependencies.
     *
     * @param array $subDependencies Sub-dependencies from content directories.
     * @param array $mainDependencies Main dependencies from root.
     * @return array
     */
    private function determineMissingRequirements($subDependencies, $mainDependencies)
    {
        return array_diff(
            $subDependencies, 
            $mainDependencies
        );
    }

    /**
     * Print missing requirements.
     *
     * @param array $requirements Missing requirements.
     */
    private function printMissingRequirements($requirements)
    {
        echo "DEPENDENCY MISMATCH: \n";
        echo "The following requirements were found in the installable resources, but not found in the main requirements. Please add them to the requirements list in composer.json to install Municipio. \n\n";

        foreach ($requirements as $requirement => $version) {
            echo '"' . $requirement . '": "' . $version . '",' . "\n";
        }
    }

    /**
     * Abort the installation process.
     */
    private function abortInstall()
    {
        exit(1);
    }
}

// Instantiate and run the installer.
$installer = new DependecyChecker();
$installer->run();
