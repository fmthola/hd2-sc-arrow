# Roadmap — arrow Samples as well as Super Credits

Planned extension: a toggle in the mod manager to put arrows above **Super
Credits**, **Samples**, or **Both**, keeping the existing colour/glow choices.

## How the mod targets a pickup

The mod replaces a Stingray `unit` (the pickup entity) with a rebuilt copy that
has an arrow mesh and bob animation baked in. It is injected through the
`packages/boot` package; the patch filename `9ba626afa44a3aa3` is
`murmur64("packages/boot")`. The Super Credit unit it replaces has name-hash
`0xbd6f4de16b9aedcd`.

To arrow a different pickup, replace that pickup's `unit` the same way.

## Sample unit IDs

All sample pickup units (name-hash = `murmur64` of the asset path), confirmed
present in the current game build. The three named `*_super_sample_*` are the
per-front Super Samples:

| unit name-hash | asset |
|---|---|
| `0x2b5d3186ee3a4a84` | bug_egg_super_sample_01 |
| `0xc71c0c7b2e688b9b` | automaton_super_sample_01 |
| `0x9d4935fa69b6b41a` | super_uranium_sample_01 |
| `0x5016ee397fdcfb6c` | bug_sample_01 |
| `0xd463836441cd0ba7` | bug_enemy_sample_01 |
| `0x769533b3827352b5` | bug_intel_sample_01 |
| `0xbeb2a0f09e36bf72` | automaton_sample_01 |
| `0xa2414ed6e129c19f` | illuminate_enemy_sample_01 |
| `0xb39fcf5c73d5c383` | artifact_sample_01 |
| `0x64b49b9d8a445266` | bio_sample_01 |
| `0xbd30758426ed2566` | blacksaffron_sample_01 |
| `0xad972a2e815a49aa` | crystalized_e710_sample_01 |
| `0xdefe062c2567c23d` | legendarium_sample_01 |
| `0x700e9500e95541bf` | tech_sample_01 |
| `0xb4d6f2f83bde45a9` | crystal_sample_01 |
| `0x8208ea6cb095be54` | mineral_sample_01 |
| `0x86f3cb87d97942b4` | plant_sample_01 |
| `0x8379b174fa1fe9f0` | se_intel_sample_01 |

Asset paths come from the community hashlist
(github.com/HW12Dev/Helldivers2-Hashlist); IDs were confirmed by reproducing
`murmur64("packages/boot")` and by finding each hash in the game archives.

## The toggle

The mod manager treats each `Options[]` entry as an independent group and merges
the selected sub-option's `Include` folders on deploy, renumbering patches per
archive. So two groups compose cleanly:

```jsonc
{ "Name": "Targets", "SubOptions": [
    { "Name": "Super Credits only", "Include": ["geometry/credits"] },
    { "Name": "Samples only",       "Include": ["geometry/samples"] },
    { "Name": "Both",               "Include": ["geometry/credits","geometry/samples"] } ] }
```

Recommended design: keep colour/glow orthogonal by having the geometry patches
reference a shared arrow material defined in a separate appearance patch (6
built folders). Fallback if cross-patch material resolution fails: one combined
group enumerating targets x appearance.

## Decisions

- Scope: arrow all 18 sample units.
- Architecture: orthogonal Targets x Appearance.

## Status

1. Loose `.patch` overrides still apply on the current `DSAR`/`.nxa` build —
   confirmed (the blue Super Credit arrows render in-game).
2. Extractor/SDK for the current build — done. The Blender HD2 SDK reads the
   live game data and all sample units resolve as importable `unit` entries.

## Done

3. Arrow grafted onto all 18 sample units at the RawMesh level (extract the
   arrow cone from the credit unit, append to each sample mesh + LOD, bind to
   the rig, re-serialize). One `9ba626afa44a3aa3` patch. Structurally validated.

## Remaining

4. Confirm in-game that the arrows render over samples.
5. Optional: bundle the credit arrow material for a uniform purple colour and
   real glow/no-glow variants (currently the arrow uses the sample's material).

When done, drop the exported patches into `purple/glow` and `purple/no_glow`,
replacing the placeholders, and re-cut the release.
