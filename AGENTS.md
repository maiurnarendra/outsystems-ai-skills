# OutSystems AI Skills: standards for coding agents

When you create, modify or review OutSystems code (O11 or ODC), follow the standards in `skills/`. Read the file that matches the task before acting:

| Task | Read |
|---|---|
| Creating or naming modules, apps, libraries | `skills/outsystems-module-naming/SKILL.md` |
| Adding dependencies, designing an app's structure | `skills/outsystems-architecture/SKILL.md` |
| Writing Server/Client/Service Action logic | `skills/outsystems-action-flows/SKILL.md` |
| Entity naming, CRUD wrappers, action inputs/outputs | `skills/outsystems-crud-conventions/SKILL.md` |
| SQL nodes | `skills/outsystems-advanced-sql/SKILL.md` |
| Reviewing existing code | `skills/outsystems-standards-review/SKILL.md` |
| Code review of a work item (Standards + Spec, read live through the Service Studio MCP) | `skills/outsystems-code-review/SKILL.md` (user-invoked) |
| Deploying work items with LifeTime | `skills/outsystems-lifetime-deploy/SKILL.md` (needs the user's config file) |

Non-negotiables, even if you read nothing else:

1. Every module has a layer suffix (`_CS`, `_BL`, `_CW`, `_FS`, `_IS`, `_Lib`, `_TH`). A leading `M` means mobile: `_MCS`, `_MBL`, `_MCW`, `_MTH`.
2. No upward references (Foundation → Core → End-user) and no references between End-user modules.
3. Entities are CamelCase and singular (`CustomerAddress`); `_` is used **only** for many-to-many entities (`User_Role`), never for prefixes like `Sales_Customer`.
4. Every entity is `Public = Yes` and `Expose Read Only = Yes`. Static entities sit in a `Static` folder in the `_CS` and their `Id` has `Is AutoNumber = No`. Entities live in `_CS`, and are written only through `<Entity>_CreateOrUpdate` (input `Source`, output `Id`) and `<Entity>_Delete` (input `Id`), plus an optional `<Entity>_DeleteAll` bulk delete in one Advanced SQL node. `_CreateOrUpdate` branches on `Source.Id <> NullIdentifier()` into separate update and create flows; on create it fills `CreatedOn`/`CreatedBy` **and** `UpdatedOn`/`UpdatedBy`.
5. `_CS` (Core Services) holds only entities and their wrappers (`_CreateOrUpdate`, `_Delete`, optional `_DeleteAll`). Get actions go in `_BL` (Business Logic), never in `_CS` or `_CW` (Core Widgets). `_FS` (Foundation Services) is agnostic to the business model: no entities with data.
6. Action, entity and attribute names are CamelCase and singular: `Structure`, `PhoneNumber`, `GetStructure`, `GetStructureById` (never `Structures` / `GetStructures`). Booleans (variables, inputs, outputs, attributes) always start with `Is` or `Has`: `IsNew`, `IsToDelete`, `HasValue`.
7. Flows go top to bottom and left to right with only straight, non-crossing connectors (route around logic with `Dummy` Assigns). If: True goes down, False (error) goes right. For Each: the Cycle connector leaves to the right; when the cycle finishes the flow continues down. Never use `not` in a condition: write `GetStructure.List.Empty = False`. Every If is labelled as a question (`Has structure?`) or a Boolean name (`HasStructure`, `IsToComplete`); every public action, input and output has a Description.
8. Advanced SQL: clause keywords UPPERCASE at the left margin, contents indented with one TAB, commas and `AND`/`OR` on the left, explicit `INNER JOIN`, CamelCase aliases (no abbreviations), `{Entity}.[Attribute]` syntax, header comment, no unsanitised Expand Inline.
9. Deployments: never deploy to Pre-Production or Production, never start a LifeTime deployment without the user's confirmation, never print the LifeTime token. Deployment notes contain only the work item keys.
