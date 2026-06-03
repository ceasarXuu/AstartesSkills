#!/usr/bin/env python3

import json
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3:
        print("usage: validate-skill-registry-coverage.py <registry> <repo-root>", file=sys.stderr)
        return 2

    registry_path = Path(sys.argv[1])
    repo_root = Path(sys.argv[2])
    skills_dir = repo_root / "skills"

    with registry_path.open("r", encoding="utf-8") as handle:
        registry = json.load(handle)

    registered_paths = []
    registered_ids = []
    for skill in registry.get("skills", []):
        skill_id = skill.get("id")
        path = skill.get("path")
        assert isinstance(skill_id, str) and skill_id.strip(), "registry skill missing id"
        assert isinstance(path, str) and path.strip(), f"registry skill {skill_id} missing path"
        assert path == f"skills/{skill_id}", f"registry id/path mismatch for {skill_id}: {path}"
        registered_ids.append(skill_id)
        registered_paths.append(path)

    duplicate_ids = sorted({item for item in registered_ids if registered_ids.count(item) > 1})
    duplicate_paths = sorted({item for item in registered_paths if registered_paths.count(item) > 1})
    assert not duplicate_ids, f"duplicate registry ids: {duplicate_ids}"
    assert not duplicate_paths, f"duplicate registry paths: {duplicate_paths}"

    actual_paths = sorted(
        f"skills/{path.name}"
        for path in skills_dir.iterdir()
        if path.is_dir() and path.name != "_templates"
    )
    registered_path_set = set(registered_paths)
    actual_path_set = set(actual_paths)
    missing_registry = sorted(actual_path_set - registered_path_set)
    missing_folder = sorted(registered_path_set - actual_path_set)
    assert not missing_registry, f"skill folders missing registry entries: {missing_registry}"
    assert not missing_folder, f"registry entries missing skill folders: {missing_folder}"

    print(
        f"[validate] registered skills: {len(registered_path_set)}; "
        f"discovered skill folders: {len(actual_path_set)}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
