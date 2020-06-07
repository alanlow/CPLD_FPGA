library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity KEPLER_TL is
port(
   mcu_clko  : in std_logic;
   adc_dclk  : in std_logic;
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

   signal Q1: std_logic;
   signal Q2: std_logic;
begin

   freq_clka <= mcu_clko;
   cpld_sdo  <= spi_miso;
   adc_clk1  <= adc_dclk;
   adc_clk0  <= adc_dclk;
   spi_clk   <= cpld_clk;
   spi_mosi  <= cpld_sdi;

   process (mcu_clko)
      variable sPulse: std_logic;
   begin
      if rising_edge(mcu_clko) then
         Q1 <= adc_drdyn and (not adc_dclk);
         Q2 <= Q1;
         sPulse := Q1 and (not Q2);
      end if;
      adc_sel0 <= sPulse; 
      adc_sel1 <= sPulse;
   end process;


end architecture TOP_LEVEL;

