# Code review: collecting the code

Reference for `outsystems-code-review`, step 2. The rules are in [../SKILL.md](../SKILL.md).

For every element in scope, read it once and keep the result for both axes:

| Element | Tool |
|---|---|
| Server / service action | `getServerAction` / `getServiceAction` (`includeJson: "Always"`) |
| Client action | `getClientAction` |
| Screen / block | `getScreen` / `getWebBlock` (Reactive), `getScreenTraditional` / `getWebBlockTraditional` |
| Entities, static entities, attributes | `getDataModel` |
| Structures | `getStructures` |
| Module references | `runQuery` on the module (never `omlRefreshReferences`: it changes the model) |

**Large elements.** A Reactive block or screen can be well over 100,000 characters. Prefer `includeJson: "Never"` (Model API code, easier to search). If the tool output is too large and saved to a file, search it for the element names in scope and read those parts in full; never judge a flow you only saw partly. List anything you could not read under "Not reviewed".

**Follow the event.** When a finding depends on code outside the scope (the parent that handles a block's event, the action that calls the one under review), say so and offer to read that element too, read-only, before calling it a defect.

Also call `getValidationMessages` for each module in scope with `filter: ["error", "warning"]`. Service Studio's own errors and warnings are findings too.

SQL nodes are inside the action JSON: review the statement text against `outsystems-advanced-sql`.

## Checks only visible in the live model

Things only visible in the live model, worth checking explicitly:
- node coordinates: True branch below the If, False branch to the right, For Each Cycle to the right, no connector going up-left except loop returns;
- default labels left behind (`If1`, `Assign1`, `Aggregate1`);
- entity properties: `Public`, `Expose Read Only`, static entity `Is AutoNumber`, folder;
- module references that point upward or sideways.
