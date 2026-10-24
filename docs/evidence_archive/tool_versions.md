# Tool versions

```bash
$ git --version
git version 2.55.0
$ verilator --version
Verilator 5.020 2024-01-01 rev (Debian 5.020-1)
$ python --version
Python 3.14.2
$ yosys -V
Yosys 0.33 (git sha1 2584903a060)
$ openlane --version
openlane: command not found
```

## Notes
- OpenLane is not installed in the current execution environment (`openlane: command not found`), so the run directories are treated as preserved raw evidence rather than live reproductions.
- The repository's `flow/config.json` indicates a 20 ns clock period and 40% core utilization placeholder configuration, which should be treated as an implementation input, not a validated design requirement.
