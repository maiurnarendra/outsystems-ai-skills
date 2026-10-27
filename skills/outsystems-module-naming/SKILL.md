---
name: outsystems-module-naming
description: OutSystems module naming conventions and layer suffixes (_CS, _BL, _CW, _FS, _IS, _TH, _Lib, _API and the mobile variants _MCS, _MBL, _MCW, _MTH). Use when creating, renaming, or reviewing OutSystems modules, applications or libraries, or when deciding which module a new element belongs in.
---

# OutSystems module naming

Every module name tells the reader two things: **which business domain** it belongs to and **which architecture layer** it sits in. The suffix encodes the layer; the agent must never create a module without one (End-user modules excepted, see below).

## Format

```
<Domain>[<SubDomain>]_<Suffix>
```

- `Domain` is CamelCase, singular, business-meaningful: `Customer`, `Order`, `Invoice`. Never technical words like `Common`, `Utils`, `Misc`, `Stuff`.
- No spaces, no hyphens, no version numbers (`Customer2_CS` is wrong; version through LifeTime/ODC, not names).
- An optional company or product prefix is allowed when the factory is shared: `ACME_Customer_CS`. Pick one rule per factory and apply it everywhere.

## Suffix table

| Suffix | Layer | Contents | Mobile variant |
|---|---|---|---|
| *(none)* or `_Portal` / `_Backoffice` | End-user | Screens, flows, UI for one user persona or app. Consumes Core; exposes nothing. | `_App` / `_Mobile` |
| `_CW` | Core | **Core Widgets**: reusable business blocks (e.g. `CustomerCard`). No Get actions. | `_MCW` |
| `_BL` | Core | **Business Logic**: Get actions (`GetStructure`, `GetStructureById`), processes, orchestration, rules spanning several entities. | `_MBL` |
| `_CS` | Core | **Core Services**: entities (exposed read-only) and their `_CreateOrUpdate` / `_Delete` / optional `_DeleteAll` wrappers. Nothing else. | `_MCS` |
| `_API` | Core | Exposed REST/SOAP APIs for external consumers. No business logic, only calls `_BL`/`_CS`. | n/a |
| `_Sync` | Core | Offline synchronisation logic for mobile. | n/a |
| `_IS` | Foundation | **Integration Services**: wraps one external system (REST consume, SOAP, SAP, DB connection). | n/a |
| `_FS` | Foundation | **Foundation Services**: reusable services agnostic to the business model (e.g. email sending, file handling, PDF generation). No entities holding data. | n/a |
| `_Lib` | Foundation | Libraries / extensions / generic utilities (string, date, crypto). | n/a |
| `_TH` | Foundation | Theme: layouts, CSS, menu. | `_MTH` |
| `_Pat` | Foundation | UI patterns: generic, business-agnostic widgets. | `_MPat` |

**An `M` at the start of the suffix means mobile**: `_MCS`, `_MBL`, `_MCW`, `_MTH`, `_MPat` are the mobile counterparts of `_CS`, `_BL`, `_CW`, `_TH`, `_Pat`. Suffixes are written exactly as in this table (`_TH`, not `_Th` or `_th`).

Mobile variants exist because Client-side entities, Client Actions and offline sync differ from Reactive Web. Do not mix mobile-only elements into the web module of the same name.

## Placement rules

1. Entity definitions live **only** in `_CS` (or `_MCS` for local storage). Never define entities in `_BL`, `_CW` or End-user modules.
2. A `_CS` module owns one business concept and its closely related entities (e.g. `Order` + `OrderLine`). Split when a module grows beyond one concept.
3. **`_CS` holds only entities and their `_CreateOrUpdate` / `_Delete` / optional `_DeleteAll` wrappers.** Get actions (`GetStructure`, `GetStructureById`, `GetStructureBy<Input>`) go in **`_BL`**, never in `_CS` or `_CW`.
4. Logic that coordinates more than one `_CS` belongs in `_BL`.
5. If something has no business meaning and could be reused by another company, it belongs in Foundation (`_FS`, `_Lib`, `_IS`, `_Pat`, `_TH`).
6. **`_FS` modules are agnostic to the business model**: they never contain entities with data and never reference Core modules. They receive everything they need through action inputs.
7. One external system = one `_IS` module. Normalise its data into your own structures there, with only the attributes the application needs; never let the external structure leak into Core. See `outsystems-integrations`.

## ODC note

In ODC, modules become **apps** and **libraries**. Keep the same suffixes:
- Foundation (`_Lib`, `_TH`, `_Pat`, generic `_IS`) are usually **libraries**.
- `_CS`/`_BL` that own data are **apps** (entities can't live in libraries).
- End-user apps consume Core apps through Service Actions and public entities.

## Examples

| Good | Bad | Why |
|---|---|---|
| `Customer_CS` | `CustomerCore` | Missing standard suffix |
| `Billing_BL` | `Billing_BL_v2` | Version in name |
| `Salesforce_IS` | `Integrations_IS` | One system per `_IS` |
| `DateTime_Lib` | `Utils` | No domain, no suffix |
| `CustomerPortal` | `Customer_UI_Final` | End-user names describe the app, not the state |
