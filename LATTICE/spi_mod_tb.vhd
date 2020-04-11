
-- VHDL Test Bench Created from source file SPI_MOD.vhd -- 04/10/20  22:10:21
--
-- Notes: 
-- 1) This testbench template has been automatically generated using types
-- std_logic and std_logic_vector for the ports of the unit under test.
-- Lattice recommends that these types always be used for the top-level
-- I/O of a design in order to guarantee that the testbench will bind
-- correctly to the timing (post-route) simulation model.
-- 2) To use this template as your testbench, change the filename to any
-- name of your choice with the extension .vhd, and use the "source->import"
-- menu in the ispLEVER Project Navigator to import the testbench.
-- Then edit the user defined section below, adding code to generate the 
-- stimulus for your design.
--
LIBRARY ieee;
LIBRARY generics;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE generics.components.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT SPI_MOD
	PORT(
		pcnt : IN std_logic_vector(23 downto 0);
		nclr : IN std_logic;
		sdi : IN std_logic;
		dclk : IN std_logic;
		nsel : IN std_logic;
		miso : IN std_logic;          
		sdo : OUT std_logic;
		sclk : OUT std_logic;
		mosi : OUT std_logic
		);
	END COMPONENT;

	SIGNAL pcnt :  std_logic_vector(23 downto 0);
	SIGNAL nclr :  std_logic:= '1';
	SIGNAL sdi :  std_logic:= '1';
	SIGNAL dclk :  std_logic:= '1';
	SIGNAL nsel :  std_logic:= '1';
	SIGNAL miso :  std_logic:= '1';
	SIGNAL sdo :  std_logic := '1';
	SIGNAL sclk :  std_logic:= '1';
	SIGNAL mosi :  std_logic:= '1';
	constant pps_cnt:std_logic_vector (23 downto 0) := "010101010101010101010101";
	constant clock_period : time := 40ns;

BEGIN

	uut: SPI_MOD PORT MAP(
		pcnt => pcnt,
		nclr => nclr,
		sdi => sdi,
		dclk => dclk,
		nsel => nsel,
		miso => miso,
		sdo => sdo,
		sclk => sclk,
		mosi => mosi
	);

pcnt <= pps_cnt;

clock_process: process
begin
dclk <= '0';
wait for clock_period/2;
dclk <= '1';
wait for clock_period/2;
end process;


-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
     wait for 100ns;
     nclr <= '0';
     wait for 40ns;
     nclr <= '1';
     wait for 385ns;
     nsel <= '0';
     wait for 960ns;
     nsel <= '1';
     wait for 115ns;
     miso <= '0';
     wait for clock_period;
     miso <= '1';
	
     wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;

