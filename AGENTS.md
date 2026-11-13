# OutSystems AI Skills: standards for coding agents

When you create, modify or review OutSystems code (O11 or ODC), follow the standards in `skills/`. Read the file that matches the task before acting:

| Task | Read |
|---|---|
| Creating or naming modules, apps, libraries | `skills/outsystems-module-naming/SKILL.md` |
| Adding dependencies, designing an app's structure | `skills/outsystems-architecture/SKILL.md` |
| Writing Server/Client/Service Action logic | `skills/outsystems-action-flows/SKILL.md` |
| Designing new entities before building them (interview, glossary, entity proposal) | `skills/outsystems-data-model/SKILL.md` (user-invoked) |
| Entity naming, CRUD wrappers, action inputs/outputs | `skills/outsystems-crud-conventions/SKILL.md` |
| SQL nodes | `skills/outsystems-advanced-sql/SKILL.md` |
| Consuming an external API or service, `_IS` modules | `skills/outsystems-integrations/SKILL.md` |
| A story needs scheduled, batch or long-running work; creating or reviewing a timer | `skills/outsystems-timers/SKILL.md` |
| Reviewing existing code | `skills/outsystems-standards-review/SKILL.md` |
| Diagnosing a bug: runtime error, slow screen or query, front-end / JavaScript issue | `skills/outsystems-debugging/SKILL.md` (user-invoked) |
| Code review of a work item (Standards + Spec, read live through the Service Studio MCP) | `skills/outsystems-code-review/SKILL.md` (user-invoked) |
| Deploying work items with LifeTime | `skills/outsystems-lifetime-deploy/SKILL.md` (user-invoked; needs the user's config file) |

Non-negotiables, even if you read nothing else (the rules agents break most; the skills hold the details):

1. **Modules:** every module has a layer suffix (`_CS`, `_BL`, `_Eng`, `_CW`, `_FS`, `_IS`, `_Lib`, `_TH`; a leading `M` means mobile). No upward references, no references between End-user modules; in Core `_CW` / `_Eng` → `_BL` → `_CS`.
2. **`_CS`:** entities (`Public = Yes`, `Expose Read Only = Yes`), `<Entity>_CreateOrUpdate` (input `Source`, output `Id`), `<Entity>_Delete` (input `Id`) and specific update/delete actions on its own entities, bulk ones as one Advanced SQL node. Get actions go in `_BL`.
3. **Names:** CamelCase and singular (`GetStructure`, never `GetStructures`); `_` in entity names only for many-to-many (`User_Role`); Booleans start with `Is` / `Has`.
4. **Flows:** top to bottom; If True down, False right; For Each Cycle to the right; straight connectors (`Dummy` Assigns for routing); never `not`; no default labels (`If1`); Descriptions on public actions, inputs and outputs.
5. **Built-ins first:** expressions and list actions (`ListAny`, `ListIndexOf`, `ListFilter`) before a For Each with an If; JavaScript only for what OutSystems can't do.
6. **SQL:** uppercase clauses at the left margin, TAB indentation, leading commas, explicit `INNER JOIN`, `{Entity}.[Attribute]`, no unsanitised Expand Inline.
7. **Integrations:** one `_IS` per system, returning the team's own structure with only the attributes needed; external errors become User Exceptions.
8. **Timers:** recurrent in `_BL` (or `_Eng`), one-off in the Timer Engine app; long-running ones wake before the timeout, commit per record and keep a checkpoint and kill switch.
9. **Deployments:** never to Pre-Production or Production, never started without the user's confirmation, never print the LifeTime token.
