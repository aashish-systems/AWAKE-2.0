# Controller State Machine, Register Interface, and Software Overhead

## Intelligent Power Manager FSM

The Intelligent Power Manager (IPM) employs a four-state finite-state
machine: SLEEP, MONITOR, WARNING, and CRITICAL. Following reset, the
controller enters SLEEP and transitions to MONITOR when wake_timer is
asserted. In MONITOR, sensor acquisition and decision processing are
enabled. A detected stress_event causes a transition to WARNING, where
the crop-stress accelerator (CSA) and decision-tree accelerator are
enabled along with the second power domain. When a valid decision-tree
output indicates critical severity, the FSM transitions to CRITICAL,
enabling the third power domain and communication resources. The
controller returns from CRITICAL to WARNING when a valid decision no
longer indicates critical severity.

From WARNING, the controller returns to MONITOR when valid normal-severity
outputs satisfy the RTL recovery-counter condition. The recovery behavior
must be described using the exact counter implementation; the intended
two-consecutive-cycle recovery behavior should be confirmed against RTL
and simulation before publication. Invalid decision cycles must not be
claimed to trigger escalation or recovery unless verified in the RTL.

The current FSM has no MONITOR-to-SLEEP transition: after waking, it
remains at MONITOR or above until reset. Consequently, SLEEP occupancy
in a directed trace represents its pre-wake interval, not recurring
low-duty-cycle sleep periods.

## Register interface

The configuration and status interface uses an 8-bit address bus, an
8-bit data bus, and separate read-enable and write-enable controls.
Although the address space contains 256 possible locations, only 36
read/write configuration registers are implemented, providing 288 bits
of nominal configuration storage. Read-only status registers are driven
by internal signals; writes to read-only or unmapped addresses are
ignored, and unmapped reads return zero. Read data is also zero when
read enable is deasserted.

The sparse map avoids implementing storage for every possible address.
The standalone Yosys synthesis result is 1,821 generic cells, including
288 enabled flip-flop bits. An alternative explicit-decoder implementation
used 1,856 generic cells, an increase of 35 cells (approximately 1.92%),
and was not adopted. These are generic synthesis counts, not physical
silicon-area measurements. The 288-bit versus hypothetical 2,048-bit
comparison is a nominal storage-capacity comparison, not a measured
total-area reduction.

## Sampling and software responsibilities

Sensor samples are accepted when the synchronized sample-valid signal
and the FSM sensor-enable signal are both asserted. Accepted samples
are captured in registers for subsequent processing.

The RTL does not define a fixed firmware polling frequency. The effective
sample rate depends on the external sampling schedule and system
integration. Processor utilization, software execution time, and firmware
memory footprint have not been quantified in the current RTL evaluation.
A compiled memory macro and firmware/software profiling remain future
evaluation items.

## Evidence boundaries

The agricultural CSV simulation processed 1,926 samples: 1,915 MONITOR
samples (99.43%) and 11 CRITICAL samples (0.57%). It produced 11 valid
decision-tree outputs and 505 valid CSA scores. These counts describe
the supplied simulation workload, not a field deployment or a validated
agricultural duty-cycle distribution.

The current SLEEP-window power estimate is provisional and must not be
presented as a validated deployment-level power result or a measured
power-saving percentage. A fair power-saving claim requires equivalent
baseline and power-gated workloads under matched constraints and verified
activity annotation.
