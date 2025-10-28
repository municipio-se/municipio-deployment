---
mode: 'agent'
model: 'GPT-4.1'
tools: ['edit', 'search', 'runCommands', 'changes', 'fetch', 'githubRepo']
description: 'Prompt template for generating a table of contents list.'
---
# Table of Contents Generation Prompt

Generate a **concise, structured table of contents** for all readmes found in all linked repositories. The table of contents should be inserted in the main README.md file under a heading called "Table of contents". It should not include any sections from the main README.md file. Only include repositorys from `helsingborg-stad` or `municipio-se` organizations.

### **Data Gathering**
1. Identify all packages in the main repository's `composer.json` file.  
   Example:  
   ```
   cat composer.json | jq -r '.require + .["require-dev"] | keys[]'
   ```
2. For each package, locate its GitHub repository fetch all README.md files and read them.  
   Example:  
   ```
    gh search code 'filename:README.md repo:<owner>/<repo>' --json path -q '.[].path' |
    while read path; do
      echo "===== $path ====="
      gh api "repos/<owner>/<repo>/contents/$path" --jq '.content' | base64 --decode
      echo -e "\n"
    done
   ```

### **Table of Contents Generation**
Output a clear, human-readable table of contents with the following structure and formatting. Below is a example of output, replace the example with actual data gathered from the readmes:
```
## Table of contents
- [Municipio](https://github.com/helsingborg-stad/Municipio/blob/main/readme.md)
{Brief description of what this plugin does, and any important notes about usage.}
  - [Getting started](https://github.com/helsingborg-stad/Municipio/blob/main/readme.md#getting-started)
  - [Coding Standards](https://github.com/helsingborg-stad/Municipio/blob/main/readme.md#coding-standards)
  - [Image Convert](https://github.com/helsingborg-stad/Municipio/blob/main/library/ImageConvert/README.md)
- [Modularity Guides](https://github.com/helsingborg-stad/modularity-guides/blob/main/README.md)
{Brief description of what this plugin does, and any important notes about usage.}
  - [Getting started](https://github.com/helsingborg-stad/modularity-guides/blob/main/README.md#getting-started)
  - [Coding Standards](https://github.com/helsingborg-stad/modularity-guides/blob/main/README.md#coding-standards)
```

### Additional Rules
- Use proper Markdown syntax for links and headings.
- Ensure that the table of contents is easy to read and navigate.
- You are only allowed to include repositories from the `helsingborg-stad` or `municipio-se` organizations.
- The table of content should only create entries for README.md files found in the linked repositories.

### Update DOCUMENTATION.md
Insert the generated table of contents into a new `DOCUMENTATION.md` file under the "Table of contents" heading. Ensure that the formatting is consistent with Markdown standards. If a "Table of contents" section already exists, replace it with the newly generated one. If it does not exist, create it after the first introductory section. If there are no DOCUMENTATION.md file, create one and add the table of contents there.