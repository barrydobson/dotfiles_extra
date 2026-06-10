---
name: grab-issue
description: Use when the user wants an agent to pick up, grab, take, claim, or start work on a GitHub issue by number in the current repo - e.g. "/grab-issue 42", "grab issue 42", "work on issue 17", "pick up #23".
---

# Grab Issue

Pick up a GitHub issue and carry it to a pull request: fetch, gate on triage label, work in an isolated worktree, then push and open a PR that closes the issue.

Assumes the current directory is the target repo and `gh` is authenticated.

## Steps

### 1. Fetch the issue

```bash
gh issue view <number> --json number,title,body,labels,state,url
```

If `state` is not `OPEN`, stop and tell the user the issue is closed. Do nothing else.

### 2. Gate on the `ready-for-agent` label

Check `labels[].name` for the literal string `ready-for-agent`.

**If absent, STOP.** Do not create a worktree, branch, or any commits. Tell the user the issue is not triaged for agents and recommend running the `triage` skill first (Matt Pocock's `/triage`) to bring it to `ready-for-agent`. End here.

**If present**, continue.

### 3. Create an isolated worktree

**REQUIRED:** Use the `superpowers:using-git-worktrees` skill to create the worktree. Never work on `main`.

Use a branch name of `issue-<number>-<slug>`, where `<slug>` is the issue title lowercased, non-alphanumerics replaced with `-`, trimmed to a few words.

### 4. Delegate the implementation to a subagent

Dispatch a single subagent to implement the issue end-to-end **inside the worktree directory**. Give it the issue title, body, and URL as its brief, plus these instructions:

- Implement following TDD (`~/.claude/rules/testing.md`) and code-quality rules.
- Run `prek run` and the relevant tests before committing; fix everything.
- Use conventional commits; one logical change per commit.
- **Do not push or open a PR** - return when the issue is complete (tests green, lints clean).

Wait for the subagent to finish.

### 5. Push and open the PR

From the worktree:

```bash
git push -u origin issue-<number>-<slug>
gh pr create --title "<conventional title>" --body "Closes #<number>

<plain factual description of what the code now does>"
```

`Closes #<number>` links and auto-closes the issue on merge. Keep the PR body plain and factual per `~/.claude/rules/workflow.md` - no "robust", "comprehensive", "critical". Use the repo PR template if one exists.

Report the PR URL to the user.

## Common Mistakes

- **Skipping the label gate** because the issue "looks ready" - the gate is the point. No label, no work.
- **Working on `main`** instead of a worktree.
- **Opening the PR from inside the skill before the subagent finishes** - let the subagent complete first.
- **Editorialising the PR body** - describe what the code does now, not the journey.
