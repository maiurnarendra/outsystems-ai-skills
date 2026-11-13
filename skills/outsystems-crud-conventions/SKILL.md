---
name: outsystems-crud-conventions
description: OutSystems entities and _CS actions - entity and attribute naming (CamelCase, singular, A_B only for many-to-many, Is/Has Booleans), Public and Expose Read Only, static entities, <Entity>_CreateOrUpdate (Source/Id) and <Entity>_Delete wrappers, and specific or bulk actions such as <Entity>_UpdateStatusAll. Use when creating or renaming entities or attributes, or writing actions in a _CS module.
---

# OutSystems entities and CRUD

Core rules. Good/bad naming tables are in [reference/examples.md](reference/examples.md); the `_CreateOrUpdate` flow, `_DeleteAll` SQL and specific-action examples in [reference/flows.md](reference/flows.md).

## Entity naming

- **CamelCase, starting uppercase, singular**: `Customer`, `CustomerAddress`, `OrderLine`. No plurals, abbreviations or technical prefixes (`Customers`, `tbl_Customer`, `Cust`).
- **Many-to-many** entities join both names with `_`: `User_Role`, `Product_Category`.
- **`_` means many-to-many only.** Never project prefixes like `Sales_Customer`: it reads as a junction between `Sales` and `Customer`. The module already says which project it belongs to.

## Default properties

Every entity, regular or static: **`Public = Yes`**, **`Expose Read Only = Yes`**. Other modules write only through the `_CS` actions, never through the built-in entity actions.

## Static entities

1. In a folder named **`Static`** in the `_CS` Data tab.
2. `Id` with **`Is AutoNumber = No`**, so Ids are stable across environments.
3. `Public = Yes`, `Expose Read Only = Yes`.
4. Records in CamelCase (`Draft`, `Submitted`), referenced by record (`Entities.OrderStatus.Draft`), never by hard-coded Id.
5. No `_CreateOrUpdate` / `_Delete` wrappers: records are defined at design time.
6. The active flag is **`IsActive`**. Service Studio creates `Is_Active`: rename it right away; reviews report existing `Is_Active`.

## `_CS` actions

All writes go through public actions in the entity's `_CS`, named `<Entity>_<Operation>`:

| Action | Input | Output |
|---|---|---|
| `Customer_CreateOrUpdate` | `Source` (record of `Customer`, mandatory) | `Id` (`Customer Identifier`) |
| `Customer_Delete` | `Id` (`Customer Identifier`, mandatory) | *(none)* |

- Many-to-many keeps the full name: `User_Role_CreateOrUpdate`, `User_Role_Delete`.
- **No separate `_Create` / `_Update` wrappers.** The record input is always `Source`, the identifier input always `Id`.
- Wrappers are `Public = Yes`; no `Success` / `ErrorMessage` outputs (raise a User Exception, see `outsystems-action-flows`); every input and output has a Description.
- No business process logic: orchestration across entities belongs in `_BL`. Get actions belong in `_BL` too.

**Specific update and delete actions** may sit in the same `_CS` when a process needs a narrower or bulk change: `Invoice_UpdateStatus`, `Invoice_UpdateStatusAll`, `Invoice_DeleteAll`.
- Named `<Entity>_<Verb><What>`, with `All` at the end when it changes many rows.
- A bulk action is **one Advanced SQL node**, never a For Each; it sets `UpdatedOn` / `UpdatedBy` in the same statement and takes a `BatchSize` input when a timer runs it in batches (see `outsystems-timers`).
- `_DeleteAll` only when a process must empty the table (sync reloads, purges); SQL node `DeleteAll<Entity>` with a header comment, per `outsystems-advanced-sql`.

## `_CreateOrUpdate` flow

Diagram in [reference/flows.md](reference/flows.md#_createorupdate-flow).

- Validate `Source` first (raise `<Entity>ValidationException`).
- Do **not** call the built-in `CreateOrUpdate<Entity>`: branch on `Source.Id <> NullIdentifier()` in an If labelled `Is existing record?`.
- **Update** branch: set `UpdatedOn = CurrDateTime()`, `UpdatedBy = GetUserId()`, call `Update<Entity>`. Keep the original `CreatedOn` / `CreatedBy`: if `Source` may not carry them, read the record with `Get<Entity>ForUpdate` and copy them across.
- **Create** branch: set `CreatedOn` / `CreatedBy` **and** `UpdatedOn` / `UpdatedBy` (same values), call `Create<Entity>`.
- `Get<Entity>ForUpdate` output is reached through the entity name: `GetCustomerForUpdate.Record.Customer.CreatedOn`, not `GetCustomerForUpdate.Record.CreatedOn` (Service Studio reports "Can't identify 'CreatedOn' element").
- Callers never set log fields; both branches return `Id`.

## Attributes

| Attribute | Type | Notes |
|---|---|---|
| `Id` | Long Integer (auto-number) | Default identifier |
| `IsActive` | Boolean | Default `True` |
| `CreatedOn` / `UpdatedOn` | Date Time | Set by the wrapper; both filled on create |
| `CreatedBy` / `UpdatedBy` | User Identifier | Set by the wrapper; both filled on create |

- CamelCase and singular (`PhoneNumber`, `Tag`); a list of values is its own entity.
- Booleans start with `Is` / `Has`; foreign keys are `<ReferencedEntity>Id`.
- No abbreviations, underscores or entity-name prefix (`Name`, not `CustomerName` inside `Customer`).
- Index every foreign key and every attribute used in frequent filters.
