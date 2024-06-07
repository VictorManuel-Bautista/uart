module gw_gao(
    eHalfBit,
    \shiftReg[8] ,
    \shiftReg[7] ,
    \shiftReg[6] ,
    \shiftReg[5] ,
    \shiftReg[4] ,
    \shiftReg[3] ,
    \shiftReg[2] ,
    \shiftReg[1] ,
    \shiftReg[0] ,
    \cBaudRate[11] ,
    \cBaudRate[10] ,
    \cBaudRate[9] ,
    \cBaudRate[8] ,
    \cBaudRate[7] ,
    \cBaudRate[6] ,
    \cBaudRate[5] ,
    \cBaudRate[4] ,
    \cBaudRate[3] ,
    \cBaudRate[2] ,
    \cBaudRate[1] ,
    \cBaudRate[0] ,
    \cHalfBit[6] ,
    \cHalfBit[5] ,
    \cHalfBit[4] ,
    \cHalfBit[3] ,
    \cHalfBit[2] ,
    \cHalfBit[1] ,
    \cHalfBit[0] ,
    eCFrame,
    eCFramer,
    clk,
    tms_pad_i,
    tck_pad_i,
    tdi_pad_i,
    tdo_pad_o
);

input eHalfBit;
input \shiftReg[8] ;
input \shiftReg[7] ;
input \shiftReg[6] ;
input \shiftReg[5] ;
input \shiftReg[4] ;
input \shiftReg[3] ;
input \shiftReg[2] ;
input \shiftReg[1] ;
input \shiftReg[0] ;
input \cBaudRate[11] ;
input \cBaudRate[10] ;
input \cBaudRate[9] ;
input \cBaudRate[8] ;
input \cBaudRate[7] ;
input \cBaudRate[6] ;
input \cBaudRate[5] ;
input \cBaudRate[4] ;
input \cBaudRate[3] ;
input \cBaudRate[2] ;
input \cBaudRate[1] ;
input \cBaudRate[0] ;
input \cHalfBit[6] ;
input \cHalfBit[5] ;
input \cHalfBit[4] ;
input \cHalfBit[3] ;
input \cHalfBit[2] ;
input \cHalfBit[1] ;
input \cHalfBit[0] ;
input eCFrame;
input eCFramer;
input clk;
input tms_pad_i;
input tck_pad_i;
input tdi_pad_i;
output tdo_pad_o;

wire eHalfBit;
wire \shiftReg[8] ;
wire \shiftReg[7] ;
wire \shiftReg[6] ;
wire \shiftReg[5] ;
wire \shiftReg[4] ;
wire \shiftReg[3] ;
wire \shiftReg[2] ;
wire \shiftReg[1] ;
wire \shiftReg[0] ;
wire \cBaudRate[11] ;
wire \cBaudRate[10] ;
wire \cBaudRate[9] ;
wire \cBaudRate[8] ;
wire \cBaudRate[7] ;
wire \cBaudRate[6] ;
wire \cBaudRate[5] ;
wire \cBaudRate[4] ;
wire \cBaudRate[3] ;
wire \cBaudRate[2] ;
wire \cBaudRate[1] ;
wire \cBaudRate[0] ;
wire \cHalfBit[6] ;
wire \cHalfBit[5] ;
wire \cHalfBit[4] ;
wire \cHalfBit[3] ;
wire \cHalfBit[2] ;
wire \cHalfBit[1] ;
wire \cHalfBit[0] ;
wire eCFrame;
wire eCFramer;
wire clk;
wire tms_pad_i;
wire tck_pad_i;
wire tdi_pad_i;
wire tdo_pad_o;
wire tms_i_c;
wire tck_i_c;
wire tdi_i_c;
wire tdo_o_c;
wire [9:0] control0;
wire gao_jtag_tck;
wire gao_jtag_reset;
wire run_test_idle_er1;
wire run_test_idle_er2;
wire shift_dr_capture_dr;
wire update_dr;
wire pause_dr;
wire enable_er1;
wire enable_er2;
wire gao_jtag_tdi;
wire tdo_er1;

IBUF tms_ibuf (
    .I(tms_pad_i),
    .O(tms_i_c)
);

IBUF tck_ibuf (
    .I(tck_pad_i),
    .O(tck_i_c)
);

IBUF tdi_ibuf (
    .I(tdi_pad_i),
    .O(tdi_i_c)
);

OBUF tdo_obuf (
    .I(tdo_o_c),
    .O(tdo_pad_o)
);

GW_JTAG  u_gw_jtag(
    .tms_pad_i(tms_i_c),
    .tck_pad_i(tck_i_c),
    .tdi_pad_i(tdi_i_c),
    .tdo_pad_o(tdo_o_c),
    .tck_o(gao_jtag_tck),
    .test_logic_reset_o(gao_jtag_reset),
    .run_test_idle_er1_o(run_test_idle_er1),
    .run_test_idle_er2_o(run_test_idle_er2),
    .shift_dr_capture_dr_o(shift_dr_capture_dr),
    .update_dr_o(update_dr),
    .pause_dr_o(pause_dr),
    .enable_er1_o(enable_er1),
    .enable_er2_o(enable_er2),
    .tdi_o(gao_jtag_tdi),
    .tdo_er1_i(tdo_er1),
    .tdo_er2_i(1'b0)
);

gw_con_top  u_icon_top(
    .tck_i(gao_jtag_tck),
    .tdi_i(gao_jtag_tdi),
    .tdo_o(tdo_er1),
    .rst_i(gao_jtag_reset),
    .control0(control0[9:0]),
    .enable_i(enable_er1),
    .shift_dr_capture_dr_i(shift_dr_capture_dr),
    .update_dr_i(update_dr)
);

ao_top u_ao_top(
    .control(control0[9:0]),
    .data_i({eHalfBit,\shiftReg[8] ,\shiftReg[7] ,\shiftReg[6] ,\shiftReg[5] ,\shiftReg[4] ,\shiftReg[3] ,\shiftReg[2] ,\shiftReg[1] ,\shiftReg[0] ,\cBaudRate[11] ,\cBaudRate[10] ,\cBaudRate[9] ,\cBaudRate[8] ,\cBaudRate[7] ,\cBaudRate[6] ,\cBaudRate[5] ,\cBaudRate[4] ,\cBaudRate[3] ,\cBaudRate[2] ,\cBaudRate[1] ,\cBaudRate[0] ,\cHalfBit[6] ,\cHalfBit[5] ,\cHalfBit[4] ,\cHalfBit[3] ,\cHalfBit[2] ,\cHalfBit[1] ,\cHalfBit[0] ,eCFrame,eCFramer}),
    .clk_i(clk)
);

endmodule
