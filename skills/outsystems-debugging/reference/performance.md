# Performance

**Measure first, change one thing, measure again.** Every performance report gives a number before and after.

## Where to measure

| Question | Where |
|---|---|
| Which screen or action is slow, and how slow? | Browser DevTools › Network (duration of each server call) and Performance; Service Center Monitoring reports (O11) or ODC traces |
| Which query is slow? | General log entries for slow queries and slow extension calls; the query's **Test** button and the Executed SQL tab in Service Studio |
| Is an external call slow? | Integrations log: duration per call |
| Is a timer slow? | General log: start, end and row counts per run; Environment Health |
| Is the page heavy? | Network tab: payload size of each request, number of requests on load |

## Known causes

| Pattern | Symptom | Check | Fix |
|---|---|---|---|
| **Query inside a loop**: Aggregate, SQL or a Get action in a For Each | Time grows with the number of rows | Nodes inside For Each loops | Fetch once with a join or `IN`, then match in memory (see `outsystems-action-flows`) |
| **Missing index** on a filter, join or sort | One query is slow, gets worse as the table grows | The query's filters and joins vs the entity's indexes; execution plan with the DBA | Add the index (see `outsystems-data-model` 2.7) |
| **No row limit** on a list feeding the UI | Slow load, large payload | Max. Records / `TOP` / pagination | Set Max. Records, paginate (`StartIndex`), server-side pagination for grids |
| **Too much data fetched**: unused attributes in SQL, a Binary Data attribute read with the record | Large payload, slow query | `SELECT` list vs what the screen uses; binary attributes on the entity | Select only used columns; keep binaries in their own entity |
| **Expand Inline** parameters | Query recompiles on every call, plan cache unused | Parameters with Expand Inline = Yes | Use normal parameters where possible; `BuildSafe_InClause*` only for `IN` lists |
| **Several server calls from one client action** | Many sequential requests in the Network tab; Service Studio warning *ConsecutiveServerInteractions* | The client action's flow | One server action that does all the work |
| **Refresh storms** in Reactive: aggregates/data actions refreshed in OnParametersChanged, on every change, or in loops | The same request repeated many times | Network tab: repeated identical requests | Refresh only when the relevant input changed; Fetch = Only on demand where it fits |
| **Everything fetched At Start** | Slow first paint | Data sources with Fetch = At start that the user may never see | Fetch on demand (tabs, popups, expandable areas) |
| **Large lists rendered at once** | Browser freezes, long tasks in the Performance tab | Rows rendered vs rows visible | Pagination or virtualised grid (OutSystems Data Grid) |
| **Timer processes everything in one run** | Timer timeouts, long locks, deadlocks with screens | Rows per run, run duration | Batches (e.g. 500–1,000 rows), `CommitTransaction` per batch, `WakeTimer` to continue, a time budget per run |
| **External call on every request** | Each screen load waits for the external system | Integrations log frequency and duration | Cache (`Cache in Minutes` on the `_IS` action) where data allows; call once per screen |
| **Heavy session or viewstate** (Traditional Web) | Every request is slow and large | Session variables holding lists or records | Keep Ids in session, not records or lists |

## Fix checklist

- One change at a time, measured.
- Check the fix with production-like data volume in Development or Test, not with ten rows.
- A longer timeout is not a fix; it is a decision to wait longer. Record why, if it is ever used.
