<!-- expected-error: speculative construction is not justified by a current need -->
# Invalid Speculative Construction

- Mode: Plan Authoring

## Work Units

| ID | Objective | Change Axis | Change Location | Target Object | Concrete Action | Resulting Behavior | Benefit | Side Effects | Verification | Safe Stop / Rollback | Plan Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| W1 | Generalize locale lookup | internal | src/account/locale.ts | LocaleProvider | Introduce a provider interface around the locale source | Locale lookup goes through a provider boundary | Makes future integrations easier to add | Complexity: adds an interface, factory, registry, configuration, and indirect call path; Reach/Cost: every locale caller, unit test, documentation, and future maintenance now depends on the layer | Run existing locale tests | Revert provider layer | planned |
