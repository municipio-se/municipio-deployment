---
mode: 'agent'
model: 'GPT-4o'
tools: ['edit', 'runCommands', 'changes', 'fetch', 'githubRepo']
description: 'Prompt template for generating release logs based on composer.json changes.'
---

# Release Log Prompt Template

Follow these steps exactly to generate the release log in a format suitable for inclusion in a `CHANGELOG.md` file:

1. **Compare** the current `composer.json` file in this branch with the `composer.json` file from the `master` branch on GitHub by running `git diff origin/master:composer.json composer.json`.
2. **Identify** all packages whose version or configuration has changed.
3. **For each changed package:**
   - Create a section with the package name and version change in the format:  
     `## [Package Name][version-from...version-to]`
   - Add a bullet-point list describing the specific changes (e.g., version updates, added/removed packages, configuration changes).
   - **Do not** include a bullet point that describes the actual version change.
   - **Include a URL to the change comparison for the version bump.**  
     Format:  
     `- [Compare changes](<url>)`
   - Visit the package's repository on GitHub or Packagist to gather more details about the changes.
   - **If the package belongs to the `helsingborg-stad` vendor,** provide detailed descriptions of the changes.
   - **If the package does not belong to the `helsingborg-stad` vendor,** keep descriptions brief.
4. **Do not include** any packages that have not changed.
5. **Format** the release log exactly as follows, so it can be copy-pasted into a `CHANGELOG.md` file:

```
## [Package Name][version-from...version-to]
- [Description of change]
- [Description of change]

## [Next Package Name][version-from...version-to]
- [Description of change]
```

**Additional rules:**
- Only include packages that have changed.
- Do not include any other information or commentary.
- Make the log clear and concise.
- Always use the specified section and bullet formatting.
- Do not deviate from these instructions.
- The output must be ready to be copy-pasted into a `CHANGELOG.md` file.

**Output the result directly. Do not write to any file.**

**Example output:**
```
## helsingborg-stad/example-package[1.2.3...1.3.0]
- [Compare changes](https://github.com/helsingborg-stad/example-package/compare/1.2.3...1.3.0)
- Added support for new API endpoints.
- Improved error handling for authentication failures.

## vendor/another-package[2.0.0...2.1.0]
- [Compare changes](https://github.com/vendor/another-package/compare/2.0.0...2.1.0)
- Minor bug fixes.
```
