import { test } from "node:test";
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const cli = fileURLToPath(new URL("./md2adf.mjs", import.meta.url));
const run = (md) => JSON.parse(execFileSync("node", [cli], { input: md, encoding: "utf8" }));

test("converts headings, lists, code and links to ADF nodes (not literal markup)", () => {
  const doc = run("## Brief\n\n- *em* and **bold**\n- `code` and [link](https://x)\n");
  assert.equal(doc.type, "doc");
  assert.equal(doc.version, 1);

  const types = doc.content.map((n) => n.type);
  assert.ok(types.includes("heading"), `expected a heading, got ${types}`);
  assert.ok(types.includes("bulletList"), `expected a bulletList, got ${types}`);

  const heading = doc.content.find((n) => n.type === "heading");
  assert.equal(heading.attrs.level, 2);
  assert.equal(heading.content[0].text, "Brief");

  // no raw markup characters survive into text nodes
  const text = JSON.stringify(doc);
  assert.ok(!text.includes("**"), "literal ** leaked into ADF");
  assert.ok(text.includes('"code"'), "inline code mark missing");
  assert.ok(text.includes("https://x"), "link href missing");
});

test("tables convert to an ADF table node", () => {
  const doc = run("| a | b |\n| - | - |\n| 1 | 2 |\n");
  assert.ok(doc.content.some((n) => n.type === "table"), "expected a table node");
});
