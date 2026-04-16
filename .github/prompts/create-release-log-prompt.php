<?php 

Class CreateReleaseLogPrompt {


    const OWNER_ORG     = ['municipio-se', 'helsingborg-stad'];
    const MAIN_BRANCH   = 'master';
    const STAGE_BRANCH  = 'stage';
    const MUNICIPIO_PACKAGE = 'helsingborg-stad/municipio';
    const MUNICIPIO_SUB_PACKAGES = [
      'helsingborg-stad/component-library',
      'helsingborg-stad/styleguide',
    ];

    protected static $composerPathTemplate = "https://raw.githubusercontent.com/municipio-se/municipio-deployment/refs/heads/%s/%s";

    public function __construct() {
      $this->assertGithubCliIsReady();
        $diff = $this->diffComposerFiles(self::STAGE_BRANCH, self::MAIN_BRANCH);
        echo "Differences in composer.json between " . self::STAGE_BRANCH . " and " . self::MAIN_BRANCH . ":\n";

        foreach($diff as $package => $versions) {
            $fromVersion = $versions['from'];
            $toVersion   = $versions['to'];

        $this->printPackageChangeLog($package, $fromVersion, $toVersion);

        // Include tracked municipio sub-packages in the same release log run.
        if ($package === self::MUNICIPIO_PACKAGE) {
          $subPackageDiff = $this->diffMunicipioSubPackages($fromVersion, $toVersion);
          foreach ($subPackageDiff as $subPackage => $subPackageVersions) {
            $this->printPackageChangeLog(
              $subPackage,
              $subPackageVersions['from'],
              $subPackageVersions['to'],
              sprintf('Sub-package of %s', self::MUNICIPIO_PACKAGE)
            );
          }
        }
        }
    }

    /**
     * Fail fast unless GitHub CLI is installed and authenticated.
     * @return void
     */
    private function assertGithubCliIsReady(): void
    {
      $ghBinary = trim((string) shell_exec('command -v gh 2>/dev/null'));
      if ($ghBinary === '') {
        throw new RuntimeException(
          'GitHub CLI (gh) is required to generate the release log. Install it and retry.'
        );
      }

      $authStatusCommand = 'gh auth status --hostname github.com >/dev/null 2>&1';
      $authStatusExitCode = 1;
      exec($authStatusCommand, $output, $authStatusExitCode);

      if ($authStatusExitCode !== 0) {
        throw new RuntimeException(
          'GitHub CLI is not authenticated for github.com. Run "gh auth login" and retry.'
        );
      }
    }

    /**
     * Print changelog output for one package compare range.
     * @param string $package
     * @param string|null $fromVersion
     * @param string|null $toVersion
     * @param string|null $contextLabel
     * @return void
     */
    private function printPackageChangeLog(string $package, ?string $fromVersion, ?string $toVersion, ?string $contextLabel = null): void
    {
      if (empty($fromVersion) || empty($toVersion)) {
        return;
      }

      $summaryCommand     = $this->githubSummaryCommand($fromVersion, $toVersion, $package);
      $summaryFormatted   = $this->formatSummary(shell_exec($summaryCommand));

      echo "----------------------------------------------------------------------\n";
      echo "The following package has been updated:\n";
      echo "Package id:   {$package}\n";
      echo "From version: {$fromVersion}\n";
      echo "To version:   {$toVersion}\n";
      if (!empty($contextLabel)) {
        echo "Context:      {$contextLabel}\n";
      }
      echo "Diff link:    https://github.com/{$package}/compare/{$fromVersion}...{$toVersion}\n\n";

      echo "----------------------------------------------------------------------\n";
      echo "Summary of commit messages and files changed:\n";
      echo "----------------------------------------------------------------------\n";

      echo $summaryFormatted ."\n";

      // If --small flag is set, skip the detailed diff output.
      if ($this->isSmallMode()) {
        echo "(Detailed diff skipped due to --small flag)\n";
        return;
      }

      $detailCommand      = $this->githubDiffCommand($fromVersion, $toVersion, $package);
      $detailFormatted    = $this->formatDiff(shell_exec($detailCommand));

      echo "----------------------------------------------------------------------\n";
      echo "Detailed diff of files changed:\n";
      echo "----------------------------------------------------------------------\n";

      echo $detailFormatted ."\n";

      echo "----------------------------------------------------------------------\n";
      echo "\n\n\n";
    }

    /**
     * Determine if the prompt runs in compact mode.
     * @return bool
     */
    private function isSmallMode(): bool
    {
      return in_array('--small', $_SERVER['argv'], true);
    }

    /**
     * Diff tracked sub-packages from municipio's own composer.json between two refs.
     * @param string $fromVersion
     * @param string $toVersion
     * @return array
     */
    private function diffMunicipioSubPackages(string $fromVersion, string $toVersion): array
    {
      $fromRequire = $this->getPackageRequireAtRef(self::MUNICIPIO_PACKAGE, $fromVersion);
      $toRequire = $this->getPackageRequireAtRef(self::MUNICIPIO_PACKAGE, $toVersion);

      $diff = [];
      foreach (self::MUNICIPIO_SUB_PACKAGES as $subPackage) {
        if (empty($fromRequire) || empty($toRequire)) {
          continue;
        }

        $fromSubVersion = isset($fromRequire[$subPackage])
          ? $this->removeLooseVersionPrefix($fromRequire[$subPackage])
          : null;
        $toSubVersion = isset($toRequire[$subPackage])
          ? $this->removeLooseVersionPrefix($toRequire[$subPackage])
          : null;

        if (empty($fromSubVersion) || empty($toSubVersion) || $fromSubVersion === $toSubVersion) {
          continue;
        }

        $diff[$subPackage] = [
          'from' => $fromSubVersion,
          'to' => $toSubVersion,
        ];
      }

      // Styleguide is not always explicitly pinned in municipio composer.json.
      if (!isset($diff['helsingborg-stad/styleguide'])) {
        $fromDate = $this->getReleasePublishedAt(self::MUNICIPIO_PACKAGE, $fromVersion);
        $toDate = $this->getReleasePublishedAt(self::MUNICIPIO_PACKAGE, $toVersion);

        if (!empty($fromDate) && !empty($toDate)) {
          $fromStyleguideTag = $this->getNearestReleaseTagAtOrBeforeDate('helsingborg-stad/styleguide', $fromDate);
          $toStyleguideTag = $this->getNearestReleaseTagAtOrBeforeDate('helsingborg-stad/styleguide', $toDate);

          if (!empty($fromStyleguideTag) && !empty($toStyleguideTag) && $fromStyleguideTag !== $toStyleguideTag) {
            $diff['helsingborg-stad/styleguide'] = [
              'from' => $fromStyleguideTag,
              'to' => $toStyleguideTag,
            ];
          }
        }
      }

      return $diff;
    }

    /**
     * Get release publish date for a package tag.
     * @param string $package
     * @param string $tag
     * @return string|null
     */
    private function getReleasePublishedAt(string $package, string $tag): ?string
    {
      $endpoint = sprintf(
        'repos/%s/releases/tags/%s',
        $package,
        rawurlencode($tag)
      );

      $command = sprintf(
        'gh api %s 2>/dev/null',
        escapeshellarg($endpoint)
      );

      $response = shell_exec($command);
      if (empty($response)) {
        return null;
      }

      $decoded = json_decode($response, true);
      if (!is_array($decoded) || empty($decoded['published_at'])) {
        return null;
      }

      return $decoded['published_at'];
    }

    /**
     * Find the closest release tag published at or before a given timestamp.
     * @param string $package
     * @param string $timestamp
     * @return string|null
     */
    private function getNearestReleaseTagAtOrBeforeDate(string $package, string $timestamp): ?string
    {
      $endpoint = sprintf(
        'repos/%s/releases?per_page=100',
        $package
      );

      $command = sprintf(
        'gh api %s 2>/dev/null',
        escapeshellarg($endpoint)
      );

      $response = shell_exec($command);
      if (empty($response)) {
        return null;
      }

      $releases = json_decode($response, true);
      if (!is_array($releases)) {
        return null;
      }

      $targetTimestamp = strtotime($timestamp);
      if ($targetTimestamp === false) {
        return null;
      }

      foreach ($releases as $release) {
        if (!is_array($release) || empty($release['tag_name']) || empty($release['published_at'])) {
          continue;
        }

        $releaseTimestamp = strtotime($release['published_at']);
        if ($releaseTimestamp === false) {
          continue;
        }

        if ($releaseTimestamp <= $targetTimestamp) {
          return $release['tag_name'];
        }
      }

      return null;
    }

    /**
     * Get decoded composer require section for a package at a specific ref.
     * @param string $package
     * @param string $ref
     * @return array
     */
    private function getPackageRequireAtRef(string $package, string $ref): array
    {
      $endpoint = sprintf(
        'repos/%s/contents/composer.json?ref=%s',
        $package,
        rawurlencode($ref)
      );

      $command = sprintf(
        'gh api %s 2>/dev/null',
        escapeshellarg($endpoint)
      );

      $response = shell_exec($command);
      if (empty($response)) {
        return [];
      }

      $decoded = json_decode($response, true);
      if (!is_array($decoded) || empty($decoded['content'])) {
        return [];
      }

      $composerRaw = base64_decode(str_replace(["\r", "\n"], '', $decoded['content']), true);
      if ($composerRaw === false) {
        return [];
      }

      $composer = json_decode($composerRaw, true);
      if (!is_array($composer) || !isset($composer['require']) || !is_array($composer['require'])) {
        return [];
      }

      return $composer['require'];
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

      if ($this->isGithubApiErrorResponse($diff)) {
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

      if ($this->isGithubApiErrorResponse($summary)) {
        return "(No summary data available)";
      }

        $output = "Ahead by:      " . ($decodedSummary['ahead_by'] ?? 'N/A') . "\n";
        $output .= "Behind by:     " . ($decodedSummary['behind_by'] ?? 'N/A') . "\n";

        $output .= "Commits:";
        if (!empty($decodedSummary['commits']) && is_array($decodedSummary['commits'])) {
            $output .= "\n";
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
            $output .= "       [No commit messages]\n";
        }

        $output .= "Changed files:";
        if (!empty($decodedSummary['files']) && is_array($decodedSummary['files'])) {
            $output .= "\n";
            foreach ($decodedSummary['files'] as $file) {
                $output .= "  - " . $file . "\n";
            }
        } else {
            $output .= " [No files changed]\n";
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
        "gh api repos/%s/compare/%s...%s --jq '{ahead_by, behind_by, commits: [(.commits // [])[] | select(.commit.author.name != \"github-actions[bot]\") | .commit.message], files: [(.files // [])[] | .filename]}' 2>/dev/null",
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
        "gh api repos/%s/compare/%s...%s -H 'Accept: application/vnd.github.v3.diff' 2>/dev/null",
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
     * Detect if the GitHub CLI returned an API error payload instead of compare data.
     * @param string $response
     * @return bool
     */
    private function isGithubApiErrorResponse(string $response): bool
    {
      $decodedResponse = json_decode($response, true);

      return is_array($decodedResponse)
        && isset($decodedResponse['message'])
        && isset($decodedResponse['status']);
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