# Phase 4 report — figure and manuscript provenance audit

Audit date: 2026-10-24

## Disposition

**Figure gate blocked for manuscript remediation.** No project-owned manuscript
source, figure file, or caption source is present in the repository outside
tool collateral. Therefore no figure-to-source/run mapping or caption review
can be completed, and no paper figures were regenerated or edited. This is a
missing-input disposition, not evidence that any external manuscript figure
is correct.

The preserved physical runs do contain traceable stage-specific layout data
and reports. These support the existence of placement, CTS, routing, and
timing outputs, but they are not rendered paper figures and do not establish
what an absent manuscript figure depicts.

## Candidate inventory findings

- `full_validation_20261024_204134/figure_inventory.csv` contains 270 image
  candidates: 160 PNG and 110 SVG files. Every listed candidate is under
  `build/openlane/volare/`; these are Sky130/Volare technology-library
  collateral, not AWAKE implementation figures.
- No project-owned PNG, JPEG, PDF, SVG, EPS, presentation, or manuscript
  source was found outside build/vendor collateral.
- No PDF/DOCX/ODT/TeX manuscript source was found. The only paper-related
  source in the repository is evidence/reviewer documentation, not the
  manuscript or its figure captions.
- The run directories contain OpenROAD database and DEF snapshots, CTS
  reports, route-stage logs/metrics, final GDS, and STA reports. These are
  primary physical-flow evidence, not rendered placement/CTS/routing images.

## Traceable physical-flow source evidence

| Figure subject | `RUN_2026-10-24_17-54-09` source evidence | `RUN_2026-10-24_19-16-36` source evidence | What can be asserted |
|---|---|---|---|
| Detailed placement | `runs/RUN_2026-10-24_17-54-09/33-openroad-detailedplacement/agrisense_ipms_top.odb` and `.def` | `runs/RUN_2026-10-24_19-16-36/33-openroad-detailedplacement/agrisense_ipms_top.odb` and `.def` | Stage outputs exist for each run; no rendered placement figure is archived |
| CTS | `runs/RUN_2026-10-24_17-54-09/34-openroad-cts/agrisense_ipms_top.odb`, `.def`, and `cts.rpt` | `runs/RUN_2026-10-24_19-16-36/34-openroad-cts/agrisense_ipms_top.odb`, `.def`, and `cts.rpt` | CTS database and report outputs exist; no CTS image is archived |
| Global routing / congestion | `runs/RUN_2026-10-24_17-54-09/38-openroad-globalrouting/agrisense_ipms_top.odb`, `.def`, `or_metrics_out.json`, and `openroad-globalrouting.log` | `runs/RUN_2026-10-24_19-16-36/38-openroad-globalrouting/agrisense_ipms_top.odb`, `.def`, `or_metrics_out.json`, and `openroad-globalrouting.log` | Route-stage outputs exist; an image/caption cannot be mapped without the manuscript source |
| Detailed routing | `runs/RUN_2026-10-24_17-54-09/43-openroad-detailedrouting/agrisense_ipms_top.odb`, `.def`, `or_metrics_out.json`, and `openroad-detailedrouting.log` | `runs/RUN_2026-10-24_19-16-36/43-openroad-detailedrouting/agrisense_ipms_top.odb`, `.def`, `or_metrics_out.json`, and `openroad-detailedrouting.log` | Detailed-route outputs exist; these are not screenshots or proof of antenna closure |
| Final layout | `runs/RUN_2026-10-24_17-54-09/final/gds/agrisense_ipms_top.gds` and `final/metrics.json` | `runs/RUN_2026-10-24_19-16-36/final/gds/agrisense_ipms_top.gds` and `final/metrics.json` | Final GDS and run-specific metrics exist; run attribution must remain distinct |
| Worst path / timing | `runs/RUN_2026-10-24_17-54-09/54-openroad-stapostpnr/<corner>/sta.log` | `runs/RUN_2026-10-24_19-16-36/54-openroad-stapostpnr/<corner>/sta.log` | STA reports exist; the 20 ns constraints and per-run timing results govern any timing claim |

The two completed runs must not be visually combined or treated as a single
implementation: they have distinct final layouts and metrics. The earlier
`RUN_2026-10-24_17-48-54` is synthesis-only and has no placement/CTS/routing
figure evidence.

## Caption and claim safeguards

No caption was available to inspect or correct. Any future figure or caption
must be tied to one run ID, a named flow stage, and its source artifact. In
particular:

- Do not label the 20 ns constrained runs as demonstrating 116.15 MHz; the
  Phase 1 audit established that 8.615 ns is a path data-arrival value, not
  the applied period.
- Do not describe the completed runs as antenna-clean; final counts are 4 and
  11 violating nets, respectively.
- Keep each run's timing, area, power, and physical output attributed to its
  own source evidence.
- Do not imply state-specific power, a measured power saving, or a baseline
  comparison; Phase 2 and Phase 3 findings leave these unsupported.

## Gate result and next action

| Requirement | Result |
|---|---|
| Map each manuscript figure to source data, run ID, and flow stage | Blocked: no manuscript or figure/caption source |
| Regenerate figures only from verified data | No figure regenerated; no identified target figure or caption to replace |
| Replace placeholder/unsupported captions | Blocked: captions are unavailable |
| Record missing provenance | Complete in this report; exact stage evidence is listed above |

Obtain the authoritative manuscript and figure source files before caption
edits or figure regeneration. Then map each item against the exact run/stage
artifacts and Phase 1 claim evidence matrix. Until that source is provided,
the figure gate remains open.
