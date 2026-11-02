---
name: trimdash
description: Compacts markdown table padding (edge spaces, dash runs) without changing rendered content. Idempotent, fence-aware, escaped-pipe safe. Use when asked to trim/compact/shrink markdown tables, cut table character count, or run trimdash.
---

# Trim-dash — markdown table compaction

Run `trimdash.sh` (this skill's directory, absolute path) on the target md files: first `--dry-run`, then apply. Do not read the target files first; the script reports what it changed.

## Apply

```sh
<skill-dir>/trimdash.sh --dry-run <files>   # 1. see what would change
<skill-dir>/trimdash.sh <files>             # 2. apply
<skill-dir>/trimdash.sh --quiet <files>     # apply, summary line only
```

Exit codes: `0` ok, `1` usage error, `2` at least one file skipped/failed. Every skip is printed on stderr with the reason — read it.

## Skip prefixes

`TRIMDASH_SKIP="vendor/mirrors:gen/api"` (colon-separated path prefixes) skips files under those paths:

```sh
TRIMDASH_SKIP=vendor/mirrors:gen/api <skill-dir>/trimdash.sh <files>
```

## Verify (after applying)

```sh
<skill-dir>/trimdash.sh --dry-run <files>   # expect no "would compact:" lines (idempotent)
git diff --stat -- <files>                  # only padding / dash runs should move
```

## Limits

- Untouched: prose, lists, horizontal rules, fenced code (``` and ~~~, closing run must match opener), blockquoted tables, tables without a leading `|` on the divider row, CRLF (byte-preserved), missing trailing newline.
- Escaped pipes `\|` preserved; `\\|` = literal backslash + real separator.
- Rare trade-off: a code span whose edge space is adjacent to a pipe has that space trimmed (only intentional content touch).
