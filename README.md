# AXI Lite Memory-Mapped Slave in Verilog

This project implements a synthesizable AXI Lite-compliant memory-mapped slave interface in Verilog. It features a clean, modular design with support for four independent memory blocks, each with 64 entries of 32-bit width. The testbench rigorously verifies AXI channel handshakes for correctness and timing compliance.

## Overview

- **Protocol**: AXI Lite (AMBA AXI4-Lite)
- **Language**: Verilog
- **Memory**: 4 blocks × 64 × 32-bit
- **Compliance**: Full channel handshake adherence (AW, W, B, AR, R)
- **Testbench**: Handshake-accurate simulation of reads/writes

## Architechure

![AXI4-Lite memory](https://github.com/user-attachments/assets/d4aebddb-127a-4494-aa2a-88a3e47d048f)

## Schematic

### Module

![memmodule](https://github.com/user-attachments/assets/c4b1e0dc-3266-4384-b2a5-667c56e807c1)

### Memory Blocks

![memblock](https://github.com/user-attachments/assets/6f72721e-32fa-4480-bc8d-01efc61602dd)

## Simulation Waveform

![simresults](https://github.com/user-attachments/assets/8a2e2fa8-2a96-4c12-84ea-4aeeaa6227b8)

## Test Log

![testlogs](https://github.com/user-attachments/assets/952bf1a9-3fa5-4ebf-b599-d58e896fda0e)

---
