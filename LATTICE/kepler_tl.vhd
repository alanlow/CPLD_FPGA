library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity KEPLER_TL is
port(
   mcu_clko  : in std_logic;
   rxd_1v8   : in std_logic;
   adc_dclk  : in std_logic;
   cpld_seln : in std_logic;
   pps_rstn  : in std_logic;
   cpld_rstn : in std_logic;
   adc_drdyn : in std_logic;
   spi_miso  : in std_logic;
   cpld_clk  : in std_logic;
   cpld_sdi  : in std_logic;

   cpld_sdo  : out std_logic;
   adc_clk1  : out std_logic;
   adc_sel1  : out std_logic;
   adc_sel0  : out std_logic;
   adc_clk0  : out std_logic;
   spi_clk   : out std_logic;
   spi_mosi  : out std_logic;
   freq_clka : out std_logic
);
end entity KEPLER_TL;

architecture TOP_LEVEL of KEPLER_TL is



begin

   freq_clka <= mcu_clko;
   cpld_sdo  <= spi_miso;
   adc_clk1  <= adc_dclk;
   adc_sel1  <= adc_drdyn;
   adc_sel0  <= adc_drdyn;
   adc_clk0  <= adc_dclk;
   spi_clk   <= cpld_clk;
   spi_mosi  <= cpld_sdi;


end architecture TOP_LEVEL;

