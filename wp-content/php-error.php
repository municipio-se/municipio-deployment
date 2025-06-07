<?php
if (!defined('ABSPATH')) {
    exit; // Prevent direct access.
}

// Capture the error details.
$errorMessage  = isset($error['message']) ? $error['message'] : __('Unknown error', 'default');
$errorFile     = isset($error['file']) ? $error['file'] : __('Unknown file', 'default');
$errorLine     = isset($error['line']) ? $error['line'] : __('Unknown line', 'default');

// Check if we're in debug mode.
$debugMode = defined('WP_DEBUG') && WP_DEBUG === true;

// Get current locale
$locale = get_locale();

// Define the error messages based on locale
switch ($locale) {
    case 'sv_SE': // Swedish
        $errorTitle = __('Sidfel', 'default');
        $errorMessage = __('Den här webbplatsen har tekniska problem och kunde inte laddas för tillfället. Försök igen senare.', 'default');
        break;

    default: // English or fallback
        $errorTitle = __('Page Error', 'default');
        $errorMessage = __('This website is experiencing technical difficulties and could not be loaded at the moment. Please, try again later.', 'default');
        break;
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php _e('Critical Error', 'default'); ?></title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f8f9fa;
            color: #212529;
            padding: 2rem;
            margin: 0;
            height: 100vh;
            box-sizing: border-box;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
        }
        .error-container {
            max-width: 600px;
            width: 100%;
            margin: auto;
            padding: 1.5rem;
            background: #fff;
            border: 1px solid #dee2e6;
            border-radius: 0.25rem;
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.1);
        }

        h1 {
            margin: 0 0 1rem 0;
        }
 
        pre {
            background: #f8f9fa;
            padding: 1rem;
            border: 1px solid #dee2e6;
            border-radius: 0.25rem;
            overflow-x: auto;
            border-radius: 0 0 0.25rem 0.25rem;
            margin: 1.5rem -1.5rem -1.5rem -1.5rem;
            border-right: none;
            border-left: none;
            border-bottom: none;
            margin: 0;
            padding: 8px;
            background-color: #f1f1f1;
            border: 1px solid #ccc;
            border-radius: 4px;
            overflow-x: auto;
            font-family: monospace;
        }

        .debug-table {
          border: 1px solid #dee2e6;
          width: 100%;
          border-collapse: collapse;
          font-family: Arial, sans-serif;
          margin-top: 1rem;
          background-color: #fff;
          border: none;
          overflow: auto; /* Add this line */
          display: block; /* This is important to enable scrolling within the table */
          max-height: 300px; /* Optional: set a max height to control the scrolling area */
        }

        .debug-table th, .debug-table td {
            padding: 8px;
            border: 1px solid #dee2e6;
            text-align: left;
        }

        .debug-table th {
            background-color: #f8f9fa;
            font-weight: bold;
        }

        .debug-table tr:nth-child(even) {
            background-color: #f8f9fa;
        }
    </style>
</head>
<body>
  <div class="error-container">
    <h1><?php echo $errorTitle; ?></h1>
    <p><?php echo $errorMessage; ?></p>

    <?php if ($debugMode): ?>
      <div class="debug-info">
          <table class="debug-table">
              <thead>
                  <tr>
                      <th><?php _e('Property', 'default'); ?></th>
                      <th><?php _e('Value', 'default'); ?></th>
                  </tr>
              </thead>
              <tbody>
                  <tr>
                      <td><?php _e('Message', 'default'); ?></td>
                      <td><?= htmlspecialchars($errorMessage, ENT_QUOTES, 'UTF-8'); ?></td>
                  </tr>
                  <tr>
                      <td><?php _e('File', 'default'); ?></td>
                      <td><?= htmlspecialchars($errorFile, ENT_QUOTES, 'UTF-8'); ?></td>
                  </tr>
                  <tr>
                      <td><?php _e('Line', 'default'); ?></td>
                      <td><?= htmlspecialchars($errorLine, ENT_QUOTES, 'UTF-8'); ?></td>
                  </tr>
                  <tr>
                      <td colspan="2">
                          <pre><?= debug_print_backtrace(); ?></pre>
                      </td>
                  </tr>
              </tbody>
          </table>
      </div>
    <?php endif; ?>
  </div>
</body>
</html>