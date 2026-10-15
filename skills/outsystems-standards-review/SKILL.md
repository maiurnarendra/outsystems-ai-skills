---
name: outsystems-standards-review
description: Review OutSystems modules, actions, entities or SQL against the team's standards and produce a findings report. Use when asked to review, audit, lint or check OutSystems code or architecture for compliance with best practices.
---

# OutSystems standards review

Review the target (module, action, entity, SQL node, or whole application) against the other skills in this plugin. Load the relevant ones before reviewing:

| Checking | Skill |
|---|---|
| Module names / where code lives | `outsystems-module-naming` |
| Dependencies between modules | `outsystems-architecture` |
| Action flows, Ifs, comments | `outsystems-action-flows` |
| Entity wrappers and parameters | `outsystems-crud-conventions` |
| SQL nodes | `outsystems-advanced-sql` |

## Checklist

**Modules & architecture**
- [ ] Every module has a valid layer suffix
- [ ] No upward or End-user-to-End-user references
- [ ] No cycles between Core modules
- [ ] Entities only in `_CS`/`_MCS`, exposed read-only
- [ ] `_CS` contains only entities and `_CreateOrUpdate` / `_Delete` / optional `_DeleteAll` wrappers
- [ ] Get actions live in `_BL`, not in `_CS` or `_CW`
- [ ] `_FS` modules have no entities with data and no Core references

**Actions**
- [ ] Verb + noun CamelCase names, singular (`GetStructure`, `GetStructureById`, not `GetStructures`)
- [ ] Every If labelled as a question or a Boolean name (`Is`/`Has`); every Switch labelled; no default `If1`/`Assign1` labels
- [ ] If: True continues down, False (error) goes right; no `not` in conditions
- [ ] For Each: Cycle connector leaves to the right; exit continues down
- [ ] Booleans (variables, inputs, outputs) start with `Is` or `Has`
- [ ] Flow top to bottom, left to right; only straight connectors, none diagonal or crossing (`Dummy` Assigns used for routing)
- [ ] Flow ≤ ~20 nodes, ≤ 3 nested Ifs
- [ ] Public actions, inputs and outputs have Descriptions
- [ ] No disconnected or commented-out nodes
- [ ] No hard-coded environment values
- [ ] No queries inside loops

**CRUD**
- [ ] Entities CamelCase and singular; many-to-many named `EntityA_EntityB`
- [ ] Attributes CamelCase and singular; Boolean attributes start with `Is`/`Has`; foreign keys `<Entity>Id`
- [ ] Only `<Entity>_CreateOrUpdate`, `<Entity>_Delete` and optional `<Entity>_DeleteAll` (no separate `_Create`/`_Update`); `_DeleteAll` is one Advanced SQL node, not a loop
- [ ] No `Prefix_Entity` names that look like many-to-many
- [ ] Every entity `Public = Yes` and `Expose Read Only = Yes`
- [ ] Static entities in a `Static` folder of the `_CS`, `Id` with `Is AutoNumber = No`, active flag named `IsActive` (not the platform default `Is_Active`)
- [ ] `_CreateOrUpdate` input is `Source`, output `Id`; `_Delete` input is `Id`
- [ ] `_CreateOrUpdate` branches on `Source.Id <> NullIdentifier()` with separate create/update flows (no built-in `CreateOrUpdate<Entity>`)
- [ ] Create branch sets `CreatedOn`/`CreatedBy` and `UpdatedOn`/`UpdatedBy`; update branch sets `UpdatedOn`/`UpdatedBy` and keeps the created values
- [ ] Wrappers validate `Source` before writing

**SQL**
- [ ] Header comment present
- [ ] Clause keywords UPPERCASE at the left margin; contents indented with one TAB
- [ ] Commas and `AND`/`OR` on the left
- [ ] Explicit `INNER JOIN` (no bare `JOIN`); aliases CamelCase, no abbreviations
- [ ] No `SELECT *`, no physical table names, no hard-coded Ids/dates
- [ ] Row limit uses `TOP n` (SQL Server) or `LIMIT n` (ODC/PostgreSQL)
- [ ] No unsanitised `Expand Inline`

## Report format

Group findings by severity and give each a concrete fix:

```
## Critical   (security, data loss, architecture violations)
- Customer_CS → Billing_BL reference (upward). Move CalculateDiscount to Billing_BL.

## Major      (standards that affect maintainability)
- Order_Create: If node "If1" unlabeled. Rename to "Has order lines?".

## Minor      (cosmetic / style)
- GetOrder SQL: keywords lowercase on lines 3–5.
```

End with a one-line summary: number of findings per severity and whether the target is ready to publish.
