# Test Custom Plugin

A simple test plugin to verify the build and deployment process works correctly.

## What it does

- Shows an admin notice in WordPress admin dashboard
- Displays a styled message in the footer of the front-end
- Tests asset compilation (SCSS → CSS, JS bundling)
- Verifies webpack manifest generation

## Build locally

```bash
cd wp-content/plugins/test-custom-plugin
npm install
npm run build
```

This will:
1. Compile SCSS to CSS
2. Bundle JavaScript
3. Generate `dist/` folder with built assets and `manifest.json`

## Test on staging

1. Commit and push this plugin to the repository
2. Push to the `stage` branch
3. The GitHub Action will automatically:
   - Install npm dependencies
   - Run `npm run build`
   - Clean up dev files
   - Deploy to production

## What to check

- ✅ Plugin appears in WordPress admin
- ✅ Admin notice is visible in dashboard
- ✅ Footer message appears with styling
- ✅ CSS and JS are loaded correctly
- ✅ Built assets work properly

