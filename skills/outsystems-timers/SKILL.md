---
name: outsystems-timers
description: Recognise when an OutSystems user story needs a timer (background or batch work - "every night", "send reminders", "import", "recalculate", "clean up old records", "backfill existing data", work too long for a user to wait), decide the kind (recurrent, on demand, one-off, or not a timer), place it (domain _BL or _Eng for recurrent timers, the Timer Engine app for one-off timers, bulk database work as an Advanced SQL action in _CS) and design it - time limit with Wake before the timeout, batches with Max. Records, commit per record, checkpoint and kill switch (an existing entity, or TimerControl_CS when there is none), no-progress guard, per-record error handling, logging, schedule, priority and timeout. Use when analysing a story or bug that involves scheduled, batch, asynchronous or long-running processing, or when creating or reviewing a timer.
---

# OutSystems timers

A timer is an asynchronous background job. It runs on a schedule or when woken by code, takes no inputs, and finds its work in the data. Use this skill to decide **whether** a story needs one, **where** it goes and **what** it must have.

Layout of the timer's flow follows `outsystems-action-flows`; bulk database actions follow `outsystems-crud-conventions` and `outsystems-advanced-sql`.

## How the platform runs timers (O11)

| Fact | Consequence |
|---|---|
| Timers wait in one queue, ordered by **priority** and next run time. Each front-end server runs a few at once (3 threads by default), and never the same timer twice at the same time | Long runs block other timers: keep each run short and set the priority |
| A run is aborted at its **timeout** (20 minutes by default, configurable per timer). The open transaction is **rolled back** | Commit as you go, and stop well before the timeout |
| After an error or a timeout the run is **re-queued, up to 3 times**, then it stops | The timer must be safe to run again: never repeat work, never stop on one bad record |
| Schedule, timeout and priority are set in Service Studio (a change needs a publish). Service Center can override the schedule ("Effective Schedule") | The schedule that runs may not be the one in the model; check Service Center before relying on it |
| Heavy timer work on entities that screens also use slows the app | Schedule heavy timers outside business hours |

ODC timers follow the same ideas with their own limits: derive the time limit from the configured timeout, and keep the pattern below.

## 1. Recognise: does the story need a timer?

| The story says | Likely answer |
|---|---|
| "Every day / night / hour", "on the 1st of the month", "X days after …" | **Recurrent** timer |
| "Send reminders / notifications / reports" automatically | **Recurrent** timer |
| "Import / sync / recalculate" many records, or work that takes longer than a user should wait | **On demand**: the screen saves a request and wakes the timer |
| "Clean up / archive / purge" old data | **Recurrent** timer calling a bulk `_CS` action |
| "Migrate / fix / backfill" existing data once | **One-off** timer in the Timer Engine app |
| "When a record is created or changes status, do X" for that one record | **Not a timer**: do it in the action that changes the record, or in a process (BPT / Light process in O11) when it must be asynchronous per record |
| A small, fast change triggered by a user | **Not a timer**: a normal server action |

When the story doesn't say how much data there is, ask, or state the assumption in the plan: volume decides the design.

## 2. Place it

| Kind | Module | Notes |
|---|---|---|
| Recurrent or on demand | The domain's **`_BL`** | The default |
| Recurrent, driving complex calculations or report generation | The domain's **`_Eng`** | Only when that heavy logic already lives in `_Eng` (see `outsystems-module-naming`) |
| One-off (migration, data fix, backfill) | **Timer Engine** app (module `TimerEngine`) | One app for all of the factory's temporary timers |
| Bulk change on the database | **`<Entity>_<Verb>All` in `_CS`**, one Advanced SQL node, called by the timer | e.g. `Invoice_UpdateStatusAll`. No For Each over records |

**Timer Engine rules**
- A single-module app. **Nothing references it**: it sits on top, like an End-user module.
- It references only public actions of `_BL`, `_CS` or `_Eng` modules. Never screens, blocks or other End-user modules.
- One timer per job, named for the job (`BackfillInvoiceDueDate`).
- When the job is done and confirmed in every environment, delete the timer **and the references it alone used**, so the app never keeps dependencies it no longer needs.

**Checkpoint and kill switch: reuse first, then suggest `TimerControl_CS`**

Long-running timers need somewhere to store their progress and a flag to stop them. Many factories already have this, under another name.

1. **Ask the user first**: "Do you already have an entity that stores timer progress or a flag to stop a timer (e.g. a timer configuration, batch control or job control entity)? What is it called and in which module?" Search the model too (`getDataModel` on the likely Core modules) for entities with names like `Timer…`, `Job…`, `Batch…` or attributes like `LastProcessedId`, `IsEnabled`.
2. **It exists** → use it. Map its attributes to the roles below. If a role is missing (most often the kill switch or the last run status), propose adding that attribute to the existing entity instead of creating a second one.
3. **It doesn't exist** → suggest creating **`TimerControl_CS`** (shared, Core) with the `TimerCheckpoint` entity below, and wait for the user's go-ahead before creating it.

Whichever entity is used, it serves **every** long-running timer, recurrent or one-off: one place to see progress and to stop any timer. In the rest of this skill, `TimerCheckpoint` means that entity.

Suggested `TimerCheckpoint` (when nothing exists):

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

## 3. Design it by volume

| Volume | Design |
|---|---|
| Small and bounded (a bootstrap of a few hundred rows, a daily e-mail to a handful of users) | Simple flow: fetch, process, log. No checkpoint or wake needed |
| Can grow with the data | **Long-running pattern** below, with every feature in the table |
| A set-based change (same update or delete for many rows) | **Bulk pattern** below: no loop over records |

### Key features of a long-running timer

| Feature | Rule |
|---|---|
| **Time limit** | First node: `TimeLimit = AddMinutes(CurrDateTime(), 15)` for the default 20-minute timeout (timeout minus 5 minutes). After each record: time left → continue; otherwise `Wake<TimerName>` and end |
| **Batches** | Fetch with **Max. Records** between 100 and 1,000, sorted by `Id`, filtered on `Id > LastProcessedId` (or on a status that processing changes) |
| **Commit per record** | `CommitTransaction` after each record (or each small group), so a retry never redoes work |
| **Checkpoint** | `TimerCheckpoint.LastProcessedId` updated in the **same transaction** as the record, before the commit. A recurrent scan over all records resets it to 0 when a run finishes |
| **Kill switch** | `TimerCheckpoint.IsEnabled` read at the start and **before every batch**. `False` → log "Stopped by kill switch", set `LastRunStatus = Stopped`, end |
| **No-progress guard** | If a batch processed no record successfully, log an error, set `LastRunStatus = Failed` and end **without waking**. This stops an infinite loop (a record that fails forever, a filter that keeps returning the same rows) without waiting for someone to use the kill switch |
| **One bad record doesn't stop the run** | Exception handler per record: log it with the record's Id, mark the record as failed (so the filter skips it), commit, continue. Otherwise the run fails, is retried 3 times on the same record and stops |
| **Logging** | `LogMessage` at the start and end of each run: records found, processed, failed, duration, and how it ended (`Finished`, `WokeUp`, `Stopped`, `Failed`) |
| **Built-ins first** | Inside the loop, follow `outsystems-action-flows`: no queries per record when one fetch can do it, no JavaScript |

### Long-running pattern

Laid out with the action-flow rules: True down, False right, Cycle to the right, loop returns routed with `Dummy` Assigns.

```
                     Start
                       │
             Assign "Set time limit"          TimeLimit = AddMinutes(CurrDateTime(), 15)
                       │
   ┌──► GetTimerCheckpointByTimerName
   │                   │
   │           ◇ IsEnabled ──False──► LogMessage "Stopped by kill switch" → End
   │                   │ True
   │      GetInvoiceToProcess                 Id > LastProcessedId, sort by Id, Max. Records 500
   │                   │
   │            ◇ HasData ──False──► LogMessage "Run finished" → End
   │                   │ True
   │               For Each ──Cycle──► Process invoice           (own exception handler: log, mark failed)
   │                   │                      │
   │                   │              Invoice_CreateOrUpdate
   │                   │                      │
   │                   │         TimerCheckpoint_CreateOrUpdate   LastProcessedId = Current.Id
   │                   │                      │
   │                   │              CommitTransaction
   │                   │                      │
   │                   │           ◇ HasTimeLeft ──False──► Wake<TimerName> → End
   │                   │                      │ True
   │                   │                    Dummy  (back to For Each, above the loop)
   │                   ▼
   │          ◇ HasProgress ──False──► LogMessage "No progress" → End
   │                   │ True
   └────────────── Dummy  (next batch)
```

`HasTimeLeft` is `CurrDateTime() < TimeLimit`, written so True is the expected path (no `not`).

### Bulk pattern

When every row gets the same change, the timer loops over **batches**, not records:

```
Start → Set time limit
  ┌──► GetTimerCheckpointByTimerName → ◇ IsEnabled ──False──► Log, End
  │        │ True
  │    Invoice_UpdateStatusAll (BatchSize = 1000)        one Advanced SQL node in Invoice_CS
  │        │
  │    CommitTransaction
  │        │
  │    GetInvoiceToUpdate (Max. Records 1) → ◇ HasData ──False──► Log "Run finished", End
  │        │ True
  │    ◇ HasTimeLeft ──False──► Wake<TimerName> → End
  │        │ True
  └──── Dummy
```

The SQL limits each statement to one batch: `UPDATE TOP (@BatchSize)` on SQL Server, `WHERE Id IN (SELECT Id … LIMIT @BatchSize)` on PostgreSQL (ODC). Format it per `outsystems-advanced-sql`.

## 4. Configure

| Property | Rule |
|---|---|
| **Schedule** | From the business need in the story. Heavy timers outside business hours. "When published" only for bootstrap timers. On-demand timers need no schedule |
| **Priority** | Raise it only when the timer competes with others on the same schedule and is more urgent |
| **Timeout** | Leave the default unless there is a reason; the time limit in the flow is derived from it (timeout minus 5 minutes) |
| **Service Center** | Record in the plan if the effective schedule must differ per environment |

## 5. Naming

| Element | Pattern | Example |
|---|---|---|
| Server action with the logic | Verb + noun, singular | `SendInvoiceReminder` |
| Timer | `Timer` + the action's name | `TimerSendInvoiceReminder` (its wake action: `WakeTimerSendInvoiceReminder`) |
| `TimerCheckpoint.TimerName` | The action's name | `"SendInvoiceReminder"` |
| One-off timers in Timer Engine | The job | `TimerBackfillInvoiceDueDate` |

The timer's action is thin: it calls the server action, so the logic can also be tested or run on demand.

## 6. On demand

Timers take no inputs. To start work from a screen:
1. The screen saves a request record (or sets a status) describing the work.
2. It calls `Wake<TimerName>` and returns at once.
3. The timer picks up pending requests and marks them done.

Never do long work inside the user's request "because it is only sometimes slow".

## 7. Put it in the plan

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

## Rules

- Decide the kind and the volume first; apply the long-running pattern only when volume can grow.
- Never let a run reach its timeout: time limit, commit per record, wake before the limit.
- Every long-running timer has a checkpoint row: checkpoint, kill switch, last run status. Ask whether the factory already has such an entity before suggesting `TimerControl_CS`; never create a second one.
- No-progress guard on every timer that wakes itself.
- Same change on many rows → `<Entity>_<Verb>All` in `_CS` with Advanced SQL, never a For Each.
- One-off timers live in Timer Engine and are deleted, with their references, once done.
- Nothing references Timer Engine; `_Eng` and `_BL` never reference it either.
