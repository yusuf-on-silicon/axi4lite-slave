# axi4lite-slave
Implementation of AXI4-Lite Slave of the AMBA family. Model capable of scaling and implementing inside other rtl program as sub modules
TO ADD :-
1. summary of what it is
2. structure
3. enhancements
4. to make driver, monitor, scoreboard, logs, graphs.

To Run:- point to project path (cd "C:/Users/Yusuf/Documents/Production/VLSI/Projects/AXI4-Lite")
         then run (do "sim/modelsim/main.do")

2. Strucutre  

project_root/  
│  
├── rtl/             # All synthesizable RTL (design IPs, top, etc.)  
│   ├── channels/    # AXI modules  
│   ├── memory/      # FIFOs, queues  
│   └── top/         # Top-level  
│  
├── tb/              # Testbench source code (human-written, tracked)  
│   ├── axi_tb.vhd  
│   ├── fifo_tb.sv  
│   └── common/      # e.g., BFMs, verification utilities  
│  
├── sim/             # Tool setup, scripts, configs (tracked)  
│   ├── modelsim/    # .do files, run scripts  
│   ├── verilator/   # C++ harnesses, Makefiles (To Add)  
│   └── logs/        # log directory (empty in git, ignored on use)  
│  
├── build/           # Auto-generated garbage (ignored in git)  
│   ├── work/        # ModelSim/Questa library  
│   ├── waves/       # wave databases  
│   └── dump/        # .vcd/.fst outputs  
│  
├── synth/           # Synthesis scripts (Tcl, constraints)  
│  
├── doc/             # Specs, diagrams, markdown  
│  
└── .gitignore  


