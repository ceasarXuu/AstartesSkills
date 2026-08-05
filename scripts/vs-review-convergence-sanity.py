#!/usr/bin/env python3

from __future__ import annotations

import re
import sys
from pathlib import Path


def fail(message: str) -> None:
    raise AssertionError(f"[vs-review-convergence] {message}")


def require(text: str, pattern: str, message: str) -> None:
    if re.search(pattern, text, re.MULTILINE | re.DOTALL) is None:
        fail(message)


def reject(text: str, pattern: str, message: str) -> None:
    if re.search(pattern, text, re.MULTILINE | re.DOTALL) is not None:
        fail(message)


def check_contract(
    skill: str,
    governor: str,
    triage: str,
    template: str,
    agent_manifest: str,
    market_manifest: str,
) -> None:
    require(
        skill,
        r"Default automatic review budget is exactly 2 total rounds",
        "skill must cap automatic review at two completed rounds",
    )
    require(
        skill,
        r"A third or later round must never start automatically",
        "skill must prohibit automatic third-or-later rounds",
    )
    require(
        skill,
        r"requires explicit\s+user approval for that additional round",
        "skill must require explicit user approval for extra rounds",
    )
    require(
        skill,
        r"Closure review is not a second full-system review",
        "skill must freeze closure review scope",
    )
    require(
        skill,
        r"E4 reasoning alone must not\s+authorize scope expansion",
        "skill must prevent reviewer-only reasoning from expanding scope",
    )
    require(
        skill,
        r"stop automatic modification when scope drift,\s+repeated failure classes, net blocker growth, insufficient external\s+evidence, or round-budget exhaustion",
        "skill must define deterministic stop triggers",
    )
    require(
        skill,
        r"If blockers remain after Round 2, automatic work is over",
        "skill must stop rather than recurse after the closure round",
    )
    require(
        skill,
        r"Convergence Reflection And User Escalation",
        "skill must include convergence reflection and user escalation",
    )
    require(
        skill,
        r"last known-good checkpoint",
        "skill must preserve a rollback checkpoint",
    )

    require(
        governor,
        r"Round 1: initial adversarial review\s+Round 2: focused blocking-closure review",
        "governor must define the two-round state machine",
    )
    require(
        governor,
        r"Round 3 or later is prohibited unless the user explicitly approves",
        "governor must reject unapproved extra rounds",
    )
    require(
        governor,
        r"unrelated-existing-risk",
        "governor must classify unrelated closure findings",
    )
    require(
        governor,
        r"E4 alone cannot authorize scope expansion",
        "governor must enforce the evidence gate",
    )
    require(
        governor,
        r"unresolved blocker count decreases",
        "governor must test convergence",
    )
    require(
        governor,
        r"rollback-evaluation-required",
        "governor must support rollback evaluation",
    )
    require(
        governor,
        r"The main agent must not modify the artifact or start another reviewer before the\s+required user decision is recorded",
        "governor stop must restore user control",
    )

    require(
        triage,
        r"## Evidence Authority",
        "triage rubric must classify evidence authority",
    )
    require(
        triage,
        r"`E4`[\s\S]*hypothesis, not independent external\s+evidence",
        "triage rubric must demote agent reasoning to hypothesis",
    )
    require(
        triage,
        r"## Closure-Round Blocking Admissibility",
        "triage rubric must gate closure blockers",
    )
    for relation in (
        "original-blocker-open",
        "fix-regression",
        "direct-adjacent-objective-failure",
    ):
        require(
            triage,
            re.escape(relation),
            f"triage rubric must support closure relation {relation}",
        )
    require(
        triage,
        r"If blockers remain after Round 2, the workflow is not allowed to start Round 3\s+automatically",
        "triage rubric must stop automatic recursive review",
    )

    require(
        template,
        r"Report schema: adversarial-v2",
        "report template must use adversarial-v2",
    )
    require(
        template,
        r"Automatic round budget: 2",
        "report template must record the automatic round budget",
    )
    require(
        template,
        r"## Review Control Contract",
        "report template must freeze objective and scope",
    )
    require(
        template,
        r"### Authoritative Sources",
        "report template must inventory external authority",
    )
    require(
        template,
        r"### Review Governor",
        "report template must record deterministic governor decisions",
    )
    require(
        template,
        r"### Convergence Reflection",
        "report template must record non-convergence reflection",
    )
    require(
        template,
        r"### User Decision",
        "report template must restore user control",
    )
    require(
        template,
        r"Third-or-later round explicitly user-approved before launch",
        "report template must audit approval before extra rounds",
    )
    require(
        template,
        r"Control outcome: none \| non-convergent \| scope-drift-detected \| evidence-insufficient \| goal-redefinition-required \| user-decision-required",
        "report template must expose bounded stop outcomes",
    )
    require(
        template,
        r"E4 reasoning alone must not authorize scope expansion",
        "report template must preserve the evidence gate",
    )
    reject(
        template,
        r"append `## Round 2`, `## Round 3`, and so on",
        "report template must not preserve unbounded round guidance",
    )

    require(
        agent_manifest,
        r"two automatic completed rounds",
        "agent discovery prompt must expose the round cap",
    )
    require(
        agent_manifest,
        r"explicit user approval before any third or later round",
        "agent discovery prompt must expose extra-round approval",
    )
    require(
        agent_manifest,
        r"E4 reviewer reasoning",
        "agent discovery prompt must expose the evidence gate",
    )
    require(
        market_manifest,
        r"bounded",
        "market description must describe bounded review",
    )
    require(
        market_manifest,
        r"scope drift",
        "market description must describe scope-drift control",
    )


def main() -> int:
    repo_root = Path(__file__).resolve().parents[1]
    paths = {
        "skill": repo_root / "skills/subagent-vs-review/SKILL.md",
        "governor": repo_root / "skills/subagent-vs-review/references/review-governor.md",
        "triage": repo_root / "skills/subagent-vs-review/references/finding-triage-rubric.md",
        "template": repo_root / "skills/subagent-vs-review/references/review-report-template.md",
        "agent_manifest": repo_root / "skills/subagent-vs-review/agents/openai.yaml",
        "market_manifest": repo_root / "skills/subagent-vs-review/markets/openai-compatible.json",
    }
    for label, path in paths.items():
        if not path.is_file():
            fail(f"missing {label}: {path.relative_to(repo_root)}")

    texts = {label: path.read_text(encoding="utf-8") for label, path in paths.items()}
    check_contract(**texts)

    weakened = texts["skill"].replace(
        "Default automatic review budget is exactly 2 total rounds",
        "Default automatic review budget is flexible",
        1,
    )
    try:
        check_contract(
            skill=weakened,
            governor=texts["governor"],
            triage=texts["triage"],
            template=texts["template"],
            agent_manifest=texts["agent_manifest"],
            market_manifest=texts["market_manifest"],
        )
    except AssertionError:
        pass
    else:
        fail("negative fixture passed after weakening the automatic round budget")

    weakened_template = texts["template"].replace(
        "E4 reasoning alone must not authorize scope expansion.",
        "E4 reasoning may authorize scope expansion.",
        1,
    )
    try:
        check_contract(
            skill=texts["skill"],
            governor=texts["governor"],
            triage=texts["triage"],
            template=weakened_template,
            agent_manifest=texts["agent_manifest"],
            market_manifest=texts["market_manifest"],
        )
    except AssertionError:
        pass
    else:
        fail("negative fixture passed after weakening the evidence gate")

    print("[vs-review-convergence] convergence contract passed")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as exc:
        print(exc, file=sys.stderr)
        raise SystemExit(1)
