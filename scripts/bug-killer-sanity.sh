#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
echo "[bug-killer-sanity] checking bug-killer package contract"

python3 - "$repo_root" <<'PY'
import json
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
skill_dir = root / 'skills/bug-killer'

def read(path):
    return (root / path).read_text(encoding='utf-8')

def require(text, phrase, label):
    if re.sub(r'\s+', ' ', phrase) not in re.sub(r'\s+', ' ', text):
        raise AssertionError(f'{label} missing: {phrase}')

skill = read('skills/bug-killer/SKILL.md')
agent = read('skills/bug-killer/agents/openai.yaml')
template = read('skills/bug-killer/templates/case-template.md')
fixtures = read('skills/bug-killer/references/interaction-fixtures.md')
manifest = json.loads(read('skills/bug-killer/markets/openai-compatible.json'))
registry = json.loads(read('registry/skills.json'))
entry = next(item for item in registry['skills'] if item['id'] == 'bug-killer')
if len(skill.splitlines()) > 500:
    raise AssertionError('SKILL.md exceeds 500 lines')
for phrase in [
    'Work in short iterations',
    'Start with the report, available context, and static reasoning',
    'make the smallest focused repair and validate it promptly',
    'Do not require reproduction before investigation or repair',
    'Respect the user\'s and project\'s permissions, test restrictions',
    'Mark a problem fixed only when relevant validation',
    'do not claim that static review alone proves the symptom is gone',
    'do not create a case just to satisfy a ritual',
    'never change `.gitignore` or Git tracking without confirmation',
    'Case files contain only `Problem`, `Hypothesis`, and `Evidence` nodes',
    'references/interaction-fixtures.md',
]:
    require(skill, phrase, 'SKILL.md')
for phrase in ['Trace the relevant code first', 'without requiring reproduction or conclusive proof beforehand', 'report the repair as unverified']:
    require(agent, phrase, 'agents/openai.yaml')
for phrase in ['# Problem P-001', '## Hypothesis H-001', '## Evidence E-001', 'Repair candidate:', 'fix-validation']:
    require(template, phrase, 'case template')
for heading in re.findall(r'(?m)^#{1,6} .+$', template):
    if not heading.startswith(('# Problem P-001:', '## Hypothesis H-', '## Evidence E-')):
        raise AssertionError(f'case template has illegal heading: {heading}')
for phrase in ['## Code-Backed Candidate Without Reproduction', '## Suspicion Without A Mechanism', '## No Executable Validation', '## Conflicting Evidence', '## Public Repository Case Privacy', '## Fix Validation']:
    require(fixtures, phrase, 'fixtures')
if manifest.get('release') != entry.get('release'):
    raise AssertionError('manifest release metadata does not match registry')
if manifest.get('description') != entry.get('summary'):
    raise AssertionError('manifest description does not match registry summary')
if entry.get('path') != 'skills/bug-killer':
    raise AssertionError('registry path mismatch')
for path in ['README.md', 'README.zh-CN.md']:
    require(read(path), '`bug-killer`', path)
require(read('scripts/test-repo.sh'), '[[ "$skill_id" == "bug-killer" ]]', 'scripts/test-repo.sh')
require(read('scripts/validate-repo.sh'), 'scripts/bug-killer-sanity.sh', 'scripts/validate-repo.sh')
print('[bug-killer-sanity] contract checks passed')
PY
