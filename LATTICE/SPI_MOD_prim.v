// Verilog netlist produced by program LSE :  version Diamond Version 0.0.0
// Netlist written on Sat Apr 11 13:53:47 2020
//
// Verilog Description of module SPI_MOD
//

module SPI_MOD (pcnt, nclr, sdi, dclk, nsel, miso, sdo, sclk, 
            mosi);   // spi_mod.vhd(7[8:15])
    input [23:0]pcnt;   // spi_mod.vhd(9[2:6])
    input nclr;   // spi_mod.vhd(10[2:6])
    input sdi;   // spi_mod.vhd(10[8:11])
    input dclk;   // spi_mod.vhd(10[13:17])
    input nsel;   // spi_mod.vhd(10[19:23])
    input miso;   // spi_mod.vhd(10[25:29])
    output sdo;   // spi_mod.vhd(11[2:5])
    output sclk;   // spi_mod.vhd(11[7:11])
    output mosi;   // spi_mod.vhd(11[13:17])
    
    wire sclk_c_c /* synthesis is_clock=1 */ ;   // spi_mod.vhd(10[13:17])
    wire dclk_N_5 /* synthesis is_inv_clock=1, SET_AS_NETWORK=dclk_N_5, is_clock=1 */ ;   // spi_mod.vhd(16[9:14])
    
    wire pcnt_c_23, pcnt_c_22, pcnt_c_21, pcnt_c_20, pcnt_c_19, pcnt_c_18, 
        pcnt_c_17, pcnt_c_16, pcnt_c_15, pcnt_c_14, pcnt_c_13, pcnt_c_12, 
        pcnt_c_11, pcnt_c_10, pcnt_c_9, pcnt_c_8, pcnt_c_7, pcnt_c_6, 
        pcnt_c_5, pcnt_c_4, pcnt_c_3, pcnt_c_2, pcnt_c_1, pcnt_c_0, 
        nclr_c, mosi_c_c, nsel_c, miso_c, sdo_c, sPcnt_7__N_89;
    wire [23:0]sPcnt;   // spi_mod.vhd(16[9:14])
    
    wire sPcnt_7__N_88, sPcnt_8__N_84, sPcnt_8__N_83, n295, sPcnt_10__N_74, 
        sPcnt_10__N_73, sPcnt_12__N_64, sPcnt_12__N_63, n292, sPcnt_14__N_54, 
        sPcnt_14__N_53, sPcnt_16__N_44, sPcnt_16__N_43, n289, sPcnt_18__N_34, 
        sPcnt_18__N_33, sPcnt_20__N_24, sPcnt_20__N_23, n286, sPcnt_22__N_14, 
        sPcnt_22__N_13, nclr_N_8, nsel_N_3, n283, n330, sPcnt_9__N_79, 
        n327, sPcnt_9__N_78, n324, n321, sPcnt_11__N_69, n318, sPcnt_11__N_68, 
        n315, n280, n312, sPcnt_13__N_59, n309, sPcnt_13__N_58, 
        n306, n303, sPcnt_15__N_49, n300, sPcnt_15__N_48, n297, 
        n277, n294, sPcnt_17__N_39, n291, sPcnt_17__N_38, n288, 
        n285, sPcnt_19__N_29, n282, sPcnt_19__N_28, n279, n274, 
        n276, sPcnt_21__N_19, n273, sPcnt_21__N_18, n270, n267, 
        sPcnt_23__N_9, sPcnt_23__N_6, sPcnt_6__N_93, n271, sPcnt_6__N_94, 
        sPcnt_5__N_98, sPcnt_5__N_99, sPcnt_4__N_103, n268, sPcnt_4__N_104, 
        sPcnt_3__N_108, sPcnt_3__N_109, sPcnt_2__N_113, n265, sPcnt_2__N_114, 
        sPcnt_1__N_118, n264, sPcnt_1__N_119, pwr, gnd, n298, n301, 
        n304, n307, n310, n313, n316, n319, n322, n325, n328, 
        n334, n331, n333;
    
    AND2 nclr_N_8_I_0_151 (.O(sPcnt_22__N_13), .I0(pcnt_c_22), .I1(nclr_N_8));
    DFFCRSH \spi_cntr.vPcnt_3__141  (.Q(sPcnt[3]), .D(sPcnt[2]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_3__N_109), .S(sPcnt_3__N_108));   // spi_mod.vhd(36[4] 42[11])
    INV i444 (.O(n328), .I0(pcnt_c_2));
    DFFCRSH \spi_cntr.vPcnt_4__137  (.Q(sPcnt[4]), .D(sPcnt[3]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_4__N_104), .S(sPcnt_4__N_103));   // spi_mod.vhd(36[4] 42[11])
    INV i443 (.O(n327), .I0(nclr_c));
    DFFCRSH \spi_cntr.vPcnt_5__133  (.Q(sPcnt[5]), .D(sPcnt[4]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_5__N_99), .S(sPcnt_5__N_98));   // spi_mod.vhd(36[4] 42[11])
    INV i441 (.O(n325), .I0(pcnt_c_3));
    DFFCRSH \spi_cntr.vPcnt_6__129  (.Q(sPcnt[6]), .D(sPcnt[5]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_6__N_94), .S(sPcnt_6__N_93));   // spi_mod.vhd(36[4] 42[11])
    INV i440 (.O(n324), .I0(nclr_c));
    DFFCRSH \spi_cntr.vPcnt_7__125  (.Q(sPcnt[7]), .D(sPcnt[6]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_7__N_89), .S(sPcnt_7__N_88));   // spi_mod.vhd(36[4] 42[11])
    INV i438 (.O(n322), .I0(pcnt_c_4));
    DFFCRSH \spi_cntr.vPcnt_8__121  (.Q(sPcnt[8]), .D(sPcnt[7]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_8__N_84), .S(sPcnt_8__N_83));   // spi_mod.vhd(36[4] 42[11])
    INV i437 (.O(n321), .I0(nclr_c));
    DFFCRSH \spi_cntr.vPcnt_9__117  (.Q(sPcnt[9]), .D(sPcnt[8]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_9__N_79), .S(sPcnt_9__N_78));   // spi_mod.vhd(36[4] 42[11])
    INV i435 (.O(n319), .I0(pcnt_c_5));
    DFFCRSH \spi_cntr.vPcnt_10__113  (.Q(sPcnt[10]), .D(sPcnt[9]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_10__N_74), .S(sPcnt_10__N_73));   // spi_mod.vhd(36[4] 42[11])
    INV i434 (.O(n318), .I0(nclr_c));
    DFFCRSH \spi_cntr.vPcnt_11__109  (.Q(sPcnt[11]), .D(sPcnt[10]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_11__N_69), .S(sPcnt_11__N_68));   // spi_mod.vhd(36[4] 42[11])
    INV i432 (.O(n316), .I0(pcnt_c_6));
    DFFCRSH \spi_cntr.vPcnt_12__105  (.Q(sPcnt[12]), .D(sPcnt[11]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_12__N_64), .S(sPcnt_12__N_63));   // spi_mod.vhd(36[4] 42[11])
    INV i431 (.O(n315), .I0(nclr_c));
    DFFCRSH \spi_cntr.vPcnt_13__101  (.Q(sPcnt[13]), .D(sPcnt[12]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_13__N_59), .S(sPcnt_13__N_58));   // spi_mod.vhd(36[4] 42[11])
    INV i429 (.O(n313), .I0(pcnt_c_7));
    DFFCRSH \spi_cntr.vPcnt_14__97  (.Q(sPcnt[14]), .D(sPcnt[13]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_14__N_54), .S(sPcnt_14__N_53));   // spi_mod.vhd(36[4] 42[11])
    INV i428 (.O(n312), .I0(nclr_c));
    DFFCRSH \spi_cntr.vPcnt_15__93  (.Q(sPcnt[15]), .D(sPcnt[14]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_15__N_49), .S(sPcnt_15__N_48));   // spi_mod.vhd(36[4] 42[11])
    INV i426 (.O(n310), .I0(pcnt_c_8));
    DFFCRSH \spi_cntr.vPcnt_16__89  (.Q(sPcnt[16]), .D(sPcnt[15]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_16__N_44), .S(sPcnt_16__N_43));   // spi_mod.vhd(36[4] 42[11])
    INV i425 (.O(n309), .I0(nclr_c));
    DFFCRSH \spi_cntr.vPcnt_17__85  (.Q(sPcnt[17]), .D(sPcnt[16]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_17__N_39), .S(sPcnt_17__N_38));   // spi_mod.vhd(36[4] 42[11])
    INV i423 (.O(n307), .I0(pcnt_c_9));
    DFFCRSH \spi_cntr.vPcnt_18__81  (.Q(sPcnt[18]), .D(sPcnt[17]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_18__N_34), .S(sPcnt_18__N_33));   // spi_mod.vhd(36[4] 42[11])
    INV i422 (.O(n306), .I0(nclr_c));
    DFFCRSH \spi_cntr.vPcnt_19__77  (.Q(sPcnt[19]), .D(sPcnt[18]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_19__N_29), .S(sPcnt_19__N_28));   // spi_mod.vhd(36[4] 42[11])
    INV i420 (.O(n304), .I0(pcnt_c_10));
    DFFCRSH \spi_cntr.vPcnt_20__73  (.Q(sPcnt[20]), .D(sPcnt[19]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_20__N_24), .S(sPcnt_20__N_23));   // spi_mod.vhd(36[4] 42[11])
    INV i419 (.O(n303), .I0(nclr_c));
    DFFCRSH \spi_cntr.vPcnt_21__69  (.Q(sPcnt[21]), .D(sPcnt[20]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_21__N_19), .S(sPcnt_21__N_18));   // spi_mod.vhd(36[4] 42[11])
    INV i417 (.O(n301), .I0(pcnt_c_11));
    DFFCRSH \spi_cntr.vPcnt_22__65  (.Q(sPcnt[22]), .D(sPcnt[21]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_22__N_14), .S(sPcnt_22__N_13));   // spi_mod.vhd(36[4] 42[11])
    INV i416 (.O(n300), .I0(nclr_c));
    DFFCRSH \spi_cntr.vPcnt_23__61  (.Q(sPcnt[23]), .D(sPcnt[22]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_23__N_9), .S(sPcnt_23__N_6));   // spi_mod.vhd(36[4] 42[11])
    INV i414 (.O(n298), .I0(pcnt_c_12));
    DFFCRSH \spi_cntr.vPcnt_1__149  (.Q(sPcnt[1]), .D(sPcnt[0]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_1__N_119), .S(sPcnt_1__N_118));   // spi_mod.vhd(36[4] 42[11])
    INV i413 (.O(n297), .I0(nclr_c));
    AND2 i433 (.O(sPcnt_6__N_94), .I0(n316), .I1(n315));
    IBUF pcnt_pad_3 (.O(pcnt_c_3), .I0(pcnt[3]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    INV i411 (.O(n295), .I0(pcnt_c_13));
    AND2 i430 (.O(sPcnt_7__N_89), .I0(n313), .I1(n312));
    IBUF pcnt_pad_4 (.O(pcnt_c_4), .I0(pcnt[4]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    AND2 i427 (.O(sPcnt_8__N_84), .I0(n310), .I1(n309));
    IBUF pcnt_pad_5 (.O(pcnt_c_5), .I0(pcnt[5]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    INV i410 (.O(n294), .I0(nclr_c));
    AND2 i424 (.O(sPcnt_9__N_79), .I0(n307), .I1(n306));
    IBUF pcnt_pad_6 (.O(pcnt_c_6), .I0(pcnt[6]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    AND2 i421 (.O(sPcnt_10__N_74), .I0(n304), .I1(n303));
    IBUF pcnt_pad_7 (.O(pcnt_c_7), .I0(pcnt[7]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    AND2 i418 (.O(sPcnt_11__N_69), .I0(n301), .I1(n300));
    IBUF pcnt_pad_8 (.O(pcnt_c_8), .I0(pcnt[8]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    INV i408 (.O(n292), .I0(pcnt_c_14));
    AND2 i415 (.O(sPcnt_12__N_64), .I0(n298), .I1(n297));
    IBUF pcnt_pad_9 (.O(pcnt_c_9), .I0(pcnt[9]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    AND2 i412 (.O(sPcnt_13__N_59), .I0(n295), .I1(n294));
    IBUF pcnt_pad_10 (.O(pcnt_c_10), .I0(pcnt[10]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    AND2 i409 (.O(sPcnt_14__N_54), .I0(n292), .I1(n291));
    IBUF pcnt_pad_11 (.O(pcnt_c_11), .I0(pcnt[11]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    INV i407 (.O(n291), .I0(nclr_c));
    AND2 i406 (.O(sPcnt_15__N_49), .I0(n289), .I1(n288));
    IBUF pcnt_pad_12 (.O(pcnt_c_12), .I0(pcnt[12]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    AND2 i449 (.O(n333), .I0(nsel_N_3), .I1(sPcnt[23]));
    IBUF pcnt_pad_13 (.O(pcnt_c_13), .I0(pcnt[13]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    AND2 i450 (.O(n334), .I0(nsel_c), .I1(miso_c));
    IBUF pcnt_pad_14 (.O(pcnt_c_14), .I0(pcnt[14]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    INV i405 (.O(n289), .I0(pcnt_c_15));
    OR2 i451 (.O(sdo_c), .I0(n334), .I1(n333));
    IBUF pcnt_pad_15 (.O(pcnt_c_15), .I0(pcnt[15]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    AND2 i403 (.O(sPcnt_16__N_44), .I0(n286), .I1(n285));
    IBUF pcnt_pad_16 (.O(pcnt_c_16), .I0(pcnt[16]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    AND2 i382 (.O(sPcnt_23__N_9), .I0(n265), .I1(n264));
    IBUF pcnt_pad_17 (.O(pcnt_c_17), .I0(pcnt[17]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    INV i404 (.O(n288), .I0(nclr_c));
    AND2 i385 (.O(sPcnt_22__N_14), .I0(n268), .I1(n267));
    IBUF pcnt_pad_18 (.O(pcnt_c_18), .I0(pcnt[18]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    AND2 i388 (.O(sPcnt_21__N_19), .I0(n271), .I1(n270));
    IBUF pcnt_pad_19 (.O(pcnt_c_19), .I0(pcnt[19]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    AND2 i391 (.O(sPcnt_20__N_24), .I0(n274), .I1(n273));
    IBUF pcnt_pad_20 (.O(pcnt_c_20), .I0(pcnt[20]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    GND i378 (.X(gnd));
    AND2 i394 (.O(sPcnt_19__N_29), .I0(n277), .I1(n276));
    IBUF pcnt_pad_21 (.O(pcnt_c_21), .I0(pcnt[21]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    AND2 i397 (.O(sPcnt_18__N_34), .I0(n280), .I1(n279));
    IBUF pcnt_pad_22 (.O(pcnt_c_22), .I0(pcnt[22]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    AND2 i400 (.O(sPcnt_17__N_39), .I0(n283), .I1(n282));
    IBUF pcnt_pad_23 (.O(pcnt_c_23), .I0(pcnt[23]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    VCC i379 (.X(pwr));
    AND2 sPcnt_23__I_1 (.O(sPcnt_23__N_6), .I0(pcnt_c_23), .I1(nclr_N_8));
    OBUF mosi_pad (.O(mosi), .I0(mosi_c_c));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    AND2 nclr_N_8_I_0_193 (.O(sPcnt_1__N_118), .I0(pcnt_c_1), .I1(nclr_N_8));
    OBUF sclk_pad (.O(sclk), .I0(sclk_c_c));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    AND2 nclr_N_8_I_0_191 (.O(sPcnt_2__N_113), .I0(pcnt_c_2), .I1(nclr_N_8));
    DLAT i195 (.Q(sPcnt[0]), .D(pcnt_c_0), .LAT(nclr_N_8));   // spi_mod.vhd(36[4] 42[11])
    INV i380 (.O(n264), .I0(nclr_c));
    AND2 nclr_N_8_I_0_189 (.O(sPcnt_3__N_108), .I0(pcnt_c_3), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_187 (.O(sPcnt_4__N_103), .I0(pcnt_c_4), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_185 (.O(sPcnt_5__N_98), .I0(pcnt_c_5), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_183 (.O(sPcnt_6__N_93), .I0(pcnt_c_6), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_181 (.O(sPcnt_7__N_88), .I0(pcnt_c_7), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_179 (.O(sPcnt_8__N_83), .I0(pcnt_c_8), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_177 (.O(sPcnt_9__N_78), .I0(pcnt_c_9), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_175 (.O(sPcnt_10__N_73), .I0(pcnt_c_10), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_173 (.O(sPcnt_11__N_68), .I0(pcnt_c_11), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_171 (.O(sPcnt_12__N_63), .I0(pcnt_c_12), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_169 (.O(sPcnt_13__N_58), .I0(pcnt_c_13), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_167 (.O(sPcnt_14__N_53), .I0(pcnt_c_14), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_165 (.O(sPcnt_15__N_48), .I0(pcnt_c_15), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_163 (.O(sPcnt_16__N_43), .I0(pcnt_c_16), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_161 (.O(sPcnt_17__N_38), .I0(pcnt_c_17), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_159 (.O(sPcnt_18__N_33), .I0(pcnt_c_18), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_157 (.O(sPcnt_19__N_28), .I0(pcnt_c_19), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_155 (.O(sPcnt_20__N_23), .I0(pcnt_c_20), .I1(nclr_N_8));
    AND2 nclr_N_8_I_0_153 (.O(sPcnt_21__N_18), .I0(pcnt_c_21), .I1(nclr_N_8));
    INV i381 (.O(n265), .I0(pcnt_c_23));
    INV i383 (.O(n267), .I0(nclr_c));
    INV i384 (.O(n268), .I0(pcnt_c_22));
    IBUF pcnt_pad_2 (.O(pcnt_c_2), .I0(pcnt[2]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF pcnt_pad_1 (.O(pcnt_c_1), .I0(pcnt[1]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF pcnt_pad_0 (.O(pcnt_c_0), .I0(pcnt[0]));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF nclr_pad (.O(nclr_c), .I0(nclr));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF mosi_c_pad (.O(mosi_c_c), .I0(sdi));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF sclk_c_pad (.O(sclk_c_c), .I0(dclk));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF nsel_pad (.O(nsel_c), .I0(nsel));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF miso_pad (.O(miso_c), .I0(miso));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    DFFCRSH \spi_cntr.vPcnt_2__145  (.Q(sPcnt[2]), .D(sPcnt[1]), .CLK(dclk_N_5), 
            .CE(nsel_N_3), .R(sPcnt_2__N_114), .S(sPcnt_2__N_113));   // spi_mod.vhd(36[4] 42[11])
    OBUF sdo_pad (.O(sdo), .I0(sdo_c));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    INV i386 (.O(n270), .I0(nclr_c));
    INV i387 (.O(n271), .I0(pcnt_c_21));
    INV i389 (.O(n273), .I0(nclr_c));
    INV i390 (.O(n274), .I0(pcnt_c_20));
    INV i392 (.O(n276), .I0(nclr_c));
    INV i393 (.O(n277), .I0(pcnt_c_19));
    INV i395 (.O(n279), .I0(nclr_c));
    INV i396 (.O(n280), .I0(pcnt_c_18));
    INV i398 (.O(n282), .I0(nclr_c));
    INV i399 (.O(n283), .I0(pcnt_c_17));
    INV i401 (.O(n285), .I0(nclr_c));
    INV i402 (.O(n286), .I0(pcnt_c_16));
    INV nsel_I_0 (.O(nsel_N_3), .I0(nsel_c));
    INV dclk_I_0 (.O(dclk_N_5), .I0(sclk_c_c));
    INV nclr_I_0 (.O(nclr_N_8), .I0(nclr_c));
    AND2 i436 (.O(sPcnt_5__N_99), .I0(n319), .I1(n318));
    AND2 i439 (.O(sPcnt_4__N_104), .I0(n322), .I1(n321));
    AND2 i442 (.O(sPcnt_3__N_109), .I0(n325), .I1(n324));
    AND2 i445 (.O(sPcnt_2__N_114), .I0(n328), .I1(n327));
    AND2 i448 (.O(sPcnt_1__N_119), .I0(n331), .I1(n330));
    INV i446 (.O(n330), .I0(nclr_c));
    INV i447 (.O(n331), .I0(pcnt_c_1));
    
endmodule
//
// Verilog Description of module AND2
// module not written out since it is a black-box. 
//

//
// Verilog Description of module INV
// module not written out since it is a black-box. 
//

//
// Verilog Description of module OR2
// module not written out since it is a black-box. 
//

//
// Verilog Description of module GND
// module not written out since it is a black-box. 
//

//
// Verilog Description of module VCC
// module not written out since it is a black-box. 
//

