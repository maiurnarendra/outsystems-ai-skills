# Built-in functions first, JavaScript last: examples

Reference for `outsystems-action-flows`. The rules are in [../SKILL.md](../SKILL.md#built-in-functions-first-javascript-last).

Write logic in OutSystems, not around it. Pick the first option that does the job:

| # | Use | Examples |
|---|---|---|
| 1 | **An expression with built-in functions** | Text: `Substr`, `Index`, `Replace`, `Trim`, `ToUpper`, `Length`. Date: `AddDays`, `DiffDays`, `NewDate`, `Year`. Math: `Round`, `Trunc`, `Max`, `Min`, `Mod`. Format and conversion: `FormatDecimal`, `FormatDateTime`, `TextToInteger`, `IntegerToText`. Conditional value: `If(condition, a, b)` |
| 2 | **A System list action** | `ListAny`, `ListAll`, `ListIndexOf`, `ListFilter`, `ListSort`, `ListDistinct`, `ListAppendAll`, `ListRemove`, `ListClear` |
| 3 | **The Aggregate itself** | Filters, sorts, calculated attributes, Group By, Max. Records: let the database do it |
| 4 | **Flow nodes** | Assign, If, Switch, For Each, laid out as above |
| 5 | **A JavaScript node** | Only when OutSystems has no way to do it (see below) |

Server and client actions don't offer exactly the same functions and list actions. Check what the System module offers for the action type before falling back to a loop or to JavaScript.

## No loop with an If to search, filter or check a list

A For Each with an If inside that sets a flag, an index or appends to a new list is a hand-written list action. Use the built-in:

| Need | Bad | Good |
|---|---|---|
| Is any item X? | For Each → If → Assign `IsFound = True` | `ListAny(OrderList, OrderList.Current.IsUrgent = True)` |
| Are all items X? | For Each → If → Assign `IsValid = False` | `ListAll(LineList, LineList.Current.Quantity > 0)` |
| Where is item X? | For Each → If → Assign `Index = …` | `ListIndexOf(UserList, UserList.Current.Id = UserId)` |
| Keep only items X | For Each → If → ListAppend to a new list | `ListFilter`, or filter in the Aggregate |
| Records from the database that match X | Fetch all, then loop and filter | Filter in the Aggregate |
| One of two values | If node → two Assigns | One Assign with `If(IsUrgent, "High", "Normal")` |
| Many branches on the same value | Chain of Ifs testing the same variable | One Switch |

A For Each is right when every item needs **work** (create a record, call an action, build an output). Not when it only needs a **question answered**.

## JavaScript nodes: the exception

Use a JavaScript node only for what OutSystems can't do: the browser or the DOM (focus, scroll, clipboard, local device APIs), or a third-party library. Before writing one, check the OutSystems UI and Forge client actions: many of these already exist.

When you do:
- **One small job per node.** Inputs through `$parameters`, results through output parameters.
- **No business logic, no data shaping, no validation that matters.** Calculations, string and date handling, list operations and decisions belong in the flow, where they are visible, debuggable and reusable.
- **Never rewrite a built-in in JavaScript** (formatting a date, rounding, trimming, searching a list).
- A comment on the node says **why** OutSystems couldn't do it.

| Bad | Good |
|---|---|
| A 60-line JavaScript node that loops the list, formats dates, totals amounts and decides which button to show | `ListFilter` + Assigns with `FormatDateTime` and `Round` + an If labelled `IsApprover`; JavaScript only for `element.focus()` |
| JavaScript `toFixed(2)` on a total | `FormatDecimal(Total, 2, ".", ",")` in the expression |
