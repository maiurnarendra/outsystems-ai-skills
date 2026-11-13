# Action flows: layout, labels and examples

Reference for `outsystems-action-flows`. The rules are in [../SKILL.md](../SKILL.md); this file shows them.

## Flow layout

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

## For Each

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

| Situation | Good condition (label) | Bad |
|---|---|---|
| List must have data | `GetStructure.List.Empty = False` (`Has structure?`) | `not GetStructure.List.Empty` |
| Record must exist | `GetStructureById.List.Empty = False` (`Has structure?`) | `not GetStructureById.List.Empty` |
| Flag must be set | `Structure.IsActive = True` (`Is structure active?`) | `not Structure.IsActive` |

With `GetStructure.List.Empty = False`, an empty list makes the condition False and the flow leaves to the right; data present continues down.

## If labels

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

## Node labels

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

## Boolean names

| Good | Bad |
|---|---|
| `IsToDelete` | `ToDelete`, `DeleteFlag`, `bDelete` |
| `HasValue` | `ValueExists`, `Valued` |
| `IsNew` | `New`, `NewRecord`, `isNew` |
| `IsEmpty` | `Empty`, `EmptyList` |

## Descriptions

Template for a public action's Description:

```
   Creates an order for the given customer and returns its Id.
   Pre: customer must be active.
   Raises: OrderValidationException when lines are empty.
   ```
