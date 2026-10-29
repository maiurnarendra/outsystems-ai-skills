# Using the standards with other coding agents

Claude Code is covered in the [README](../README.md#getting-started-claude-code). Every other agent uses one of two mechanisms:

- **Skills folder**: the agent reads `SKILL.md` files from a known directory and loads each one when its description matches the task. Best results.
- **`AGENTS.md`**: the agent reads `AGENTS.md` from the root of the workspace on every request. It contains the condensed rules and points to the skill files.

For both, start by cloning the repository:

```
git clone https://github.com/maiurnarendra/outsystems-ai-skills.git
```

## GitHub Copilot

Copilot (VS Code and CLI) reads `AGENTS.md` and `.github/copilot-instructions.md` from the workspace root.

1. Copy `AGENTS.md`, `.github/copilot-instructions.md` and the `skills/` folder into the root of the workspace where you work on OutSystems code.
2. Open a new Copilot chat and ask the [verification question](#verify).

## Cursor

Copy the skill folders into `.cursor/skills/` (or `.agents/skills/`) in your workspace:

```
mkdir -p .cursor/skills
cp -r outsystems-ai-skills/skills/* .cursor/skills/
```

Alternatively, copy `AGENTS.md` and `skills/` to the workspace root.

## Google Antigravity

Antigravity reads `SKILL.md` skills and `AGENTS.md` rules.

1. **Install the skills** for all workspaces (`~/.gemini/config/skills/`):
   ```
   powershell -ExecutionPolicy Bypass -File scripts\install.ps1 -Target antigravity
   ```
   or `bash scripts/install.sh --target antigravity`. For one workspace only, install into its `.agents/skills/` folder: `-Destination <workspace>\.agents\skills` (`--destination` in bash).
2. **Rules:** copy `AGENTS.md` to the root of the workspace where you work on OutSystems code.
3. **On-demand skills:** type `/outsystems-code-review`, `/outsystems-data-model` or `/outsystems-debugging` in the agent chat. Antigravity has no `disable-model-invocation`, so these skills carry a guard that tells the agent not to start them unless you ask.
4. **Service Studio MCP:** the code-review, data-model and debugging skills read your modules live. Add the Service Studio MCP to Antigravity's MCP servers the same way as for Claude Code (see the [OutSystems 11 MCP](https://github.com/OutSystems/outsystems11-mcp) setup), and approve the agent's session request in Service Studio.
5. Start a new agent session and ask the [verification question](#verify).

Paths can change between Antigravity versions; if the skills don't load, check Antigravity's Skills documentation for the current location.

## Kiro

Copy the skill folders into your user skills directory:

```
mkdir -p ~/.kiro/skills
cp -r outsystems-ai-skills/skills/* ~/.kiro/skills/
```

Kiro rejects skills whose `description` is longer than 1024 characters or whose `name` does not match the folder name. `scripts/validate.ps1` checks both.

## Codex CLI

Copy the skill folders into `~/.codex/skills/` (all projects) or `.agents/skills/` (one project):

```
mkdir -p ~/.codex/skills
cp -r outsystems-ai-skills/skills/* ~/.codex/skills/
```

## Windows

Replace `cp -r` with:

```
Copy-Item -Recurse -Force outsystems-ai-skills\skills\* <target-folder>
```

## Verify

Start a new session and ask:

> What suffix should a mobile theme module have, and how should I name the wrappers for a many-to-many entity between Employee and Project?

Expected: `_MTH`, and `Employee_Project_CreateOrUpdate` / `Employee_Project_Delete`.

## Updating

Pull the latest version (`git pull`) and repeat the copy step, or re-run the install script with the same `-Target`. Copied files do not update themselves.
