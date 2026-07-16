#!/usr/bin/env node
// Convert Markdown to Jira ADF JSON. Reads a file arg or stdin, writes ADF to stdout.
import { readFileSync } from "node:fs";
import { markdownToAdf } from "marklassian";

const arg = process.argv[2];

function read(src) {
  try {
    return readFileSync(src === undefined || src === "-" ? 0 : src, "utf8");
  } catch (err) {
    console.error(`md2adf: cannot read ${src === undefined ? "stdin" : src}: ${err.message}`);
    process.exit(1);
  }
}

const md = read(arg);
process.stdout.write(JSON.stringify(markdownToAdf(md), null, 2) + "\n");
