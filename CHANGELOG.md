# Changelog

All notable changes to this project are documented here. Versions follow [semantic versioning](https://semver.org/).

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
