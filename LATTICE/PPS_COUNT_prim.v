// Verilog netlist produced by program LSE :  version Diamond Version 0.0.0
// Netlist written on Sat Apr 11 15:13:57 2020
//
// Verilog Description of module PPS_COUNT
//

module PPS_COUNT (pps, nclr, pcnt);   // pps_count.vhd(6[8:17])
    input pps;   // pps_count.vhd(8[2:5])
    input nclr;   // pps_count.vhd(8[7:11])
    output [23:0]pcnt;   // pps_count.vhd(9[2:6])
    
    wire pps_c /* synthesis SET_AS_NETWORK=pps_c, is_clock=1 */ ;   // pps_count.vhd(8[2:5])
    
    wire pwr, nclr_c, pcnt_c_23, pcnt_c_22, pcnt_c_21, pcnt_c_20, 
        pcnt_c_19, pcnt_c_18, pcnt_c_17, pcnt_c_16, pcnt_c_15, pcnt_c_14, 
        pcnt_c_13, pcnt_c_12, pcnt_c_11, pcnt_c_10, pcnt_c_9, pcnt_c_8, 
        pcnt_c_7, pcnt_c_6, pcnt_c_5, pcnt_c_4, pcnt_c_3, pcnt_c_2, 
        pcnt_c_1, pcnt_c_0, n103, n102, n103_adj_1, n104, n105, 
        n106, n107, n108, n109, n110_adj_2, n111, n112, n113, 
        n114, n115, n116, n117_adj_3, n118, n119, n120, n121, 
        n122, n123, n124_adj_4, n125, gnd, n96, n110, n117, 
        n124, n131, n138, n145, n152, n159, n166, n173, n180, 
        n187, n194, n201, n208, n215, n222, n229, n236, n243;
    
    AND2 i73 (.O(n117), .I0(n110), .I1(pcnt_c_4));
    AND2 i192 (.O(n236), .I0(n229), .I1(pcnt_c_21));
    AND2 i199 (.O(n243), .I0(n236), .I1(pcnt_c_22));
    AND2 i185 (.O(n229), .I0(n222), .I1(pcnt_c_20));
    XOR2 i56 (.O(n123), .I0(n96), .I1(pcnt_c_2));
    AND2 i66 (.O(n110), .I0(n103), .I1(pcnt_c_3));
    AND2 i52 (.O(n96), .I0(pcnt_c_0), .I1(pcnt_c_1));
    AND2 i59 (.O(n103), .I0(n96), .I1(pcnt_c_2));
    XOR2 i49 (.O(n124_adj_4), .I0(pcnt_c_0), .I1(pcnt_c_1));
    DFFR temp_pcnt_12__i24 (.Q(pcnt_c_23), .D(n102), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    XOR2 i70 (.O(n121), .I0(n110), .I1(pcnt_c_4));
    XOR2 i77 (.O(n120), .I0(n117), .I1(pcnt_c_5));
    XOR2 i84 (.O(n119), .I0(n124), .I1(pcnt_c_6));
    XOR2 i91 (.O(n118), .I0(n131), .I1(pcnt_c_7));
    XOR2 i98 (.O(n117_adj_3), .I0(n138), .I1(pcnt_c_8));
    XOR2 i105 (.O(n116), .I0(n145), .I1(pcnt_c_9));
    XOR2 i112 (.O(n115), .I0(n152), .I1(pcnt_c_10));
    XOR2 i119 (.O(n114), .I0(n159), .I1(pcnt_c_11));
    XOR2 i126 (.O(n113), .I0(n166), .I1(pcnt_c_12));
    XOR2 i133 (.O(n112), .I0(n173), .I1(pcnt_c_13));
    XOR2 i140 (.O(n111), .I0(n180), .I1(pcnt_c_14));
    XOR2 i147 (.O(n110_adj_2), .I0(n187), .I1(pcnt_c_15));
    XOR2 i154 (.O(n109), .I0(n194), .I1(pcnt_c_16));
    XOR2 i161 (.O(n108), .I0(n201), .I1(pcnt_c_17));
    XOR2 i168 (.O(n107), .I0(n208), .I1(pcnt_c_18));
    XOR2 i203 (.O(n102), .I0(n243), .I1(pcnt_c_23));
    XOR2 i189 (.O(n104), .I0(n229), .I1(pcnt_c_21));
    XOR2 i63 (.O(n122), .I0(n103), .I1(pcnt_c_3));
    XOR2 i175 (.O(n106), .I0(n215), .I1(pcnt_c_19));
    XOR2 i196 (.O(n103_adj_1), .I0(n236), .I1(pcnt_c_22));
    XOR2 i182 (.O(n105), .I0(n222), .I1(pcnt_c_20));
    GND i211 (.X(gnd));
    INV i47 (.O(n125), .I0(pcnt_c_0));
    DFFR temp_pcnt_12__i23 (.Q(pcnt_c_22), .D(n103_adj_1), .CLK(pps_c), 
         .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i22 (.Q(pcnt_c_21), .D(n104), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i21 (.Q(pcnt_c_20), .D(n105), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i20 (.Q(pcnt_c_19), .D(n106), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i19 (.Q(pcnt_c_18), .D(n107), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i18 (.Q(pcnt_c_17), .D(n108), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i17 (.Q(pcnt_c_16), .D(n109), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i16 (.Q(pcnt_c_15), .D(n110_adj_2), .CLK(pps_c), 
         .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i15 (.Q(pcnt_c_14), .D(n111), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i14 (.Q(pcnt_c_13), .D(n112), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i13 (.Q(pcnt_c_12), .D(n113), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i12 (.Q(pcnt_c_11), .D(n114), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i11 (.Q(pcnt_c_10), .D(n115), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i10 (.Q(pcnt_c_9), .D(n116), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i9 (.Q(pcnt_c_8), .D(n117_adj_3), .CLK(pps_c), 
         .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i8 (.Q(pcnt_c_7), .D(n118), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i7 (.Q(pcnt_c_6), .D(n119), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i6 (.Q(pcnt_c_5), .D(n120), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i5 (.Q(pcnt_c_4), .D(n121), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i4 (.Q(pcnt_c_3), .D(n122), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i3 (.Q(pcnt_c_2), .D(n123), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i2 (.Q(pcnt_c_1), .D(n124_adj_4), .CLK(pps_c), 
         .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_12__i1 (.Q(pcnt_c_0), .D(n125), .CLK(pps_c), .R(nclr_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    IBUF nclr_pad (.O(nclr_c), .I0(nclr));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF pps_pad (.O(pps_c), .I0(pps));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    OBUF pcnt_pad_0 (.O(pcnt[0]), .I0(pcnt_c_0));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_1 (.O(pcnt[1]), .I0(pcnt_c_1));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_2 (.O(pcnt[2]), .I0(pcnt_c_2));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_3 (.O(pcnt[3]), .I0(pcnt_c_3));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_4 (.O(pcnt[4]), .I0(pcnt_c_4));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_5 (.O(pcnt[5]), .I0(pcnt_c_5));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_6 (.O(pcnt[6]), .I0(pcnt_c_6));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_7 (.O(pcnt[7]), .I0(pcnt_c_7));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_8 (.O(pcnt[8]), .I0(pcnt_c_8));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_9 (.O(pcnt[9]), .I0(pcnt_c_9));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_10 (.O(pcnt[10]), .I0(pcnt_c_10));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_11 (.O(pcnt[11]), .I0(pcnt_c_11));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_12 (.O(pcnt[12]), .I0(pcnt_c_12));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_13 (.O(pcnt[13]), .I0(pcnt_c_13));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_14 (.O(pcnt[14]), .I0(pcnt_c_14));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_15 (.O(pcnt[15]), .I0(pcnt_c_15));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_16 (.O(pcnt[16]), .I0(pcnt_c_16));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_17 (.O(pcnt[17]), .I0(pcnt_c_17));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_18 (.O(pcnt[18]), .I0(pcnt_c_18));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_19 (.O(pcnt[19]), .I0(pcnt_c_19));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_20 (.O(pcnt[20]), .I0(pcnt_c_20));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_21 (.O(pcnt[21]), .I0(pcnt_c_21));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_22 (.O(pcnt[22]), .I0(pcnt_c_22));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF pcnt_pad_23 (.O(pcnt[23]), .I0(pcnt_c_23));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    VCC i212 (.X(pwr));
    AND2 i178 (.O(n222), .I0(n215), .I1(pcnt_c_19));
    AND2 i171 (.O(n215), .I0(n208), .I1(pcnt_c_18));
    AND2 i164 (.O(n208), .I0(n201), .I1(pcnt_c_17));
    AND2 i157 (.O(n201), .I0(n194), .I1(pcnt_c_16));
    AND2 i150 (.O(n194), .I0(n187), .I1(pcnt_c_15));
    AND2 i143 (.O(n187), .I0(n180), .I1(pcnt_c_14));
    AND2 i136 (.O(n180), .I0(n173), .I1(pcnt_c_13));
    AND2 i129 (.O(n173), .I0(n166), .I1(pcnt_c_12));
    AND2 i122 (.O(n166), .I0(n159), .I1(pcnt_c_11));
    AND2 i115 (.O(n159), .I0(n152), .I1(pcnt_c_10));
    AND2 i108 (.O(n152), .I0(n145), .I1(pcnt_c_9));
    AND2 i101 (.O(n145), .I0(n138), .I1(pcnt_c_8));
    AND2 i94 (.O(n138), .I0(n131), .I1(pcnt_c_7));
    AND2 i87 (.O(n131), .I0(n124), .I1(pcnt_c_6));
    AND2 i80 (.O(n124), .I0(n117), .I1(pcnt_c_5));
    
endmodule
//
// Verilog Description of module AND2
// module not written out since it is a black-box. 
//

//
// Verilog Description of module XOR2
// module not written out since it is a black-box. 
//

//
// Verilog Description of module GND
// module not written out since it is a black-box. 
//

//
// Verilog Description of module INV
// module not written out since it is a black-box. 
//

//
// Verilog Description of module VCC
// module not written out since it is a black-box. 
//

