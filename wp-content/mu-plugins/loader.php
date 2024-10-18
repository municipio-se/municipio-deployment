<?php

/**
 * Include all plugins in subdirectories from Must Use plugin folder
 */

// If this file is called directly, abort.
if (!function_exists('add_filter')) {
	header('Status: 403 Forbidden');
	header('HTTP/1.1 403 Forbidden');
	exit();
}

if (!is_blog_installed()) {
	return;
}

add_action('muplugins_loaded', function () {
	$loader = new MustUseLoader();
	$pluginFiles = $loader->getMuPluginFiles();
	$loader->includePluginFiles($pluginFiles);
});

/**
 * Class must_use_loader
 */
class MustUseLoader
{

	/**
	 * Get all plugins from MU plugin directory.
	 *
	 * @return array
	 */
	public function getMuPluginFiles(): array
	{

		$plugins = [];
		$mu_plugins_folder = explode('/', WPMU_PLUGIN_DIR);
		$wpmu_plugin_dir = '/../' . end($mu_plugins_folder);

		// get_plugins is not included by default
		if (!function_exists('get_plugins')) {
			require ABSPATH . 'wp-admin/includes/plugin.php';
		}

		$mu_plugins = get_plugins($wpmu_plugin_dir);

		foreach ($mu_plugins as $plugin_file => $not_used) {
			if ('.' !== dirname($plugin_file) && dirname($plugin_file)[0] !== '_') {
				$plugins[] = $plugin_file;
			}
		}

		return $plugins;
	}

	/**
	 * Include all plugins from subdirectories
	 * 
	 * @param array $pluginFiles
	 * 
	 * @return void
	 */
	public function includePluginFiles(array $pluginFiles): void
	{
		foreach ($pluginFiles as $pluginFile) {
			require_once WPMU_PLUGIN_DIR . '/' . $pluginFile;
			wp_register_plugin_realpath(WPMU_PLUGIN_DIR . '/' . $pluginFile);
		}
	}
}
