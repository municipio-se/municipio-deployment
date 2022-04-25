#!/bin/php
<?php
/**
 * This script is meant to be run from github actions and not locally.
 * It searches any sub folder from the folders in $contentDirectories for a build.php and runs it to prepare a compleate built package of the site.
 * It cleans up files like .git and dev tools that should not be on a public facing server.
 */

// Only allow run from cli.
if (php_sapi_name() !== 'cli') {
    exit(0);
}

// Directories to search for build script in.
$contentDirectories = [
    'wp-content/themes',
    'wp-content/plugins',
    'wp-content/mu-plugins'
];

// Build file name.
$buildFile = 'build.php';

// Files and directories not suitable for public servers to be removed.
$removables = [
    '.git',
    '.gitignore',
    'config',
    'wp-content/uploads',
    'wp-content/themes/municipio/node_modules',
    '.github',
    'build.php',
    'composer.json',
    'composer.lock',
    'images'
];

$dirName = basename(dirname(__FILE__));

// Iterate through directories and try to find and run build scripts.
$root = getcwd();
$output = '';
$exitCode = 0;
$cleanup = (isset($argv[1]) && ($argv[1] === '--cleanup')) ? $argv[1] : '';
foreach ($contentDirectories as $contentDirectory) {
    $directories = glob("$contentDirectory/*", GLOB_ONLYDIR);
    foreach ($directories as $directory) {
        if (file_exists("$directory/$buildFile")) {
            print "-- Running build script in $directory. --\n";
            chdir($directory);

            $exitCode = executeCommand("php $buildFile $cleanup");
            // Break script if any exit code other than 0 is returned.
            if ($exitCode > 0) {
                exit($exitCode);
            }
            chdir($root);
            print "-- Done build script in $directory. --\n";
        }
    }
}


// Remove files and directories.
if ($cleanup) {
    foreach ($removables as $removable) {
        if (file_exists($removable)) {
            print "Removing $removable from $dirName\n";
            // Let this fail without breaking script as its not that important.
            shell_exec("rm -rf $removable");
        }
    }
}

/**
 * Better shell script execution with live output to STDOUT and status code return.
 * @param  string $command Command to execute in shell.
 * @return int             Exit code.
 */
function executeCommand($command)
{
    $proc = popen("$command 2>&1 ; echo Exit status : $?", 'r');

    $liveOutput     = '';
    $completeOutput = '';

    while (!feof($proc)) {
        $liveOutput     = fread($proc, 4096);
        $completeOutput = $completeOutput . $liveOutput;
        print $liveOutput;
        @ flush();
    }

    pclose($proc);

    // Get exit status.
    preg_match('/[0-9]+$/', $completeOutput, $matches);

    // Return exit status.
    return intval($matches[0]);
}
