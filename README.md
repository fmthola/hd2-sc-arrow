# Super Credit & Rare Sample Arrows (hd2-sc-arrow)

![Thumbnail](thumbnail.png)

Helldivers 2 mod that marks pickups with tall glowing arrows:
**blue arrows on Super Credits, purple arrows on Rare Samples** — pick one, or Both.

![In-game: blue arrows mark Super Credits, purple arrows mark Rare Samples](docs/in-game.png)

Fork of [Giovani1906/hd2-sc-arrow](https://github.com/Giovani1906/hd2-sc-arrow).
The blue Super Credit arrows are upstream's, unchanged. This fork adds **purple
arrows on the Rare Samples** (E-710 Crystal, Black Saffron, Legendarium) — built
with the Blender HD2 SDK by grafting the arrow onto each rare-sample unit and
giving it its own material so it runs alongside the blue credit arrows. Confirmed
in-game (see above). Also adds a local DevSecOps baseline (SonarQube scan +
evidence) and install/revert scripts.

## Code status

Last scan: 2026-06-19. Self-hosted SonarQube Community (server from the local
credential store). Numbers from [`docs/evidence/sonar-report.txt`](docs/evidence/sonar-report.txt).

| Metric | Value |
|---|---|
| Quality gate | OK |
| Bugs | 0 |
| Vulnerabilities | 0 |
| Security hotspots | 0 |
| Code smells | 0 |
| Security rating | A |
| Reliability rating | A |
| Maintainability rating | A |
| Coverage | N/A (no unit tests; binary mod) |
| Packaging check | pass ([`manifest-pull.txt`](docs/evidence/manifest-pull.txt)) |

![SonarQube dashboard](docs/evidence/sonar-dashboard.png)

Gate evidenced by the dashboard above, [`sonar-report.txt`](docs/evidence/sonar-report.txt),
the scrubbed scanner log [`sonar-scan-log.txt`](docs/evidence/sonar-scan-log.txt),
and the [`sonar-issues.png`](docs/evidence/sonar-issues.png) /
[`sonar-measures.png`](docs/evidence/sonar-measures.png) screenshots.

## Status

| Area | State |
|---|---|
| Blue = Super Credit arrows | works (upstream patches); glow / no-glow |
| Purple = Rare Sample arrows | works — confirmed in-game (E-710 Crystal, Black Saffron, Legendarium) |
| Target menu | Blue / Purple / Both, in HD2ModManager EDIT |
| Coexistence | purple uses its own material, so it runs alongside the blue credit arrows |
| SonarQube gate | passing |

## How it works

The mod replaces the Super Credit `unit` with a copy that has an arrow mesh and
bob animation baked in, injected through the `packages/boot` package (patch file
`9ba626afa44a3aa3`). Each appearance variant lives in its own folder
(`blue/glow`, `blue/no_glow`, `purple/glow`, `purple/no_glow`).

### Install

Use [HD2ModManager](https://www.nexusmods.com/helldivers2/mods/109?tab=files):
`Add` the mod archive, enable it, optionally `EDIT` the appearance, then
`Deploy`.

Manual / scripted:

```bash
scripts/install.sh blue/glow /path/to/Helldivers\ 2   # blue = Super Credits; or set HD2_GAME_PATH
```

### Revert

```bash
scripts/revert-mods.sh /path/to/Helldivers\ 2           # removes only this mod's patches
```

Back up the data dir first: `cp -a "$GAME/data" "$GAME/data.bak"`.

## Validation Reports

### Tested environments

| Environment | Result |
|---|---|
| In-game (Helldivers 2, current build) | blue Credit + purple Rare Sample arrows render (see screenshot) |
| SonarQube Community (self-hosted, container scanner via podman) | gate OK |
| Manifest/packaging vs HD2ModManager ingest model | pass |

### Checklist

- [x] `manifest.json` deserializes as a Version 1 manifest
- [x] all patch files match the manager's deploy pattern
- [x] SonarQube scan runs and the quality gate passes
- [x] Rare Sample arrows built and grafted (E-710 Crystal, Black Saffron, Legendarium)
- [x] in-game arrow render confirmed — blue Credits + purple Rare Samples together

### Report log

- 2026-06-19 — v2.1: Rare Sample arrows. The arrow cone from the Super Credit
  unit is grafted onto the rare-sample units via the Blender HD2 SDK and given
  its own material (`0xc7436f5fa783f938`) so it runs alongside the blue credit
  arrows. **Confirmed in-game** (screenshot above). SonarQube gate OK.

- 2026-06-19 — v2: added the blue/purple target menu (blue = Super Credits,
  functional; purple = Samples, preview). Packaging re-validated; SonarQube gate OK.
- 2026-06-19 — Baseline applied to the fork. SonarQube scan: gate OK, 0 bugs /
  0 vulnerabilities / 0 hotspots / 0 code smells, ratings A/A/A. Packaging
  validated against the mod manager's model. Evidence in `docs/evidence/`.

## Validation and DevSecOps

The pipeline is local shell scripts; there is no CI service. See
[`docs/TESTING.md`](docs/TESTING.md) for how this mod is tested.

- **Test** — packaging and install/revert checks (`docs/TESTING.md`).
- **Scan** — `scripts/sonar.sh` (scan + quality gate),
  `scripts/sonar-evidence.sh` (UI screenshots). Server URL and token come from
  the local credential store (KWallet) at run time.
- **Deploy / revert** — `scripts/install.sh` installs a variant;
  `scripts/revert-mods.sh` removes only this mod's patches.

## Security

- No bugs, vulnerabilities, or security hotspots reported by SonarQube
  (`docs/evidence/sonar-report.txt`).
- No secrets, server URLs, or machine paths in the repo; the scan scripts read
  the SonarQube URL and token from KWallet at run time.

## Relationship to upstream

Fork of [Giovani1906/hd2-sc-arrow](https://github.com/Giovani1906/hd2-sc-arrow).
The mod content (manifest, patches, thumbnail) is upstream's. This fork adds the
DevSecOps baseline, scripts, docs, and evidence. License follows upstream.
