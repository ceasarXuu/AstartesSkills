#!/usr/bin/env python3
"""Validate repository documentation integrity without imposing a default layout."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from urllib.parse import unquote

VERSION_TRIO = {"prd.md", "technical-design.md", "engineering-plan.md"}
EXCLUDED_DIRS = {".git", "node_modules", "dist", "vendor", ".venv", "venv"}
LINK_RE = re.compile(r"!?\[[^\]]*\]\(([^)]+)\)")
FENCE_RE = re.compile(r"```.*?```|~~~.*?~~~", re.S)


def fail(message: str) -> None:
    raise SystemExit(f"docs governance validation failed: {message}")


def markdown_files(repo_root: Path) -> list[Path]:
    files: list[Path] = []
    for path in repo_root.rglob("*.md"):
        try:
            rel = path.relative_to(repo_root)
        except ValueError:
            continue
        if any(part in EXCLUDED_DIRS for part in rel.parts):
            continue
        files.append(path)
    return sorted(files)


def normalize_link_target(raw: str) -> str | None:
    target = raw.strip()
    if target.startswith("<") and target.endswith(">"):
        target = target[1:-1].strip()
    if not target:
        return None

    # Markdown titles may follow a path: (path "title").
    if " " in target and not target.startswith(("http://", "https://")):
        target = target.split()[0]

    lower = target.lower()
    if lower.startswith(("http://", "https://", "mailto:", "data:", "javascript:")):
        return None
    if target.startswith("#"):
        return None

    target = unquote(target.split("#", 1)[0].split("?", 1)[0])
    if not target or any(token in target for token in ("<", ">", "{", "}")):
        return None
    return target


def validate_local_markdown_links(repo_root: Path) -> None:
    broken: list[str] = []
    for source in markdown_files(repo_root):
        text = FENCE_RE.sub("", source.read_text(encoding="utf-8", errors="replace"))
        for raw in LINK_RE.findall(text):
            target = normalize_link_target(raw)
            if target is None:
                continue
            resolved = Path(target)
            if not resolved.is_absolute():
                resolved = source.parent / resolved
            if not resolved.exists():
                broken.append(f"{source.relative_to(repo_root)} -> {target}")
    if broken:
        sample = "; ".join(broken[:20])
        suffix = f"; +{len(broken) - 20} more" if len(broken) > 20 else ""
        fail(f"broken local Markdown links: {sample}{suffix}")


def validate_version_source(repo_root: Path, version_source: Path) -> None:
    if not version_source.exists():
        return
    try:
        data = json.loads(version_source.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        fail(f"invalid JSON in {version_source.relative_to(repo_root)}: {exc}")

    current = data.get("currentRelease")
    if not isinstance(current, dict):
        return

    documents = current.get("documents", [])
    if documents is None:
        documents = []
    if not isinstance(documents, list):
        fail("currentRelease.documents must be a list")

    for document in documents:
        if not isinstance(document, str) or not document:
            fail("currentRelease.documents entries must be non-empty strings")
        if document.startswith("docs/archive/"):
            fail(f"currentRelease document must not point to archive: {document}")
        if not (repo_root / document).exists():
            fail(f"currentRelease document does not exist: {document}")

    for key in ("prdDocument", "technicalDesignDocument", "engineeringPlanDocument"):
        document = current.get(key)
        if document is None:
            continue
        if not isinstance(document, str) or not document:
            fail(f"currentRelease.{key} must be a non-empty string")
        if document.startswith("docs/archive/"):
            fail(f"currentRelease.{key} must not point to archive: {document}")
        if not (repo_root / document).exists():
            fail(f"currentRelease.{key} does not exist: {document}")
        if documents and document not in documents:
            fail(f"currentRelease.{key} must be listed in currentRelease.documents")


def validate_version_trio_profile(docs_root: Path) -> None:
    if not docs_root.is_dir():
        fail(f"version-trio profile requires docs directory: {docs_root}")

    root_files = sorted(path.name for path in docs_root.iterdir() if path.is_file())
    if root_files:
        fail("version-trio profile forbids files directly under docs/: " + ", ".join(root_files))

    pattern = re.compile(r"^v\d+\.\d+\.\d+$")
    version_dirs = sorted(path for path in docs_root.iterdir() if path.is_dir() and pattern.match(path.name))
    if not version_dirs:
        fail("version-trio profile requires at least one docs/v<version> directory")

    for version_dir in version_dirs:
        subdirs = sorted(path.name for path in version_dir.iterdir() if path.is_dir())
        if subdirs:
            fail(f"version-trio profile forbids subdirectories in {version_dir}: {', '.join(subdirs)}")
        files = {path.name for path in version_dir.iterdir() if path.is_file()}
        if files != VERSION_TRIO:
            fail(
                f"{version_dir} must contain exactly {', '.join(sorted(VERSION_TRIO))}; "
                f"found {', '.join(sorted(files)) if files else 'no files'}"
            )


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", default=".", help="Repository root")
    parser.add_argument("--docs-root", default="docs", help="Docs directory relative to repo root")
    parser.add_argument(
        "--version-source",
        default="version.json",
        help="Optional JSON version source relative to repo root",
    )
    parser.add_argument(
        "--profile",
        choices=("generic", "version-trio"),
        default="generic",
        help="Generic integrity checks by default; fixed version-trio layout only when explicitly selected",
    )
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    if not repo_root.is_dir():
        fail(f"repository root does not exist: {repo_root}")

    validate_local_markdown_links(repo_root)
    validate_version_source(repo_root, repo_root / args.version_source)

    if args.profile == "version-trio":
        validate_version_trio_profile(repo_root / args.docs_root)

    print(f"docs governance validation passed ({args.profile})")


if __name__ == "__main__":
    main()
