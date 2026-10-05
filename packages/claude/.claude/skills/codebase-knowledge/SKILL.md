---
name: codebase-knowledge
description: Analyse a codebase in phases and write a self-contained knowledge document for engineers and LLM agents.
argument-hint: "[subdirectory or feature to focus on]"
disable-model-invocation: true
---

Explore this repository with your own tools and write a knowledge document that another engineer or LLM agent can use to implement features, fix bugs and refactor safely. Read only the files you need. Nobody will paste the code into chat.

If `$ARGUMENTS` names a path or feature, limit the analysis to it and its direct dependencies.

## Output

- Write to `codebase-analysis-docs/CODEBASE_KNOWLEDGE.md` in the repo root. Create the folder if it does not exist.
- Write each phase's findings to the document as you finish that phase. A compacted or restarted run resumes from what is on disk.
- If the document already exists, read it first and update it rather than starting again.
- Reference code as `path:line`, relative to the repo root.
- Use Mermaid for diagrams, one concern per diagram.

## Rules

- Work on one phase at a time. Finish and write a phase before starting the next.
- Tie every claim to a file, function or config value. Write "not confirmed" rather than guess.
- If a section does not apply to this repo, say so in one line rather than invent content.
- Use the same name for a thing in every section.
- Where the repo's own docs disagree with the code, the code is correct. Record each disagreement for section 6.
- Label any fact that comes from memory or another repo rather than this one.
- Write in British English.

## Subagents

Phases 3 and 5 use `codebase-analyzer` subagents. Start them all in a single message with `model: sonnet`. End every brief with: "Give every path relative to the repo root, for example `internal/cache/redis.go:48`, never relative to the package."

## Phase 1: Initial scan

1. Run `git rev-parse --short HEAD` and `git branch --show-current`. Record them for the header table in Phase 6, not as a section.
2. Map the directory tree and classify files as code, tests, config, migrations, infra or docs. Ignore vendored dependencies and build output.
3. Find the entry points and the most-imported modules. Integration and end-to-end tests are a quick way to find the features.
4. Read the most important files for structure: routers, wiring, types and signatures. Leave function bodies to the Phase 3 subagents. Record:
   - what the application is, who or what calls it, and its business purpose
   - the tech stack and notable dependencies
   - the architecture style and directory layout
   - the list of features, each with its business purpose and how it relates to the others

Write section 1. The feature list sets the work for Phase 3.

## Phase 2: Architecture

Map the major components and how they interact. Read for structure, as in Phase 1. Record:

- start-up and the dependency graph
- data flow from input to output, for example request to handler to storage to response
- third-party integrations
- shared state
- cross-cutting concerns: security, logging, caching, authentication, configuration
- architectural patterns and conventions

Write section 2.

## Phase 3: Features (parallel)

Start one subagent per feature from Phase 1. Give each subagent the feature name, its likely entry points and this brief:

> Document this feature with `path:line` references. Cover its purpose and the business need it serves; its entry points (routes, CLI commands, UI, consumers); its services and models; its side effects (messages, jobs, webhooks, external calls); how it interacts with other features and shared modules; and its edge cases and hidden dependencies. Return findings only, not prose for a reader.

Check each result against the code where it is unclear or conflicts with another result. Then write section 3: one subsection per feature, followed by a cross-feature interaction map.

## Phase 4: Things you must know before changing code

Record:

- a short list of the most dangerous things to get wrong
- authentication and trust boundaries per entry point, secrets handling, and personal data processed
- performance characteristics and bottlenecks
- hardcoded business rules
- concurrency and consistency behaviour
- non-obvious design decisions and their likely reasons
- tooling or version mismatches

Write section 4.

## Phase 5: Technical reference (parallel)

Start one subagent per reference type that applies. Typical types are:

- glossary of domain terms
- module index: key packages, classes and functions with one-line summaries, each module's tests and its main dependants
- data model and schema, with an ER diagram
- configuration reference
- API reference with examples
- metrics and events catalogue

Ask each subagent to return a table or list with `path:line` references. Write section 5.

## Phase 6: Assemble and verify

1. Assemble the document in this order:
   - a header table: repository, commit analysed, audience, scope
   - a "How to use this document" table that maps reader goals to sections
   - contents
   - Part I, high-level overview: section 1
   - Part II, mid-level technical notes: sections 2 to 4
   - Part III, deep reference: section 5
   - section 6, known defects, accepted risks and places where the repo's docs contradict the code. Mark each defect Confirmed (you read the code) or Reported (a subagent finding you did not recheck).
   - section 7, open questions, and an assumptions table with a confidence level for each
2. Extract every `path:line` reference and confirm the path exists with `rg --files` or `ls`. Fix or remove any that do not.
3. Check the document reads on its own for someone without the repo open.
