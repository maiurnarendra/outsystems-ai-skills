# OutSystems AI Skills

**Teach any coding agent to build OutSystems the way your team does: consistent names, clean flows, a sound architecture.**

AI coding agents can now read and change OutSystems applications through MCP servers such as the [OutSystems 11 MCP](https://github.com/OutSystems/outsystems11-mcp). They know *how* to change your model, but not *how your team wants it done*. Left alone, an agent will name a module `Utils`, leave If nodes called `If1`, write `JOIN` in lowercase, and skip the audit fields.

This repository packages a set of OutSystems development standards as **Agent Skills**. Once installed, the agent loads the right standard at the right moment and applies it to everything it generates or reviews.

## Why it matters

- **Consistency at scale.** Every developer's agent follows the same rules, so code generated on Monday by one person looks like code generated on Friday by another.
- **Reviews get shorter.** Naming, layout and formatting issues are fixed before the code reaches a reviewer. A dedicated review skill checks existing code against the same rules.
- **Architecture stays clean.** The agent knows which layer a module belongs to and refuses upward or side references.
- **Your standards, versioned.** Rules live in plain Markdown under version control. Change a rule, publish, and every agent picks it up.
- **Tool-neutral.** Built on the open `SKILL.md` and `AGENTS.md` formats. Optimized for Claude Code, also usable with GitHub Copilot, Cursor, Kiro and Codex.

## What it is

| Aspect | Details |
| --- | --- |
| **Type** | Seven standards skills that are content only (Markdown, nothing runs), one data-model design skill, `outsystems-data-model`, that interviews you before entities are built, one code-review skill, `outsystems-code-review`, that reads your modules through the Service Studio MCP without changing them, and one deployment skill, `outsystems-lifetime-deploy`, that calls the LifeTime API with a small PowerShell script, only when you use it. |
| **Platforms** | OutSystems 11 and OutSystems Developer Cloud (ODC). |
| **Works with** | Claude Code (plugin or skill install), GitHub Copilot, Cursor, Kiro, Codex CLI. |
| **Pairs with** | Any OutSystems MCP server: the MCP gives the agent access to your app, these skills govern what it writes. Also useful on its own for design and review conversations. |
| **Status** | Actively maintained. See [Releases](https://github.com/maiurnarendra/outsystems-ai-skills/releases) for the latest version and [CHANGELOG.md](CHANGELOG.md) for what changed. |
| **Tested** | Standards skills run against a real OutSystems 11 module through the Service Studio MCP. Results in [evals/results/](evals/results/). |

## Key capabilities

| Skill | What the agent will do |
| --- | --- |
| [**Module naming**](skills/outsystems-module-naming/SKILL.md) | Name every module with its layer suffix: `_CS`, `_BL`, `_CW`, `_FS`, `_IS`, `_Lib`, `_TH`, `_Pat`, `_API`, and the mobile variants `_MCS`, `_MBL`, `_MCW`, `_MTH` (a leading `M` means mobile). Place each element in the right module. |
| [**Architecture**](skills/outsystems-architecture/SKILL.md) | Apply the 3-layer Architecture Canvas (End-user, Core, Foundation), block upward and End-user-to-End-user references, and fix common violations. |
| [**Action flows**](skills/outsystems-action-flows/SKILL.md) | Name actions in the singular (`GetStructure`, `GetStructureById`) and place Get actions in `_BL`. Lay flows out top to bottom and left to right with straight, non-crossing connectors. If branches go True down, False right, with no `not` in conditions and a question or Boolean name as the label (`Has structure?`, `IsToComplete`). Write Descriptions on every public action, input and output. |
| [**Data model design**](skills/outsystems-data-model/SKILL.md) | Before any entity exists, interview you one question at a time, each with a recommended answer: the business term and its glossary entry, the owning `_CS`, static vs regular entity, foreign key vs real many-to-many, delete rules (Protect / Delete / Ignore), attributes and lengths, indexes, volume and sensitive data. Checks the existing model and `GLOSSARY.md` first, then writes an entity proposal with a diagram and the reasons for each decision. Runs only when you ask for it. |
| [**Entities & CRUD**](skills/outsystems-crud-conventions/SKILL.md) | Name entities in CamelCase (`CustomerAddress`), use `_` only for many-to-many (`User_Role`), and generate `Entity_CreateOrUpdate` (input `Source`, output `Id`, separate create/update branches, audit fields filled), `Entity_Delete` (input `Id`) and, when needed, an `Entity_DeleteAll` bulk delete in Advanced SQL. |
| [**Advanced SQL**](skills/outsystems-advanced-sql/SKILL.md) | Format queries with uppercase clauses at the left margin, tab-indented contents, leading commas, explicit `INNER JOIN`, CamelCase aliases and parameters instead of hard-coded values. `TOP` for SQL Server, `LIMIT` for ODC/PostgreSQL. |
| [**Integrations**](skills/outsystems-integrations/SKILL.md) | Keep every external system behind its own `_IS`. Consumed methods and imported structures stay private; public actions have business names (`GetWeatherForecast`) and return your own structure with **only the attributes you need**: if the API returns 30 fields and you use 4, the structure has 4. Types are converted at the boundary and external errors become User Exceptions. |
| [**Standards review**](skills/outsystems-standards-review/SKILL.md) | Review a module, action, entity or query against all of the above and report findings by severity with a concrete fix for each. |
| [**Code review**](skills/outsystems-code-review/SKILL.md) | Review the code changed for a work item on two independent axes: **Standards** (all of the above) and **Spec** (each acceptance criterion marked Met, Partly met, Not found or Needs testing, plus changes the story didn't ask for). Reads the modules live through the Service Studio MCP, never edits them, and ends with a verdict: Ready, Needs changes or Blocked. Runs only when you ask for it. |
| [**LifeTime deploy**](skills/outsystems-lifetime-deploy/SKILL.md) | Read the work items that are ready for test from your tracker (Jira, Azure DevOps, GitHub Issues or none), find the modules in their comments, tag the changed apps and create **one** LifeTime deployment plan with the item keys as notes. Starts it only when you confirm. Tracker, environments and any after-deploy status/assignee changes come from your own config file. |

### What you can ask

- *"Create the Core modules for an expense-claims app with a mobile app."*
- *"/outsystems-data-model Design the entities for expense claims with approvals."*
- *"Write the CreateOrUpdate and Delete wrappers for the Invoice entity."*
- *"Write an Advanced SQL query that returns the top 50 customers by order total."*
- *"Consume the weather API in Weather_IS. I only need date, temperature, condition and wind speed."*
- *"Review the Order_CS module against our OutSystems standards."*
- *"/outsystems-code-review ORD-123"*: check the actions changed for a story against the standards and its acceptance criteria.
- *"Create the deployment plan to Testing for my work items that are ready for test."*

## What's in this repository

| Layer | Cross-tool standard? | In this repo |
| --- | --- | --- |
| **Skills** | ✅ `SKILL.md`: Claude Code, Cursor, Kiro, Codex | [`skills/`](skills/), one folder per topic |
| **Agent instructions** | ✅ `AGENTS.md`: Copilot, Cursor, Kiro, Codex, Claude Code | [`AGENTS.md`](AGENTS.md), plus [`.github/copilot-instructions.md`](.github/copilot-instructions.md) for Copilot |
| **Claude Code plugin** | Claude Code only | [`.claude-plugin/`](.claude-plugin/), installable with `/plugin` |
| **Evals** | Runner-agnostic | [`evals/`](evals/), test prompts that prove the skills change the agent's output |

```
outsystems-ai-skills/
├─ skills/
│  ├─ outsystems-module-naming/SKILL.md     # module suffixes and placement
│  ├─ outsystems-architecture/SKILL.md      # layers and dependency rules
│  ├─ outsystems-action-flows/SKILL.md      # flows, If labels, comments, exceptions
│  ├─ outsystems-data-model/SKILL.md        # entity design interview, glossary, proposal
│  ├─ outsystems-crud-conventions/SKILL.md  # entity naming and CRUD wrappers
│  ├─ outsystems-advanced-sql/SKILL.md      # SQL formatting and safety
│  ├─ outsystems-integrations/SKILL.md      # _IS modules: private API, lean own structures
│  ├─ outsystems-standards-review/SKILL.md  # review checklist and report
│  ├─ outsystems-code-review/SKILL.md       # work item review: Standards + Spec, via the Service Studio MCP
│  └─ outsystems-lifetime-deploy/           # work items → LifeTime plan (SKILL.md, config.example.json, reference/, scripts/)
├─ evals/
│  ├─ README.md                             # how to test the skills
│  └─ scenarios.json                        # prompts + expected behaviour
├─ .claude-plugin/                          # Claude Code plugin + marketplace manifests
├─ .github/copilot-instructions.md          # Copilot always-on instructions
├─ scripts/
│  ├─ install.ps1 / install.sh              # copy skills into ~/.claude/skills
│  └─ validate.ps1                          # structural checks before a release
├─ setup-docs/other-agents.md               # Copilot, Cursor, Kiro, Codex setup
├─ AGENTS.md                                # cross-tool summary of the rules
├─ CLAUDE.md                                # routing for Claude Code
├─ CONTRIBUTING.md                          # how to change a rule and release
├─ CHANGELOG.md                             # what changed in each version
└─ LICENSE
```

## Getting started (Claude Code)

### Option A: install as a plugin (recommended)

In any Claude Code session:

```
/plugin marketplace add maiurnarendra/outsystems-ai-skills
/plugin install outsystems-ai-skills@outsystems-ai-skills
```

Start a new session so the skills load. To get new versions later:

```
/plugin marketplace update outsystems-ai-skills
```

### Option B: install the skills directly

Clone the repository and run the installer. It copies every folder in `skills/` into your Claude Code skills directory (`%USERPROFILE%\.claude\skills\` on Windows, `~/.claude/skills/` on macOS/Linux), replacing older copies. Re-run it any time to update.

```
git clone https://github.com/maiurnarendra/outsystems-ai-skills.git
cd outsystems-ai-skills
```

**Windows PowerShell**

```
powershell -ExecutionPolicy Bypass -File scripts\install.ps1
```

**macOS / Linux / Git Bash**

```
bash scripts/install.sh
```

Start a new Claude Code session afterwards.

### Verify

In a new session, ask:

> What suffix should a mobile theme module have, and how should I name the wrappers for a many-to-many entity between Employee and Project?

The answer should be `_MTH`, and `Employee_Project_CreateOrUpdate` / `Employee_Project_Delete`. If it is, the skills are loaded.

### With the OutSystems 11 MCP

Install both. The [OutSystems 11 MCP](https://github.com/OutSystems/outsystems11-mcp) skill tells the agent how to edit the model open in Service Studio; these skills tell it what good looks like. No extra configuration is needed: Claude Code loads both when you work on an OutSystems module.

## Using other coding agents

| Tool | How it picks up the standards | Guide |
| --- | --- | --- |
| **GitHub Copilot (VS Code / CLI)** | `AGENTS.md` and `.github/copilot-instructions.md` | [setup-docs/other-agents.md](setup-docs/other-agents.md#github-copilot) |
| **Cursor** | `skills/` copied to `.cursor/skills/`, or `AGENTS.md` | [setup-docs/other-agents.md](setup-docs/other-agents.md#cursor) |
| **Kiro** | `skills/` copied to `~/.kiro/skills/`, or `AGENTS.md` | [setup-docs/other-agents.md](setup-docs/other-agents.md#kiro) |
| **Codex CLI** | `skills/` copied to `~/.codex/skills/`, or `AGENTS.md` | [setup-docs/other-agents.md](setup-docs/other-agents.md#codex-cli) |

## Customizing for your team

The rules are a starting point. Fork the repository, edit the Markdown in `skills/`, and install from your fork. [CONTRIBUTING.md](CONTRIBUTING.md) explains how to change a rule safely, test it, and release a new version.

## Contributing

Issues and pull requests are welcome. Every proposed rule needs a *good* and a *bad* example and the reason behind it. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Credits

- [**Matt Pocock**](https://github.com/mattpocock) and his [skills repository](https://github.com/mattpocock/skills). Two skills here are based on his work, rewritten for OutSystems:
  - `outsystems-code-review` on his `code-review` skill, which reviews a change on two independent axes, Standards and Spec. OutSystems has no git diff, so the scope comes from the developer or the work item, and modules are read live through the Service Studio MCP.
  - `outsystems-data-model` on his `domain-modeling` and `grilling` skills: a one-question-at-a-time interview, with a recommended answer each time, that challenges terms against a glossary. Here the decisions are OutSystems ones: owning `_CS`, static vs regular entity, many-to-many, delete rules.
- [**OutSystems 11 MCP**](https://github.com/OutSystems/outsystems11-mcp): the model for this repository's structure and README.

## License

[MIT](LICENSE)
