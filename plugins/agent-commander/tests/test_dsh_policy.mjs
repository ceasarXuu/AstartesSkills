import assert from "node:assert/strict";
import { apply } from "../scripts/dsh_readonly.mjs";
let guard;
let ready = false;
apply({
  tools: {
    restrict() { throw new Error("global restrict is unsupported by Harness"); },
    guard(callback) { guard = callback; },
  },
  provide(name, value) { ready = name === "commanderReadOnly" && value; },
});
assert.equal(ready, true);
for (const name of ["read", "read_image", "glob", "grep"]) {
  assert.equal(guard({ name }), undefined);
}
for (const name of ["write", "edit", "bash", "run_code", "spawn_agent", "unknown"]) {
  assert.equal(typeof guard({ name }), "string");
}
assert.throws(() => apply({ tools: {} }), /required read-only/);
console.log("Harness read-only policy checks passed");
