---
name: outsystems-architecture
description: OutSystems architecture design rules based on the 3-layer Architecture Canvas (End-user, Core, Foundation) and allowed dependency directions. Use when designing a new OutSystems application, adding a dependency between modules, splitting or merging modules, or reviewing an architecture for violations.
---

# OutSystems architecture design

Follow the **Architecture Canvas**: three layers, dependencies only point down or sideways where explicitly allowed. Module suffixes are defined in the `outsystems-module-naming` skill.

```
┌──────────────────────────────────────────────┐
│ End-user   CustomerPortal, Backoffice, _App  │  ← UI, user stories
├──────────────────────────────────────────────┤
│ Core       _CW  →  _BL  →  _CS    _API       │  ← business concepts
├──────────────────────────────────────────────┤
│ Foundation _IS  _FS  _Lib  _TH  _Pat         │  ← business-agnostic
└──────────────────────────────────────────────┘
```

## Dependency rules

| From \ To | End-user | Core | Foundation |
|---|---|---|---|
| **End-user** | ❌ never | ✅ | ✅ |
| **Core** | ❌ never | ⚠️ only without cycles | ✅ |
| **Foundation** | ❌ never | ❌ never | ⚠️ only without cycles |

1. **No upward references.** Foundation never references Core; Core never references End-user.
2. **No side references between End-user modules.** If two apps need the same screen or block, move it to `_CW` (business) or `_Pat` (generic). Navigate between End-user apps with external URLs, not screen references.
3. **No cycles in Core.** Preferred direction inside Core: `_CW → _BL → _CS`. A `_CS` must never reference a `_BL`.
4. **Foundation is business-agnostic.** If you need a business entity in a Foundation module, the code is in the wrong layer.
5. **Entities are exposed read-only.** `Public = Yes`, `Expose Read Only = Yes`. Writes go through CRUD wrappers (see `outsystems-crud-conventions`).
6. **`_API` modules hold no logic.** They map external contracts to calls on `_BL`/`_CS`.

## Design process for a new application

1. **Disclose** the concepts: list user stories, business entities, integrations, personas.
2. **Organise** each concept into a layer: personas → End-user; entities/processes → Core; integrations, themes and utilities → Foundation.
3. **Assemble** concepts into modules, applying the suffix rules. Start with fewer, cohesive modules and split when ownership, change frequency or deployment cadence differ.
4. **Validate** with Discovery / AI Mentor Studio (O11) or the ODC dependency view; fix every upward or side reference before the first release.

## Granularity heuristics

- Split a module when different teams own parts of it, or parts change at different rates.
- Merge modules that are always deployed together and have one owner.
- Large `_CS` modules with many consumers cause long recompile/refresh cycles. Keep them stable and small.
- Weak (Service) vs strong (Server/Public Action) references: prefer Service Actions between Core apps when independent deployment matters (O11 Service Actions, ODC public Service Actions).

## Common violations and fixes

| Violation | Fix |
|---|---|
| End-user module A uses a block from End-user module B | Move the block to `_CW` |
| `_CS` calls a `_BL` action | Move the logic up into `_BL`, or invert with an event / callback |
| `_TH` references a business entity | Move the dependent widget into `_CW` |
| `GetStructureById` defined in `_CS` or `_CW` | Move it to the domain's `_BL` |
| `_FS` module defines an entity with data, or references a Core module | Move the entity to a `_CS`; pass data to the `_FS` through action inputs |
| `_IS` returns the external system's raw structures to End-user | Map to own structures inside `_IS` or a `_BL` |
| Two Core modules reference each other | Extract the shared part into a third module lower in the chain |
