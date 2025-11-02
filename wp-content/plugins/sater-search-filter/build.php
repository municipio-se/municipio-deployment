<?php

// Autoloader path
$autoloadPath = __DIR__ . '/vendor/autoload.php';

// Autoloader
if (file_exists($autoloadPath)) {
    require_once $autoloadPath;
}

// Build commands
$buildCommands = [];

// Run composer install if composer.json exists
if (file_exists('composer.json')) {
    $buildCommands[] = 'composer dump-autoload';
}

// Run npm if package.json is found
if(file_exists('package.json') && file_exists('package-lock.json')) {
    // Always use npm ci when package-lock.json exists, ignore --install-npm flag
    $buildCommands[] = 'npm ci --no-progress --no-audit';
} elseif(file_exists('package.json') && !file_exists('package-lock.json')) {
    if(is_array($argv) && !in_array('--install-npm', $argv)) {
        $buildCommands[] = 'npm install --no-progress --no-audit';
    } else {
        $npmPackage = json_decode(file_get_contents('package.json'));
        $buildCommands[] = "npm install $npmPackage->name";
        $buildCommands[] = "rm -rf ./dist";
        $buildCommands[] = "mv node_modules/$npmPackage->name/dist ./";
    }
}

// Run build if package-lock.json is found
if(file_exists('package-lock.json') && !file_exists('gulp.js')) {
    $buildCommands[] = 'npx --yes browserslist@latest --update-db';
    $buildCommands[] = 'npm run build';
}

// Execute build commands
if (!empty($buildCommands)) {
    echo "🏗️ Building " . basename(__DIR__) . "...\n";
    echo "🔧 Running commands:\n";
    foreach ($buildCommands as $command) {
        echo "   $ " . $command . "\n";
        passthru($command);
    }
    echo "\n✅ Build completed.\n";
} else {
    echo "✅ No build commands to run.\n";
}

