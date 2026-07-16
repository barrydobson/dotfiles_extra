# jira-adf - maintainer notes

The skill runs `tools/md2adf.mjs`, a **self-contained bundle** with no runtime
dependency. `node_modules/` is not needed to use the skill, only to rebuild it.

## Files

- `tools/md2adf.src.mjs` - the source. Edit this.
- `tools/md2adf.mjs` - generated bundle (marklassian + marked inlined by esbuild).
  Committed, run at skill invocation. Do **not** hand-edit; the banner says so.
- `tools/md2adf.test.mjs` - runs the bundle end-to-end via the CLI.

## When to re-bundle

Re-run the build after **either**:

- editing `md2adf.src.mjs`, or
- bumping `marklassian` / `esbuild` in `package.json`.

## How to re-bundle

```sh
npm install        # dev-only: esbuild + marklassian (gitignored node_modules)
npm run build      # regenerates tools/md2adf.mjs
npm test           # verifies the bundle with node_modules absent-equivalent
```

`npm test` runs the bundle through node directly, so a green test proves the
bundle is self-contained (it doesn't reach into `node_modules`).
