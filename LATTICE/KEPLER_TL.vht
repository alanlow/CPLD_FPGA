
-- VHDL Test Bench Created from source file KEPLER_TL.vhd -- 04/11/20  15:52:53
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

	COMPONENT KEPLER_TL
	PORT(
		mcu_clko : IN std_logic;
		rxd_1v8 : IN std_logic;
		adc_dclk : IN std_logic;
		cpld_seln : IN std_logic;
		pps_rstn : IN std_logic;
		cpld_rstn : IN std_logic;
		adc_drdyn : IN std_logic;
		spi_miso : IN std_logic;
		cpld_clk : IN std_logic;
		cpld_sdi : IN std_logic;          
		cpld_sdo : OUT std_logic;
		adc_clk1 : OUT std_logic;
		adc_sel1 : OUT std_logic;
		adc_sel0 : OUT std_logic;
		adc_clk0 : OUT std_logic;
		spi_clk : OUT std_logic;
		spi_mosi : OUT std_logic;
		freq_clka : OUT std_logic
		);
	END COMPONENT;

	SIGNAL mcu_clko :  std_logic;
	SIGNAL rxd_1v8 :  std_logic;
	SIGNAL adc_dclk :  std_logic;
	SIGNAL cpld_seln :  std_logic;
	SIGNAL pps_rstn :  std_logic;
	SIGNAL cpld_rstn :  std_logic;
	SIGNAL adc_drdyn :  std_logic;
	SIGNAL spi_miso :  std_logic;
	SIGNAL cpld_clk :  std_logic;
	SIGNAL cpld_sdi :  std_logic;
	SIGNAL cpld_sdo :  std_logic;
	SIGNAL adc_clk1 :  std_logic;
	SIGNAL adc_sel1 :  std_logic;
	SIGNAL adc_sel0 :  std_logic;
	SIGNAL adc_clk0 :  std_logic;
	SIGNAL spi_clk :  std_logic;
	SIGNAL spi_mosi :  std_logic;
	SIGNAL freq_clka :  std_logic;

BEGIN

	uut: KEPLER_TL PORT MAP(
		mcu_clko => mcu_clko,
		rxd_1v8 => rxd_1v8,
		adc_dclk => adc_dclk,
		cpld_seln => cpld_seln,
		pps_rstn => pps_rstn,
		cpld_rstn => cpld_rstn,
		adc_drdyn => adc_drdyn,
		spi_miso => spi_miso,
		cpld_clk => cpld_clk,
		cpld_sdi => cpld_sdi,
		cpld_sdo => cpld_sdo,
		adc_clk1 => adc_clk1,
		adc_sel1 => adc_sel1,
		adc_sel0 => adc_sel0,
		adc_clk0 => adc_clk0,
		spi_clk => spi_clk,
		spi_mosi => spi_mosi,
		freq_clka => freq_clka
	);


-- *** Test Bench - User Defined Section ***
   tb : PROCESS
   BEGIN
      wait; -- will wait forever
   END PROCESS;
-- *** End Test Bench - User Defined Section ***

END;
