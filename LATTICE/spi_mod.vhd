library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity SPI_MOD is
port(
	pcnt: in std_logic_vector (23 downto 0);
	nclr, sdi, dclk, nsel, miso: in std_logic;
	sdo, sclk, mosi: out std_logic
);
end entity SPI_MOD;

architecture SPI_CPLD of SPI_MOD is
	signal sOut : std_logic;
        signal sOut1: std_logic;
begin

--Bypass signals
	sclk <= dclk;
	mosi <= sdi;
        sdo <= sOut when (nsel = '0') else miso;

 
--Read counter with SPI
spi_cntr: process (nclr, dclk, nsel)
   variable vPcnt: std_logic_vector(23 downto 0);
   
begin

--   if nclr = '0' then -- Before reading PPS counter, toggle nclr 'low' then high before reading to load PPS counter into registe
   if falling_edge (nsel) then
      vPcnt := pcnt;
   elsif falling_edge (dclk) and nsel = '0' then
      for i in 23 downto 1 loop
        vPcnt(i) := vPcnt(i - 1);
      end loop;
      vPcnt(0) := '0';
--      sOut1 <= vPcnt(23);
--      sOut <= sOut1;
   end if;
   sOut <= vPcnt(23);   
end process;

end architecture SPI_CPLD;

