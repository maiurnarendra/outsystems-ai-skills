---
name: outsystems-standards-review
description: Review OutSystems modules, actions, entities or SQL against the team's standards and produce a findings report. Use when asked to review, audit, lint or check OutSystems code or architecture for compliance with best practices.
---

# OutSystems standards review

Review the target (module, action, entity, SQL node, or whole application) against the checklist below. **Walk the checklist first.** Load a detailed skill only for the kinds of element in scope (no SQL node in scope → no `outsystems-advanced-sql`), and open it when a check fails or is unclear and you need the exact rule or fix:

To review the code changed for a work item against both the standards and its acceptance criteria, reading the modules live from Service Studio, use `outsystems-code-review` instead; it uses this checklist for its Standards axis.

| Checking | Skill |
|---|---|
| Module names / where code lives | `outsystems-module-naming` |
| Dependencies between modules | `outsystems-architecture` |
| Action flows, Ifs, comments | `outsystems-action-flows` |
| Entity wrappers and parameters | `outsystems-crud-conventions` |
| SQL nodes | `outsystems-advanced-sql` |
| Integration modules (`_IS`) | `outsystems-integrations` |
| Timers | `outsystems-timers` |

## Checklist

**Modules & architecture**
- [ ] Every module has a valid layer suffix
- [ ] No upward or End-user-to-End-user references
- [ ] No cycles between Core modules
- [ ] Entities only in `_CS`/`_MCS`, exposed read-only
- [ ] `_CS` contains only entities, their `_CreateOrUpdate` / `_Delete` wrappers and specific update/delete actions on its own entities (`<Entity>_<Verb><What>`, bulk ones as one Advanced SQL node)
- [ ] `_Eng` only for complex calculations and report generation; nothing below it (`_BL`, `_CS`, `_CW`) references it
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
- [ ] Built-in functions, System list actions (`ListAny`, `ListAll`, `ListIndexOf`, `ListFilter`) and Aggregate filters used before a For Each; no For Each + If that only searches, checks or filters a list
- [ ] Simple conditional values use `If()` in an expression, not an If node with two Assigns; repeated Ifs on one value use a Switch
- [ ] JavaScript nodes only for what OutSystems can't do (DOM, browser APIs, a library): small, no business logic, a comment saying why

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

**Timers**
- [ ] Placed by kind: recurrent in the domain's `_BL` (or `_Eng` for heavy calculations/reports); one-off in Timer Engine; nothing references Timer Engine
- [ ] Long-running timers: time limit (timeout minus 5 min) with `Wake<Timer>` before it, batches with Max. Records, commit per record
- [ ] A row in the factory's shared checkpoint entity (or `TimerControl_CS` when there was none): checkpoint updated before each commit, kill switch read before every batch; no second checkpoint entity created
- [ ] No-progress guard; one failing record is logged, marked and skipped, not retried forever
- [ ] Same change on many rows done by a bulk `_CS` action (Advanced SQL), not a For Each
- [ ] Start/end logging; schedule outside business hours when heavy; timer named `Timer<Action>`

**SQL**
- [ ] Header comment present
- [ ] Clause keywords UPPERCASE at the left margin; contents indented with one TAB
- [ ] Commas and `AND`/`OR` on the left
- [ ] Explicit `INNER JOIN` (no bare `JOIN`); aliases CamelCase, no abbreviations
- [ ] No `SELECT *`, no physical table names, no hard-coded Ids/dates
- [ ] Row limit uses `TOP n` (SQL Server) or `LIMIT n` (ODC/PostgreSQL)
- [ ] No unsanitised `Expand Inline`

**Integrations**
- [ ] One `_IS` per external system
- [ ] Consumed methods and imported structures are `Public = No`; no other module references them
- [ ] Public `_IS` actions have business names and return the team's own structure
- [ ] Own structures hold only the attributes the application uses; dates, numbers and Booleans have real types
- [ ] No raw response (external structure, JSON text, status code, `Success`/`ErrorMessage`) in a public output; external errors raise User Exceptions
- [ ] Endpoints and credentials in configuration, not in the flow

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
