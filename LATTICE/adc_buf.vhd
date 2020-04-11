library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ADC_BUF is
port(

	drdyn, dclk: in std_logic;
	sel0, sel1: out std_logic;
	clk0, clk1: out std_logic

);
end entity ADC_BUF;

architecture BUFF of ADC_BUF is
begin
	sel0 <= drdyn;
	sel1 <= drdyn;
	clk0 <= dclk;
	clk1 <= dclk;
end architecture BUFF;

