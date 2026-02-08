# AXI4-Lite Slave Peripheral  
**RTL Design and Constrained-Random Verification**
> **Status:** RTL Complete│Regression-Tested Verification Environment  
> **Development Timeline:** ( **[RTL]:** July - July, 2025│**[UVM Inspired TB]:** February - February, 2026 )
## 1. Project Overview

This project implements a **modular AXI4-Lite slave peripheral** in RTL, designed using a channelized finite state machine (FSM) architecture. Each AXI channel (AW, W, B, AR, R) is implemented as an independent control unit to reflect real-world protocol handling and hardware microarchitecture practices.

The design supports memory-mapped read and write operations with protocol-compliant response generation, including correct handling of valid accesses, illegal writes, and address decode errors.

Verification is performed using a **self-checking constrained-random testbench** that validates protocol behavior, data integrity, and system robustness under large-scale interleaved traffic. The environment includes passive channel monitors, a reference memory model, and a transaction-level scoreboard.

This project was developed as part of a growing **RTL IP portfolio**, emphasizing scalable verification, protocol correctness, and design modularity consistent with industry RTL development workflows.

---

## 2. Repository Folder Structure

```
async_fifo/
│
├── build/                                #(gitignored)               
│   └── modelsim/                     
│
├── docs/                                 #(gitignored)                
│   ├── architecture/                 
│   ├── waveforms/                    
│   ├── reports/                      
│   └── notes.md                      
│
├── results/                          
│   └── sim/                          
│       ├── AXI_Memory.png
│       ├── AXI_Memory_Module.png
│       ├── AXI_Read.png
│       ├── AXI_scoreboard.png
│       ├── AXI_Write.png
│       └── Regression_Summary.txt
│  
├── rtl/                                
│   ├── channel/                    
│   │   ├── read/
│   │   │   ├── ARchannel.v
│   │   │   └── Rchannel.v
│   │   ├── write/
│   │   │   ├── AWchannel.v
│   │   │   ├── Bchannel.v
│   │   │   └── Wchannel.v
│   │   ├── Read.v
│   │   └── Write.v
│   ├── memory/  
│   │   └── memory.v
│   └── top/     
│       └── main.v
│
├── sim/                             
│   └── modelsim/
│       └── main.do                  
│
├── syn/                                # Future Planned
│
├── tb/                                 
│   └── mainTB.v
│
├── uvm/                                # Future Planned
│
├── .gitignore                          
└── README.md                           

```

---
## 3. Design Architecture

### 3.1 Key Features

- Fully compliant **AXI4-Lite slave interface**
- Independent FSMs for each AXI channel:
  - Write Address (AW)
  - Write Data (W)
  - Write Response (B)
  - Read Address (AR)
  - Read Data (R)
- Handshake-driven design using **VALID/READY protocol**
- Parameterized **data width, address width, and memory depth**
- Byte-level write support using **WSTRB**
- Protocol-aware response generation
  - **OKAY** for valid accesses
  - **SLVERR** for illegal write attempts
  - **DECERR** for out-of-range address access
- Memory-mapped register space with controlled read/write regions

---

### 3.2 Channelized Control Strategy

The AXI slave is architected as a set of **independent yet coordinated FSM-based channels**, reflecting the decoupled nature of the AXI protocol.

#### Write Path
- **AWchannel FSM** captures write addresses
- **Wchannel FSM** captures write data and strobe signals
- Write enable is asserted only when both address and data are valid
- **Bchannel FSM** generates protocol-compliant write responses

#### Read Path
- **ARchannel FSM** captures read addresses
- Memory subsystem returns data and response
- **Rchannel FSM** manages read data handshaking and response signaling

This separation ensures correct operation even when read and write transactions occur concurrently.

---

### 3.3 FSM Operation Model

Each AXI channel follows a structured FSM design pattern:

1. **IDLE** – Wait for VALID handshake
2. **ACTIVE** – Capture and process transaction
3. **COMPLETE** – Hold response until READY is received

This guarantees:
- No premature de-assertion of VALID
- No loss of transactions
- Deterministic protocol sequencing
NYKPINK300
---

### 3.4 Memory & Response Logic

The memory subsystem is tightly integrated with protocol response logic:

- Writes update memory only for valid address ranges
- Read-only regions reject write attempts with **SLVERR**
- Out-of-range accesses return **DECERR**
- Read responses return stored data along with correct RRESP codes

This enables both **data integrity validation** and **protocol error scenario testing** during verification.
perfect now the following text as well

---

## 4. Verification Strategy

### 4.1 Verification Methodology

The AXI4-Lite slave is verified using a **self-checking, constrained-random testbench** designed to validate protocol correctness, data integrity, and system robustness under interleaved traffic conditions.

The verification environment is transaction-oriented rather than waveform-driven, enabling large-scale regression testing.

---

### 4.2 Testbench Architecture

The testbench is structured into stimulus, monitoring, and checking components:

**Stimulus Generation**

* Randomized write and read transactions
* Variable inter-transaction delays
* Mixed automatic read-back and independent manual read operations
* Address range exploration including valid, restricted, and invalid regions

**Passive Channel Monitors**

* Independent monitors for AW, W, B, AR, and R channels
* Capture handshake events and transaction data
* Track protocol-level activity without driving DUT signals

**Reference Memory Model**

* Mirrors DUT memory updates for valid write transactions
* Used as a golden model for read data comparison

**Transaction Tracking**

* FIFO-based tracking links completed write transactions to expected read-back operations
* Ensures correct pairing of writes and subsequent data checks under out-of-order interleaving

---

### 4.3 Scoreboard & Checking Strategy

The scoreboard performs response-aware validation:

* **OKAY responses** → Read data compared against reference model
* **SLVERR / DECERR responses** → Classified as expected protocol errors
* Unexpected mismatches or unrecognized responses flagged as failures

This allows the environment to distinguish between:

* Functional data errors
* Legitimate protocol error responses

---

### 4.4 Stress & Regression Testing

The environment is capable of large-scale randomized regressions, validating both DUT stability and verification infrastructure scalability.

Representative regression runs include:

* **100,000+ write transactions**
* **200,000+ read transactions**
* Randomized interleaving of manual and automatic reads
* No lost handshakes, deadlocks, or data mismatches observed

These tests ensure the design operates correctly under sustained, mixed traffic conditions rather than only directed scenarios.

---

### 4.5 Verification Goals

The verification flow is designed to ensure:

* ✔ Protocol-compliant VALID/READY handshaking
* ✔ Correct memory update and retrieval behavior
* ✔ Proper handling of read-only and invalid address accesses
* ✔ Stability under randomized, interleaved traffic
* ✔ Accurate classification of protocol error responses

---

*(Future extensions may include a class-based UVM environment using similar monitor and scoreboard concepts for improved reuse and coverage modeling.)*

---
## 5. Verification Results & Metrics

The AXI4-Lite slave was validated using large-scale constrained-random regressions to evaluate protocol correctness, data integrity, and system stability under interleaved traffic.

### 5.1 Channel Activity Statistics (Representative Regression)

| Channel            | Handshake Count |
| ------------------ | --------------- |
| Write Address (AW) | 100,000         |
| Write Data (W)     | 100,000         |
| Write Response (B) | 100,000         |
| Read Address (AR)  | 200,000         |
| Read Data (R)      | 200,000         |

These counts confirm:

* No lost transactions
* No protocol deadlocks
* Sustained operation under heavy mixed traffic

---

### 5.2 Scoreboard Results

| Category                   | Count   |
| -------------------------- | ------- |
| Successful Writes          | 100,000 |
| Write Failures             | 0       |
| Successful Reads           | 200,000 |
| Read Data Mismatches       | 0       |
| Recognized Protocol Errors | 429     |

All protocol error responses (e.g., **DECERR** for invalid addresses) were correctly identified and classified by the scoreboard, ensuring no false data mismatches were reported.

---

### 5.3 Functional Validation Observations

* No data corruption across **300,000+ transactions**
* No lost VALID/READY handshakes across any AXI channel
* Stable operation with interleaved read and write traffic
* Correct handling of read-only and out-of-range address regions
* Accurate classification of protocol error responses

These results demonstrate both **design correctness** and **verification environment scalability**.

---

### 5.4 Waveform & Summary Evidence

Waveform captures confirming protocol sequencing and memory behavior are stored in:

```
[/results/sim/waveform.PNG]
```
```
[/results/sim/Regression_Summary.txt]
```

These include:

* Write → Read-back data integrity sequences
* Concurrent read/write transaction behavior
* Error response generation (SLVERR / DECERR)


---
## 7. Simulation Instructions

### ModelSim / Questa

```
cd ../../../sim/modelsim
do main.do
```

This script performs:

* RTL and testbench compilation
* Simulation launch
* Waveform configuration for AXI channels and memory

Ensure ModelSim/Questa is added to your system path before running.

---

## 8. Roadmap

* [x] AXI4-Lite slave RTL implementation
* [x] Channelized FSM-based architecture
* [x] Constrained-random self-checking testbench
* [x] Large-scale regression validation
* [x] Protocol error handling (SLVERR / DECERR)
* [ ] SystemVerilog/UVM migration of verification environment
* [ ] Functional coverage model (future SV implementation)
* [ ] Integration as memory-mapped peripheral in larger SoC design

---

## 9. Author

**Yusuf Ahmad**  
B.Tech Electronics & Communication Engineering  
RTL Design, Verification, and SoC Architecture  
[linkedin](https://www.linkedin.com/in/yusuf-silicon/)

---

> *This project is part of a long-term RTL design portfolio aimed at developing industry-grade digital IP and verification expertise.*
