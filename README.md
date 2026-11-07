# Elevator Controller – RTL to Physical Design

## Project Overview

This project implements a multi-floor elevator controller using Verilog HDL. It uses a Finite State Machine (FSM) to manage elevator movement, floor requests and door operations.

The project covers RTL design, functional simulation, synthesis and ASIC physical design.

## Tools & Technologies

- **HDL:** Verilog / SystemVerilog
- **Simulation:** Icarus Verilog, GTKWave
- **RTL Platform:** EDA Playground
- **Synthesis:** Yosys
- **Physical Design:** OpenLane
- **Layout Inspection:** KLayout

## Repository Structure

```text
VLSI-Design/
├── RTL/
├── Testbench/
├── Netlist/
├── Simulation/
└── Physical_Design/
```

## Design Features

- Parameterized floor configuration
- Finite State Machine (FSM) based control
- Floor request handling
- Upward and downward motor control signals
- Door operation control
- Configurable door timing

## Simulation

The RTL design was simulated using Icarus Verilog, with GTKWave used to inspect signal waveforms.

![Simulation Waveform](Simulation/waveform_simulation.png)

## Synthesis

Yosys was used for synthesis and netlist generation.

![Yosys Synthesis Output](Physical_Design/yosys_synthesis_output.png)

## Physical Design

OpenLane was used for the ASIC physical design workflow, with KLayout used to inspect the generated layout.

![KLayout Output](Physical_Design/klayout_output.png)

## Project Files

- `RTL/` – Main elevator controller RTL source.
- `Testbench/` – Testbench for functional verification.
- `Netlist/` – Generated synthesis netlist.
- `Simulation/` – Simulation waveform.
- `Physical_Design/` – Physical design screenshots and synthesis evidence.

## Author

**Aniket Aher**

B.Tech – Electronics and Telecommunication Engineering
