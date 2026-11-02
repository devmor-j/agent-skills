---
name: updatelog
description: Generate a concise migration report of differences, breaking changes, and migration steps between two versions of a package.
disable-model-invocation: true
---

# UpdateLog

## Purpose

Analyze git commits between two versions and generate a concise, actionable
report enabling AI agents to refactor code. Focus on what to do, not what to
know.

Like a changelog but built for agents: analyzes the actual git commits between
versions and hands the agent an actionable plan, never speculation. Language-
agnostic (package.json / go.mod / requirements.txt / Cargo.toml / ...).

Example: "Update React from 18.0.0 to 18.1.0" produces
`react-18.0.0-to-18.1.0.md` — breaking changes with exact migration code,
deprecations with replacement patterns, API changes requiring updates, and
bug fixes that change behavior — which the agent then applies to the codebase.

## Workflow

1. Get versions: Target version from user request, source version from
   dependency file (package.json/go.mod/requirements.txt/Cargo.toml/etc.)
2. Find repo: Look up GitHub repository for the package
3. Clone target: `git clone --branch <target-tag> --depth=1 <repo-url>/tmp/updatelog-<package>-<target>`
4. Check changelog: Look for `CHANGELOG.md` in cloned repo ->
   TOP PRIORITY - follow migration instructions
5. Fetch source: `git fetch origin <source-tag>` (in cloned repo)
6. Diff commits: `git log <source-tag>..HEAD`
7. Analyze: Identify breaking changes, deprecations, API changes that require
   code modifications, bug fixes that change behavior
8. Report: Generate concise markdown with only actionable migration steps ->
   save to user's codebase as `<package>-<source>-<target>.md`
9. Cleanup: Delete `/tmp/updatelog-<package>-<target>` directory

## Report Content

INCLUDE:

- Breaking changes with exact migration code
- Deprecations with replacement patterns
- API changes that require code updates
- Bug fixes that change behavior in ways that break existing code

EXCLUDE:

- Background information, performance improvements, bug fixes that don't affect
  user code, new features that don't require changes, file-by-file analysis,
  testing recommendations, rollback strategies
- Any mention of "no migration needed", "no actions needed", or optional features
- New features, enhancements, or improvements that don't break existing code

## Constraints

- Be concise: report length matches change complexity
- Never speculate: only report actual git commits
- Prioritize CHANGELOG.md: If present, follow maintainer's migration
  instructions exactly
- Handle errors gracefully: package not found, version not found, GitHub API
  errors
- Clean up temporary clones after analysis
- Support all programming languages

## Best Practices

- Read actual commits, not release notes
- Identify breaking changes first
- Prioritize migration steps by impact
- Include before/after code examples
- Watch for bug fixes that change behavior: Some "fixes" may break code that
  relied on previous (buggy) behavior
