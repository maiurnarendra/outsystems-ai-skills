# Timers: checkpoint entity, configuration and plan block

Reference for `outsystems-timers`. The rules are in [../SKILL.md](../SKILL.md).

## Suggested `TimerCheckpoint` entity

Use it only when the factory has no checkpoint / kill-switch entity under another name (ask first). Module: `TimerControl_CS`.

| Attribute | Type | Purpose |
|---|---|---|
| `Id` | Long Integer (auto-number) | |
| `TimerName` | Text (100), unique index | The timer's name |
| `LastProcessedId` | Long Integer | Last record fully processed; the next batch starts after it |
| `IsEnabled` | Boolean, default `True` | **Kill switch**: `False` stops the timer at its next check |
| `LastRunOn` | Date Time | Start of the last run |
| `LastRunStatus` | Static entity `TimerRunStatus` (`Running`, `Finished`, `WokeUp`, `Stopped`, `Failed`) | How the last run ended |
| `CreatedOn` / `CreatedBy` / `UpdatedOn` / `UpdatedBy` | | Standard log fields |

Written only through `TimerCheckpoint_CreateOrUpdate`, like every entity (see `outsystems-crud-conventions`). Timers read their row with an Aggregate (`GetTimerCheckpointByTimerName`).

## Configuration

| Property | Rule |
|---|---|
| **Schedule** | From the business need in the story. Heavy timers outside business hours. "When published" only for bootstrap timers. On-demand timers need no schedule |
| **Priority** | Raise it only when the timer competes with others on the same schedule and is more urgent |
| **Timeout** | Leave the default unless there is a reason; the time limit in the flow is derived from it (timeout minus 5 minutes) |
| **Service Center** | Record in the plan if the effective schedule must differ per environment |

## Plan block

When a story needs a timer, describe it in the plan before building, so the decision is approved like any other:

```
Timer: TimerSendInvoiceReminder (recurrent, daily 02:00, priority Normal)
Module: Billing_BL
Volume: grows with invoices → long-running pattern
  Batch 500 · checkpoint "SendInvoiceReminder" · kill switch · wake at 15 min · no-progress guard
Checkpoint entity: existing Job_CS.JobControl (adds IsEnabled)   |   or: new TimerControl_CS (confirmed by the user)
Calls: Billing_BL.SendReminder, Invoice_CS.Invoice_CreateOrUpdate
Bulk: none
Not a timer because: —
```
