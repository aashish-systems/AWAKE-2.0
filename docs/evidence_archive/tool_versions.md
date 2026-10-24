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
- The preserved completed runs' `resolved.json` files and final SDCs record a 20 ns clock period. The current working-tree `flow/config.json` is modified and is not used as historical run evidence. Treat the clock period and utilization setting as flow inputs, not as validated design requirements.
