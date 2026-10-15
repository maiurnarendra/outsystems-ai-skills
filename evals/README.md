# Evals: proving the skills work

A skill "works" when an agent **with** it produces output that follows the standard, and the same agent **without** it does not. If both runs pass, the rule teaches nothing new and can be shortened. If the with-skill run fails, the rule is unclear or the skill isn't loading.

[`scenarios.json`](scenarios.json) holds one entry per behaviour:

| Field | Meaning |
| --- | --- |
| `id` | Stable identifier, e.g. `crud-01` |
| `skill` | The skill the scenario exercises |
| `prompt` | Exactly what to type into the agent |
| `expectations` | Pass/fail statements to check against the answer |

The last scenario is a **negative** test: an unrelated prompt must *not* trigger the skills.

## Level 1: structural checks (every change, 5 seconds)

```
powershell -ExecutionPolicy Bypass -File scripts\validate.ps1
```

Checks manifests, frontmatter, description length, references in AGENTS.md/README, and that every scenario points at a real skill. It does not judge content.

## Level 2: with/without comparison (every rule change, ~20 minutes)

1. **Baseline.** Temporarily disable the skills (Claude Code: disable `outsystems-ai-skills` from the `/plugin` menu, or rename the `~/.claude/skills/outsystems-*` folders). Start a new session per scenario, paste the `prompt`, save the answer.
2. **With skills.** Re-enable, start a new session per scenario, paste the same prompt, save the answer.
3. **Score.** For each expectation, mark pass/fail in both runs. You can ask a separate Claude session to grade: paste the expectations and the answer and ask for pass/fail per line with a one-line reason.
4. Record results in a table like this, in the pull request or in `evals/results/<date>.md`:

| Scenario | Without | With |
| --- | --- | --- |
| crud-01 | 1/7 | 7/7 |
| sql-01 | 3/8 | 8/8 |

New sessions matter: skills load at session start, and earlier messages in a session bias later answers.

Claude Code's `skill-creator` skill (from Anthropic's skills plugin) can automate steps 1–3 — running prompts with and without a skill, grading, and benchmarking — once you have Claude Code installed.

## Level 3: real usage (before announcing a version)

1. Pick 2–3 developers. Have them install the plugin and use it for a week on real work with an OutSystems MCP server.
2. Ask the agent to run `outsystems-standards-review` on the modules it touched.
3. Collect every case where the agent broke a rule or the rule itself was wrong. Each one becomes a new scenario in `scenarios.json` and, if needed, a clarified rule.

## Adding a scenario

- Write the prompt the way a developer actually would, not the way the rule is phrased.
- Each expectation must be checkable by reading the answer: concrete names, keywords, structure.
- Add a scenario for every new or changed rule, in the same pull request.
