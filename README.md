# Personal Agent Skills

My collection of agent skills. Each skill is a self-contained folder under
`.agents/skills/<name>/` with a `SKILL.md` (agent instructions) plus its
scripts. Pushing `main` releases the update to every machine/project using
them.

## Skills

|Skill|Invocation|What it does|
|-|-|-|
|[updatelog](.agents/skills/updatelog/SKILL.md)|manual|Migration report between two package versions, built from real git commits + CHANGELOG|
|[trimdash](.agents/skills/trimdash/SKILL.md)|auto|Compact markdown table padding; fence-aware, idempotent, escaped-pipe safe|

## Install

```sh
npx skills add devmor-j/agent-skills              # both skills, current project
npx skills add devmor-j/agent-skills -g           # user-level (global)
npx skills add devmor-j/agent-skills -s trimdash  # one skill only
npx skills add devmor-j/agent-skills -l           # list what's available
```

Update later with `npx skills update`.

## Adding a skill

1. Create `.agents/skills/<name>/SKILL.md` — frontmatter `name` + `description`
   (the description is what triggers auto-invocation; add
   `disable-model-invocation: true` for manual-only skills).
2. Scripts live beside `SKILL.md`, executable, self-contained.
3. Keep scripts project-agnostic: per-repo tweaks go through env vars
   (see `TRIMDASH_SKIP` in trimdash), never hardcoded paths.
4. Push, then install/update wherever needed.
