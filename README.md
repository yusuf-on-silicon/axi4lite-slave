# axi4lite-slave
Implementation of AXI4-Lite Slave of the AMBA family. Model capable of scaling and implementing inside other rtl program as sub modules
TO ADD :-
1. summary of what it is
2. sttructure
3. enhancements

2. Strucutre  
axi4lite-slave/  
│── src/              # RTL source files (Verilog/VHDL)  
│   ├── axi_slave.vhd  
│   ├── axi_write_channel.vhd  
│   └── ...  
│  
│── tb/               # Testbenches  
│   ├── tb_axi_slave.vhd  
│   └── ...  
│  
│── sim/              # Simulation scripts (ModelSim/Vivado/Verilator run.do, etc.)  
│  
│── docs/             # Diagrams, notes, AXI protocol reference  
│  
│── Makefile          # For running simulations (optional, later we’ll add)  
│── README.md         # Project overview  
│── .gitignore  
