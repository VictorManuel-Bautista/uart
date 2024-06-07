# source tcl/IncludeUARTFiles.tcl
set tcl_path [ file dirname [ file normalize [ info script ] ] ]
set GoWinProject_path [file dirname $tcl_path]
set UARTProject_path [file dirname $GoWinProject_path]
set UARTsrc_path ${UARTProject_path}/src

# CST files
add_file -type cst ${GoWinProject_path}/GoWinUART.cst

# Source vhdl files
add_file -type vhdl ${UARTsrc_path}/uartRX.vhd