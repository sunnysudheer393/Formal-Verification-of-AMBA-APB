# Formal Verification of AMBA APB Master-Slave Design in JasperGold

This repository contains a **formal verification environment** for the **AMBA APB (Advanced Peripheral Bus)** master-slave design using **SystemVerilog Assertions (SVA)** and **Cadence JasperGold** formal verification tools.

The AMBA APB protocol is a widely used on-chip communication interface in SoC designs, connecting low-performance peripherals with simple read/write transactions. This project demonstrates how formal methods can be used to exhaustively verify the correctness of an APB master and slave implementation without relying solely on simulation. :contentReference[oaicite:0]{index=0}

---

## 📌 Project Overview

This repository implements and verifies a simple **APB Master-Slave bus interface** using SystemVerilog and formal assertions.

Formal verification provides **mathematically exhaustive guarantees** that the design meets its specification. Unlike traditional simulation, a formal tool such as JasperGold explores **all possible states and signal interactions** to prove correctness or expose corner-case bugs.

The verification environment in this project includes:

- Formal assertion library (`.svh`) covering protocol correctness
- Top-level design interface (`apb_top.svh`)
- Master and Slave models (`apb_master.svh`, `apb_slave.svh`)
- Testbench bindings and helpers (`apb_fv_tb.svh`, `apb_bind_new.svh`)
- JasperGold formal test script (`apb-formal.tcl`)

---

## 🧠 AMBA APB Protocol Background

The AMBA APB (Advanced Peripheral Bus) protocol is part of ARM’s AMBA family of bus standards designed for efficient, low-complexity peripheral communication in modern SoC designs. It features a **non-pipelined protocol** with a simple setup, transfer, and repeat cycle, making it suitable for control register access and low-speed peripherals. :contentReference[oaicite:1]{index=1}

Formal verification of APB verifies key design properties such as:

- Correct handshake between master and slave
- Proper sequencing of setup and enable phases
- No illegal bus transactions
- Data integrity on read and write transfers

---

## 🧪 Verification Strategy

The formal environment in this repository uses:

✔ **SystemVerilog Assertions (SVA)** to encode protocol rules  
✔ **Assumptions** to constrain stimulus where needed  
✔ **Proof directives** to drive JasperGold verification  
✔ **Cover properties** (optional) to demonstrate intended behavior

Formal verification checks *all legal input combinations* and signal interactions, rather than random or directed simulation.

---

## 🛠 How to Run Formal Verification

### Prerequisites
1. **Cadence JasperGold** installed and licensed
2. SystemVerilog design and assertion files present in repository

### Steps

```bash
# Change to repository directory
cd Formal-Verification-of-AMBA-APB

# Launch JasperGold with the provided TCL script
jg -f apb-formal.tcl
