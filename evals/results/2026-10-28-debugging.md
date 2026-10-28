# Live test: `outsystems-debugging` (2026-10-28)

First run of the debugging skill on a real bug in an OutSystems 11 **mobile** app, read through the Service Studio MCP. Project, module, work item and people details are left out.

## Setup

- **Bug:** a work item from the team's tracker. Two user actions (choosing an item in a setup step, and disconnecting a paired device) don't appear in the app's user-action log. There is no error message.
- **Modules:** three mobile modules (App, `_MBL`, `_MCW`). Two shared blocks of about 5,400 and 2,500 lines of Model API code, plus one screen.
- **Tools used, read-only:** `listApps`, `getActionNames`, `getScreenNames`, `getWebBlockNames`, `getWebBlock` / `getScreen` / `getClientAction` (`includeJson: "Never"`). No edit, merge or publish calls.

## Result

| Check | Result |
|---|---|
| Symptom captured before any theory; track chosen (runtime, missing data, no error) | ✅ |
| Asked for the modules instead of guessing | ✅ The modules were closed at first |
| Evidence from the model: every flow involved was found and read | ✅ 8 flows traced |
| One hypothesis at a time, each confirmed or revised by the evidence | ✅ "Disconnects are never logged" was **disproved**: one path does log. It was narrowed to "3 of 4 disconnect paths don't log" |
| Root cause tied to module › element › node | ✅ Selection handler has no log call; three disconnect paths without logging |
| Found a related defect in passing | ✅ A log node with no connectors, so it never runs |
| Open hypothesis kept open, with a check | ✅ Client-side logging might only reach the server after sync; check by reading the logger module, or test after a sync |
| Fix proposed following the standards, not applied | ✅ 6 changes; nothing changed in the model |
| Check and risk sections | ✅ Steps per path; shared-block impact |

## What the run taught us (skill changes to consider)

1. **"Missing behaviour" bugs need a coverage table.** With no error to follow, the useful output was a table of every path that should log, and whether it does. The skill could name this technique for missing-data bugs.
2. **Search the model for disconnected nodes.** A node with no incoming connector never runs. That's easy to miss when reading flows top-down and worth checking explicitly.
3. **Hypotheses got disproved, and that was valuable.** The first theory ("disconnects are never logged") was wrong for one path. Reading every path before concluding avoided a wrong fix.
4. **Two logging mechanisms (client and server) are a hypothesis in themselves.** Mobile apps often log locally and sync later. The skill's runtime catalogue could add "logs missing on mobile: check whether logging is local until sync".
5. **Some evidence lives in modules that aren't open** (the logger module, the device SDK). The report lists them as open checks instead of guessing.
