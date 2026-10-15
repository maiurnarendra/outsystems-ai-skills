---
name: outsystems-advanced-sql
description: Formatting, indentation and safety standards for OutSystems Advanced SQL nodes - uppercase clauses on the left, tab-indented fields, leading commas, explicit INNER JOIN, CamelCase aliases, {Entity}.[Attribute] syntax, parameters and Expand Inline safety. Use when writing, formatting or reviewing SQL inside an OutSystems SQL node.
---

# OutSystems Advanced SQL

Use an Aggregate first. Use Advanced SQL only when Aggregates can't express the query (`HAVING`, subqueries, `UNION`, `WITH`, window functions, bulk `UPDATE`/`DELETE`, performance-critical joins).

## Formatting rules

1. **Clause keywords in UPPERCASE, always at the left margin, alone on their line**: `SELECT`, `FROM`, `WHERE`, `GROUP BY`, `HAVING`, `ORDER BY`. (`SELECT TOP n` / `SELECT DISTINCT` stay on the `SELECT` line.)
2. **Everything under a clause is indented with one TAB** (a tab character, not spaces): fields, tables, joins, conditions.
3. **Commas on the left.** Each field after the first starts with `,` so a missing comma is visible at a glance.
4. **`AND` / `OR` on the left**, one condition per line, indented with a TAB under `WHERE` / `HAVING`.
5. **Joins in UPPERCASE and explicit**: `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`. Never a bare `JOIN`. Each join goes on its own line under `FROM`, with its `ON` condition on the same line.
6. **All SQL functions and keywords in UPPERCASE**: `COUNT`, `SUM`, `ISNULL`, `AS`, `IN`, `DESC`.
7. Always use OutSystems syntax `{Entity}.[Attribute]`. Never physical table names (`OSUSR_...`).
8. **Aliases only when necessary** (self-joins, the same entity joined twice, derived tables). When used, the alias is a **normalized CamelCase name, never an abbreviation**: `{Employee} AS Manager`, not `{Employee} e` or `{Employee} AS Mgr`.
9. Column aliases are CamelCase too: `AS OrderCount`, not `AS counter` or `AS cnt`.
10. Never `SELECT *`; list columns in the **same order as the output structure**.
11. No commented-out code left in a published query.

## Example

```sql
/* GetCustomerOverOrderLimit
   Returns active customers whose number of open orders exceeds their OrderLimit.
   Params: @ExcludedUserId, @FromDate */
SELECT TOP 200
	COUNT({Order}.[Id]) AS OrderCount
	,{Customer}.[Id]
	,{Customer}.[Name]
	,{Customer}.[OrderLimit]
	,AccountManager.[Name] AS AccountManagerName
FROM
	{Customer}
	INNER JOIN {Order} ON {Order}.[CustomerId] = {Customer}.[Id]
	LEFT JOIN {User} AS AccountManager ON AccountManager.[Id] = {Customer}.[AccountManagerId]
WHERE
	{Order}.[IsActive] = 1
	AND {Order}.[IsCancelled] = 0
	AND {Customer}.[IsActive] = 1
	AND {Customer}.[IsBlocked] = 0
	AND {Customer}.[OrderLimit] > 0
	AND {Customer}.[CreatedBy] <> @ExcludedUserId
	AND {Customer}.[CreatedOn] > @FromDate
GROUP BY
	{Customer}.[Id]
	,{Customer}.[Name]
	,{Customer}.[OrderLimit]
	,AccountManager.[Name]
HAVING
	COUNT({Order}.[Id]) > {Customer}.[OrderLimit]
ORDER BY
	OrderCount DESC
```

## Header comment (mandatory)

Every SQL node starts with a block comment: query name, one-line purpose, parameters. Explain any non-obvious join or filter inline with `--`.

## Node and parameter naming

- SQL node name: `Get<Entity>By<Filter>`, `Count<Entity>By<Filter>`, `Update<Entity><What>` (same as Aggregates).
- Parameters CamelCase, matching the action variables: `@CustomerId`, `@FromDate`.
- **No hard-coded Ids, dates or magic numbers** in the query. Pass them as parameters (fed from Site Properties / Settings or Static Entities).
- Output structure: a dedicated Structure named `<Purpose>Row` (e.g. `CustomerOrderCountRow`) or the entity itself when returning only that entity's columns.

## Safety

- **Never set `Expand Inline = Yes` on user-controlled input** without sanitising:
  - Lists for `IN (...)`: build with `BuildSafe_InClauseIntegerList` / `BuildSafe_InClauseTextList` (Sanitization extension).
  - Dynamic `ORDER BY`: validate against a whitelist of column names.
  - Text: `EncodeSql()`.
- Prefer normal parameters everywhere else. Expand Inline disables plan caching and is an injection risk.
- Always filter inactive data (`IsActive = 1`) unless the query is explicitly about inactive records.
- Limit rows (`TOP n` / Max. Records) when feeding UI lists; page with `OFFSET ... FETCH` for large result sets.
- Comment any vendor-specific function.

## ODC / PostgreSQL

All the rules above apply unchanged. The only difference: `TOP n` (SQL Server) is replaced by `LIMIT n`, placed on its own line at the left margin as the last clause.

```sql
/* GetCustomerOrderCount
   Returns active customers with their number of open orders.
   Params: none */
SELECT
	COUNT({Order}.[Id]) AS OrderCount
	,{Customer}.[Id]
	,{Customer}.[Name]
FROM
	{Customer}
	INNER JOIN {Order} ON {Order}.[CustomerId] = {Customer}.[Id]
WHERE
	{Customer}.[IsActive] = 1
	AND {Order}.[IsActive] = 1
GROUP BY
	{Customer}.[Id]
	,{Customer}.[Name]
ORDER BY
	OrderCount DESC
LIMIT 200
```

## Test before commit

Use the node's **Test** button with realistic parameter values and check the **Executed SQL** tab for the generated statement.
