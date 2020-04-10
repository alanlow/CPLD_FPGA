
-- VHDL Test Bench Created from source file PPS_COUNT.vhd -- 04/10/20  15:32:30
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

	COMPONENT PPS_COUNT
	PORT(
		pps : IN std_logic;
		nclr : IN std_logic;          
		pcnt : OUT std_logic_vector(23 downto 0)
		);
	END COMPONENT;

	SIGNAL pps :  std_logic := '0';
	SIGNAL nclr :  std_logic := '0';
	SIGNAL pcnt :  std_logic_vector(23 downto 0);
	constant clock_period : time := 40ns; 

BEGIN

	uut: PPS_COUNT PORT MAP(
		pps => pps,
		nclr => nclr,
		pcnt => pcnt
	);


clock_process : process
begin
pps <= '0';
wait for clock_period/2;
pps <= '1';
wait for clock_period/2;
end process;


-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
wait for 400ns;
nclr <= '1';
wait for 4us;
nclr <= '0';	
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;

