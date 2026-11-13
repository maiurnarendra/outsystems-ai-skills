# Entities and CRUD: naming examples

Reference for `outsystems-crud-conventions`. The rules are in [../SKILL.md](../SKILL.md).

## Entity names

| Good | Bad | Why |
|---|---|---|
| `CustomerAddress` | `Customer_Address`, `customerAddress` | `_` is reserved for many-to-many; must start uppercase |
| `User_Role` | `UserRole`, `UserRoles` | Junction entity needs the separator; singular |
| `Product_Category` | `ProdCat` | No abbreviations |
| `Customer`, `CustomerAddress` | `Sales_Customer`, `Sales_CustomerAddress` | Prefix + `_` reads as many-to-many but isn't |

## Attribute names

| Good | Bad | Why |
|---|---|---|
| `PhoneNumber` | `PhoneNumbers`, `phone_number`, `PhoneNr` | Singular, CamelCase, no abbreviation |
| `Tag` | `Tags` | Singular (a list of values belongs in its own entity) |
| `IsDeleted` | `Deleted`, `DelFlag` | Booleans start with Is/Has |
| `CustomerId` | `Customer`, `IdCustomer`, `Customer_Id` | Foreign key pattern |
