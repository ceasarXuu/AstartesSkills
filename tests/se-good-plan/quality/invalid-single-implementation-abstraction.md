<!-- expected-error: new abstraction for one current implementation lacks justification -->
# Invalid Single Implementation Abstraction

- Mode: Plan Authoring

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W1 | Wrap locale lookup | internal | src/account/locale.ts | LocaleProvider | Introduce a provider interface around the only current locale source | Existing locale lookup uses an interface | Standardizes access to locale data | Complexity: adds an interface and indirection for the only current implementation; Reach/Cost: all locale callers, tests, code navigation, and ownership gain maintenance burden without a second consumer | Run locale unit tests | Revert interface and direct call | planned |
