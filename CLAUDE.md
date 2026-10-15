# CLAUDE.md

This file is read in two situations. Find yours:

- **You are generating or reviewing OutSystems code.** Follow [AGENTS.md](AGENTS.md) and load the matching skill from `skills/` before acting.
- **You are editing this repository.** The skills in `skills/*/SKILL.md` are the single source of truth. `AGENTS.md`, `.github/copilot-instructions.md` and the README tables restate parts of them and must be updated in the same change. Follow [CONTRIBUTING.md](CONTRIBUTING.md): keep the frontmatter `name` equal to the folder name, keep `description` under 1024 characters, add or update a scenario in `evals/scenarios.json` for every rule you change, bump the version and update `CHANGELOG.md`.
