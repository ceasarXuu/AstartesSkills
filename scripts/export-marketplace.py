#!/usr/bin/env python3

import json
from pathlib import Path


def log(message: str) -> None:
    print(f"[export] {message}")


def load_json(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def main() -> int:
    repo_root = Path(__file__).resolve().parent.parent
    dist_root = repo_root / "dist"
    markets_root = dist_root / "markets" / "openai-compatible"
    registry_path = repo_root / "registry" / "skills.json"

    registry = load_json(registry_path)
    dist_root.mkdir(exist_ok=True)
    markets_root.mkdir(parents=True, exist_ok=True)

    catalog = {
        "version": registry["version"],
        "skills": [],
    }

    for skill in registry.get("skills", []):
        skill_entry = {
            "id": skill["id"],
            "name": skill["name"],
            "summary": skill["summary"],
            "tags": skill.get("tags", []),
            "path": skill["path"],
            "installable": skill.get("installable", True),
            "source": skill.get("source", {}),
            "release": skill.get("release", {}),
            "markets": list(skill.get("markets", {}).keys()),
        }
        catalog["skills"].append(skill_entry)

        manifest_relpath = (
            skill.get("markets", {})
            .get("openai-compatible", {})
            .get("manifest")
        )
        if not manifest_relpath:
            continue

        manifest_path = repo_root / manifest_relpath
        manifest = load_json(manifest_path)
        output_path = markets_root / f"{skill['id']}.json"
        with output_path.open("w", encoding="utf-8") as handle:
            json.dump(manifest, handle, indent=2, ensure_ascii=False)
            handle.write("\n")
        log(f"wrote {output_path.relative_to(repo_root)}")

    catalog_path = dist_root / "catalog.json"
    with catalog_path.open("w", encoding="utf-8") as handle:
        json.dump(catalog, handle, indent=2, ensure_ascii=False)
        handle.write("\n")
    log(f"wrote {catalog_path.relative_to(repo_root)}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
