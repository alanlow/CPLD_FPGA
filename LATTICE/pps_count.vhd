library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity PPS_COUNT is
port(
	pps, nclr: in std_logic;
	pcnt: out std_logic_vector (23 downto 0)
);
end entity PPS_COUNT;


architecture UP_COUNT of PPS_COUNT is
	
	signal temp_pcnt: std_logic_vector (23 downto 0);

begin

	process (pps, nclr)
	begin
		if nclr = '0' then
			temp_pcnt <= (others => '0');
		elsif rising_edge(pps) then
			temp_pcnt <= temp_pcnt + 1;
		end if;
	end process;
	pcnt <= temp_pcnt;

end architecture UP_COUNT;

