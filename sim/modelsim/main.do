cd "C:/Users/Yusuf/Documents/Production/VLSI/Projects/AXI4-Lite/build/work"

vlib "C:/Users/Yusuf/Documents/Production/VLSI/Projects/AXI4-Lite/build/work"
vmap work "C:/Users/Yusuf/Documents/Production/VLSI/Projects/AXI4-Lite/build/work"

vlog "C:/Users/Yusuf/Documents/Production/VLSI/Projects/AXI4-Lite/rtl/top/main.v"
vlog "C:/Users/Yusuf/Documents/Production/VLSI/Projects/AXI4-Lite/rtl/memory/memory.v"
vlog "C:/Users/Yusuf/Documents/Production/VLSI/Projects/AXI4-Lite/rtl/tb/main.v"

vsim work.TBmain -wlf "C:/Users/Yusuf/Documents/Production/VLSI/Projects/AXI4-Lite/build/waves/main.wlf"
add wave -r /*

run -all

