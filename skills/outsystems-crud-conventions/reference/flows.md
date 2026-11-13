# Entities and CRUD: flows and SQL

Reference for `outsystems-crud-conventions`. The rules are in [../SKILL.md](../SKILL.md).

## `_CreateOrUpdate` flow

The wrapper does **not** call the built-in `CreateOrUpdate<Entity>`. It has two branches so creation and update set their log fields correctly:

```
Start
  │
Validate Source            (raise <Entity>ValidationException on failure)
  │
If  "Is existing record?"  Source.Id <> NullIdentifier()
  ├── True  (update) ─────────────────────────────┐
  │     Assign "Set update log fields"            │
  │       Source.UpdatedOn = CurrDateTime()       │
  │       Source.UpdatedBy = GetUserId()          │
  │     Update<Entity>(Source)                    │
  │     Assign Id = Source.Id                     │
  │     End                                       │
  └── False (create)                              │
        Assign "Set create log fields"            │
          Source.CreatedOn = CurrDateTime()       │
          Source.CreatedBy = GetUserId()          │
          Source.UpdatedOn = CurrDateTime()       │
          Source.UpdatedBy = GetUserId()          │
        Create<Entity>(Source)                    │
        Assign Id = Create<Entity>.Id             │
        End                                       │
```

## `_DeleteAll` (bulk delete)

Create it only when a process needs to empty the table (sync reloads, test data, purges). It uses **one Advanced SQL node**, never a For Each over `Delete<Entity>`:

```sql
/* DeleteAllCustomer
   Deletes every Customer record in a single statement.
   Params: none */
DELETE FROM
	{Customer}
```

- Action `<Entity>_DeleteAll`, SQL node `DeleteAll<Entity>`, header comment, formatting per `outsystems-advanced-sql`.
- A filtered bulk delete adds a `WHERE` clause with parameters and keeps the same names (`Customer_DeleteAll` with a `CountryId` input, for example).

## Specific update and delete actions

| Action | Does | Implementation |
|---|---|---|
| `Invoice_UpdateStatus` | Changes one invoice's status (inputs `Id`, `InvoiceStatusId`) | `Get<Entity>ForUpdate` + `Update<Entity>`, update log fields set |
| `Invoice_UpdateStatusAll` | Changes the status of every invoice that matches (inputs: filter, new status, `BatchSize`) | **One Advanced SQL node**, never a For Each |
| `Invoice_DeleteAll` | Deletes every invoice, or every one that matches | One Advanced SQL node |
