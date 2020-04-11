-- VHDL netlist-file
library mach;
use mach.components.all;

library ieee;
use ieee.std_logic_1164.all;
entity ADC_BUF is
  port (
    drdyn : in std_logic;
    dclk : in std_logic;
    sel0 : out std_logic;
    sel1 : out std_logic;
    clk0 : out std_logic;
    clk1 : out std_logic
  );
end ADC_BUF;

architecture NetList of ADC_BUF is

  signal drdynPIN : std_logic;
  signal dclkPIN : std_logic;
  signal sel0COM : std_logic;
  signal sel1COM : std_logic;
  signal clk0COM : std_logic;
  signal GND_net : std_logic;

begin
  GND_I_I_1:   GND port map ( X=>GND_net );
  IN_drdyn_I_1:   IBUF
 generic map( PULL => "Down")
 port map ( O=>drdynPIN, 
            I0=>drdyn );
  IN_dclk_I_1:   IBUF
 generic map( PULL => "Down")
 port map ( O=>dclkPIN, 
            I0=>dclk );
  OUT_sel0_I_1:   OBUF
 generic map( PULL => "Down")
 port map ( O=>sel0, 
            I0=>sel0COM );
  OUT_sel1_I_1:   OBUF
 generic map( PULL => "Down")
 port map ( O=>sel1, 
            I0=>sel1COM );
  OUT_clk0_I_1:   OBUF
 generic map( PULL => "Down")
 port map ( O=>clk0, 
            I0=>clk0COM );
  OUT_clk1_I_1:   BUFTH port map ( I0=>GND_net, 
            O=>clk1, 
            OE=>GND_net );
  GATE_sel0_I_1:   BUFF port map ( I0=>drdynPIN, 
            O=>sel0COM );
  GATE_sel1_I_1:   BUFF port map ( I0=>drdynPIN, 
            O=>sel1COM );
  GATE_clk0_I_1:   BUFF port map ( I0=>dclkPIN, 
            O=>clk0COM );

end NetList;
