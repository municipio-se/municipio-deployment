<?php 

Class CreateReleaseLogPrompt {


    const OWNER_ORG     = ['municipio-se', 'helsingborg-stad'];
    const MAIN_BRANCH   = 'master';
    const STAGE_BRANCH  = 'stage';

    protected static $composerPathTemplate = "https://raw.githubusercontent.com/municipio-se/municipio-deployment/refs/heads/%s/%s";

    public function __construct() {
        $diff = $this->diffComposerFiles(self::STAGE_BRANCH, self::MAIN_BRANCH);
        echo "Differences in composer.json between " . self::STAGE_BRANCH . " and " . self::MAIN_BRANCH . ":\n";

        foreach($diff as $package => $versions) {
            $fromVersion = $versions['from'];
            $toVersion   = $versions['to'];

            $summaryCommand     = $this->githubSummaryCommand($fromVersion, $toVersion, $package);
            $summaryFormatted   = $this->formatSummary(shell_exec($summaryCommand));

            $detailCommand      = $this->githubDiffCommand($fromVersion, $toVersion, $package);
            $detailFormatted    = $this->formatDiff(shell_exec($detailCommand));

            echo "----------------------------------------------------------------------\n";
            echo "The following package has been updated:\n";
            echo "Package id:   {$package}\n";
            echo "From version: {$fromVersion}\n";
            echo "To version:   {$toVersion}\n\n";

            echo "----------------------------------------------------------------------\n";
            echo "Summary of commit messages and files changed:\n";
            echo "----------------------------------------------------------------------\n";

            echo $summaryFormatted ."\n";

            echo "----------------------------------------------------------------------\n";
            echo "Detailed diff of files changed:\n";
            echo "----------------------------------------------------------------------\n";

            echo $detailFormatted ."\n";

            echo "----------------------------------------------------------------------\n";
            echo "\n\n\n";
        }
    }

    /**
     * Format raw diff into readable text, excluding certain paths
     * @param string $diff
     * @return string
     **/
    public function formatDiff(string $diff): string
    {
      if (empty($diff)) {
        return "(No diff data available)";
      }

      // Paths to exclude
      $excludePatterns = [
        '#^assets/dist/#',
        '#^dist/#',
        '#^vendor/#',
        '#^node_modules/#',
        '#^composer\.lock$#',
        '#^composer\.json$#',
        '#^\.gitignore$#',
      ];

      $lines = explode("\n", $diff);
      $output = '';
      $skipBlock = false;

      foreach ($lines as $i => $line) {
        // Detect "diff --git" block start
        if (preg_match('#^diff --git a/(.*?) b/(.*?)$#', $line, $m)) {
          $filePath = $m[1];

          // Determine if this file should be excluded
          $skipBlock = false;
          foreach ($excludePatterns as $pattern) {
            if (preg_match($pattern, $filePath)) {
              $skipBlock = true;
              break;
            }
          }

          // Check if the file is deleted in the next few lines
          $deleted = false;
          for ($j = $i + 1; $j <= $i + 3 && $j < count($lines); $j++) {
            if (preg_match('#^deleted file mode#', $lines[$j])) {
              $deleted = true;
              break;
            }
          }
          if ($deleted) {
            $skipBlock = true;
            continue;
          }

          // Skip the header line itself if excluded
          if ($skipBlock) {
            continue;
          }
        }

        // If currently skipping this file block → continue skipping until next block
        if ($skipBlock) {
          continue;
        }

        // --- Original formatting logic ---
        if (trim($line) === '') {
          continue;
        }

        if (str_starts_with($line, '+')) {
          $output .= "  + " . substr($line, 1) . "\n";
        } elseif (str_starts_with($line, '-')) {
          $output .= "  - " . substr($line, 1) . "\n";
        } else {
          $output .= "    " . $line . "\n";
        }
      }

      return $output ?: "(All changes excluded)";
    }

    /**
     * Format summary JSON into readable text
     * @param string $summary
     * @return string
     **/
    public function formatSummary($summary) {
        $decodedSummary  = json_decode($summary, true);
        if (!$decodedSummary || !is_array($decodedSummary)) {
            return "(No summary data available)";
        }

        $output = "Ahead by:   " . ($decodedSummary['ahead_by'] ?? 'N/A') . "\n";
        $output .= "Behind by:  " . ($decodedSummary['behind_by'] ?? 'N/A') . "\n";

        $output .= "Commits:\n";
        if (!empty($decodedSummary['commits']) && is_array($decodedSummary['commits'])) {
            foreach ($decodedSummary['commits'] as $commit) {
                $lines = explode("\n", $commit);
                foreach ($lines as $i => $line) {
                    if (trim($line) === '') {
                        continue;
                    }
                    if ($i === 0) {
                        $output .= "  - " . $line . "\n";
                    } else {
                        $output .= "    * " . $line . "\n";
                    }
                }
            }
        } else {
            $output .= "  (No commit messages)\n";
        }

        $output .= "Changed files:\n";
        if (!empty($decodedSummary['files']) && is_array($decodedSummary['files'])) {
            foreach ($decodedSummary['files'] as $file) {
                $output .= "  - " . $file . "\n";
            }
        } else {
            $output .= "  (No files changed)\n";
        }

        return $output;
    }

    /**
     * Generate GitHub CLI command to get summary (commits and files) between two versions of a package
     * @param string $fromVersion
     * @param string $toVersion
     * @param string $package
     * @return string
     **/
    public function githubSummaryCommand($fromVersion, $toVersion, $package) {
        return sprintf(
            "gh api repos/%s/compare/%s...%s --jq '{ahead_by, behind_by, commits: [(.commits // [])[] | select(.commit.author.name != \"github-actions[bot]\") | .commit.message], files: [(.files // [])[] | .filename]}'",
            $package,
            $fromVersion,
            $toVersion
        );
    }

    /**
     * Generate GitHub CLI command to get raw diff between two versions of a package
     * @param string $fromVersion
     * @param string $toVersion
     * @param string $package
     * @return string
     **/
    public function githubDiffCommand($fromVersion, $toVersion, $package) {
        return sprintf(
            "gh api repos/%s/compare/%s...%s -H 'Accept: application/vnd.github.v3.diff'",
            $package,
            $fromVersion,
            $toVersion
        );
    }

    /**
     * Get composer.json file URL for a specific branch
     * @param string $branch
     * @return string
     **/
    public static function getComposerFileUrl($branch): string {
      return sprintf(self::$composerPathTemplate, $branch);
    }

    /**
     * Get file content from a specific branch
     * @param string $path
     * @param string $branch
     * @return string
     **/
    public function getFileContent($path, $branch): string {
        $url = sprintf(
            self::$composerPathTemplate,
            $branch,
            ltrim($path, '/')
        );
        return file_get_contents($url);
    }

    /**
     * Diff composer.json files between two branches
     * @param string $fromBranch
     * @param string $toBranch
     * @return array
     **/
    public function diffComposerFiles($fromBranch, $toBranch): array {

        //Get file contents
        $fromContent  = $this->getFileContent('composer.json', $fromBranch);
        $toContent    = $this->getFileContent('composer.json', $toBranch);

        //Decode JSON and get "require" section
        $fromContent  = (json_decode($fromContent, true))['require'];
        $toContent    = (json_decode($toContent, true))['require'];

        //Construct diff array 
        $diff = [];
        foreach ($toContent as $package => $version) {

            $toVersion = isset($fromContent[$package]) ? $this->removeLooseVersionPrefix($fromContent[$package]) : null;
            $fromVersion   = $this->removeLooseVersionPrefix($version);

            if (isset($fromVersion) && $fromVersion !== $toVersion) {

                $isOwner = false;
                foreach (self::OWNER_ORG as $owner) {
                  if (str_starts_with($package, $owner . '/')) {
                    $isOwner = true;
                    break;
                  }
                }
                if (!$isOwner) {
                  continue;
                }

                $diff[$package] = [
                    'to'   => $toVersion,
                    'from' => $fromVersion,
                ];
            }
        }
        return $diff;
    }

    /**
     * Remove loose version prefixes like ^ or ~ from version strings
     * @param string $version
     * @return string
     **/
    private function removeLooseVersionPrefix($version) {
        return ltrim($version, "^~");
    }

    /**
     * Format shell command for display
     * @param string $command
     * @return string
     **/
    private function formatShellCommandForDisplay($command) {
        return preg_replace('/\s+/', ' ', trim($command));
    }

}

new CreateReleaseLogPrompt();