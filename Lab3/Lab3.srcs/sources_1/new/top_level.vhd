library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level is
    port(
        --GENERAL
        clk       : in    std_logic; --125 MHz 
        reset_btn : in    std_logic; --active-high reset button
        state_btn : in    std_logic; --active-high state change button
        
        --ADC
        adc_sda   : inout std_logic; --SDA for ADC
        adc_scl   : inout std_logic; --SCL for ADC
        
        --LCD
        lcd_sda   : inout std_logic; --SDA for LCD
        lcd_scl   : inout std_logic  --SCL for LCD
    );
end top_level;

architecture Behavioral of top_level is

begin


end Behavioral;
