---
mode: 'agent'
model: 'GPT-4.1'
tools: ['edit', 'search', 'runCommands', 'changes', 'fetch', 'githubRepo']
description: 'Prompt template for generating release logs based on composer.json changes.'
---
# Release Log Generation Prompt

Generate a **concise, structured changelog** summarizing all relevant updates between two versions. The changelog should be ready to paste directly into `CHANGELOG.md`.

### **Data Gathering**
1. Compare the current and previous `composer.json` files to identify packages with changed versions or configurations.  
   Example:  
   ```
   git diff origin/master:composer.json composer.json
   ```

2. For each changed package, gather the version differences and detailed changes using the GitHub CLI. EBoth commands below MUST be used to gather complete information:
   ```
    gh api repos/<owner>/<repo>/compare/<from_version>...<to_version> --jq '{ahead_by, behind_by, commits: [.commits[] | select(.commit.author.name != "github-actions[bot]") | .commit.message], files: [.files[].filename]}'
   ```
   ```
    gh api repos/<owner>/<repo>/compare/<from_version>...<to_version> -H "Accept: application/vnd.github.v3.diff"
   ```

### **Changelog Generation**
Output a clear, human-readable changelog with the following structure and formatting:

```
## [Package Name] [version-from...version-to]
- [Description of change]
- [Description of change]

## [Next Package Name] [version-from...version-to]
- [Description of change]
```

Do not create any files; simply output the changelog content in the chat.

### **What to Include**
- All **new features**, **enhancements**, **bug fixes**, and **functional changes**.
- Only packages that have changed.
- Information that impacts how users or developers use the package or app.
- Clear, user-friendly package names (e.g., `Component Library` instead of `helsingborg-stad/component-library`).
- Brief technical details where necessary to explain impact.
- **Exclude generic entries such as "Updated package file versions to align with the new release" or similar statements that provide no functional or behavioral insight.**
- **Avoid vague language for example "Miscellaneous improvements" or "Various bug fixes".**

### **Tone and Style**
- Use **simple, non-technical language** when possible.
- Be **clear, direct, and descriptive**.
- Write in a **concise, user-facing** tone.
- Ensure every line communicates a meaningful change.

### **Formatting**
- Follow the section and bullet structure exactly.
- Output should be in Markdown and HTML format both in a escaped manner, so i can copy it easily.

### **Example**
```
Municipio Theme [5.177.1...5.177.2](https://github.com/helsingborg-stad/Municipio/compare/5.177.1...5.177.2)
Image Focus: Automatically sets the focus point to detected faces in an image (requires DeepFace), or falls back to detecting the most visually active area.
Schema Import: Prevents empty imports by validating data before processing.
Resource from API: Replaces the live API fetching feature with the SchemaData importer for improved stability.
Gutenberg Rendering: Reduces calls to the do_blocks method by 50%, improving performance.
Singular Controller: Simplifies post preparation to avoid redundant calls.
Gutenberg Hero: Adjusts layout so the hero block now appears before the helper navigation.
Archive Appearance: Displays the post type name in archive list titles.

Modularity [5.177.1...5.177.2](https://github.com/helsingborg-stad/modularity/compare/5.177.1...5.177.2)
Menu Module: Normalizes grid layouts automatically to prevent layout issues when column counts differ.

Component Library [5.177.1...5.177.2](https://github.com/helsingborg-stad/component-library/compare/5.177.1...5.177.2)
Button Component: Corrects email link sanitization for safer output.

S3 Index [5.177.1...5.177.2](https://github.com/helsingborg-stad/s3-local-index/compare/5.177.1...5.177.2)
Manage Index: Handles index deletion errors gracefully to prevent fatal errors.
Index Identifier: Improves path parsing for more accurate directory handling.
Directory Resolver: Disabled on admin pages to prevent recursive folder creation failures during file uploads.
```

### **Goal**
Produce a clear, consistent, and accurate changelog that summarizes all impactful updates between two versions, formatted for publication. Present the result in the chat. 

### Additional output requirements
The output should also include a lead paragraph summarizing the overall changes made in this release, highlighting the most significant updates across all packages. It should be concise and informative, providing context for users about what to expect in this release. It should also categorize the release as one of the following: Major, Minor, or Patch, based on the nature of the changes included. It should be less than 75 words.

### **Additional Output version**
After generating the changelog in Markdown, also output an ESCAPED HTML version under a separate heading called **"HTML Version"**. Present the result in the chat. Any bullet points with a prefix (maked with:) shound be marked with bold in the HTML version.