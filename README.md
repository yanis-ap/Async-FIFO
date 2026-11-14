# Asynchronous FIFO with Clock Domain Crossing (CDC)

A dual-clock Asynchronous FIFO (8-depth × 8-bit) designed in Verilog to safely transfer data across independent clock domains. The design implements First-Word Fall-Through (FWFT) read logic and mitigates metastability by passing Gray-coded read and write pointers through 2-stage flip-flop synchronizers.

<!-- PLACEHOLDER: Insert your Block Diagram image here -->
![FIFO Architecture](images/async-fifo-image.png)
*Figure 1: High-level architecture showing independent clock domains, Gray code conversion, and 2-stage synchronizers.*

---

## 1. Functional Verification (Front-End)

The RTL was rigorously verified using a self-checking SystemVerilog testbench executed in Xilinx Vivado. 

* **Reference Model Scoreboard:** Automated verification against a golden reference queue to ensure data integrity during simultaneous read/write bursts.
* **SystemVerilog Assertions (SVA):** Concurrent SVAs actively monitor the bus and flag catastrophic failure modes, specifically verifying zero `overflow` (writing while full) and `underflow` (reading while empty) conditions.

<!-- PLACEHOLDER: Insert your Vivado Simulation Waveform / Console output here -->
![Simulation Waveform](images/waveform.png)
*Figure 2: Vivado simulation demonstrating FWFT read logic and clean clock domain crossing.*

---

## 2. Physical Design: RTL-to-GDSII (Back-End)

The physical implementation was executed using the **LibreLane / OpenROAD** open-source EDA toolchain targeting the **SkyWater 130nm** High-Density PDK (`sky130_fd_sc_hd`). The automated pipeline handled the complete ASIC flow from synthesis through physical verification.

### Layout Progression

<!-- PLACEHOLDERS: Insert your KLayout/OpenROAD GUI stage exports here -->

| Placement | Detailed Routing | Final GDSII Layout |
| :---: | :---: | :---: | :---: |
| ![Placement](images/placement-layout.png)  | ![Clock Tree Synthesis](images/cts.png) | | ![Routing](images/routing-layout.png) | ![GDSII](images/gds.png) |
| *Standard cells packed into core rows prior to signal routing.* | *Multi-layer metal interconnects and vias routed across the core.* | *Signoff-ready GDSII layout with filler cells and power rails.* |

---

## 3. Implementation Metrics (Sky130)

The design successfully achieved timing closure and passed all physical design rule checks. Extracted from the LibreLane sign-off reports:

| Parameter | Value |
| :--- | :--- |
| **Target Technology** | SkyWater 130nm |
| **Logic Area** | 4,211.5 µm² |
| **Instance Count (Standard Cells)** | 358 |
| **Core Utilization** | 59.0% |
| **Total Power** | 1.17 mW |
| **Setup Slack (WS)** | + 6.05 ns |
| **Hold Slack (WS)** | + 0.26 ns |
| **Routing DRC Errors** | 0 |
| **LVS & Magic DRC Errors** | 0 |

---

## Repository Structure

```text
├── verilog-code/                  # Verilog HDL source files (FIFO core, RAM, synchronizers)               
├── runs/                 # LibreLane config.json and physical design reports
└── images/               # Architecture diagrams, waveforms, and layout screenshots
