# Provider Package Contract

Use this contract when adding or changing an Agent/Provider combination.

## Required catalog fields

- `id`: stable kebab-case combination id.
- `agent`: concrete client or CLI.
- `provider`: concrete API provider.
- `model`: default model exposed by the wrapper or profile.
- `scope`: `temporary-profile` unless a persistent-only agent forces another choice.
- `command`: primary user-facing launch command.
- `minimum_agent_version`: lowest verified agent version.
- `reference`: direct path to one combination reference.
- `installer`: deterministic installer path, or `null` only when no repeatable mutation exists.

## Reference requirements

Record:

1. official agent and provider sources;
2. verified protocol, endpoint, model, and minimum version;
3. config, auth, and process boundaries;
4. target files and file modes;
5. install/update behavior and secret handling;
6. mock and real-provider validation boundaries;
7. rollback and login recovery;
8. known incompatibilities and unsupported modes.

Do not duplicate the entire core workflow from `SKILL.md`.

## Installer requirements

- Accept explicit target roots for offline tests.
- Validate external payloads before creating target files.
- Write atomically in the target directory.
- Back up every changed existing file to a recoverable timestamped location.
- Preserve an existing non-placeholder credential.
- Produce `[provider-switch]` action logs without secrets.
- Distinguish `create`, `update`, `unchanged`, `backup`, `validate`, and `error` states.
- Return nonzero before partial installation on failed prerequisites or payload validation.
- Avoid modifying the agent's main config or login store for a temporary profile.

## Validation matrix

| Scenario | Required result |
|---|---|
| First install | Dedicated files created with restrictive modes |
| Same-input rerun | Files reported unchanged; no backup churn |
| Existing real key | Key preserved without appearing in output |
| Changed managed file | Previous file copied to backup before replacement |
| Invalid external payload | No target file created or changed |
| Wrapper arguments | User arguments preserve token boundaries and ordering |
| Existing agent login | Login mode remains unchanged after provider mock run |
| Missing dependency | Actionable error and nonzero status |

## Repository release checklist

- Update `agents/openai.yaml` when the user-facing contract changes.
- Update the market manifest and mirrored registry release metadata.
- Update README discovery entries.
- Add or update a skill-specific sanity test.
- Run skill validation, packaging/export, smoke, and repository regression gates.
