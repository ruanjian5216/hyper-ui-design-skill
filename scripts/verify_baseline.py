"""Verify frozen rendering sources, optionally comparing an existing repository."""
import argparse
import hashlib
import json
from pathlib import Path


def contained_path(root, relative):
    candidate = (root / relative).resolve()
    if not candidate.is_relative_to(root.resolve()):
        raise ValueError(f"Path outside root: {relative}")
    return candidate


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--platform", choices=("kotlin", "flutter"))
    parser.add_argument("--root", type=Path, help="Repository root to compare")
    parser.add_argument("--group", action="append", help="Compare only these groups")
    args = parser.parse_args()
    if bool(args.platform) != bool(args.root):
        parser.error("--platform and --root must be used together")
    baseline = Path(__file__).resolve().parents[1] / "assets" / "baseline"
    manifest = json.loads((baseline / "manifest.json").read_text(encoding="utf-8"))
    problems = []
    checked = compared = 0
    for item in manifest["files"]:
        snapshot = contained_path(baseline / item["platform"], item["path"])
        checked += 1
        if not snapshot.is_file() or digest(snapshot) != item["sha256"]:
            problems.append(f"SNAPSHOT MISMATCH {item['platform']}/{item['path']}")
        if args.root and item["platform"] == args.platform:
            if args.group and item["group"] not in args.group:
                continue
            target = contained_path(args.root, item["path"])
            compared += 1
            if not target.is_file():
                problems.append(f"MISSING {item['path']}")
            elif digest(target) != item["sha256"]:
                problems.append(f"CHANGED {item['path']}")
    if args.root and compared == 0:
        problems.append("No matching source files selected")
    for problem in problems:
        print(problem)
    print(f"Snapshot files checked: {checked}; repository files compared: {compared}; differences: {len(problems)}")
    print("Hash comparison does not establish pixel or animation equivalence.")
    return 1 if problems else 0


if __name__ == "__main__":
    raise SystemExit(main())
