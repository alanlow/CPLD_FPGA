// Verilog netlist produced by program LSE :  version Diamond Version 0.0.0
// Netlist written on Sat Apr 11 22:00:49 2020
//
// Verilog Description of module KEPLER_TL
//

module KEPLER_TL (mcu_clko, rxd_1v8, adc_dclk, cpld_seln, pps_rstn, 
            cpld_rstn, adc_drdyn, spi_miso, cpld_clk, cpld_sdi, cpld_sdo, 
            adc_clk1, adc_sel1, adc_sel0, adc_clk0, spi_clk, spi_mosi, 
            freq_clka);   // kepler_tl.vhd(6[8:17])
    input mcu_clko;   // kepler_tl.vhd(8[4:12])
    input rxd_1v8;   // kepler_tl.vhd(9[4:11])
    input adc_dclk;   // kepler_tl.vhd(10[4:12])
    input cpld_seln;   // kepler_tl.vhd(11[4:13])
    input pps_rstn;   // kepler_tl.vhd(12[4:12])
    input cpld_rstn;   // kepler_tl.vhd(13[4:13])
    input adc_drdyn;   // kepler_tl.vhd(14[4:13])
    input spi_miso;   // kepler_tl.vhd(15[4:12])
    input cpld_clk;   // kepler_tl.vhd(16[4:12])
    input cpld_sdi;   // kepler_tl.vhd(17[4:12])
    output cpld_sdo;   // kepler_tl.vhd(19[4:12])
    output adc_clk1;   // kepler_tl.vhd(20[4:12])
    output adc_sel1;   // kepler_tl.vhd(21[4:12])
    output adc_sel0;   // kepler_tl.vhd(22[4:12])
    output adc_clk0;   // kepler_tl.vhd(23[4:12])
    output spi_clk;   // kepler_tl.vhd(24[4:11])
    output spi_mosi;   // kepler_tl.vhd(25[4:12])
    output freq_clka;   // kepler_tl.vhd(26[4:13])
    
    wire rxd_1v8_c /* synthesis SET_AS_NETWORK=rxd_1v8_c, is_clock=1 */ ;   // kepler_tl.vhd(9[4:11])
    wire cpld_seln_c /* synthesis is_clock=1 */ ;   // kepler_tl.vhd(11[4:13])
    wire nsel_N_28 /* synthesis is_inv_clock=1, SET_AS_NETWORK=\spi_module/nsel_N_28, is_clock=1 */ ;   // spi_mod.vhd(16[9:13])
    
    wire freq_clka_c_c, adc_clk0_c_c, pps_rstn_c, cpld_rstn_c, adc_sel0_c_c, 
        spi_miso_c, spi_clk_c_c, spi_mosi_c_c, cpld_sdo_c, n165, n172, 
        sOut, n259;
    wire [23:0]pps_reg;   // kepler_tl.vhd(57[10:17])
    
    wire n24, n23, n22, n21, n20, n19, n18, n17, n16, n15, 
        n14, n13, n12, n11, n10, n9, n8, n7, n6, n5, n4, 
        n3, n2, pwr, n151, n109, n158, n179, n186, n193, n200, 
        n207, n214, n221, n228, n235, n242, n249, gnd, n116, 
        n123, n260, n130, n102, n137, n144, n102_adj_29, n103, 
        n104, n105, n106, n107, n108, n109_adj_30, n110, n111, 
        n112, n113, n114, n115, n116_adj_31, n117, n118, n119, 
        n120, n121, n122, n123_adj_32, n124, n125;
    
    AND2 i163 (.O(n228), .I0(n221), .I1(n5));
    AND2 i170 (.O(n235), .I0(n228), .I1(n4));
    AND2 i177 (.O(n242), .I0(n235), .I1(n3));
    AND2 i149 (.O(n214), .I0(n207), .I1(n7));
    AND2 i184 (.O(n249), .I0(n242), .I1(n2));
    AND2 i156 (.O(n221), .I0(n214), .I1(n6));
    AND2 i199 (.O(n260), .I0(cpld_seln_c), .I1(spi_miso_c));
    AND2 i198 (.O(n259), .I0(nsel_N_28), .I1(sOut));
    XOR2 i41 (.O(n123_adj_32), .I0(n102), .I1(n22));
    AND2 i51 (.O(n116), .I0(n109), .I1(n21));
    AND2 i37 (.O(n102), .I0(n24), .I1(n23));
    AND2 i44 (.O(n109), .I0(n102), .I1(n22));
    XOR2 i34 (.O(n124), .I0(n24), .I1(n23));
    XOR2 i55 (.O(n121), .I0(n116), .I1(n20));
    XOR2 i62 (.O(n120), .I0(n123), .I1(n19));
    XOR2 i69 (.O(n119), .I0(n130), .I1(n18));
    XOR2 i76 (.O(n118), .I0(n137), .I1(n17));
    XOR2 i83 (.O(n117), .I0(n144), .I1(n16));
    XOR2 i90 (.O(n116_adj_31), .I0(n151), .I1(n15));
    XOR2 i97 (.O(n115), .I0(n158), .I1(n14));
    XOR2 i104 (.O(n114), .I0(n165), .I1(n13));
    XOR2 i111 (.O(n113), .I0(n172), .I1(n12));
    XOR2 i118 (.O(n112), .I0(n179), .I1(n11));
    XOR2 i125 (.O(n111), .I0(n186), .I1(n10));
    XOR2 i132 (.O(n110), .I0(n193), .I1(n9));
    XOR2 i139 (.O(n109_adj_30), .I0(n200), .I1(n8));
    XOR2 i146 (.O(n108), .I0(n207), .I1(n7));
    XOR2 i153 (.O(n107), .I0(n214), .I1(n6));
    XOR2 i160 (.O(n106), .I0(n221), .I1(n5));
    XOR2 i167 (.O(n105), .I0(n228), .I1(n4));
    XOR2 i174 (.O(n104), .I0(n235), .I1(n3));
    XOR2 i181 (.O(n103), .I0(n242), .I1(n2));
    XOR2 i48 (.O(n122), .I0(n109), .I1(n21));
    XOR2 i188 (.O(n102_adj_29), .I0(n249), .I1(pps_reg[23]));
    AND2 i58 (.O(n123), .I0(n116), .I1(n20));
    OR2 i200 (.O(cpld_sdo_c), .I0(n260), .I1(n259));
    SPI_MOD spi_module (.n66({sOut}), .nsel_N_28(nsel_N_28), .\pps_reg[23] (pps_reg[23]));   // kepler_tl.vhd(69[16:23])
    GND i196 (.X(gnd));
    INV i32 (.O(n125), .I0(n24));
    INV nsel_I_0 (.O(nsel_N_28), .I0(cpld_seln_c));
    PPS_COUNT pps_counter (.\pps_reg[23] (pps_reg[23]), .rxd_1v8_c(rxd_1v8_c), 
            .pps_rstn_c(pps_rstn_c), .n101({n102_adj_29, n103, n104, 
            n105, n106, n107, n108, n109_adj_30, n110, n111, n112, 
            n113, n114, n115, n116_adj_31, n117, n118, n119, n120, 
            n121, n122, n123_adj_32, n124, n125}), .n24(n24), .n2(n2), 
            .n3(n3), .n4(n4), .n5(n5), .n6(n6), .n7(n7), .n8(n8), 
            .n9(n9), .n10(n10), .n11(n11), .n12(n12), .n13(n13), .n14(n14), 
            .n15(n15), .n16(n16), .n17(n17), .n18(n18), .n19(n19), 
            .n20(n20), .n21(n21), .n22(n22), .n23(n23));   // kepler_tl.vhd(63[17:26])
    IBUF spi_mosi_c_pad (.O(spi_mosi_c_c), .I0(cpld_sdi));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF spi_clk_c_pad (.O(spi_clk_c_c), .I0(cpld_clk));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF spi_miso_pad (.O(spi_miso_c), .I0(spi_miso));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF adc_sel0_c_pad (.O(adc_sel0_c_c), .I0(adc_drdyn));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF cpld_rstn_pad (.O(cpld_rstn_c), .I0(cpld_rstn));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF pps_rstn_pad (.O(pps_rstn_c), .I0(pps_rstn));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF cpld_seln_pad (.O(cpld_seln_c), .I0(cpld_seln));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF adc_clk0_c_pad (.O(adc_clk0_c_c), .I0(adc_dclk));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF rxd_1v8_pad (.O(rxd_1v8_c), .I0(rxd_1v8));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF freq_clka_c_pad (.O(freq_clka_c_c), .I0(mcu_clko));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    OBUF freq_clka_pad (.O(freq_clka), .I0(freq_clka_c_c));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF spi_mosi_pad (.O(spi_mosi), .I0(spi_mosi_c_c));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF spi_clk_pad (.O(spi_clk), .I0(spi_clk_c_c));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF adc_clk0_pad (.O(adc_clk0), .I0(adc_clk0_c_c));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF adc_sel0_pad (.O(adc_sel0), .I0(adc_sel0_c_c));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF adc_sel1_pad (.O(adc_sel1), .I0(adc_sel0_c_c));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF adc_clk1_pad (.O(adc_clk1), .I0(adc_clk0_c_c));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF cpld_sdo_pad (.O(cpld_sdo), .I0(cpld_sdo_c));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    VCC i197 (.X(pwr));
    AND2 i142 (.O(n207), .I0(n200), .I1(n8));
    AND2 i135 (.O(n200), .I0(n193), .I1(n9));
    AND2 i128 (.O(n193), .I0(n186), .I1(n10));
    AND2 i121 (.O(n186), .I0(n179), .I1(n11));
    AND2 i114 (.O(n179), .I0(n172), .I1(n12));
    AND2 i107 (.O(n172), .I0(n165), .I1(n13));
    AND2 i100 (.O(n165), .I0(n158), .I1(n14));
    AND2 i93 (.O(n158), .I0(n151), .I1(n15));
    AND2 i86 (.O(n151), .I0(n144), .I1(n16));
    AND2 i79 (.O(n144), .I0(n137), .I1(n17));
    AND2 i72 (.O(n137), .I0(n130), .I1(n18));
    AND2 i65 (.O(n130), .I0(n123), .I1(n19));
    
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
// Verilog Description of module OR2
// module not written out since it is a black-box. 
//

//
// Verilog Description of module SPI_MOD
//

module SPI_MOD (n66, nsel_N_28, \pps_reg[23] );
    output [0:0]n66;
    input nsel_N_28;
    input \pps_reg[23] ;
    
    wire nsel_N_28 /* synthesis is_inv_clock=1, SET_AS_NETWORK=\spi_module/nsel_N_28, is_clock=1 */ ;   // spi_mod.vhd(16[9:13])
    
    DFF \spi_cntr.vPcnt_i0  (.Q(n66[0]), .D(\pps_reg[23] ), .CLK(nsel_N_28)) /* synthesis LSE_LINE_FILE_ID=26, LSE_LCOL=16, LSE_RCOL=23, LSE_LLINE=69, LSE_RLINE=69 */ ;   // spi_mod.vhd(33[4] 42[11])
    
endmodule
//
// Verilog Description of module GND
// module not written out since it is a black-box. 
//

//
// Verilog Description of module INV
// module not written out since it is a black-box. 
//

//
// Verilog Description of module PPS_COUNT
//

module PPS_COUNT (\pps_reg[23] , rxd_1v8_c, pps_rstn_c, n101, n24, 
            n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, 
            n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, 
            n23);
    output \pps_reg[23] ;
    input rxd_1v8_c;
    input pps_rstn_c;
    input [23:0]n101;
    output n24;
    output n2;
    output n3;
    output n4;
    output n5;
    output n6;
    output n7;
    output n8;
    output n9;
    output n10;
    output n11;
    output n12;
    output n13;
    output n14;
    output n15;
    output n16;
    output n17;
    output n18;
    output n19;
    output n20;
    output n21;
    output n22;
    output n23;
    
    wire rxd_1v8_c /* synthesis SET_AS_NETWORK=rxd_1v8_c, is_clock=1 */ ;   // kepler_tl.vhd(9[4:11])
    
    DFFR temp_pcnt_5__i23 (.Q(\pps_reg[23] ), .D(n101[23]), .CLK(rxd_1v8_c), 
         .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i0 (.Q(n24), .D(n101[0]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i22 (.Q(n2), .D(n101[22]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i21 (.Q(n3), .D(n101[21]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i20 (.Q(n4), .D(n101[20]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i19 (.Q(n5), .D(n101[19]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i18 (.Q(n6), .D(n101[18]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i17 (.Q(n7), .D(n101[17]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i16 (.Q(n8), .D(n101[16]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i15 (.Q(n9), .D(n101[15]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i14 (.Q(n10), .D(n101[14]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i13 (.Q(n11), .D(n101[13]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i12 (.Q(n12), .D(n101[12]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i11 (.Q(n13), .D(n101[11]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i10 (.Q(n14), .D(n101[10]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i9 (.Q(n15), .D(n101[9]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i8 (.Q(n16), .D(n101[8]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i7 (.Q(n17), .D(n101[7]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i6 (.Q(n18), .D(n101[6]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i5 (.Q(n19), .D(n101[5]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i4 (.Q(n20), .D(n101[4]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i3 (.Q(n21), .D(n101[3]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i2 (.Q(n22), .D(n101[2]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    DFFR temp_pcnt_5__i1 (.Q(n23), .D(n101[1]), .CLK(rxd_1v8_c), .R(pps_rstn_c)) /* synthesis syn_use_carry_chain=1 */ ;   // C:/ispLEVER_Classic2_0/lse/vhdl_packages/syn_unsi.vhd(118[20:31])
    
endmodule
//
// Verilog Description of module VCC
// module not written out since it is a black-box. 
//

