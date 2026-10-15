# Contributing

This repository is **content, not code**: Markdown skills that teach a coding agent your OutSystems standards. There is no build and no runtime. A change is a Markdown edit, checked by a validation script and by evals.

## Where rules live

| File | Role | Edit when |
| --- | --- | --- |
| `skills/*/SKILL.md` | **Source of truth.** One topic per skill. | Any rule changes |
| `AGENTS.md` | Condensed rules for agents that don't load skills | A "non-negotiable" rule changes |
| `.github/copilot-instructions.md` | Points Copilot to the skills | A skill is added, renamed or removed |
| `README.md` | Key capabilities table for humans | A capability changes |
| `evals/scenarios.json` | Proof that the rule changes agent behaviour | Every rule change |

`AGENTS.md`, the Copilot file and the README are **derived**. Never define a rule only there. A stale adapter silently teaches the old rule to every Copilot or Cursor user.

## Changing a rule, step by step

1. **Edit the skill.** Keep the rule short, give a *good* and a *bad* example, and state the reason in one line. Agents follow rules with reasons more reliably than bare commands.
2. **Update the derived files** listed above if the change affects them.
3. **Add or update an eval scenario** in `evals/scenarios.json` that would fail without the new rule.
4. **Run the checks:**
   ```
   powershell -ExecutionPolicy Bypass -File scripts\validate.ps1
   ```
5. **Test locally.** Install from your checkout and start a new Claude Code session:
   ```
   powershell -ExecutionPolicy Bypass -File scripts\install.ps1 -Source .
   ```
   Run the scenarios you touched, with and without the skill (see [evals/README.md](evals/README.md)).
6. **Release** (see below).

## Writing a good skill

- **The `description` decides when the skill loads.** Name the concrete things a developer would ask about (entity, wrapper, SQL node, module suffix). Keep it under 1024 characters (Kiro's limit). `name` must be lowercase-with-hyphens and equal the folder name.
- **Keep `SKILL.md` focused.** Aim for under ~150 lines. If a topic grows, move detail to a `reference/` file inside the skill folder and link it.
- **Tables and examples beat prose.** Agents copy patterns they see.
- **Don't duplicate rules across skills.** Link to the other skill instead (e.g. "see `outsystems-action-flows`").

## Releasing a version

Versions follow [semantic versioning](https://semver.org/):

| Change | Bump | Example |
| --- | --- | --- |
| Wording, typo, extra example | Patch | 0.1.0 → 0.1.1 |
| New rule or new skill | Minor | 0.1.0 → 0.2.0 |
| Rule changed so existing code no longer complies | Major | 0.2.0 → 1.0.0 |

1. Bump `version` in **both** `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`.
2. Add an entry at the top of `CHANGELOG.md`.
3. Run `scripts\validate.ps1` (it fails if the versions or changelog don't match).
4. Commit, push, and create a GitHub release tagged `v<version>`.

Users then update with `/plugin marketplace update outsystems-ai-skills` (plugin) or by re-running `scripts/install.ps1` / `install.sh` (direct install).

## Pull requests

Fork, branch off `main`, open a pull request against `main`. Include in the description: the rule changed, the reason, and the before/after eval results for the scenarios you touched.
