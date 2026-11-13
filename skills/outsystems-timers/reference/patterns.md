# Timers: flow patterns

Reference for `outsystems-timers`. The rules are in [../SKILL.md](../SKILL.md). Layout follows `outsystems-action-flows`: True down, False right, Cycle to the right, loop returns routed with `Dummy` Assigns.

## Long-running pattern

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

## Bulk pattern

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
