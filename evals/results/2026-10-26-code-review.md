# Live test: `outsystems-code-review` (2026-10-26)

First run of the code-review skill against a real OutSystems 11 Reactive `_CW` module, through the Service Studio MCP. Project, module, work item and people details are left out.

## Setup

- **Work item:** a user story read from the team's tracker through its MCP. It asks for a UI change to a multi-select list, with 6 acceptance criteria. A dev comment named the module to deploy; it did not name elements.
- **Scope:** one Reactive block (≈1,700 lines of Model API code: 2 data actions with Advanced SQL, 7 screen actions, 2 Data Grids). Proposed by the agent after listing the module's blocks, confirmed by the developer.
- **Tools used, read-only:** `createSessionToken`, `listApps`, `getActionNames`, `getWebBlockNames`, `getWebBlock` (`includeJson: "Never"`), `getValidationMessages`. No edit, merge or publish calls.

## Result

| Check | Result |
|---|---|
| Scope taken from the work item, not guessed; developer asked to confirm | ✅ |
| Read-only: no `applyModelApiCode` / `omlMerge` / `omlPublish` | ✅ |
| Spec table: one row per criterion with a verdict and node-level evidence | ✅ 1 Met, 1 Partly met, 4 Needs testing |
| Partly met backed by evidence (a later work item comment reopening part of the criterion) | ✅ |
| Standards findings grouped by severity with a fix each | ✅ 0 Critical, 5 Major, 8 Minor |
| Service Studio warnings in scope reported | ✅ |
| Verdict follows the rules (Partly met + Major → Needs changes) | ✅ |
| Real defect found | ✅ A selection-handling bug in the block's event logic, confirmed by comparison with a similar block |

## What the run taught us (skill changes to consider)

1. **No diff means old debt shows up.** Most Standards findings were older than the story. The report marked them *(pre-existing?)* by judgement. The skill should require that marker and keep story-related findings first.
2. **Library behaviour can't be judged from the model.** The feature came from a built-in Data Grid option, so 4 of 6 criteria could only be marked Needs testing. That is correct, but the report should then give the test steps. It did.
3. **Large elements exceed the tool output limit.** One block was 120–130 k characters. `includeJson: "Never"` (Model API code) was readable. The agent had to save the output and search it in chunks.
4. **The session token needs approval in Service Studio.** The first `createSessionToken` call waited 300 s and timed out, and the second call succeeded once approved. The skill should tell the user to watch for the approval dialog.
5. **Reference code is out of reach.** The parent block that handles the event was outside the scope, so the main defect is reported "to confirm". The skill should suggest reading the event's handler when a finding depends on it.
