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

   component ADC_BUF
   port(

      drdyn, dclk: in std_logic;
      sel0, sel1: out std_logic;
      clk0, clk1: out std_logic

   );
   end component;

   component PPS_COUNT
   port(
      pps, nclr: in std_logic;
      pcnt: out std_logic_vector (23 downto 0)
   );
   end component;

   component SPI_MOD
   port(
      pcnt: in std_logic_vector (23 downto 0);
      nclr, sdi, dclk, nsel, miso: in std_logic;
      sdo, sclk, mosi: out std_logic
   );
   end component;

  signal pps_reg: std_logic_vector (23 downto 0) := (others => '0');

begin

   freq_clka <= mcu_clko;

   pps_counter: PPS_COUNT port map(
      pps => rxd_1v8, --PPS pulse
      nclr=> pps_rstn, --Reset all cpld when low
      pcnt=> pps_reg
   );

   spi_module: SPI_MOD port map(
      pcnt => pps_reg,
      nclr => cpld_rstn,
      sdi  => cpld_sdi,
      dclk => cpld_clk,
      nsel => cpld_seln,
      miso => spi_miso,
      sdo  => cpld_sdo,
      sclk => spi_clk,
      mosi => spi_mosi
   );

   adc_sig: ADC_BUF port map(

      drdyn => adc_drdyn,
      dclk  => adc_dclk,
      sel0  => adc_sel0,
      sel1  => adc_sel1,
      clk0  => adc_clk0,
      clk1  => adc_clk1
   );


end architecture TOP_LEVEL;

