# Release Log Generation

Generate a **concise, structured changelog** summarizing all relevant updates between two versions. The changelog should be ready to paste directly into `CHANGELOG.md`.

## Step 1 — Gather Data

Run the following command to identify changed packages and their versions:

```bash
php ./.github/prompts/create-release-log-prompt.php --small
```

## Step 2 — Generate Changelog

Using the output from Step 1, produce a clear, human-readable changelog with this structure:

```
## [Package Name] [version-from...version-to]
- [Description of change]
- [Description of change]

## [Next Package Name] [version-from...version-to]
- [Description of change]
```

**What to include:**
- All new features, enhancements, bug fixes, and functional changes
- Only packages that have changed
- Information that impacts how users or developers use the package or app
- Clear, user-friendly package names (e.g., `Component Library` instead of `helsingborg-stad/component-library`)
- Brief technical details where necessary to explain impact

**Exclude:**
- Generic entries such as "Updated package file versions to align with the new release"
- Vague language like "Miscellaneous improvements" or "Various bug fixes"

**Tone and style:**
- Simple, non-technical language when possible
- Clear, direct, and descriptive
- Concise, user-facing tone
- Every line must communicate a meaningful change

## Step 3 — Lead Paragraph

Before the changelog, output a lead paragraph (max 75 words) that:
- Summarizes the overall changes in this release
- Highlights the most significant updates across all packages
- Categorizes the release as **Major**, **Minor**, or **Patch** based on the nature of the changes

## Step 4 — HTML Version

After the Markdown changelog, output a second section titled **"HTML Version"** containing an escaped HTML version of the same content. Any bullet point prefix separated by a colon (e.g. `Button Component:`) must be wrapped in `<strong>` tags in the HTML version.

---

**Example output:**

```
Municipio Theme [5.177.1...5.177.2](https://github.com/helsingborg-stad/Municipio/compare/5.177.1...5.177.2)
- Image Focus: Automatically sets the focus point to detected faces in an image (requires DeepFace), or falls back to detecting the most visually active area.
- Schema Import: Prevents empty imports by validating data before processing.

Modularity [5.177.1...5.177.2](https://github.com/helsingborg-stad/modularity/compare/5.177.1...5.177.2)
- Menu Module: Normalizes grid layouts automatically to prevent layout issues when column counts differ.
```

Do not create any files — output the changelog content directly in the chat.
