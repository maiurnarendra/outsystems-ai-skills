# Work trackers

The skill needs four operations from the tracker. Use whatever access the config's `tracker.access` names (an MCP connector or a CLI). If that access isn't available in the session, say so and stop; don't fall back to scraping web pages.

| Operation | Jira | Azure DevOps | GitHub Issues |
|---|---|---|---|
| Find ready items | JQL search with `readyQuery` | `az boards query --wiql "<readyQuery>"` | `gh issue list --search "<readyQuery>"` |
| Read item, comments, links | Get issue with comments and `issuelinks` | `az boards work-item show --id <id> --expand relations`; comments via `az devops invoke --area wit --resource comments` | `gh issue view <n> --comments`; linked issues from the body / "linked issues" |
| Change status | List transitions, pick the one whose **target** status name matches; never guess transition ids | `az boards work-item update --id <id> --state "<state>"` | Labels or project status field (`gh issue edit --add-label`); close only if configured |
| Change assignee | Edit `assignee` with the account id; `reporter` = the issue's `reporter.accountId` | `--assigned-to "<email>"`; `reporter` = `System.CreatedBy` | `gh issue edit --add-assignee <login>`; `reporter` = the issue author |

## Keys in deployment notes

Use the tracker's own key format: `ORD-123` (Jira), `AB#123` or `123` (Azure DevOps), `#123` or `owner/repo#123` (GitHub). Separate several keys with a space.

## Linked bugs

| Tracker | A story's bugs are |
|---|---|
| Jira | Issue links of type Bug (any link direction) or sub-tasks of type Bug |
| Azure DevOps | Child or Related work items of type Bug |
| GitHub | Issues labelled `bug` that reference the story |

If it is unclear whether a linked item belongs to the story, ask.

## `tracker.type = none`

The user gives the keys and the modules directly. Skip every tracker read and every `afterDeploy` change.
