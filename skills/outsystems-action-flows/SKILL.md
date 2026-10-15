---
name: outsystems-action-flows
description: Standards for OutSystems action flows (Server, Client and Service Actions) - action naming (singular, GetStructure / GetStructureById), flow layout top to bottom and left to right, If branches (True down, False right, no "not"), For Each cycles (Cycle connector to the right, exit down), Boolean names starting with Is/Has, no diagonal or crossing connectors, Dummy assigns for routing, Assign and Switch labels, variables, exception handling, and required comments and descriptions. Use when creating, editing or reviewing any OutSystems action logic.
---

# OutSystems action flows

## Action naming

1. **CamelCase, verb + noun, always singular**: `CalculateOrderTotal`, `SendWelcomeEmail`, `ValidateStructure`. Never plural: `GetStructure`, not `GetStructures`.
2. Avoid vague verbs: `Process`, `Handle`, `Do`, `Manage` must be followed by a precise noun or replaced.
3. Client actions that react to UI events: `<Widget><Event>` e.g. `SaveButtonOnClick`, `CountryDropdownOnChange`.
4. Boolean-returning actions start with `Is` or `Has`: `IsCustomerActive`, `HasOpenInvoice`.
5. CRUD wrappers (`<Entity>_CreateOrUpdate`, `<Entity>_Delete`) follow `outsystems-crud-conventions`.

### Get actions (reading from the database)

| Retrieves | Name | Example |
|---|---|---|
| Records of an entity (list, optional filters) | `Get<Entity>` | `GetStructure` |
| One record by its identifier | `Get<Entity>ById` | `GetStructureById` (input `StructureId`) |
| Records by one other input | `Get<Entity>By<Input>` | `GetStructureByCode`, `GetStructureByParentId` |

- The entity part is **singular**, even when the action returns a list.
- Get actions live in the **`_BL`** module of the domain. Not in `_CS` (which only holds entities and their `_CreateOrUpdate` / `_Delete` / `_DeleteAll` wrappers) and not in `_CW` (which holds widgets). See `outsystems-module-naming`.
- Aggregates and SQL nodes inside a flow follow the same pattern: `GetStructureById`, `GetStructureByParentId`.

## Flow layout

The flow reads **top to bottom and left to right**.

1. Start at the top, End(s) at the bottom. The happy path is one **straight vertical line**.
2. **If branches: True goes down, False goes right.** The False branch is the exception/error path and ends in its own End or Raise Exception node on the right.
3. **Only vertical and horizontal connectors.** No diagonal lines. Align nodes on the same column/row so connectors are straight.
4. **Connectors never cross other connectors or pass behind nodes.**
5. When a connector has to go around existing logic (for example, returning to a For Each to close a cycle), route it with **Dummy Assign nodes** (empty Assigns labelled `Dummy`) placed at the corners, so every segment stays straight and nothing crosses.
6. **Maximum ~20 nodes per flow.** Beyond that, extract a well-named action. A flow must fit on one screen.
7. Maximum **3 levels of nested Ifs**. Deeper → use a Switch, or extract an action.
8. Validate inputs first ("guard clauses"), then do the work.

```
          Start
            │
     GetStructureById
            │
    ◇ Has structure? ──False──► Raise StructureNotFoundException
            │ True
    ◇ Is structure active? ──False──► Raise StructureInactiveException
            │ True
     Assign "Set totals"
            │
           End
```

## For Each cycles

1. The **Cycle connector always leaves the For Each to the right**. Never up, never down, never diagonal.
2. The loop body is laid out on the right, top to bottom, and returns to the For Each with straight connectors, using `Dummy` Assigns at the corners.
3. When the cycle finishes, the flow **continues down** from the For Each.

```
     GetStructure
          │     Dummy ◄─────────────────────────── Dummy
          │       │                                  ▲
          ▼       ▼                                  │
       For Each ──Cycle──► Assign "Set total"        │
          │                        │                 │
          │              StructureLine_CreateOrUpdate│
          │                        │                 │
          │                      Dummy ──────────────┘
          ▼
         End
```

The return path goes right, up and back left **above** the loop, then down into the For Each, so it never crosses the Cycle connector or the exit line.

## If conditions

- **Write conditions so that True is the expected path** and the error goes right as False.
- **Never use `not`** in an If condition. Compare explicitly instead:

| Situation | Good condition (label) | Bad |
|---|---|---|
| List must have data | `GetStructure.List.Empty = False` (`Has structure?`) | `not GetStructure.List.Empty` |
| Record must exist | `GetStructureById.List.Empty = False` (`Has structure?`) | `not GetStructureById.List.Empty` |
| Flag must be set | `Structure.IsActive = True` (`Is structure active?`) | `not Structure.IsActive` |

With `GetStructure.List.Empty = False`, an empty list makes the condition False and the flow leaves to the right; data present continues down.

### If labels

An If node is labelled in one of two ways:

1. **As a question** ending in `?`: `Has structure?`, `Is order approved?`
2. **As a Boolean name**, exactly like a Boolean variable: CamelCase starting with `Is` or `Has`: `IsToComplete`, `HasValue`, `IsEmpty`, `HasStructure`.

Either way, the label describes what **True** means, and the True branch goes down. Pick the label that matches the condition:

| Condition | True means | Label |
|---|---|---|
| `GetStructure.List.Empty = False` | there is data | `HasStructure` or `Has structure?` |
| `Structure.IsCompleted = False` | still to complete | `IsToComplete` |
| `GetStructure.List.Empty = True` | list is empty (only when empty is the expected path) | `IsEmpty` |

Use one style consistently within a module.

## Node labels (mandatory)

Every node must be labelled so the flow reads without opening properties.

| Node | Label rule | Good | Bad |
|---|---|---|---|
| **If** | Either a yes/no question ending in `?`, or a Boolean-style name like a Boolean variable (`Is`/`Has` + CamelCase). See [If labels](#if-labels). | `Has structure?`, `Is order approved?`, `HasStructure`, `IsToComplete`, `HasValue` | `If`, `If1`, `Check`, `Structure` |
| **Switch** | The subject being switched on; each branch label is the case | `Order status?` → `Draft`, `Submitted`, `Otherwise` | `Switch1` |
| **Assign** | What is being set | `Set totals`, `Map structure to output` | `Assign1` |
| **Dummy Assign** | `Dummy` (used only for connector routing) | `Dummy` | `Assign5` |
| **Aggregate / SQL** | `Get<Entity>`, `Get<Entity>ById`, `Get<Entity>By<Input>` (singular) | `GetOrderByCustomerId` | `GetOrders2`, `GetOrdersByCustomer` |
| **For Each** | Leave default but iterate a well-named list; Cycle connector to the right | — | — |
| **Exception Handler** | Name of the handled exception | `DatabaseException` | — |

## Variables and parameters

- CamelCase: `OrderTotal`, `CustomerId`. No Hungarian prefixes (`strName`, `iCount`).
- Identifiers: `<Entity>Id`. Lists: `<Entity>List`. Records: `<Entity>`.
- **Booleans** (variables, inputs, outputs, attributes) are CamelCase and **always start with `Is` or `Has`**: `IsNew`, `IsEmpty`, `IsToDelete`, `HasValue`, `HasError`.

| Good | Bad |
|---|---|
| `IsToDelete` | `ToDelete`, `DeleteFlag`, `bDelete` |
| `HasValue` | `ValueExists`, `Valued` |
| `IsNew` | `New`, `NewRecord`, `isNew` |
| `IsEmpty` | `Empty`, `EmptyList` |
- Never hard-code environment values: use Site Properties / Settings (ODC) or Static Entities.
- Mark inputs **Mandatory = Yes** unless there is a real default.

## Comments and descriptions (mandatory)

1. **Every public action, input and output has a Description.** The action description states *what* it does, *preconditions*, and *exceptions raised*. Template:
   ```
   Creates an order for the given customer and returns its Id.
   Pre: customer must be active.
   Raises: OrderValidationException when lines are empty.
   ```
2. Add a **Comment node** next to any non-obvious logic explaining *why*, not *what*. Keep it to 1–3 lines.
3. Add a comment at the top of flows longer than ~10 nodes summarising the steps.
4. **No commented-out / disconnected nodes** left in the flow. Use version control (Service Studio history / ODC revisions) instead.
5. Mark temporary workarounds with `TODO:` + ticket reference, e.g. `TODO: JIRA-123 remove after SAP fix`.

## Exception handling

- Raise **User Exceptions** with business meaning (`StructureNotFoundException`) instead of generic ones.
- Server/Service Actions in Core handle infrastructure errors only where they can add context; let business exceptions propagate.
- End-user screens have a global or screen-level handler that shows a friendly message and logs details.
- Never swallow an exception silently: an empty handler must at least log.
- Use **Abort Transaction = Yes** in handlers that must roll back writes.

## Performance reminders

- No Aggregates or SQL inside a For Each over large lists. Fetch once, then join/filter.
- Fetch only needed attributes; set Max. Records on Aggregates feeding UI.
- Server calls from Client Actions are expensive: batch them into one server action.
