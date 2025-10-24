<?php

/**
 * GithubDiffDataProvider
 * 
 * Provides an interface to compare two versions (commits, branches, or tags) of a GitHub repository
 * using the GitHub REST API's "Compare two commits" endpoint.
 */
class GithubDiffDataProvider
{
    private string $owner;
    private string $repo;
    private ?string $token;

    public function __construct(string $owner, string $repo, ?string $token = null)
    {
        $this->owner = $owner;
        $this->repo = $repo;
        $this->token = $token;
    }

    /**
     * Compare two versions of the repository.
     *
     * @param string $base Base branch, tag, or commit SHA.
     * @param string $head Head branch, tag, or commit SHA.
     * @return array|null Decoded JSON response or null on failure.
     */
    public function compareVersions(string $base, string $head): ?array
    {
        $url = "https://api.github.com/repos/{$this->owner}/{$this->repo}/compare/{$base}...{$head}";
        $perPage = 50;
        $page = 1;
        $allFiles = [];
        $allCommits = [];
        $firstResponse = null;

        do {
            $pagedUrl = $url . "?per_page={$perPage}&page={$page}";
            $ch = curl_init();

            curl_setopt($ch, CURLOPT_URL, $pagedUrl);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_USERAGENT, 'PHP-GitHub-Comparer');

            $headers = [
                'Accept: application/vnd.github+json',
                'X-GitHub-Api-Version: 2022-11-28',
            ];
            if ($this->token) {
                $headers[] = 'Authorization: Bearer ' . $this->token;
            }
            curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

            $response = curl_exec($ch);

            if (curl_errno($ch)) {
                error_log('cURL Error: ' . curl_error($ch));
                curl_close($ch);
                return null;
            }

            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);

            if ($httpCode !== 200) {
                error_log("GitHub API Error - HTTP Code: {$httpCode}. Response: " . $response);
                return null;
            }

            $data = json_decode($response, true);

            if (json_last_error() !== JSON_ERROR_NONE) {
                error_log('JSON Decoding Error: ' . json_last_error_msg());
                return null;
            }

            if ($firstResponse === null) {
                $firstResponse = $data;
            }

            if (!empty($data['files'])) {
                $allFiles = array_merge($allFiles, $data['files']);
            }
            if (!empty($data['commits'])) {
                $allCommits = array_merge($allCommits, $data['commits']);
            }

            $filesCount = isset($data['files']) ? count($data['files']) : 0;
            $commitsCount = isset($data['commits']) ? count($data['commits']) : 0;
            $hasMore = ($filesCount === $perPage) || ($commitsCount === $perPage);
            $page++;
        } while ($hasMore);

        if ($firstResponse !== null) {
            $firstResponse['files'] = $allFiles;
            $firstResponse['commits'] = $allCommits;
        }

        return $firstResponse;
    }

    /**
     * Format the comparison data for output.
     *
     * @param array $comparisonData Raw comparison data from GitHub API.
     * @param string $baseVersion
     * @param string $headVersion
     * @return array Formatted output.
     */
    public function formatComparisonOutput(array $comparisonData, string $baseVersion, string $headVersion): array
    {
        $output = [
            "comparisonSummary" => [
                "baseVersion" => $baseVersion,
                "headVersion" => $headVersion,
                "status" => $comparisonData['status'] ?? 'N/A',
                "totalCommits" => $comparisonData['total_commits'] ?? 0,
                "commitsAhead" => $comparisonData['ahead_by'] ?? 0,
                "commitsBehind" => $comparisonData['behind_by'] ?? 0,
            ],
            "changedFiles" => []
        ];

        if (!empty($comparisonData['files'])) {
            foreach ($comparisonData['files'] as $file) {
                $fileInfo = [
                    "filename" => $file['filename'],
                    "status" => $file['status'],
                    "additions" => $file['additions'],
                    "deletions" => $file['deletions'],
                    "diff" => $file['patch'] ?? null
                ];
                $output["changedFiles"][] = $fileInfo;
            }
        }

        return $output;
    }
}

// --- CLI Interface ---

$options = getopt('', [
    'owner:',
    'repo:',
    'base:',
    'head:',
    'token::'
]);

if (
    empty($options['owner']) ||
    empty($options['repo']) ||
    empty($options['base']) ||
    empty($options['head'])
) {
    fwrite(STDERR, "Usage: php getDiffFromGithubApi.php --owner=<owner> --repo=<repo> --base=<base_version> --head=<head_version> [--token=<personal_access_token>]\n");
    exit(1);
}

$owner = $options['owner'];
$repo = $options['repo'];
$baseVersion = $options['base'];
$headVersion = $options['head'];
$personalAccessToken = $options['token'] ?? null;

$comparer = new GithubDiffDataProvider($owner, $repo, $personalAccessToken);
$comparisonData = $comparer->compareVersions($baseVersion, $headVersion);

if ($comparisonData) {
    $output = $comparer->formatComparisonOutput($comparisonData, $baseVersion, $headVersion);

    // Print summary
    echo "=== Comparison Summary ===\n";
    printf("Base Version   : %s\n", $output['comparisonSummary']['baseVersion']);
    printf("Head Version   : %s\n", $output['comparisonSummary']['headVersion']);
    printf("Status         : %s\n", $output['comparisonSummary']['status']);
    printf("Total Commits  : %d\n", $output['comparisonSummary']['totalCommits']);
    printf("Commits Ahead  : %d\n", $output['comparisonSummary']['commitsAhead']);
    printf("Commits Behind : %d\n", $output['comparisonSummary']['commitsBehind']);
    echo "\n";

    // Print changed files as a table
    echo "=== Changed Files ===\n";
    if (!empty($output['changedFiles'])) {
        printf("%-50s %-10s %-10s %-10s\n", "Filename", "Status", "Additions", "Deletions");
        echo str_repeat("-", 85) . "\n";
        foreach ($output['changedFiles'] as $file) {
            printf(
                "%-50s %-10s %-10d %-10d\n",
                $file['filename'],
                ucfirst($file['status']),
                $file['additions'],
                $file['deletions']
            );
            if (!empty($file['diff'])) {
                echo "  Patch:\n";
                foreach (explode("\n", $file['diff']) as $line) {
                    echo "    " . $line . "\n";
                }
            }
            echo "\n";
        }
    } else {
        echo "No files changed.\n";
    }
} else {
    $errorOutput = [
        "error" => "Failed to retrieve comparison data. Check error logs for details."
    ];
    echo json_encode($errorOutput, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES) . "\n";
}