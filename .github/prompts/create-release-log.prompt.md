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
- Make the log clear and concise but still elaborate on the changes.
- Always use the specified section and bullet formatting.
- Do not deviate from these instructions.
- The output must be ready to be copy-pasted into a `CHANGELOG.md` file.
- Do not add generic statements like "Multiple updates and fixes across 92 files.". 
- Be non-technical where possible, explaining changes in layman's terms.
- Focus on the impact of changes rather than technical details. If a change cannot be explained in layman's terms, include it with technical details but keep it concise.
- Do not speculate about the reasons or motivations behind changes.
- Do not speculate about the impact of changes beyond what is explicitly stated in the change logs or commit messages.
- Be shure to include all changes that has a effect on the user or developer using the package / application.

**Output the result directly. Do not write to any file.**

**Example output:**
```
## helsingborg-stad/example-package[1.2.3...1.3.0]
- [Compare changes](https://github.com/helsingborg-stad/example-package/compare/1.2.3...1.3.0)
- Image Focus: Automatic sets the focus point to detected faces in a image (requires deepface), or fallbacks to automatic focus detection by “most busy area”.
- Schema Import: A fix has been applied to avoid the risk och importing a empty set of data.
- Resource from API: Removes the feature that could fetch data from a remote api in realtime. This has been completly replaces by SchemaData importer.
- Gutenberg Rendering: Optimize number of call to do_blocks method. This patch reduces number of calls by 50%.
- Singular Controller: Once is enough to prepare a post.
- Gutenberg Hero: We are now reordering the flow of a page, when a hero is used first in a gutenberg page. The helper nav will now be placed after this block visually.

## vendor/another-package[2.0.0...2.1.0]
- [Compare changes](https://github.com/vendor/another-package/compare/2.0.0...2.1.0)
- Minor bug fixes.
```
