# show-my-repo Design

## Goal

Add a repository-packaging skill that turns code and docs into evidence-backed external presentation materials.

## Design

Ship `show-my-repo` as a self-contained installable skill with:

- a concise `SKILL.md` that defines trigger conditions, workflow, claim discipline, and required outputs
- reusable `rubrics/` for value extraction, architecture framing, highlight selection, commercialization logic, and evidence grading
- reusable `templates/` for investor, user, demo, pitch, FAQ, and fact-sheet outputs
- short `examples/` that calibrate tone without bloating the main skill body
- a default write-to-disk contract that saves each run under repo-root `show-my-repo/YYYYMMDD_vN/`

## Decisions

- Keep the main skill file concise and move longer evaluation logic into auxiliary files
- Treat evidence grading as a first-class constraint so packaging does not drift into overclaiming
- Optimize for multi-audience output rather than a single generic repo summary
- Keep the skill installable and marketplace-ready on first commit by adding agent metadata, market metadata, and registry registration together
- Default the runtime artifact to a versioned Markdown document so repeated repo-packaging runs remain comparable and reviewable
