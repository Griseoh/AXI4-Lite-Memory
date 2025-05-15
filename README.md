# AXI Lite Memory-Mapped Slave in Verilog

This project implements a synthesizable AXI Lite-compliant memory-mapped slave interface in Verilog. It features a clean, modular design with support for four independent memory blocks, each with 64 entries of 32-bit width. The testbench rigorously verifies AXI channel handshakes for correctness and timing compliance.

## Overview

- **Protocol**: AXI Lite (AMBA AXI4-Lite)
- **Language**: Verilog
- **Memory**: 4 blocks × 64 × 32-bit
- **Compliance**: Full channel handshake adherence (AW, W, B, AR, R)
- **Testbench**: Handshake-accurate simulation of reads/writes
