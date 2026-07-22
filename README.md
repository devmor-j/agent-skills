# UpdateLog

## What It Does

UpdateLog generates a precise migration report when you need to upgrade a dependency.
Like a changelog but more useful for AI agents, it analyzes the actual git commits
and gives your AI agent a clear, actionable plan, not guesswork.

## How It Works

1. You ask your AI agent to update a package (e.g., "Upgrade React from 18.0.0
   to 18.1.0")
2. UpdateLog finds your current version in your dependency file
3. It clones the target version and compares it to your current version
4. It checks for a CHANGELOG.md and uses it as the top priority for migration instructions
5. It generates a concise markdown report with only the changes you need to make
6. Your AI agent uses that report to update your codebase precisely

## Why Use It

- **No speculation**: Reports only real git commits, not release notes
- **Language-agnostic**: Works for any project
- **Actionable**: Shows exactly what code to change
- **Safe**: Includes bug fixes that might affect your code

## Example

**You ask**: "Update React from 18.0.0 to 18.1.0"

**UpdateLog generates**: `react-18.0.0-to-18.1.0.md` containing:

- Breaking changes with exact migration code
- Deprecations with replacement patterns
- API changes that require updates
- Bug fixes that change behavior

**Your AI agent applies**: The changes from the report to your codebase

## Files Created

- Migration report in your codebase: `<package>-<source>-<target>.md`
- Temporary files are automatically cleaned up
