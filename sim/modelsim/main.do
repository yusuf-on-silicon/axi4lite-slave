# do ../../sim/main.do

set PROJECT_ROOT "C:/Users/Yusuf/OneDrive/Documents/Production/VLSI/Projects/3.0 - AXI4-Lite Slave Peripheral"
set SOURCE_PATH "${PROJECT_ROOT}/rtl"
set BUILD_PATH "${PROJECT_ROOT}/build/modelsim"
set WORK_PATH "${BUILD_PATH}/work"

# cd "${PROJECT_ROOT}"

if { [catch {exec mkdir -p $BUILD_PATH } ] } {
    puts "Could not create build path. Assuming it exists."
}

if { [catch {vlib $WORK_PATH } ] } {
    puts "Library already exists or could not be created."
}

#if {[file exists "${BUILD_PATH}/waves/main.wlf"]} {
#    file delete -force "${BUILD_PATH}/waves/main.wlf"
#}

vmap work $WORK_PATH

vlog -work work "${PROJECT_ROOT}/rtl/top/main.v"
vlog -work work "${PROJECT_ROOT}/rtl/memory/memory.v"
vlog -work work "${PROJECT_ROOT}/rtl/channels/Write.v"
vlog -work work "${PROJECT_ROOT}/rtl/channels/write/AWchannel.v"
vlog -work work "${PROJECT_ROOT}/rtl/channels/write/Wchannel.v"
vlog -work work "${PROJECT_ROOT}/rtl/channels/write/Bchannel.v"
vlog -work work "${PROJECT_ROOT}/rtl/channels/Read.v"
vlog -work work "${PROJECT_ROOT}/rtl/channels/read/ARchannel.v"
vlog -work work "${PROJECT_ROOT}/rtl/channels/read/Rchannel.v"
vlog -work work "${PROJECT_ROOT}/tb/mainTB.v"

vsim work.mainTB -wlf "$BUILD_PATH/AXI4_Lite_waveform.wlf"

radix binary

add wave -group {AW}      -position insertpoint sim:/mainTB/DUT/WriteEntity/AWentity/*
add wave -group {W}       -position insertpoint sim:/mainTB/DUT/WriteEntity/Wentity/*
add wave -group {B}       -position insertpoint sim:/mainTB/DUT/WriteEntity/Bentity/*
add wave -group {AR}      -position insertpoint sim:/mainTB/DUT/ReadEntity/ARentity/*
add wave -group {R}       -position insertpoint sim:/mainTB/DUT/ReadEntity/Rentity/*
add wave -group {Mem}     -position insertpoint sim:/mainTB/DUT/memory/*
add wave -group {Monitor} -position insertpoint \
sim:/mainTB/awready  \
sim:/mainTB/awvalid  \
sim:/mainTB/wready   \
sim:/mainTB/wvalid   \
sim:/mainTB/bready   \
sim:/mainTB/bvalid   \
sim:/mainTB/aw_done  \
sim:/mainTB/w_done   \
sim:/mainTB/arvalid  \
sim:/mainTB/arready  \
sim:/mainTB/rready   \
sim:/mainTB/rvalid   \
sim:/mainTB/readData \
sim:/mainTB/ar_done

add wave -position insertpoint  \
-radix decimal sim:/mainTB/WRITE_COUNT \
-radix decimal sim:/mainTB/READ_COUNT

add wave -position insertpoint  \
sim:/mainTB/DUT/memory/memory


run -all