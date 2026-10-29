# Changelog

All notable changes to this project are documented here. Versions follow [semantic versioning](https://semver.org/).

## [0.11.1] - 2026-10-29

### Changed
- README: new "Principles" section (the skills assist, developers decide; reading is the default; every rule has a reason; team workflows stay out of this repository).
- README: "Key capabilities" split into Standards, Practices and Tooling.

## [0.11.0] - 2026-10-29

### Added
- **Google Antigravity support.**
  - `install.ps1 -Target antigravity` / `install.sh --target antigravity` installs the skills into `~/.gemini/config/skills/`. `-Destination` / `--destination` installs into any folder, e.g. a workspace's `.agents/skills/`.
  - Setup section in `setup-docs/other-agents.md`: skills, `AGENTS.md`, on-demand skills with `/<skill-name>`, and the Service Studio MCP.
- On-demand guard in `outsystems-code-review`, `outsystems-data-model` and `outsystems-debugging`: agents without `disable-model-invocation` (Antigravity, Cursor, Codex, Kiro) start them only when the user asks.
- Eval scenario `trigger-negative-02`.

### Changed
- README lists Antigravity in "Works with", the repository table and "Using other coding agents".

## [0.10.0] - 2026-10-28

### Added
- `outsystems-debugging`: takes a bug to a confirmed root cause before anything changes. User-invoked only.
  - **Three tracks:** runtime errors, performance, and front-end (especially JavaScript in Reactive and Mobile).
  - **Evidence first:** Service Center / ODC logs, the browser DevTools, and the model read through the Service Studio MCP (read-only).
  - **One hypothesis at a time,** each with a check that could prove it wrong.
  - **Report:** symptom, evidence, root cause, fix, check and risk. Performance fixes need a measurement before and after.
  - **Catalogues** in `reference/`: `runtime-errors.md`, `performance.md`, `frontend.md`.
- Based on the diagnosing-bugs skill in [mattpocock/skills](https://github.com/mattpocock/skills), credited in the README.
- Eval scenarios `debugging-01` to `debugging-04`.

### Changed
- README, `AGENTS.md`, Copilot instructions and plugin descriptions list the new skill.

## [0.9.0] - 2026-10-28

### Added
- `outsystems-integrations`: standards for `_IS` modules.
  - One `_IS` per external system.
  - Consumed methods and imported structures stay `Public = No`.
  - Public actions have business names and return the team's own structure with **only the attributes the application needs** (an API with 30 fields used for 4 gives a structure with 4).
  - Types are converted at the boundary; the raw response never leaves the `_IS`.
  - External errors become User Exceptions; endpoints and credentials live in configuration.
- Review checklist: Integrations section.
- Eval scenarios `integration-01` to `integration-03`.

### Changed
- `outsystems-module-naming`, `outsystems-code-review`, README, `AGENTS.md` (new non-negotiable 9), Copilot instructions and plugin descriptions point to the new skill.

## [0.8.2] - 2026-10-27

### Changed
- `evals/results/2026-10-26-code-review.md`: removed the warning count and the defect description of the reviewed module. Results keep the checks, not details of a real system.

## [0.8.1] - 2026-10-27

Lessons from the first live runs (results in `evals/results/`).

### Changed
- `outsystems-code-review`:
  - Warns the user to approve the Service Studio session-token dialog, and retries once on time-out.
  - Handles large elements: prefers Model API code, searches saved output, and lists unread parts under "Not reviewed".
  - Offers to read the event handler or caller, read-only, before calling a finding a defect.
  - Marks findings unrelated to the work item as *(pre-existing?)*, lists work-item findings first, and lets pre-existing findings affect the verdict only when Critical.
  - "Needs testing" criteria now come with test steps and the expected result.
- `outsystems-data-model`:
  - Uses the referenced entities in `getDataModel` as a reuse map, and notes where the existing model breaks the standard.
  - Prefers concrete-case questions over "Is X right?".
  - Checks decisions against each other before writing; surprises become open questions.
  - Topics that don't change the model may be parked.
  - Proposal and glossary are shown and approved before they are written to a project folder.

## [0.8.0] - 2026-10-27

### Added
- `outsystems-data-model`: designs entities before they are built. It interviews the developer one question at a time, each with a recommended answer, covering the business term, owning `_CS`, static vs regular entity, foreign key vs real many-to-many, delete rules, attributes and lengths, indexes, volume and sensitive data. It reads the existing model (Service Studio MCP, read-only) and `GLOSSARY.md` first, then writes an entity proposal (tables, Mermaid diagram, decisions with reasons, open questions) and updates the glossary. It never creates entities; `outsystems-crud-conventions` builds them on request. User-invoked only.
- Based on the domain-modeling and grilling skills in [mattpocock/skills](https://github.com/mattpocock/skills), credited in the README.
- Eval scenarios `data-model-01` to `data-model-03`.

### Changed
- README, `AGENTS.md`, Copilot instructions and plugin descriptions list the new skill.

## [0.7.1] - 2026-10-27

### Added
- README: Credits section. Matt Pocock's [skills](https://github.com/mattpocock/skills) repository is credited as the basis of `outsystems-code-review`, and the OutSystems 11 MCP as the model for this repository.
- `outsystems-code-review`: credit line to the original Standards + Spec review.

## [0.7.0] - 2026-10-26

### Added
- `outsystems-code-review`: reviews the code changed for a work item on two independent axes. **Standards** walks the `outsystems-standards-review` checklist; **Spec** marks each acceptance criterion Met, Partly met, Not found or Needs testing, with the element and node as evidence, and lists changes the story didn't ask for. Reads modules live through the Service Studio MCP and never edits, merges or publishes. Ends with a verdict: Ready, Needs changes or Blocked.
- The skill is user-invoked only (`disable-model-invocation: true`): it runs when the developer types `/outsystems-code-review`.
- Eval scenarios `code-review-01` to `code-review-03`.
- Inspired by the Standards + Spec review in [mattpocock/skills](https://github.com/mattpocock/skills), rewritten for OutSystems (no git diff: scope comes from the user or the work item).

### Changed
- README, `AGENTS.md`, Copilot instructions, plugin descriptions and `outsystems-standards-review` point to the new skill.

## [0.6.1] - 2026-10-26

### Changed
- README: the Status row no longer shows a hard-coded version; it links to Releases and the changelog. New Tested row links to the live test results.

## [0.6.0] - 2026-10-22

### Added
- `outsystems-lifetime-deploy`: creates one LifeTime deployment plan from the work items that are ready for test, using the LifeTime Deployment API v2. Reads modules from the items' comments, maps them to applications, tags changed apps and uses only the item keys as deployment notes. Starts a plan only after the user confirms.
- Tracker-agnostic: Jira, Azure DevOps, GitHub Issues or none, chosen in a local config file (`config.example.json`). People, statuses and after-deploy rules live only in that file.
- `scripts/lifetime.ps1` (Windows PowerShell 5.1 and `pwsh`): refuses targets listed in `forbiddenTargets`, never prints the token, starts plans with `RedeployOutdated=true`, and lists deployments running on the target.
- Handling for a refused start: wait while another deployment runs on the target; if nothing runs, recreate the stale plan with the same versions.
- Eval scenarios `deploy-01` to `deploy-03`.

### Changed
- README, CONTRIBUTING, `AGENTS.md` and Copilot instructions mention the deployment skill; the repository is no longer "content only".

## [0.5.0] - 2026-10-15

### Added
- `outsystems-crud-conventions`: optional `<Entity>_DeleteAll` bulk delete in `_CS`, implemented as one Advanced SQL node (`DeleteAll<Entity>`), never a loop.
- `outsystems-crud-conventions`: `Get<Entity>ForUpdate` output path is `Record.<Entity>.<Attribute>`.
- `evals/results/2026-10-15.md`: first live test results against a real OutSystems 11 `_CS` module (static entity 8/8; entity + CRUD + bulk delete passed developer review).
- Eval scenario `crud-05`.

### Changed
- Module naming, architecture summary, review checklist, `AGENTS.md` and README now list `_DeleteAll` as an allowed `_CS` action.

## [0.4.0] - 2026-10-15

### Changed
- Project renamed to **OutSystems AI Skills**. Repository `maiurnarendra/outsystems-ai-skills` (GitHub redirects the old `outsystems-best-practices` URL). Plugin and marketplace renamed from `outsystems-standards` to `outsystems-ai-skills`; install with `/plugin install outsystems-ai-skills@outsystems-ai-skills`.

## [0.3.1] - 2026-10-15

### Changed
- `outsystems-crud-conventions`: states explicitly that static entities use `IsActive`, not the Service Studio default `Is_Active`. Found while testing the skills against a real `_CS` module.
- Review checklist and eval `crud-03` check the static entity active-flag name.

## [0.3.0] - 2026-10-15

### Changed
- `outsystems-action-flows`: If nodes can be labelled as a question (`Has structure?`) or as a Boolean name like a Boolean variable (`HasStructure`, `IsToComplete`, `IsEmpty`). The label always describes the True case.

## [0.2.1] - 2026-10-15

### Changed
- Examples now use a generic Customer / Order domain (SQL examples, entity naming tables, AGENTS.md, README, eval `crud-02`). No rule changes.

## [0.2.0] - 2026-10-15

### Added
- `outsystems-action-flows`: Boolean variables, inputs and outputs always start with `Is` or `Has` (`IsNew`, `IsToDelete`, `HasValue`).
- `outsystems-action-flows`: For Each layout. The Cycle connector leaves to the right, and the flow continues down when the cycle finishes.
- `outsystems-crud-conventions`: attribute naming. CamelCase, singular, Booleans with `Is`/`Has`, foreign keys `<Entity>Id`.
- Review checklist items and eval scenarios `action-flow-05` and `crud-04`.

### Changed
- `Can` is no longer an accepted Boolean prefix; only `Is` and `Has`.

## [0.1.0] - 2026-10-15

### Added
- `outsystems-module-naming`: layer suffixes (`_CS`, `_BL`, `_CW`, `_FS`, `_IS`, `_Lib`, `_TH`, `_Pat`, `_API`) and mobile variants (`_MCS`, `_MBL`, `_MCW`, `_MTH`).
- `outsystems-architecture`: 3-layer Architecture Canvas and dependency rules.
- `outsystems-action-flows`: singular action names, `GetStructure` / `GetStructureById` Get naming, flows top to bottom and left to right, If True down / False right, no `not` in conditions, no diagonal or crossing connectors (`Dummy` Assigns for routing), labels, comments, exceptions.
- Placement rules: Get actions in `_BL`, `_CS` limited to entities and wrappers, `_FS` without entities holding data.
- `outsystems-crud-conventions`: CamelCase entity names, `_` for many-to-many only, `Entity_CreateOrUpdate` (`Source` → `Id`) and `Entity_Delete` (`Id`) wrappers with separate create/update branches and audit fields; every entity `Public = Yes` and `Expose Read Only = Yes`; static entities in a `Static` folder with `Is AutoNumber = No`.
- `outsystems-advanced-sql`: tab indentation, leading commas, explicit joins, CamelCase aliases, `TOP` / `LIMIT`.
- `outsystems-standards-review`: review checklist and report format.
- Claude Code plugin and marketplace manifests, `AGENTS.md`, Copilot instructions, install and validation scripts, eval scenarios.
