---
name: outsystems-action-flows
description: Standards for OutSystems action logic (Server, Client and Service Actions) - singular action names and Get actions in _BL, flow layout (top to bottom, True down, False right, For Each Cycle to the right, straight connectors, Dummy routing), If/Assign/Switch labels, Is/Has Booleans, built-in functions and list actions before loops and JavaScript, descriptions, comments and exceptions. Use when creating, editing or reviewing any OutSystems action logic.
---

# OutSystems action flows

Core rules. Diagrams, full label tables and examples are in [reference/layout.md](reference/layout.md); built-in function and JavaScript examples in [reference/builtins.md](reference/builtins.md). Open them when drawing a flow or when a rule below is unclear.

## Naming

- Actions: CamelCase verb + noun, **always singular**: `CalculateOrderTotal`, `GetStructure` (never `GetStructures`).
- UI event client actions: `<Widget><Event>` (`SaveButtonOnClick`). Boolean-returning actions start with `Is`/`Has`.
- CRUD wrappers follow `outsystems-crud-conventions`.

| Retrieves | Name |
|---|---|
| Records of an entity | `Get<Entity>` |
| One record by Id | `Get<Entity>ById` (input `<Entity>Id`) |
| Records by another input | `Get<Entity>By<Input>` |

Get actions live in the domain's **`_BL`**, never in `_CS` or `_CW`. Aggregates and SQL nodes use the same names.

## Flow layout

1. Top to bottom, left to right. Start at the top, Ends at the bottom; the happy path is one straight vertical line.
2. **If: True goes down, False goes right.** False is the exception path and ends in its own End or Raise Exception.
3. Only vertical and horizontal connectors: no diagonals, no crossings, nothing behind nodes. Route around logic with empty Assigns labelled **`Dummy`** at the corners.
4. **For Each: the Cycle connector leaves to the right**; the body runs top to bottom on the right and returns above the loop through `Dummy` corners; when the cycle ends the flow **continues down**.
5. At most ~20 nodes per flow and 3 nested Ifs; beyond that use a Switch or extract an action.
6. Guard clauses first, then the work.

## Conditions and labels

- Write conditions so **True is the expected path**. **Never `not`**: `GetStructure.List.Empty = False`, not `not GetStructure.List.Empty`.
- Label every If as a question (`Has structure?`) or a Boolean name (`HasStructure`, `IsToComplete`) describing what True means; one style per module.
- Switch: the subject (`Order status?`), each branch named by its case. Assign: what it sets (`Set totals`). Routing Assign: `Dummy`. Aggregate/SQL: `Get…` names. Exception handler: the exception's name.
- Never leave default labels (`If1`, `Assign1`, `Aggregate1`).

## Variables and parameters

- CamelCase; `<Entity>Id`, `<Entity>List`, `<Entity>`.
- **Booleans** (variables, inputs, outputs, attributes) start with `Is` or `Has`: `IsNew`, `HasValue`.
- No hard-coded environment values: Site Properties / Settings (ODC) or Static Entities.
- Inputs `Mandatory = Yes` unless there is a real default.

## Built-in functions first, JavaScript last

Pick the first option that does the job:
1. An expression with built-in functions (`If()`, `Substr`, `Trim`, `AddDays`, `Round`, `FormatDecimal`, `FormatDateTime`, `TextToInteger`, …).
2. A System list action: `ListAny`, `ListAll`, `ListIndexOf`, `ListFilter`, `ListSort`, `ListDistinct`, `ListAppendAll`, `ListRemove`.
3. The Aggregate itself: filters, sorts, calculated attributes, Group By, Max. Records.
4. Flow nodes.
5. A JavaScript node, only for what OutSystems can't do.

- **No For Each with an If inside only to search, check or filter a list**: `ListAny` / `ListAll` / `ListIndexOf` / `ListFilter`, or filter in the Aggregate. A For Each is for doing **work** on each item.
- One of two values → `If(condition, a, b)` in one Assign, not an If node with two Assigns. Many branches on one value → a Switch.
- **JavaScript nodes** only for the DOM, browser APIs or a third-party library (check OutSystems UI and Forge client actions first): one small job, inputs through `$parameters`, no business logic, never a rewrite of a built-in, and a comment saying why.
- Server and client actions don't offer the same built-ins: check the System module for the action type before falling back to a loop.

## Descriptions and comments

- Every public action, input and output has a **Description**: what it does, preconditions, exceptions raised (template in [reference/layout.md](reference/layout.md#descriptions)).
- Comment nodes explain **why**, in 1–3 lines; a summary comment on flows over ~10 nodes.
- No disconnected or commented-out nodes. Workarounds marked `TODO:` with a ticket reference.

## Exceptions

- Raise **User Exceptions** with business meaning (`StructureNotFoundException`), never `Success`/`ErrorMessage` outputs.
- Core handles infrastructure errors only where it adds context; business exceptions propagate.
- Screens have a global or screen handler with a friendly message and a log.
- Never swallow an exception: an empty handler at least logs. `Abort Transaction = Yes` when writes must roll back.

## Performance

- No Aggregate or SQL inside a For Each: fetch once, then use list actions.
- Max. Records on Aggregates that feed the UI.
- One server action per client interaction instead of several server calls.
