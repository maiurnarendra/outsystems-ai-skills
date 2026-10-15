---
name: outsystems-crud-conventions
description: OutSystems entity and attribute naming (CamelCase, singular, many-to-many with underscore, Is/Has Booleans), default entity properties (Public, Expose Read Only), static entity rules (Static folder, Is AutoNumber = No) and CRUD wrapper conventions (<Entity>_CreateOrUpdate, <Entity>_Delete) with their Source/Id inputs. Use when creating or renaming entities, writing CRUD wrapper actions in Core Services (_CS) modules, or naming action inputs and outputs that carry entity data.
---

# OutSystems entities and CRUD

## Entity naming

1. Entities are always named in **CamelCase** starting with a capital letter, singular: `Customer`, `CustomerAddress`, `OrderLine`.
2. **Many-to-many** (junction) entities join the two entity names, each in CamelCase, separated by `_`: `User_Role`, `Product_Category`, `Customer_Segment`.
3. Never plural, never technical prefixes or abbreviations: `Customers`, `tbl_Customer`, `Cust`, `customer` are all wrong.
4. **No project/app prefixes with `_`** (`Sales_Customer`). The underscore must only ever mean many-to-many, so anyone reading `Sales_Customer` would wrongly assume a junction between `Sales` and `Customer`. The module already tells you which project the entity belongs to.
5. Static entities follow the same naming rule (`OrderStatus`); see [Static entities](#static-entities).

## Default entity properties

Every entity, regular or static, is created with:

| Property | Value |
|---|---|
| **Public** | `Yes` |
| **Expose Read Only** | `Yes` |

Writes from other modules go through the `_CS` wrappers, never through the built-in entity actions.

## Static entities

1. **Folder:** in a `_CS` module, static entities are always placed in a folder named **`Static`** in the Data tab.
2. **Identifier:** the `Id` attribute has **Is AutoNumber = No**. Ids are fixed values, so they are stable across environments.
3. **Public = Yes** and **Expose Read Only = Yes**, like every entity.
4. Records are CamelCase (`Draft`, `Submitted`) and are referenced by record (`Entities.OrderStatus.Draft`), never by hard-coded Id.
5. Static entities have no `_CreateOrUpdate` / `_Delete` wrappers: their records are defined at design time.
6. **The active flag is `IsActive`**, like every other Boolean attribute. Service Studio creates new static entities with the default attribute `Is_Active`; rename it to `IsActive` right after creating the entity. Existing static entities with `Is_Active` are reported by reviews and renamed when the module is next refactored.

| Good | Bad | Why |
|---|---|---|
| `CustomerAddress` | `Customer_Address`, `customerAddress` | `_` is reserved for many-to-many; must start uppercase |
| `User_Role` | `UserRole`, `UserRoles` | Junction entity needs the separator; singular |
| `Product_Category` | `ProdCat` | No abbreviations |
| `Customer`, `CustomerAddress` | `Sales_Customer`, `Sales_CustomerAddress` | Prefix + `_` reads as many-to-many but isn't |

## CRUD wrapper actions

Entities are `Public = Yes` and exposed **read-only** from `_CS` modules. All writes go through public wrapper actions in the same `_CS`, so validation and audit logic live in one place.

Every entity has these two wrappers, plus an optional bulk delete, named `<EntityName>_<Operation>`:

| Action | Wraps | Input | Output |
|---|---|---|---|
| `Customer_CreateOrUpdate` | `CreateCustomer` / `UpdateCustomer` | `Source` (record of `Customer`, mandatory) | `Id` (`Customer Identifier`) |
| `Customer_Delete` | `DeleteCustomer` | `Id` (`Customer Identifier`, mandatory) | *(none)* |
| `Customer_DeleteAll` *(optional)* | Advanced SQL bulk delete | *(none)* | *(none)* |

For a many-to-many entity the full entity name is kept: `User_Role_CreateOrUpdate`, `User_Role_Delete`, `User_Role_DeleteAll`.

These are the **only** actions in a `_CS` module. Get actions (`GetCustomer`, `GetCustomerById`) belong in the `_BL` module (see `outsystems-action-flows`).

### `_DeleteAll` (bulk delete)

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

Rules:
- Do **not** create separate `_Create` / `_Update` wrappers; `_CreateOrUpdate` covers both.
- The record input is always named **`Source`**. The identifier input is always named **`Id`**. Their data type makes the entity explicit, and every wrapper reads the same way.
- Wrappers are `Public = Yes`; the built-in entity actions stay internal because the entity is read-only.
- Never return `Success`/`ErrorMessage` output pairs. Raise a User Exception on failure (see `outsystems-action-flows`).
- Every input and output has a Description.

## `_CreateOrUpdate` flow

The wrapper does **not** call the built-in `CreateOrUpdate<Entity>`. It has two separate branches so creation and update can set their log fields correctly:

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

Rules:
- The check is always `Source.Id <> NullIdentifier()`, in an If labelled `Is existing record?`.
- **On creation, `UpdatedOn` / `UpdatedBy` are set too**, with the same values as `CreatedOn` / `CreatedBy`. Log fields are never left empty.
- On update, `CreatedOn` / `CreatedBy` must keep their original values. If `Source` may not carry them, read the record with `Get<Entity>ForUpdate` and copy them across before calling `Update<Entity>`.
- The output of `Get<Entity>ForUpdate` is reached through the entity name: `GetCustomerForUpdate.Record.Customer.CreatedOn`, not `GetCustomerForUpdate.Record.CreatedOn` (Service Studio reports "Can't identify 'CreatedOn' element").
- Callers never set log fields; the wrapper always overwrites them.
- Both branches return `Id`.

No business process logic in wrappers. Orchestration across entities belongs in `_BL`.

## Standard entity attributes

| Attribute | Type | Notes |
|---|---|---|
| `Id` | Long Integer (auto-number) | Default identifier |
| `IsActive` | Boolean | Default `True` |
| `CreatedOn` / `UpdatedOn` | Date Time | Set by wrapper; both filled on create |
| `CreatedBy` / `UpdatedBy` | User Identifier | Set by wrapper; both filled on create |

## Attribute naming

1. Attribute names are **CamelCase and singular**, like entity names: `Name`, `CreatedOn`, `PhoneNumber`.
2. Booleans start with `Is` or `Has`: `IsActive`, `IsInvalid`, `HasAttachment`.
3. Foreign keys are `<ReferencedEntity>Id`: `CustomerId`, `StructureId`.
4. No abbreviations, no underscores, no entity-name prefix (`Name`, not `CustomerName` inside `Customer`).

| Good | Bad | Why |
|---|---|---|
| `PhoneNumber` | `PhoneNumbers`, `phone_number`, `PhoneNr` | Singular, CamelCase, no abbreviation |
| `Tag` | `Tags` | Singular (a list of values belongs in its own entity) |
| `IsDeleted` | `Deleted`, `DelFlag` | Booleans start with Is/Has |
| `CustomerId` | `Customer`, `IdCustomer`, `Customer_Id` | Foreign key pattern |

Index every foreign key and every attribute used in frequent filters.
