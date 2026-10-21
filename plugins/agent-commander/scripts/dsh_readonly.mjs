// The guard is global and monotonic: later policy listeners cannot allow writes.
export const name = "agent-commander-readonly";
export const inject = ["tools"];
export function apply(ctx) {
  const allowed = new Set(["read", "read_image", "glob", "grep"]);
  if (typeof ctx.tools.guard !== "function") {
    throw new Error("Harness lacks the required read-only tool policy API");
  }
  ctx.tools.guard(exec => allowed.has(exec.name)
    ? undefined : "AgentCommander only permits read, read_image, glob, and grep");
  ctx.provide("commanderReadOnly", true);
}
