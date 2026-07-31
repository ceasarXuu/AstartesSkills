<!-- expected-error: multiple or unsupported change axes -->
# Invalid Coupled Axes

- Mode: Plan Authoring

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|
| W1 | Ship account locale | data + API + client | src/account/locale_flow.md | account locale flow | Add locale support | Schema, endpoint, and UI change together | Run the full account end-to-end test | Revert the entire release | planned |
