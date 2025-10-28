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
Output a clear, human-readable table of contents with the following structure and formatting:
```
## Table of contents
- [Section 1](#section-1)
  - [Subsection 1.1](#subsection-1.1)
  - [Subsection 1.2](#subsection-1.2)
- [Section 2](https://example.com/section-2)
  - [Subsection 2.1](https://example.com/section-2-1)
```