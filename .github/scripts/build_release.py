#!/usr/bin/env python3
"""Make the flat installer ZIP for genericMud's built-in Update from source.

Run in GitHub Actions when a GitHub Release is published. The asset URL is
stable across releases and is persisted as pack.toml origin inside the ZIP.
"""
from __future__ import annotations

import os
import re
import sys
import tomllib
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEST = ROOT / 'dist' / 'Soulbound-Soundpack.zip'
repo = os.environ.get('GITHUB_REPOSITORY', '')
tag = os.environ.get('GITHUB_REF_NAME', '')
if not re.fullmatch(r'[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+', repo):
    raise SystemExit('ERROR: Invalid/missing GITHUB_REPOSITORY')
if not re.fullmatch(r'v[0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?', tag):
    raise SystemExit('ERROR: Release tag should be vX.Y.Z (or vX.Y.Z.W)')
manifest_path = ROOT / 'pack.toml'
manifest_text = manifest_path.read_text(encoding='utf-8')
manifest = tomllib.loads(manifest_text)
if tag[1:] != manifest.get('version'):
    raise SystemExit(f'ERROR: Release {tag} != pack.toml version {manifest.get("version")}')
if manifest.get('id') != 'soulbound-soundpack-twoje-ogg':
    raise SystemExit('ERROR: pack ID unexpectedly changed')
if manifest.get('entry') != 'soundpack.lua' or manifest.get('dialect') != 'lua':
    raise SystemExit('ERROR: malformed pack manifest')
if not (ROOT / 'soundpack.lua').is_file():
    raise SystemExit('ERROR: Missing soundpack.lua')

sounds = sorted((ROOT / 'sounds').rglob('*.ogg'))
if not sounds:
    raise SystemExit('ERROR: Brak plikow OGG w sounds/')
for sound in sounds:
    if sound.stat().st_size <= 128:
        raise SystemExit(f'ERROR: Empty/tiny OGG: {sound}')

url = f'https://github.com/{repo}/releases/latest/download/Soulbound-Soundpack.zip'
# Ignore any development-time origin: release points to its own repository.
manifest_text = re.sub(r'^origin\s*=.*(?:\n|$)', '', manifest_text, flags=re.M)
manifest_text = manifest_text.rstrip() + f'\norigin = "{url}"\n'
parsed = tomllib.loads(manifest_text)
assert parsed['origin'] == url

DEST.parent.mkdir(parents=True, exist_ok=True)
if DEST.exists(): DEST.unlink()
with zipfile.ZipFile(DEST, 'w', compression=zipfile.ZIP_STORED) as z:
    z.writestr('pack.toml', manifest_text.encode('utf-8'))
    for name in ('soundpack.lua', 'README_PL.txt', 'CHANGELOG_PL.txt'):
        z.write(ROOT / name, name)
    for sound in sounds:
        z.write(sound, sound.relative_to(ROOT).as_posix())

with zipfile.ZipFile(DEST) as z:
    assert z.testzip() is None
    assert z.namelist()[0] == 'pack.toml'
    assert len([n for n in z.namelist() if n.endswith('.ogg')]) == len(sounds)
    assert 'origin = "' + url + '"' in z.read('pack.toml').decode('utf-8')
print(f'OK: {DEST} ({DEST.stat().st_size} B, {len(sounds)} OGG, origin={url})')
