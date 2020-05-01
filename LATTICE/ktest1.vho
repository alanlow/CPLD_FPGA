-- VHDL netlist-file
library mach;
use mach.components.all;

library ieee;
use ieee.std_logic_1164.all;
entity KEPLER_TL is
  port (
    mcu_clko : in std_logic;
    rxd_1v8 : in std_logic;
    adc_dclk : in std_logic;
    cpld_seln : in std_logic;
    pps_rstn : in std_logic;
    adc_drdyn : in std_logic;
    spi_miso : in std_logic;
    cpld_clk : in std_logic;
    cpld_sdi : in std_logic;
    cpld_sdo : out std_logic;
    adc_clk1 : out std_logic;
    adc_sel1 : out std_logic;
    adc_sel0 : out std_logic;
    adc_clk0 : out std_logic;
    spi_clk : out std_logic;
    spi_mosi : out std_logic;
    freq_clka : out std_logic
  );
end KEPLER_TL;

architecture NetList of KEPLER_TL is

  signal mcu_clkoPIN : std_logic;
  signal rxd_1v8PIN : std_logic;
  signal adc_dclkPIN : std_logic;
  signal cpld_selnPIN : std_logic;
  signal pps_rstnPIN : std_logic;
  signal adc_drdynPIN : std_logic;
  signal spi_misoPIN : std_logic;
  signal cpld_clkPIN : std_logic;
  signal cpld_sdiPIN : std_logic;
  signal cpld_sdoCOM : std_logic;
  signal adc_clk1COM : std_logic;
  signal adc_sel1COM : std_logic;
  signal adc_sel0COM : std_logic;
  signal adc_clk0COM : std_logic;
  signal spi_clkCOM : std_logic;
  signal spi_mosiCOM : std_logic;
  signal freq_clkaCOM : std_logic;
  signal spi_module_Xspi_cntr_vPcnt_i0Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi23Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi0Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi1Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi2Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi3Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi4Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi5Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi6Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi7Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi8Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi9Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi10Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi11Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi12Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi13Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi14Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi15Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi16Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi17Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi18Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi19Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi20Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi21Q : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi22Q : std_logic;
  signal spi_module_Xspi_cntr_vPcnt_i0_C : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi23_T : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi23_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi0_D : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi0_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi1_D : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi1_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi2_D : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi2_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi3_D : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi3_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi4_D_X1 : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi4_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi5_T : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi5_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi6_T : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi6_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi7_T : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi7_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi8_T : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi8_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi9_T : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi9_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi10_D : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi10_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi11_D : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi11_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi12_D_X1 : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi12_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi13_T : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi13_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi14_T : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi14_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi15_T : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi15_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi16_T : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi16_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi17_T : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi17_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi18_T : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi18_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi19_T : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi19_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi20_T : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi20_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi21_T : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi21_AR : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi22_T : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi22_AR : std_logic;
  signal n151 : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi4_D : std_logic;
  signal pps_counter_Xtemp_pcnt_5_Xi12_D : std_logic;
  signal T_0 : std_logic;
  signal T_1 : std_logic;
  signal T_2 : std_logic;
  signal T_3 : std_logic;
  signal T_4 : std_logic;
  signal T_5 : std_logic;
  signal T_6 : std_logic;
  signal T_7 : std_logic;
  signal T_8 : std_logic;
  signal T_9 : std_logic;
  signal T_10 : std_logic;
  signal T_11 : std_logic;
  signal T_12 : std_logic;
  signal T_13 : std_logic;
  signal T_14 : std_logic;
  signal T_15 : std_logic;
  signal T_16 : std_logic;
  signal T_17 : std_logic;
  signal T_18 : std_logic;
  signal T_19 : std_logic;
  signal T_20 : std_logic;
  signal T_21 : std_logic;
  signal T_22 : std_logic;
  signal T_23 : std_logic;
  signal T_24 : std_logic;
  signal T_25 : std_logic;
  signal T_26 : std_logic;
  signal T_27 : std_logic;
  signal T_28 : std_logic;
  signal T_29 : std_logic;
  signal T_30 : std_logic;
  signal T_31 : std_logic;
  signal T_32 : std_logic;
  signal T_33 : std_logic;
  signal T_34 : std_logic;
  signal T_35 : std_logic;
  signal T_36 : std_logic;
  signal T_37 : std_logic;
  signal T_38 : std_logic;
  signal T_39 : std_logic;
  signal T_40 : std_logic;
  signal T_41 : std_logic;
  signal T_42 : std_logic;
  signal T_43 : std_logic;
  signal T_44 : std_logic;
  signal T_45 : std_logic;
  signal T_46 : std_logic;
  signal T_47 : std_logic;
  signal T_48 : std_logic;
  signal T_49 : std_logic;
  signal T_50 : std_logic;
  signal T_51 : std_logic;
  signal T_52 : std_logic;
  signal T_53 : std_logic;
  signal T_54 : std_logic;
  signal T_55 : std_logic;
  signal T_56 : std_logic;
  signal T_57 : std_logic;
  signal T_58 : std_logic;
  signal T_59 : std_logic;
  signal T_60 : std_logic;
  signal T_61 : std_logic;
  signal T_62 : std_logic;
  signal T_63 : std_logic;
  signal T_64 : std_logic;
  signal T_65 : std_logic;
  signal T_66 : std_logic;
  signal T_67 : std_logic;
  signal T_68 : std_logic;
  signal T_69 : std_logic;
  signal T_70 : std_logic;
  signal T_71 : std_logic;
  signal T_72 : std_logic;
  signal T_73 : std_logic;
  signal T_74 : std_logic;
  signal T_75 : std_logic;
  signal T_76 : std_logic;
  signal T_77 : std_logic;
  signal T_78 : std_logic;
  signal T_79 : std_logic;
  signal T_80 : std_logic;
  signal T_81 : std_logic;
  signal T_82 : std_logic;
  signal T_83 : std_logic;
  signal T_84 : std_logic;
  signal T_85 : std_logic;
  signal T_86 : std_logic;
  signal T_87 : std_logic;
  signal T_88 : std_logic;
  signal T_89 : std_logic;
  signal T_90 : std_logic;
  signal T_91 : std_logic;
  signal T_92 : std_logic;
  signal T_93 : std_logic;
  signal T_94 : std_logic;
  signal T_95 : std_logic;
  signal T_96 : std_logic;
  signal T_97 : std_logic;
  signal T_98 : std_logic;
  signal T_99 : std_logic;
  signal T_100 : std_logic;
  signal T_101 : std_logic;
  signal T_102 : std_logic;
  signal T_103 : std_logic;
  signal T_104 : std_logic;
  signal T_105 : std_logic;
  signal T_106 : std_logic;
  signal T_107 : std_logic;
  signal T_108 : std_logic;
  signal T_109 : std_logic;
  signal T_110 : std_logic;
  signal T_111 : std_logic;
  signal T_112 : std_logic;
  signal T_113 : std_logic;
  signal T_114 : std_logic;
  signal T_115 : std_logic;
  signal T_116 : std_logic;
  signal T_117 : std_logic;
  signal T_118 : std_logic;
  signal T_119 : std_logic;
  signal T_120 : std_logic;
  signal T_121 : std_logic;
  signal T_122 : std_logic;
  signal T_123 : std_logic;
  signal T_124 : std_logic;
  signal T_125 : std_logic;
  signal T_126 : std_logic;
  signal T_127 : std_logic;
  signal T_128 : std_logic;
  signal T_129 : std_logic;
  signal T_130 : std_logic;
  signal T_131 : std_logic;
  signal GATE_T_0_A : std_logic;
  signal GATE_T_1_A : std_logic;
  signal GATE_T_2_A : std_logic;
  signal GATE_T_3_A : std_logic;
  signal GATE_T_4_A : std_logic;
  signal GATE_T_5_A : std_logic;
  signal GATE_T_6_A : std_logic;
  signal GATE_T_7_A : std_logic;
  signal GATE_T_8_A : std_logic;
  signal GATE_T_9_A : std_logic;
  signal GATE_T_10_A : std_logic;
  signal GATE_T_11_A : std_logic;
  signal GATE_T_12_A : std_logic;
  signal GATE_T_13_A : std_logic;
  signal GATE_T_14_A : std_logic;

begin
  IN_mcu_clko_I_1:   IBUF
 generic map( PULL => "Up")
 port map ( O=>mcu_clkoPIN, 
            I0=>mcu_clko );
  IN_rxd_1v8_I_1:   IBUF
 generic map( PULL => "Up")
 port map ( O=>rxd_1v8PIN, 
            I0=>rxd_1v8 );
  IN_adc_dclk_I_1:   IBUF
 generic map( PULL => "Up")
 port map ( O=>adc_dclkPIN, 
            I0=>adc_dclk );
  IN_cpld_seln_I_1:   IBUF
 generic map( PULL => "Up")
 port map ( O=>cpld_selnPIN, 
            I0=>cpld_seln );
  IN_pps_rstn_I_1:   IBUF
 generic map( PULL => "Up")
 port map ( O=>pps_rstnPIN, 
            I0=>pps_rstn );
  IN_adc_drdyn_I_1:   IBUF
 generic map( PULL => "Up")
 port map ( O=>adc_drdynPIN, 
            I0=>adc_drdyn );
  IN_spi_miso_I_1:   IBUF
 generic map( PULL => "Up")
 port map ( O=>spi_misoPIN, 
            I0=>spi_miso );
  IN_cpld_clk_I_1:   IBUF
 generic map( PULL => "Up")
 port map ( O=>cpld_clkPIN, 
            I0=>cpld_clk );
  IN_cpld_sdi_I_1:   IBUF
 generic map( PULL => "Up")
 port map ( O=>cpld_sdiPIN, 
            I0=>cpld_sdi );
  OUT_cpld_sdo_I_1:   OBUF
 generic map( PULL => "Up")
 port map ( O=>cpld_sdo, 
            I0=>cpld_sdoCOM );
  OUT_adc_clk1_I_1:   OBUF
 generic map( PULL => "Up")
 port map ( O=>adc_clk1, 
            I0=>adc_clk1COM );
  OUT_adc_sel1_I_1:   OBUF
 generic map( PULL => "Up")
 port map ( O=>adc_sel1, 
            I0=>adc_sel1COM );
  OUT_adc_sel0_I_1:   OBUF
 generic map( PULL => "Up")
 port map ( O=>adc_sel0, 
            I0=>adc_sel0COM );
  OUT_adc_clk0_I_1:   OBUF
 generic map( PULL => "Up")
 port map ( O=>adc_clk0, 
            I0=>adc_clk0COM );
  OUT_spi_clk_I_1:   OBUF
 generic map( PULL => "Up")
 port map ( O=>spi_clk, 
            I0=>spi_clkCOM );
  OUT_spi_mosi_I_1:   OBUF
 generic map( PULL => "Up")
 port map ( O=>spi_mosi, 
            I0=>spi_mosiCOM );
  OUT_freq_clka_I_1:   OBUF
 generic map( PULL => "Up")
 port map ( O=>freq_clka, 
            I0=>freq_clkaCOM );
  FF_spi_module_Xspi_cntr_vPcnt_i0_I_1:   DFF port map ( D=>pps_counter_Xtemp_pcnt_5_Xi23Q, 
            Q=>spi_module_Xspi_cntr_vPcnt_i0Q, 
            CLK=>spi_module_Xspi_cntr_vPcnt_i0_C );
  FF_pps_counter_Xtemp_pcnt_5_Xi23_I_1:   TFFRH port map ( T=>pps_counter_Xtemp_pcnt_5_Xi23_T, 
            Q=>pps_counter_Xtemp_pcnt_5_Xi23Q, 
            CLK=>rxd_1v8PIN, 
            R=>pps_counter_Xtemp_pcnt_5_Xi23_AR );
  FF_pps_counter_Xtemp_pcnt_5_Xi0_I_1:   DFFRH port map ( Q=>pps_counter_Xtemp_pcnt_5_Xi0Q, 
            R=>pps_counter_Xtemp_pcnt_5_Xi0_AR, 
            CLK=>rxd_1v8PIN, 
            D=>pps_counter_Xtemp_pcnt_5_Xi0_D );
  FF_pps_counter_Xtemp_pcnt_5_Xi1_I_1:   DFFRH port map ( Q=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            R=>pps_counter_Xtemp_pcnt_5_Xi1_AR, 
            CLK=>rxd_1v8PIN, 
            D=>pps_counter_Xtemp_pcnt_5_Xi1_D );
  FF_pps_counter_Xtemp_pcnt_5_Xi2_I_1:   DFFRH port map ( Q=>pps_counter_Xtemp_pcnt_5_Xi2Q, 
            R=>pps_counter_Xtemp_pcnt_5_Xi2_AR, 
            CLK=>rxd_1v8PIN, 
            D=>pps_counter_Xtemp_pcnt_5_Xi2_D );
  FF_pps_counter_Xtemp_pcnt_5_Xi3_I_1:   DFFRH port map ( Q=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            R=>pps_counter_Xtemp_pcnt_5_Xi3_AR, 
            CLK=>rxd_1v8PIN, 
            D=>pps_counter_Xtemp_pcnt_5_Xi3_D );
  FF_pps_counter_Xtemp_pcnt_5_Xi4_I_1:   DFFRH port map ( Q=>pps_counter_Xtemp_pcnt_5_Xi4Q, 
            R=>pps_counter_Xtemp_pcnt_5_Xi4_AR, 
            CLK=>rxd_1v8PIN, 
            D=>pps_counter_Xtemp_pcnt_5_Xi4_D );
  FF_pps_counter_Xtemp_pcnt_5_Xi5_I_1:   TFFRH port map ( T=>pps_counter_Xtemp_pcnt_5_Xi5_T, 
            Q=>pps_counter_Xtemp_pcnt_5_Xi5Q, 
            CLK=>rxd_1v8PIN, 
            R=>pps_counter_Xtemp_pcnt_5_Xi5_AR );
  FF_pps_counter_Xtemp_pcnt_5_Xi6_I_1:   TFFRH port map ( T=>pps_counter_Xtemp_pcnt_5_Xi6_T, 
            Q=>pps_counter_Xtemp_pcnt_5_Xi6Q, 
            CLK=>rxd_1v8PIN, 
            R=>pps_counter_Xtemp_pcnt_5_Xi6_AR );
  FF_pps_counter_Xtemp_pcnt_5_Xi7_I_1:   TFFRH port map ( T=>pps_counter_Xtemp_pcnt_5_Xi7_T, 
            Q=>pps_counter_Xtemp_pcnt_5_Xi7Q, 
            CLK=>rxd_1v8PIN, 
            R=>pps_counter_Xtemp_pcnt_5_Xi7_AR );
  FF_pps_counter_Xtemp_pcnt_5_Xi8_I_1:   TFFRH port map ( T=>pps_counter_Xtemp_pcnt_5_Xi8_T, 
            Q=>pps_counter_Xtemp_pcnt_5_Xi8Q, 
            CLK=>rxd_1v8PIN, 
            R=>pps_counter_Xtemp_pcnt_5_Xi8_AR );
  FF_pps_counter_Xtemp_pcnt_5_Xi9_I_1:   TFFRH port map ( T=>pps_counter_Xtemp_pcnt_5_Xi9_T, 
            Q=>pps_counter_Xtemp_pcnt_5_Xi9Q, 
            CLK=>rxd_1v8PIN, 
            R=>pps_counter_Xtemp_pcnt_5_Xi9_AR );
  FF_pps_counter_Xtemp_pcnt_5_Xi10_I_1:   DFFRH port map ( Q=>pps_counter_Xtemp_pcnt_5_Xi10Q, 
            R=>pps_counter_Xtemp_pcnt_5_Xi10_AR, 
            CLK=>rxd_1v8PIN, 
            D=>pps_counter_Xtemp_pcnt_5_Xi10_D );
  FF_pps_counter_Xtemp_pcnt_5_Xi11_I_1:   DFFRH port map ( Q=>pps_counter_Xtemp_pcnt_5_Xi11Q, 
            R=>pps_counter_Xtemp_pcnt_5_Xi11_AR, 
            CLK=>rxd_1v8PIN, 
            D=>pps_counter_Xtemp_pcnt_5_Xi11_D );
  FF_pps_counter_Xtemp_pcnt_5_Xi12_I_1:   DFFRH port map ( Q=>pps_counter_Xtemp_pcnt_5_Xi12Q, 
            R=>pps_counter_Xtemp_pcnt_5_Xi12_AR, 
            CLK=>rxd_1v8PIN, 
            D=>pps_counter_Xtemp_pcnt_5_Xi12_D );
  FF_pps_counter_Xtemp_pcnt_5_Xi13_I_1:   TFFRH port map ( T=>pps_counter_Xtemp_pcnt_5_Xi13_T, 
            Q=>pps_counter_Xtemp_pcnt_5_Xi13Q, 
            CLK=>rxd_1v8PIN, 
            R=>pps_counter_Xtemp_pcnt_5_Xi13_AR );
  FF_pps_counter_Xtemp_pcnt_5_Xi14_I_1:   TFFRH port map ( T=>pps_counter_Xtemp_pcnt_5_Xi14_T, 
            Q=>pps_counter_Xtemp_pcnt_5_Xi14Q, 
            CLK=>rxd_1v8PIN, 
            R=>pps_counter_Xtemp_pcnt_5_Xi14_AR );
  FF_pps_counter_Xtemp_pcnt_5_Xi15_I_1:   TFFRH port map ( T=>pps_counter_Xtemp_pcnt_5_Xi15_T, 
            Q=>pps_counter_Xtemp_pcnt_5_Xi15Q, 
            CLK=>rxd_1v8PIN, 
            R=>pps_counter_Xtemp_pcnt_5_Xi15_AR );
  FF_pps_counter_Xtemp_pcnt_5_Xi16_I_1:   TFFRH port map ( T=>pps_counter_Xtemp_pcnt_5_Xi16_T, 
            Q=>pps_counter_Xtemp_pcnt_5_Xi16Q, 
            CLK=>rxd_1v8PIN, 
            R=>pps_counter_Xtemp_pcnt_5_Xi16_AR );
  FF_pps_counter_Xtemp_pcnt_5_Xi17_I_1:   TFFRH port map ( T=>pps_counter_Xtemp_pcnt_5_Xi17_T, 
            Q=>pps_counter_Xtemp_pcnt_5_Xi17Q, 
            CLK=>rxd_1v8PIN, 
            R=>pps_counter_Xtemp_pcnt_5_Xi17_AR );
  FF_pps_counter_Xtemp_pcnt_5_Xi18_I_1:   TFFRH port map ( T=>pps_counter_Xtemp_pcnt_5_Xi18_T, 
            Q=>pps_counter_Xtemp_pcnt_5_Xi18Q, 
            CLK=>rxd_1v8PIN, 
            R=>pps_counter_Xtemp_pcnt_5_Xi18_AR );
  FF_pps_counter_Xtemp_pcnt_5_Xi19_I_1:   TFFRH port map ( T=>pps_counter_Xtemp_pcnt_5_Xi19_T, 
            Q=>pps_counter_Xtemp_pcnt_5_Xi19Q, 
            CLK=>rxd_1v8PIN, 
            R=>pps_counter_Xtemp_pcnt_5_Xi19_AR );
  FF_pps_counter_Xtemp_pcnt_5_Xi20_I_1:   TFFRH port map ( T=>pps_counter_Xtemp_pcnt_5_Xi20_T, 
            Q=>pps_counter_Xtemp_pcnt_5_Xi20Q, 
            CLK=>rxd_1v8PIN, 
            R=>pps_counter_Xtemp_pcnt_5_Xi20_AR );
  FF_pps_counter_Xtemp_pcnt_5_Xi21_I_1:   TFFRH port map ( T=>pps_counter_Xtemp_pcnt_5_Xi21_T, 
            Q=>pps_counter_Xtemp_pcnt_5_Xi21Q, 
            CLK=>rxd_1v8PIN, 
            R=>pps_counter_Xtemp_pcnt_5_Xi21_AR );
  FF_pps_counter_Xtemp_pcnt_5_Xi22_I_1:   TFFRH port map ( T=>pps_counter_Xtemp_pcnt_5_Xi22_T, 
            Q=>pps_counter_Xtemp_pcnt_5_Xi22Q, 
            CLK=>rxd_1v8PIN, 
            R=>pps_counter_Xtemp_pcnt_5_Xi22_AR );
  GATE_cpld_sdo_I_1:   OR2 port map ( O=>cpld_sdoCOM, 
            I1=>T_15, 
            I0=>T_14 );
  GATE_adc_clk1_I_1:   BUFF port map ( I0=>adc_dclkPIN, 
            O=>adc_clk1COM );
  GATE_adc_sel1_I_1:   BUFF port map ( I0=>adc_drdynPIN, 
            O=>adc_sel1COM );
  GATE_adc_sel0_I_1:   BUFF port map ( I0=>adc_drdynPIN, 
            O=>adc_sel0COM );
  GATE_adc_clk0_I_1:   BUFF port map ( I0=>adc_dclkPIN, 
            O=>adc_clk0COM );
  GATE_spi_clk_I_1:   BUFF port map ( I0=>cpld_clkPIN, 
            O=>spi_clkCOM );
  GATE_spi_mosi_I_1:   BUFF port map ( I0=>cpld_sdiPIN, 
            O=>spi_mosiCOM );
  GATE_freq_clka_I_1:   BUFF port map ( I0=>mcu_clkoPIN, 
            O=>freq_clkaCOM );
  GATE_spi_module_Xspi_cntr_vPcnt_i0_C_I_1:   INV port map ( I0=>cpld_selnPIN, 
            O=>spi_module_Xspi_cntr_vPcnt_i0_C );
  GATE_pps_counter_Xtemp_pcnt_5_Xi23_T_I_1:   AND4 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi23_T, 
            I3=>T_119, 
            I2=>T_123, 
            I1=>T_127, 
            I0=>T_131 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi23_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi23_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi0_D_I_1:   INV port map ( I0=>pps_counter_Xtemp_pcnt_5_Xi0Q, 
            O=>pps_counter_Xtemp_pcnt_5_Xi0_D );
  GATE_pps_counter_Xtemp_pcnt_5_Xi0_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi0_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi1_D_I_1:   XOR2 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi1_D, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_pps_counter_Xtemp_pcnt_5_Xi1_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi1_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi2_D_I_1:   OR3 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi2_D, 
            I2=>T_12, 
            I1=>T_11, 
            I0=>T_13 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi2_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi2_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi3_D_I_1:   OR4 port map ( I0=>T_7, 
            I1=>T_8, 
            O=>pps_counter_Xtemp_pcnt_5_Xi3_D, 
            I2=>T_9, 
            I3=>T_10 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi3_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi3_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi4_D_X1_I_1:   AND4 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi4_D_X1, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi2Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_pps_counter_Xtemp_pcnt_5_Xi4_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi4_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi5_T_I_1:   AND3 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi5_T, 
            I2=>T_116, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi4Q, 
            I0=>T_115 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi5_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi5_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi6_T_I_1:   AND3 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi6_T, 
            I2=>T_113, 
            I1=>T_114, 
            I0=>T_112 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi6_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi6_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi7_T_I_1:   AND4 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi7_T, 
            I3=>T_109, 
            I2=>T_110, 
            I1=>T_111, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi6Q );
  GATE_pps_counter_Xtemp_pcnt_5_Xi7_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi7_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi8_T_I_1:   AND4 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi8_T, 
            I3=>T_105, 
            I2=>T_106, 
            I1=>T_107, 
            I0=>T_108 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi8_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi8_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi9_T_I_1:   AND3 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi9_T, 
            I2=>T_103, 
            I1=>T_104, 
            I0=>T_102 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi9_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi9_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi10_D_I_1:   OR3 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi10_D, 
            I2=>T_5, 
            I1=>T_4, 
            I0=>T_6 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi10_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi10_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi11_D_I_1:   OR4 port map ( I0=>T_0, 
            I1=>T_1, 
            O=>pps_counter_Xtemp_pcnt_5_Xi11_D, 
            I2=>T_2, 
            I3=>T_3 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi11_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi11_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi12_D_X1_I_1:   AND4 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi12_D_X1, 
            I3=>n151, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi11Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi10Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi9Q );
  GATE_pps_counter_Xtemp_pcnt_5_Xi12_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi12_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi13_T_I_1:   AND4 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi13_T, 
            I3=>T_96, 
            I2=>T_97, 
            I1=>T_98, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi12Q );
  GATE_pps_counter_Xtemp_pcnt_5_Xi13_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi13_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi14_T_I_1:   AND4 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi14_T, 
            I3=>T_92, 
            I2=>T_93, 
            I1=>T_94, 
            I0=>T_95 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi14_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi14_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi15_T_I_1:   AND4 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi15_T, 
            I3=>T_88, 
            I2=>T_89, 
            I1=>T_90, 
            I0=>T_91 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi15_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi15_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi16_T_I_1:   AND4 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi16_T, 
            I3=>T_84, 
            I2=>T_85, 
            I1=>T_86, 
            I0=>T_87 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi16_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi16_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi17_T_I_1:   AND4 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi17_T, 
            I3=>T_74, 
            I2=>T_77, 
            I1=>T_80, 
            I0=>T_83 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi17_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi17_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi18_T_I_1:   AND4 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi18_T, 
            I3=>T_64, 
            I2=>T_67, 
            I1=>T_70, 
            I0=>T_73 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi18_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi18_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi19_T_I_1:   AND4 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi19_T, 
            I3=>T_54, 
            I2=>T_57, 
            I1=>T_60, 
            I0=>T_63 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi19_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi19_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi20_T_I_1:   AND4 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi20_T, 
            I3=>T_44, 
            I2=>T_47, 
            I1=>T_50, 
            I0=>T_53 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi20_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi20_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi21_T_I_1:   AND4 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi21_T, 
            I3=>T_29, 
            I2=>T_33, 
            I1=>T_37, 
            I0=>T_41 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi21_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi21_AR );
  GATE_pps_counter_Xtemp_pcnt_5_Xi22_T_I_1:   AND4 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi22_T, 
            I3=>T_16, 
            I2=>T_20, 
            I1=>T_24, 
            I0=>T_28 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi22_AR_I_1:   INV port map ( I0=>pps_rstnPIN, 
            O=>pps_counter_Xtemp_pcnt_5_Xi22_AR );
  GATE_n151_I_1:   AND3 port map ( O=>n151, 
            I2=>T_100, 
            I1=>T_101, 
            I0=>T_99 );
  GATE_pps_counter_Xtemp_pcnt_5_Xi4_D_I_1:   XOR2 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi4_D, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi4_D_X1, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi4Q );
  GATE_pps_counter_Xtemp_pcnt_5_Xi12_D_I_1:   XOR2 port map ( O=>pps_counter_Xtemp_pcnt_5_Xi12_D, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi12_D_X1, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi12Q );
  GATE_T_0_I_1:   AND4 port map ( O=>T_0, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi10Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi9Q, 
            I1=>n151, 
            I0=>GATE_T_0_A );
  GATE_T_0_I_2:   INV port map ( I0=>pps_counter_Xtemp_pcnt_5_Xi11Q, 
            O=>GATE_T_0_A );
  GATE_T_1_I_1:   AND2 port map ( O=>T_1, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi11Q, 
            I0=>GATE_T_1_A );
  GATE_T_1_I_2:   INV port map ( O=>GATE_T_1_A, 
            I0=>n151 );
  GATE_T_2_I_1:   AND2 port map ( O=>T_2, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi11Q, 
            I0=>GATE_T_2_A );
  GATE_T_2_I_2:   INV port map ( O=>GATE_T_2_A, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi10Q );
  GATE_T_3_I_1:   AND2 port map ( O=>T_3, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi11Q, 
            I0=>GATE_T_3_A );
  GATE_T_3_I_2:   INV port map ( O=>GATE_T_3_A, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi9Q );
  GATE_T_4_I_1:   INV port map ( I0=>pps_counter_Xtemp_pcnt_5_Xi10Q, 
            O=>GATE_T_4_A );
  GATE_T_4_I_2:   AND3 port map ( O=>T_4, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi9Q, 
            I1=>n151, 
            I0=>GATE_T_4_A );
  GATE_T_5_I_1:   AND2 port map ( O=>T_5, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi10Q, 
            I0=>GATE_T_5_A );
  GATE_T_5_I_2:   INV port map ( O=>GATE_T_5_A, 
            I0=>n151 );
  GATE_T_6_I_1:   AND2 port map ( O=>T_6, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi10Q, 
            I0=>GATE_T_6_A );
  GATE_T_6_I_2:   INV port map ( O=>GATE_T_6_A, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi9Q );
  GATE_T_7_I_1:   AND4 port map ( O=>T_7, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi0Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi2Q, 
            I0=>GATE_T_7_A );
  GATE_T_7_I_2:   INV port map ( I0=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            O=>GATE_T_7_A );
  GATE_T_8_I_1:   AND2 port map ( O=>T_8, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I0=>GATE_T_8_A );
  GATE_T_8_I_2:   INV port map ( O=>GATE_T_8_A, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi2Q );
  GATE_T_9_I_1:   AND2 port map ( O=>T_9, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I0=>GATE_T_9_A );
  GATE_T_9_I_2:   INV port map ( O=>GATE_T_9_A, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi1Q );
  GATE_T_10_I_1:   AND2 port map ( O=>T_10, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I0=>GATE_T_10_A );
  GATE_T_10_I_2:   INV port map ( O=>GATE_T_10_A, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_T_11_I_1:   INV port map ( I0=>pps_counter_Xtemp_pcnt_5_Xi2Q, 
            O=>GATE_T_11_A );
  GATE_T_11_I_2:   AND3 port map ( O=>T_11, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi0Q, 
            I0=>GATE_T_11_A );
  GATE_T_12_I_1:   AND2 port map ( O=>T_12, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi2Q, 
            I0=>GATE_T_12_A );
  GATE_T_12_I_2:   INV port map ( O=>GATE_T_12_A, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi1Q );
  GATE_T_13_I_1:   AND2 port map ( O=>T_13, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi2Q, 
            I0=>GATE_T_13_A );
  GATE_T_13_I_2:   INV port map ( O=>GATE_T_13_A, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_T_14_I_1:   AND2 port map ( O=>T_14, 
            I1=>spi_module_Xspi_cntr_vPcnt_i0Q, 
            I0=>GATE_T_14_A );
  GATE_T_14_I_2:   INV port map ( O=>GATE_T_14_A, 
            I0=>cpld_selnPIN );
  GATE_T_15_I_1:   AND2 port map ( O=>T_15, 
            I1=>spi_misoPIN, 
            I0=>cpld_selnPIN );
  GATE_T_16_I_1:   AND4 port map ( O=>T_16, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi21Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi20Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi19Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi18Q );
  GATE_T_17_I_1:   AND2 port map ( O=>T_17, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi17Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi16Q );
  GATE_T_18_I_1:   AND2 port map ( O=>T_18, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi15Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi14Q );
  GATE_T_19_I_1:   AND2 port map ( O=>T_19, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi13Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi12Q );
  GATE_T_20_I_1:   AND3 port map ( O=>T_20, 
            I2=>T_18, 
            I1=>T_19, 
            I0=>T_17 );
  GATE_T_21_I_1:   AND2 port map ( O=>T_21, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi11Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi10Q );
  GATE_T_22_I_1:   AND2 port map ( O=>T_22, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi9Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi8Q );
  GATE_T_23_I_1:   AND2 port map ( O=>T_23, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi7Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi6Q );
  GATE_T_24_I_1:   AND3 port map ( O=>T_24, 
            I2=>T_22, 
            I1=>T_23, 
            I0=>T_21 );
  GATE_T_25_I_1:   AND2 port map ( O=>T_25, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi5Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi4Q );
  GATE_T_26_I_1:   AND2 port map ( O=>T_26, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi2Q );
  GATE_T_27_I_1:   AND2 port map ( O=>T_27, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_T_28_I_1:   AND3 port map ( O=>T_28, 
            I2=>T_26, 
            I1=>T_27, 
            I0=>T_25 );
  GATE_T_29_I_1:   AND3 port map ( O=>T_29, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi19Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi18Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi20Q );
  GATE_T_30_I_1:   AND2 port map ( O=>T_30, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi17Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi16Q );
  GATE_T_31_I_1:   AND2 port map ( O=>T_31, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi15Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi14Q );
  GATE_T_32_I_1:   AND2 port map ( O=>T_32, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi13Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi12Q );
  GATE_T_33_I_1:   AND3 port map ( O=>T_33, 
            I2=>T_31, 
            I1=>T_32, 
            I0=>T_30 );
  GATE_T_34_I_1:   AND2 port map ( O=>T_34, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi11Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi10Q );
  GATE_T_35_I_1:   AND2 port map ( O=>T_35, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi9Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi8Q );
  GATE_T_36_I_1:   AND2 port map ( O=>T_36, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi7Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi6Q );
  GATE_T_37_I_1:   AND3 port map ( O=>T_37, 
            I2=>T_35, 
            I1=>T_36, 
            I0=>T_34 );
  GATE_T_38_I_1:   AND2 port map ( O=>T_38, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi5Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi4Q );
  GATE_T_39_I_1:   AND2 port map ( O=>T_39, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi2Q );
  GATE_T_40_I_1:   AND2 port map ( O=>T_40, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_T_41_I_1:   AND3 port map ( O=>T_41, 
            I2=>T_39, 
            I1=>T_40, 
            I0=>T_38 );
  GATE_T_42_I_1:   AND2 port map ( O=>T_42, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi18Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi17Q );
  GATE_T_43_I_1:   AND2 port map ( O=>T_43, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi16Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi15Q );
  GATE_T_44_I_1:   AND3 port map ( O=>T_44, 
            I2=>T_43, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi19Q, 
            I0=>T_42 );
  GATE_T_45_I_1:   AND2 port map ( O=>T_45, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi13Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi12Q );
  GATE_T_46_I_1:   AND2 port map ( O=>T_46, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi11Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi10Q );
  GATE_T_47_I_1:   AND3 port map ( O=>T_47, 
            I2=>T_46, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi14Q, 
            I0=>T_45 );
  GATE_T_48_I_1:   AND2 port map ( O=>T_48, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi8Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi7Q );
  GATE_T_49_I_1:   AND2 port map ( O=>T_49, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi6Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi5Q );
  GATE_T_50_I_1:   AND3 port map ( O=>T_50, 
            I2=>T_49, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi9Q, 
            I0=>T_48 );
  GATE_T_51_I_1:   AND2 port map ( O=>T_51, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi2Q );
  GATE_T_52_I_1:   AND2 port map ( O=>T_52, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_T_53_I_1:   AND3 port map ( O=>T_53, 
            I2=>T_52, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi4Q, 
            I0=>T_51 );
  GATE_T_54_I_1:   AND4 port map ( O=>T_54, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi18Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi17Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi16Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi15Q );
  GATE_T_55_I_1:   AND2 port map ( O=>T_55, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi13Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi12Q );
  GATE_T_56_I_1:   AND2 port map ( O=>T_56, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi11Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi10Q );
  GATE_T_57_I_1:   AND3 port map ( O=>T_57, 
            I2=>T_56, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi14Q, 
            I0=>T_55 );
  GATE_T_58_I_1:   AND2 port map ( O=>T_58, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi8Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi7Q );
  GATE_T_59_I_1:   AND2 port map ( O=>T_59, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi6Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi5Q );
  GATE_T_60_I_1:   AND3 port map ( O=>T_60, 
            I2=>T_59, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi9Q, 
            I0=>T_58 );
  GATE_T_61_I_1:   AND2 port map ( O=>T_61, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi2Q );
  GATE_T_62_I_1:   AND2 port map ( O=>T_62, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_T_63_I_1:   AND3 port map ( O=>T_63, 
            I2=>T_62, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi4Q, 
            I0=>T_61 );
  GATE_T_64_I_1:   AND3 port map ( O=>T_64, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi16Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi15Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi17Q );
  GATE_T_65_I_1:   AND2 port map ( O=>T_65, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi13Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi12Q );
  GATE_T_66_I_1:   AND2 port map ( O=>T_66, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi11Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi10Q );
  GATE_T_67_I_1:   AND3 port map ( O=>T_67, 
            I2=>T_66, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi14Q, 
            I0=>T_65 );
  GATE_T_68_I_1:   AND2 port map ( O=>T_68, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi8Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi7Q );
  GATE_T_69_I_1:   AND2 port map ( O=>T_69, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi6Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi5Q );
  GATE_T_70_I_1:   AND3 port map ( O=>T_70, 
            I2=>T_69, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi9Q, 
            I0=>T_68 );
  GATE_T_71_I_1:   AND2 port map ( O=>T_71, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi2Q );
  GATE_T_72_I_1:   AND2 port map ( O=>T_72, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_T_73_I_1:   AND3 port map ( O=>T_73, 
            I2=>T_72, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi4Q, 
            I0=>T_71 );
  GATE_T_74_I_1:   AND2 port map ( O=>T_74, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi16Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi15Q );
  GATE_T_75_I_1:   AND2 port map ( O=>T_75, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi13Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi12Q );
  GATE_T_76_I_1:   AND2 port map ( O=>T_76, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi11Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi10Q );
  GATE_T_77_I_1:   AND3 port map ( O=>T_77, 
            I2=>T_76, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi14Q, 
            I0=>T_75 );
  GATE_T_78_I_1:   AND2 port map ( O=>T_78, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi8Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi7Q );
  GATE_T_79_I_1:   AND2 port map ( O=>T_79, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi6Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi5Q );
  GATE_T_80_I_1:   AND3 port map ( O=>T_80, 
            I2=>T_79, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi9Q, 
            I0=>T_78 );
  GATE_T_81_I_1:   AND2 port map ( O=>T_81, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi2Q );
  GATE_T_82_I_1:   AND2 port map ( O=>T_82, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_T_83_I_1:   AND3 port map ( O=>T_83, 
            I2=>T_82, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi4Q, 
            I0=>T_81 );
  GATE_T_84_I_1:   AND4 port map ( O=>T_84, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi15Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi14Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi13Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi12Q );
  GATE_T_85_I_1:   AND4 port map ( O=>T_85, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi11Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi10Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi9Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi8Q );
  GATE_T_86_I_1:   AND4 port map ( O=>T_86, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi7Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi6Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi5Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi4Q );
  GATE_T_87_I_1:   AND4 port map ( O=>T_87, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi2Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_T_88_I_1:   AND3 port map ( O=>T_88, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi13Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi12Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi14Q );
  GATE_T_89_I_1:   AND4 port map ( O=>T_89, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi11Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi10Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi9Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi8Q );
  GATE_T_90_I_1:   AND4 port map ( O=>T_90, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi7Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi6Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi5Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi4Q );
  GATE_T_91_I_1:   AND4 port map ( O=>T_91, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi2Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_T_92_I_1:   AND2 port map ( O=>T_92, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi13Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi12Q );
  GATE_T_93_I_1:   AND4 port map ( O=>T_93, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi11Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi10Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi9Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi8Q );
  GATE_T_94_I_1:   AND4 port map ( O=>T_94, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi7Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi6Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi5Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi4Q );
  GATE_T_95_I_1:   AND4 port map ( O=>T_95, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi2Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_T_96_I_1:   AND4 port map ( O=>T_96, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi11Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi10Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi9Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi8Q );
  GATE_T_97_I_1:   AND4 port map ( O=>T_97, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi7Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi6Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi5Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi4Q );
  GATE_T_98_I_1:   AND4 port map ( O=>T_98, 
            I3=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi2Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_T_99_I_1:   AND3 port map ( O=>T_99, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi7Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi6Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi8Q );
  GATE_T_100_I_1:   AND3 port map ( O=>T_100, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi4Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi5Q );
  GATE_T_101_I_1:   AND3 port map ( O=>T_101, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi0Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi2Q );
  GATE_T_102_I_1:   AND3 port map ( O=>T_102, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi7Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi6Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi8Q );
  GATE_T_103_I_1:   AND3 port map ( O=>T_103, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi4Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi5Q );
  GATE_T_104_I_1:   AND3 port map ( O=>T_104, 
            I2=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi0Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi2Q );
  GATE_T_105_I_1:   AND2 port map ( O=>T_105, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi7Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi6Q );
  GATE_T_106_I_1:   AND2 port map ( O=>T_106, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi5Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi4Q );
  GATE_T_107_I_1:   AND2 port map ( O=>T_107, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi2Q );
  GATE_T_108_I_1:   AND2 port map ( O=>T_108, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_T_109_I_1:   AND2 port map ( O=>T_109, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi5Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi4Q );
  GATE_T_110_I_1:   AND2 port map ( O=>T_110, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi2Q );
  GATE_T_111_I_1:   AND2 port map ( O=>T_111, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_T_112_I_1:   AND2 port map ( O=>T_112, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi5Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi4Q );
  GATE_T_113_I_1:   AND2 port map ( O=>T_113, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi2Q );
  GATE_T_114_I_1:   AND2 port map ( O=>T_114, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_T_115_I_1:   AND2 port map ( O=>T_115, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi2Q );
  GATE_T_116_I_1:   AND2 port map ( O=>T_116, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_T_117_I_1:   AND2 port map ( O=>T_117, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi21Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi20Q );
  GATE_T_118_I_1:   AND2 port map ( O=>T_118, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi19Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi18Q );
  GATE_T_119_I_1:   AND3 port map ( O=>T_119, 
            I2=>T_118, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi22Q, 
            I0=>T_117 );
  GATE_T_120_I_1:   AND2 port map ( O=>T_120, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi17Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi16Q );
  GATE_T_121_I_1:   AND2 port map ( O=>T_121, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi15Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi14Q );
  GATE_T_122_I_1:   AND2 port map ( O=>T_122, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi13Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi12Q );
  GATE_T_123_I_1:   AND3 port map ( O=>T_123, 
            I2=>T_121, 
            I1=>T_122, 
            I0=>T_120 );
  GATE_T_124_I_1:   AND2 port map ( O=>T_124, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi11Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi10Q );
  GATE_T_125_I_1:   AND2 port map ( O=>T_125, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi9Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi8Q );
  GATE_T_126_I_1:   AND2 port map ( O=>T_126, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi7Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi6Q );
  GATE_T_127_I_1:   AND3 port map ( O=>T_127, 
            I2=>T_125, 
            I1=>T_126, 
            I0=>T_124 );
  GATE_T_128_I_1:   AND2 port map ( O=>T_128, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi5Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi4Q );
  GATE_T_129_I_1:   AND2 port map ( O=>T_129, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi3Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi2Q );
  GATE_T_130_I_1:   AND2 port map ( O=>T_130, 
            I1=>pps_counter_Xtemp_pcnt_5_Xi1Q, 
            I0=>pps_counter_Xtemp_pcnt_5_Xi0Q );
  GATE_T_131_I_1:   AND3 port map ( O=>T_131, 
            I2=>T_129, 
            I1=>T_130, 
            I0=>T_128 );

end NetList;
