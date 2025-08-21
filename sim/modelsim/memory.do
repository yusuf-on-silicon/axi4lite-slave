cd "C:/Users/Yusuf/Documents/Production/VLSI/Projects/AXI4-Lite/build/work"

vlib "C:/Users/Yusuf/Documents/Production/VLSI/Projects/AXI4-Lite/build/work"
vmap work "C:/Users/Yusuf/Documents/Production/VLSI/Projects/AXI4-Lite/build/work"

vlog "C:/Users/Yusuf/Documents/Production/VLSI/Projects/AXI4-Lite/rtl/memory/memory.v"
vlog "C:/Users/Yusuf/Documents/Production/VLSI/Projects/AXI4-Lite/tb/TBmemoryTemp.v"

vsim work.TBmemory -wlf "C:/Users/Yusuf/Documents/Production/VLSI/Projects/AXI4-Lite/build/waves/memory.wlf"
add wave -r /*

run -all

