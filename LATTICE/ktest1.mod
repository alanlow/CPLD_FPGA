MODEL
MODEL_VERSION "1.0";
DESIGN "ktest1";
DATE "Fri May 01 16:57:46 2020";
VENDOR "Lattice Semiconductor Corporation";
PROGRAM "STAMP Model Generator";

/* port name and type */
INPUT adc_dclk;
INPUT adc_drdyn;
INPUT cpld_clk;
INPUT cpld_sdi;
INPUT cpld_seln;
INPUT mcu_clko;
INPUT pps_rstn;
INPUT rxd_1v8;
INPUT spi_miso;
OUTPUT adc_clk0;
OUTPUT adc_clk1;
OUTPUT adc_sel0;
OUTPUT adc_sel1;
OUTPUT cpld_sdo;
OUTPUT freq_clka;
OUTPUT spi_clk;
OUTPUT spi_mosi;

/* timing arc definitions */
adc_dclk_adc_clk0_delay: DELAY adc_dclk adc_clk0;
adc_dclk_adc_clk1_delay: DELAY adc_dclk adc_clk1;
adc_drdyn_adc_sel0_delay: DELAY adc_drdyn adc_sel0;
adc_drdyn_adc_sel1_delay: DELAY adc_drdyn adc_sel1;
cpld_clk_spi_clk_delay: DELAY cpld_clk spi_clk;
cpld_sdi_spi_mosi_delay: DELAY cpld_sdi spi_mosi;
cpld_seln_cpld_sdo_delay: DELAY cpld_seln cpld_sdo;
mcu_clko_freq_clka_delay: DELAY mcu_clko freq_clka;
spi_miso_cpld_sdo_delay: DELAY spi_miso cpld_sdo;
cpld_seln_cpld_sdo_delay: DELAY cpld_seln cpld_sdo;

/* timing check arc definitions */

ENDMODEL
