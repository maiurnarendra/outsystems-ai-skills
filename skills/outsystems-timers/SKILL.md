---
name: outsystems-timers
description: Recognise when an OutSystems user story needs a timer ("every night", "send reminders", "import", "recalculate", "clean up old records", "backfill existing data", work too long for a user to wait), decide the kind, place it (_BL, _Eng, Timer Engine app, bulk _CS action) and design it - wake before the timeout, batches, commit per record, checkpoint and kill switch, no-progress guard, logging, schedule. Use when a story or bug involves scheduled, batch or long-running work, or when creating or reviewing a timer.
---

# OutSystems timers

A timer is a background job: it runs on a schedule or when woken, takes no inputs, and finds its work in the data. Decide **whether** a story needs one, **where** it goes and **what** it must have.

Flow diagrams: [reference/patterns.md](reference/patterns.md). Checkpoint entity, configuration and the plan block: [reference/setup.md](reference/setup.md). Layout follows `outsystems-action-flows`; bulk actions follow `outsystems-crud-conventions` and `outsystems-advanced-sql`.

## How the platform runs timers (O11)

- One queue ordered by **priority** and next run time; a few threads per front-end server (3 by default); the same timer never runs twice at once. Long runs block other timers.
- A run is aborted at its **timeout** (20 minutes by default, configurable per timer) and its open transaction is **rolled back**.
- After an error or a timeout the run is **re-queued up to 3 times**, then stops. The timer must be safe to re-run.
- Service Center can override the schedule ("Effective Schedule"); Service Studio changes need a publish.
- ODC: same ideas, its own limits. Derive the time limit from the configured timeout.

## 1. Recognise

| The story says | Answer |
|---|---|
| "Every day / night / hour", "on the 1st", "X days after …", "send reminders / reports" | **Recurrent** timer |
| "Import / sync / recalculate" many records, work too long to wait for | **On demand**: the screen saves a request and wakes the timer |
| "Clean up / archive / purge" old data | **Recurrent** timer calling a bulk `_CS` action |
| "Migrate / fix / backfill" existing data once | **One-off** timer in Timer Engine |
| "When a record is created or changes status, do X" for that record | **Not a timer**: the action that changes it, or a process (BPT / Light process in O11) if it must be asynchronous |
| A small, fast change triggered by a user | **Not a timer**: a normal server action |

Volume decides the design: if the story doesn't say how much data, ask or state the assumption in the plan.

## 2. Place it

| Kind | Module |
|---|---|
| Recurrent or on demand | The domain's **`_BL`** (default) |
| Recurrent, driving complex calculations or report generation | The domain's **`_Eng`** |
| One-off (migration, data fix, backfill) | **Timer Engine** app (module `TimerEngine`) |
| Same change on many rows | **`<Entity>_<Verb>All` in `_CS`** (one Advanced SQL node), called by the timer. No For Each |

**Timer Engine:** a single-module app for all of the factory's temporary timers. Nothing references it; it references only public `_BL`, `_CS` or `_Eng` actions. One timer per job. When the job is done and confirmed in every environment, delete the timer **and the references only it used**.

**Checkpoint and kill switch: reuse first.**
1. **Ask the user** whether the factory already has an entity for timer progress or a stop flag (timer configuration, batch or job control), and search the model (`getDataModel`) for `Timer…`, `Job…`, `Batch…` entities or attributes like `LastProcessedId`, `IsEnabled`.
2. **It exists** → use it; propose adding any missing attribute (often the kill switch or last run status) instead of a second entity.
3. **It doesn't** → suggest **`TimerControl_CS`** with a `TimerCheckpoint` entity ([reference/setup.md](reference/setup.md)) and wait for the go-ahead.

One entity serves every long-running timer. Below, `TimerCheckpoint` means that entity.

## 3. Design it by volume

| Volume | Design |
|---|---|
| Small and bounded (bootstrap, a few hundred rows) | Simple flow: fetch, process, log |
| Can grow with the data | **Long-running pattern**: every feature below |
| Same change on many rows | **Bulk pattern**: the timer loops over batches of a `_CS` bulk action |

| Feature | Rule |
|---|---|
| **Time limit** | First node `TimeLimit = AddMinutes(CurrDateTime(), 15)` (timeout minus 5 min). After each record: `HasTimeLeft` → continue; otherwise `Wake<TimerName>` and end |
| **Batches** | Max. Records 100–1,000, sorted by `Id`, `Id > LastProcessedId` (or a status that processing changes) |
| **Commit per record** | `CommitTransaction` after each record or small group |
| **Checkpoint** | `LastProcessedId` updated in the same transaction as the record, before the commit; a recurrent full scan resets it to 0 when done |
| **Kill switch** | `IsEnabled` read at the start and **before every batch**; `False` → log, `LastRunStatus = Stopped`, end |
| **No-progress guard** | A batch with no record processed successfully → log an error, `LastRunStatus = Failed`, end **without waking** |
| **Bad records** | Per-record handler: log with the Id, mark the record failed so the filter skips it, commit, continue |
| **Logging** | Start and end of each run: found, processed, failed, duration, how it ended |

Configure schedule (heavy timers outside business hours), priority and timeout: [reference/setup.md](reference/setup.md#configuration).

## 4. Naming and on demand

- Logic in a server action, verb + noun: `SendInvoiceReminder`. Timer: `Timer` + that name (`TimerSendInvoiceReminder`, woken with `WakeTimerSendInvoiceReminder`). `TimerCheckpoint.TimerName` = the action's name. The timer's action only calls the server action.
- On demand: the screen saves a request record (or sets a status), calls `Wake<TimerName>` and returns. The timer picks up pending requests. Never run long work inside the user's request.

## 5. In the plan

When a story needs a timer, add a "Timer" block to the plan (kind, schedule, module, volume, features, checkpoint entity, calls) before building: template in [reference/setup.md](reference/setup.md#plan-block).
