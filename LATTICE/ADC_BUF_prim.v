// Verilog netlist produced by program LSE :  version Diamond Version 0.0.0
// Netlist written on Fri Apr 10 18:34:36 2020
//
// Verilog Description of module ADC_BUF
//

module ADC_BUF (drdyn, dclk, sel0, sel1, clk0, clk1);   // adc_buf.vhd(6[8:15])
    input drdyn;   // adc_buf.vhd(9[2:7])
    input dclk;   // adc_buf.vhd(9[9:13])
    output sel0;   // adc_buf.vhd(10[2:6])
    output sel1;   // adc_buf.vhd(10[8:12])
    output clk0;   // adc_buf.vhd(11[2:6])
    output clk1;   // adc_buf.vhd(11[8:12])
    
    
    wire sel1_c_c, clk1_c_c, pwr, gnd;
    
    OBUF sel0_pad (.O(sel0), .I0(sel1_c_c));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF clk0_pad (.O(clk0), .I0(clk1_c_c));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    OBUF clk1_pad (.O(clk1), .I0(clk1_c_c));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    IBUF sel1_c_pad (.O(sel1_c_c), .I0(drdyn));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    IBUF clk1_c_pad (.O(clk1_c_c), .I0(dclk));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(186[8:12])
    VCC i33 (.X(pwr));
    OBUF sel1_pad (.O(sel1), .I0(sel1_c_c));   // C:/ispLEVER_Classic2_0/lse/userware/NT/SYNTHESIS_HEADERS/mach.v(270[8:12])
    GND i32 (.X(gnd));
    
endmodule
//
// Verilog Description of module VCC
// module not written out since it is a black-box. 
//

//
// Verilog Description of module GND
// module not written out since it is a black-box. 
//

