---
mode: 'agent'
model: 'GPT-4o'
tools: ['edit', 'search', 'runCommands', 'changes', 'fetch', 'githubRepo']
description: 'Prompt template for generating release logs based on composer.json changes.'
---
# Release Log Generation Prompt

Generate a release log suitable for direct inclusion in a `CHANGELOG.md` file by following these steps. Be elaborate in the process of what wou are doint to retrive data and how you are remodeling it into a changelog:

1. **Compare composer.json files:**  
  Run `git diff origin/master:composer.json composer.json` to identify all packages with changed versions or configurations.

2. **Gather change details:**
  For each package identified in step 1, determine the changes made by comparing the previous version number with the current version number. Use the GitHub CLI to fetch commit messages, changed files and the complete diff between the two versions:
  - gh api repos/<owner>/<repo>/compare/<to_version>...<from_version> --jq '{ahead_by, behind_by, commits: [.commits[].commit.message], files: [.files[].filename]}'
  - gh api repos/<owner>/<repo>/compare/<from_version>...<to_version> -H "Accept: application/vnd.github.v3.diff"

3. **Format** the release log exactly as follows, so it can be copy-pasted into a `CHANGELOG.md` file:
```
## [Package Name][version-from...version-to]
- [Description of change]
- [Description of change]

## [Next Package Name][version-from...version-to]
- [Description of change]
```

**Additional rules:**
- Include all new features, enhancements, bug fixes, and any changes that impact functionality.
- Include only packages that have changed.
- Exclude all unrelated info or commentary.
- Keep the log concise but clear and descriptive.
- Follow the required section and bullet formatting exactly.
- Make it ready to paste into CHANGELOG.md.
- Avoid vague summaries like “Multiple updates and fixes.”
- Use simple, non-technical language when possible.
- If needed, include brief technical details—no speculation or assumptions.
- Include all changes that impact usage or development of the package/app.
- Do not mention commits specifically bumping or adding a package version unless they include other changes.
- Names of the packages should be formatted to a user friendly style, e.g., `Component Library` instead of `helsingborg-stad/component-library`.
- Exclude any rows that starts with "Bump" in the output.

**Output the result directly. Do not write to any file.**

**Example output:**
```
## Example Package [1.2.3...1.3.0](https://github.com/helsingborg-stad/example-package/compare/1.2.3...1.3.0)
- Image Focus: Automatic sets the focus point to detected faces in a image (requires deepface), or fallbacks to automatic focus detection by “most busy area”.
- Schema Import: A fix has been applied to avoid the risk och importing a empty set of data.
- Resource from API: Removes the feature that could fetch data from a remote api in realtime. This has been completly replaces by SchemaData importer.
- Gutenberg Rendering: Optimize number of call to do_blocks method. This patch reduces number of calls by 50%.
- Singular Controller: Once is enough to prepare a post.
- Gutenberg Hero: We are now reordering the flow of a page, when a hero is used first in a gutenberg page. The helper nav will now be placed after this block visually.

## Another Package [2.0.0...2.1.0](https://github.com/vendor/another-package/compare/2.0.0...2.1.0)
- Manage Index: Delete method now, handles index errors correctly and avoids fatal errors.
- Index Indentifier: Updates method to enable better parsing on paths to collect correct path details.
- Directory Resolver: Deactivated on admin pages, due to recursive directory creation failing when uploading files to a folder that is not created yet.
```