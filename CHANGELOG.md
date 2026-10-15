# Changelog

All notable changes to this project are documented here. Versions follow [semantic versioning](https://semver.org/).

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
