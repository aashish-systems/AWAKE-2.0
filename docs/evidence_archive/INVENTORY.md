# Evidence Inventory

## Repository status
- Branch: main
- HEAD: 0e9b806611c0bff6523f16b69bd53539a3e467a6
- Working tree: modified user files preserved; archival docs added without touching RTL or OpenLane run directories.
- Remotes: origin -> https://github.com/aashish-systems/AWAKE-2.0
- Disk: /dev/loop4       32G   22G  8.1G  74% /workspaces
- Total repo size: 3.7G

## Artifact categories

| Category | Discovered path | Count | Size | Archival decision | Notes |
|---|---|---:|---:|---|---|
| RTL sources | rtl/ | 19 | 46006 B | preserve | No RTL edits made during archival task |
| OpenLane configs | flow/config.json, flow/config.json.bak | 2 | 1571 B | preserve in place | flow/config.json is user-modified; left untouched |
| Simulation traces and benches | sim/, tb/ | 20 | 91210 B | preserve in place | Source-level validation artifacts |
| Result checkpoints | results/ | 4 | 3309584 B | preserve and archive manifest | Contains checkpoint metrics and netlist artifacts |
| OpenLane runs | runs/ | 2376 | 1654473585 B | preserve in place | Large generated output; config is ignored by git |
| Review archives | docs/reviews/awake_paper_815/ | 3 | 0 B | document and preserve in repo | Original reviewer feedback file was not present in repo; tracker created from prompt |
| Archive docs | docs/evidence_archive/ | 1 | 571179 B | commit to Git | Summary docs and hash manifest |

## OpenLane runs discovered

| Run ID | Files | Size bytes | Notes |
|---|---:|---:|---|
| RUN_2026-10-24_17-48-54 | 63 | 19598776 | original OpenLane execution; preserved in place and referenced by manifest |
| RUN_2026-10-24_17-54-09 | 1153 | 813875624 | original OpenLane execution; preserved in place and referenced by manifest |
| RUN_2026-10-24_19-16-36 | 1160 | 820999185 | original OpenLane execution; preserved in place and referenced by manifest |

## Result checkpoints

| Checkpoint | Files | Size bytes | Notes |
|---|---:|---:|---|
| checkpoint_20261024_194321 | 2 | 1654792 | checkpoint summary and netlist evidence |
| checkpoint_20261024_194335 | 2 | 1654792 | checkpoint summary and netlist evidence |

## Verified run metrics

### RUN_2026-10-24_17-54-09

- setup slack: -1.6932535852710704 ns
- setup TNS: -11.565447593641487 ns
- setup violation count: 29
- total power: 0.013314031064510345 mW
- antenna violating nets: 4
- core area: 177839 µm²
- instance area: 71217.1 µm²
- utilization: 0.400457

### RUN_2026-10-24_19-16-36

- setup slack: 0.6247749161531793 ns
- setup TNS: 0 ns
- setup violation count: 0
- total power: 0.012208886444568634 mW
- antenna violating nets: 11
- core area: 180158 µm²
- instance area: 71996.6 µm²
- utilization: 0.399631


The machine-readable manifest is at [artifact_manifest.csv](artifact_manifest.csv).
