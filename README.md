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

## Simulation Waveform

![simresults](https://github.com/user-attachments/assets/203beb6d-cb09-4dc9-99a1-561e6c33d9b3)

## Test Log

![testlogs](https://github.com/user-attachments/assets/952bf1a9-3fa5-4ebf-b599-d58e896fda0e)

---
