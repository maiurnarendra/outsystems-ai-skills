# Data model: decisions in detail

Reference for `outsystems-data-model`, step 2: tables, tests and examples per decision. The rules are in [../SKILL.md](../SKILL.md).

## 2.1 Name and meaning
- One business term, CamelCase and singular (`CustomerAddress`), with a one-sentence definition for the glossary.
- Synonyms the business uses, recorded as "avoid" terms.
- **Reuse before create:** if an existing entity already represents the concept, extend or reference it instead of creating a second one.

## 2.2 Owning module
- The entity lives in the `_CS` (or `_MCS`) of the business concept that **owns** it, not the module where it is first used.
- An entity that only one feature reads still belongs to its concept's `_CS`.
- Never in `_BL`, `_CW` or `_FS` (see `outsystems-module-naming`).

## 2.3 Static or regular entity

| Choose | When |
|---|---|
| **Static entity** | Values are known at design time, change only with a deployment, and logic refers to specific values (`Entities.OrderStatus.Submitted`) |
| **Regular entity** | Business users add or edit values at runtime, or the list differs between environments |
| **Regular entity + static** | Users manage the list, but logic needs a few fixed codes: keep the codes in a static entity and reference it from the regular one |

Test it: "A new status is needed next month. Who adds it: a developer with a deployment, or a key user in a back office?"

Static entities follow `outsystems-crud-conventions` (`Static` folder, `Is AutoNumber = No`, `IsActive`).

## 2.4 Relationships

| Situation | Model |
|---|---|
| Each B belongs to exactly one A | Foreign key `AId` on B (one-to-many) |
| B can exist without A | Foreign key on B, not mandatory |
| Each A has at most one B, and B only exists with A | Extension entity: B's `Id` is A's identifier (one-to-one) |
| An A has many B **and** a B has many A | Junction entity `A_B` with `AId` and `BId`, plus a unique index on both |

- Use a junction entity **only** for a real many-to-many. Test it: "Can one B really belong to two A at the same time?" If not, it is a foreign key.
- The junction is named `A_B` even when it carries extra attributes (`User_Role` with `ValidFrom`).

## 2.5 Delete rules
For every foreign key, decide what happens when the referenced record is deleted:

| Rule | Use when |
|---|---|
| **Protect** (default) | The child has its own meaning (orders of a customer). Deleting the parent must fail |
| **Delete** | The child cannot exist without the parent (order lines of an order) |
| **Ignore** | Rare: logs or history that must survive the parent. Record the reason |

If records are deactivated rather than deleted, say so: the entity keeps `IsActive` and the wrapper never deletes.

## 2.6 Attributes
For every attribute: name, data type, length or precision, mandatory or not, default value.
- Names follow `outsystems-crud-conventions`: CamelCase, singular, Booleans `Is`/`Has`, foreign keys `<Entity>Id`.
- **Text lengths are explicit.** The Service Studio default of 50 is a decision too: confirm it.
- Dates: `Date` when the time does not matter, `Date Time` when it does. Amounts: `Currency` or `Decimal` with the precision stated.
- A repeating value (`Tag1`, `Tag2`, `Tag3`) is its own entity, not several attributes.
- Standard attributes (`CreatedOn`, `CreatedBy`, `UpdatedOn`, `UpdatedBy`, and `IsActive` where records are deactivated) are added by default.

## 2.7 Indexes and uniqueness
- An index on every foreign key.
- An index on attributes used in frequent filters or sorts.
- A **unique** index for every natural key (`Code`, `Email` per tenant, `AId + BId` on a junction).

## 2.8 Volume, retention and sensitive data
- Expected rows now and after a year. Large or fast-growing tables need indexes planned now, and may need an archive or purge process (with `<Entity>_DeleteAll` or a filtered bulk delete).
- How long records are kept, and who may delete them.
- Personal or sensitive data (names, emails, health, financial): mark it, and record who may read it and any masking or retention rule.
