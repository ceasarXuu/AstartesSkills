#!/usr/bin/env python3
"""Validate a conventional versioned docs layout."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


REQUIRED_VERSION_FILES = {
    "engineering-plan.md",
    "prd.md",
    "technical-design.md",
}
DEFAULT_RETIRED_DIRS = {
    "docs/engineering-plan",
    "docs/operations",
    "docs/prd",
    "docs/technical-design",
}


def fail(message: str) -> None:
    raise SystemExit(f"docs governance validation failed: {message}")


def contains_any(text: str, needles: tuple[str, ...]) -> bool:
    return any(needle in text for needle in needles)


def validate_docs_tree(repo_root: Path, docs_root: Path) -> None:
    if not docs_root.exists():
        fail(f"{docs_root} is required")
    if not docs_root.is_dir():
        fail(f"{docs_root} must be a directory")

    root_files = sorted(path for path in docs_root.iterdir() if path.is_file())
    if root_files:
        fail("docs root must not contain files: " + ", ".join(str(path) for path in root_files))

    retired = sorted(repo_root / path for path in DEFAULT_RETIRED_DIRS if (repo_root / path).exists())
    if retired:
        fail("retired docs directories must not exist: " + ", ".join(str(path) for path in retired))

    version_pattern = re.compile(r"^v\d+\.\d+\.\d+$")
    version_dirs = sorted(path for path in docs_root.iterdir() if path.is_dir() and version_pattern.match(path.name))
    if not version_dirs:
        fail("at least one docs/v<version> directory is required")

    for version_dir in version_dirs:
        children = sorted(version_dir.iterdir())
        subdirs = [path.name for path in children if path.is_dir()]
        if subdirs:
            fail(f"{version_dir} must not contain subdirectories: {', '.join(subdirs)}")

        files = {path.name for path in children if path.is_file()}
        if files != REQUIRED_VERSION_FILES:
            actual = ", ".join(sorted(files)) if files else "no files"
            expected = ", ".join(sorted(REQUIRED_VERSION_FILES))
            fail(f"{version_dir} must contain exactly {expected}; found {actual}")

        prd_path = version_dir / "prd.md"
        technical_path = version_dir / "technical-design.md"
        plan_path = version_dir / "engineering-plan.md"
        prd = prd_path.read_text(encoding="utf-8")
        technical = technical_path.read_text(encoding="utf-8")
        plan = plan_path.read_text(encoding="utf-8")

        if not contains_any(prd, ("PRD 文档版本", "PRD Document Version")):
            fail(f"{prd_path} must declare a PRD document version")
        if not contains_any(prd, ("PRD 文档版本记录", "PRD Document Version History")):
            fail(f"{prd_path} must include PRD document version history")

        prd_ref = str(prd_path.relative_to(repo_root))
        technical_ref = str(technical_path.relative_to(repo_root))
        if prd_ref not in technical and "`prd.md`" not in technical:
            fail(f"{technical_path} must reference {prd_ref}")
        if prd_ref not in plan and "`prd.md`" not in plan:
            fail(f"{plan_path} must reference {prd_ref}")
        if technical_ref not in plan and "`technical-design.md`" not in plan:
            fail(f"{plan_path} must reference {technical_ref}")


def validate_version_source(repo_root: Path, version_source: Path) -> None:
    if not version_source.exists():
        return
    data = json.loads(version_source.read_text(encoding="utf-8"))
    current = data.get("currentRelease")
    if not isinstance(current, dict):
        return

    documents = current.get("documents", [])
    if not isinstance(documents, list):
        fail("currentRelease.documents must be a list")
    for document in documents:
        if not isinstance(document, str) or not document:
            fail("currentRelease.documents entries must be non-empty strings")
        if document.startswith("docs/archive/"):
            fail(f"currentRelease document must not point to archive: {document}")
        if not (repo_root / document).exists():
            fail(f"currentRelease document does not exist: {document}")

    root = current.get("documentsRoot")
    required = [
        current.get("prdDocument"),
        current.get("technicalDesignDocument"),
        current.get("engineeringPlanDocument"),
    ]
    if isinstance(root, str):
        for document in required:
            if not isinstance(document, str) or not document:
                fail("currentRelease version document fields must be non-empty strings")
            if not document.startswith(f"{root}/"):
                fail(f"{document} must be inside {root}")
            if document not in documents:
                fail(f"{document} must be listed in currentRelease.documents")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", default=".", help="Repository root")
    parser.add_argument("--docs-root", default="docs", help="Docs directory relative to repo root")
    parser.add_argument(
        "--version-source",
        default="version.json",
        help="Optional JSON version source relative to repo root",
    )
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    validate_docs_tree(repo_root, repo_root / args.docs_root)
    validate_version_source(repo_root, repo_root / args.version_source)
    print("docs governance validation passed")


if __name__ == "__main__":
    main()
