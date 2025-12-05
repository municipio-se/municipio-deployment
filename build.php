#!/bin/php
<?php
/**
 * This script is meant to be run from github actions and not locally.
 * It searches any sub folder from the folders in $contentDirectories for a build.php and runs it to prepare a compleate built package of the site.
 * It cleans up files like .git and dev tools that should not be on a public facing server.
 * 
 * This script takes two arguments:
 *  - no-composer-in-child-packages: Does not run composer in sub-repositories. 
 *  - cleanup: Remove files and folders in removeables list. 
 *  - install-npm: Installs JS and CSS dists from NPM instead of building them. 
 * 
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
    'GitVersion.yml',
    'config',
    'wp-content/uploads',
    '.github',
    'build.php',
    'composer.json',
    'composer.local.json',
    'post-install.php',
    'composer.lock',
    'images',
    'README.md',
    'guide',
    'db',
    '.devcontainer',
    '.vscode',
    'install.html',
    'build-pre.php',
    'franken',
    '.composerignore',
];


$dirName = basename(dirname(__FILE__));

// Iterate through directories and try to find and run build scripts.
$root       = getcwd();
$output     = '';
$exitCode   = 0;
$cleanup    = is_array($argv) && in_array('--cleanup', $argv) ? '--cleanup' : '';
$noComposer = is_array($argv) && in_array('--no-composer-in-child-packages', $argv) ? '--no-composer' : '';
$installNPM = is_array($argv) && in_array('--install-npm', $argv) ? '--install-npm' : '';

$builds = [];
foreach ($contentDirectories as $contentDirectory) {
    $directories = glob("$contentDirectory/*", GLOB_ONLYDIR);
    foreach ($directories as $directory) {
        if (file_exists("$directory/$buildFile")) {
            print "-- Running build script in $directory. --\n";
            $timeStart = microtime(true);
            chdir($directory);

            $exitCode = executeCommand("php $buildFile $cleanup $noComposer $installNPM");
            // Break script if any exit code other than 0 is returned.
            if ($exitCode > 0) {
                exit($exitCode);
            }
            chdir($root);
            $buildTime = round(microtime(true) - $timeStart);
            array_push($builds, ['directory' => $directory, 'buildTime' =>  $buildTime]);
            print "-- Done build script in $directory. Build time: $buildTime seconds. --\n";
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

// Print all build times in a list
print "\n\nBuild Time\t\t\t\tDirectory\n";
$totalTime = 0;
foreach ($builds as $build) {
    print $build['buildTime'] . "s\t\t\t\t\t" . $build['directory'] . "\n";
    $totalTime += $build['buildTime'];
}
print "Total: $totalTime seconds\n\n";

/**
 * Better shell script execution with live output to STDOUT and status code return.
 * @param  string $command Command to execute in shell.
 * @return int             Exit code.
 */
function executeCommand($command)
{
    $fullCommand = '';
    if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
        $fullCommand = "cmd /v:on /c \"$command 2>&1 & echo Exit status : !ErrorLevel!\"";
    } else {
        $fullCommand = "$command 2>&1 ; echo Exit status : $?";
    }

    $proc = popen($fullCommand, 'r');

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
