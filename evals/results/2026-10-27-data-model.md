# Live test: `outsystems-data-model` (2026-10-27)

First run of the data-model skill against a real OutSystems 11 `_CS` module, read through the Service Studio MCP. Project and module details are generalised.

## Setup

- **Feature:** per-person notification preferences (receive or mute, per channel and per application), with critical notifications always delivered.
- **Existing model:** one notifications `_CS` with 8 entities, read with `getDataModel` (`includeJson: "Never"`). Its references showed that the person, channel (static) and application (static) concepts already existed in other modules.
- **Glossary:** none existed; created by the run.
- **Tools used, read-only:** `listApps`, `getDataModel`. No edit, merge or publish calls.

## Result

| Check | Result |
|---|---|
| Context gathered before the first question; existing concepts listed and confirmed | ✅ 3 reused, 1 new |
| One question at a time, each with a recommended answer and a reason | ✅ 9 questions |
| Static vs regular decided with a concrete case | ✅ "A user turns off email tomorrow: who changes it?" |
| Delete rule decided with a concrete case | ✅ "The person is erased (GDPR)" → Delete |
| Owning `_CS` chosen by dependencies, not by first use | ✅ The owner already referenced all three related modules; the alternative would have added a Core-to-Core reference |
| No false many-to-many | ✅ `Notification_Preference` rejected; the entity is `NotificationPreference` with three foreign keys and a unique index |
| New entity follows the standard where the existing model doesn't | ✅ `PeopleId`, not the older `TargetPeopleId` |
| Proposal written: entity table, attributes, indexes, Mermaid diagram, 9 decisions with reasons, 3 open questions | ✅ |
| Glossary written with "avoid" terms | ✅ 5 terms |
| Nothing created in the model | ✅ |

## What the run taught us (skill changes to consider)

1. **The developer accepted every recommendation.** That makes the interview fast, but it can become rubber-stamping. The concrete-case questions (erasure, "turn off all email") were the ones that produced real decisions, so the skill should prefer them over "Is X right?" questions.
2. **The best findings were open questions, not decisions.** For example, "a person who muted all email still gets email from an application added later". The skill should explicitly look for interactions between decisions before writing the proposal.
3. **The existing model's references are a reuse map.** `getDataModel` also lists the referenced entities from other modules, and that answered "does this already exist?" without asking. Worth saying in step 0.
4. **The proposal was saved before being shown.** The skill says to show it first; the run saved it to a scratch folder and showed it afterwards. Keep "show, then save" for project folders.
5. **Volume and sensitive data became open questions**, not interview questions, because they didn't change the design. That's acceptable; the skill could say these may be parked when they don't affect the model.
