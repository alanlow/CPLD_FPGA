
-- VHDL Test Bench Created from source file ADC_BUF.vhd -- 04/10/20  18:08:03
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

	COMPONENT ADC_BUF
	PORT(
		drdyn : IN std_logic;
		dclk : IN std_logic;          
		sel0 : OUT std_logic;
		sel1 : OUT std_logic;
		clk0 : OUT std_logic;
		clk1 : OUT std_logic
		);
	END COMPONENT;

	SIGNAL drdyn :  std_logic;
	SIGNAL dclk :  std_logic;
	SIGNAL sel0 :  std_logic;
	SIGNAL sel1 :  std_logic;
	SIGNAL clk0 :  std_logic;
	SIGNAL clk1 :  std_logic;

BEGIN

	uut: ADC_BUF PORT MAP(
		drdyn => drdyn,
		dclk => dclk,
		sel0 => sel0,
		sel1 => sel1,
		clk0 => clk0,
		clk1 => clk1
	);


-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
