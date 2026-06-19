# Testing

How this mod is validated. The mod ships binary game-asset patches, so testing
covers packaging correctness, install/revert safety, and static analysis of the
tooling rather than unit tests.

## 1. Manifest and packaging

The mod is loaded by HD2ModManager. It must:

- carry a `manifest.json` at the archive root that deserializes into the
  manager's `Manifest` model (it is a `Version 1` manifest), and
- name every patch file to the manager's pattern
  `^[0-9a-f]{16}\.patch_\d+(\.gpu_resources|\.stream)?$`.

Both were checked against the manager's own Rust model and patch-name regex.
Evidence: `evidence/manifest-pull.txt`.

## 2. Install and revert

- `scripts/install.sh <variant> [GAME_PATH]` copies one appearance variant's
  patch triplet into `<game>/data`.
- `scripts/revert-mods.sh [GAME_PATH]` removes only this mod's archive
  (`9ba626afa44a3aa3.patch_*`); base game files and other mods are untouched.

Back up the data dir before installing: `cp -a "$GAME/data" "$GAME/data.bak"`.

## 3. Static analysis (SonarQube)

```bash
scripts/sonar.sh           # scan + quality gate (exit 0 pass)
scripts/sonar-evidence.sh  # capture the SonarQube UI screenshots
```

The scanner analyses the pipeline tooling under `scripts/`. Coverage is not
applicable (no unit tests; the product is binary assets), so it is excluded from
the gate; bug, vulnerability, hotspot, and code-smell rules still apply.
Evidence: `evidence/sonar-report.txt` and the `sonar-*.png` screenshots.

## 4. In-game check

After install, launch the game and confirm an arrow renders above a Super
Credit pile, including at distance. Revert with `scripts/revert-mods.sh`.
