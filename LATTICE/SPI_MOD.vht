
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
		sel : IN std_logic;
		miso : IN std_logic;          
		sdo : OUT std_logic;
		sclk : OUT std_logic;
		mosi : OUT std_logic
		);
	END COMPONENT;

	SIGNAL pcnt :  std_logic_vector(23 downto 0);
	SIGNAL nclr :  std_logic;
	SIGNAL sdi :  std_logic;
	SIGNAL dclk :  std_logic;
	SIGNAL sel :  std_logic;
	SIGNAL miso :  std_logic;
	SIGNAL sdo :  std_logic;
	SIGNAL sclk :  std_logic;
	SIGNAL mosi :  std_logic;

BEGIN

	uut: SPI_MOD PORT MAP(
		pcnt => pcnt,
		nclr => nclr,
		sdi => sdi,
		dclk => dclk,
		sel => sel,
		miso => miso,
		sdo => sdo,
		sclk => sclk,
		mosi => mosi
	);


-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
