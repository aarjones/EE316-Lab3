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
        lcd_scl   : inout std_logic; --SCL for LCD
        
        --PWM
        pwm_o     : out   std_logic;  --PWM output signal
        
        --CLOCK
        clock_o   : out   std_logic    --Clock output signal
    );
end top_level;

architecture Behavioral of top_level is
--Reset, Button Related
signal reset_h : std_logic;
signal reset_n : std_logic;
signal reset_delay_out : std_logic;
signal reset_btn_deb : std_logic;
signal state_pulse : std_logic;

signal final_data : std_logic_vector(7 downto 0);

--ADC Related
signal adc_data : std_logic_vector(7 downto 0);
signal adc_valid : std_logic;
signal adc_busy : std_logic;
signal adc_read : std_logic;
signal adc_sel : std_logic_vector(1 downto 0);
signal change_ch : std_logic;

--Clock related
signal run_clk : std_logic;

--COMPONENTS
component system_controller is
    port(
	   --General Inputs
		clk          : in    std_logic;                     --125 MHz
		reset_h      : in    std_logic;                     --active-high reset
		state_btn    : in    std_logic;                     --change states, expects pulse
		
		--General Outputs
		data_out     : out   std_logic_vector(7 downto 0);  --data output to use in the clock, pwm
		
		--ADC Connections
		adc_busy     : in    std_logic;                     --the ADC is busy
		adc_val      : in    std_logic;                     --sample the data from the ADC
		adc_data     : in    std_logic_vector(7 downto 0);  --data read from the ADC
		adc_read     : out   std_logic;                     --read from the adc
		adc_sel      : out   std_logic_vector(1 downto 0);  --which adc channel to use
		change_ch    : out   std_logic;                     --Change channels
		
		--Clock Connections
		run_clk      : out   std_logic                      --should the clock be on
	);
end component;

component i2c_adc_user is
    generic(
        ADC_ADDRESS : std_logic_vector(6 downto 0) := "1001111"
    );
	port(
	   --GENERAL 
	   clk       : in  std_logic;                     --clock input
	   reset_h   : in  std_logic;                     --active-high reset
	   busy_h    : out std_logic;                     --busy signal
		
	   --FOR ADC
	   read_adc   : in  std_logic;                     --should we read from the adc
	   change_ch  : in  std_logic;                     --send the command to change the address
	   adc_sel    : in  std_logic_vector(1 downto 0);  --Which ADC input to use
	   data_o     : out std_logic_vector(7 downto 0);  --The data read from the ADC
	   data_valid : out std_logic;                     --Data valid pulse
		
		-- I2C Connections
		sda_adc   : inout std_logic;                   --i2c data
		scl_adc   : inout std_logic                    --i2c clock
	);
end component;

component PWM is
    port (
        --INS
        clk 	 : in std_logic;
        reset_h  : in std_logic;
        en 	     : in std_logic;
        value_i  : in std_logic_vector(7 downto 0);
        
        --OUTS
        pwm_o	 : out std_logic
	);
end component;

component btn_debounce_toggle is
    generic (
	   constant CNTR_MAX : std_logic_vector(15 downto 0) := X"FFFF"
	);
    port( 
        btn_i 	 : in  std_logic;
        clk 	 : in  std_logic;
        btn_o 	 : out std_logic;
		pulse_o  : out std_logic;
        toggle_o : out std_logic
    );
end component;

component reset_delay is
    port(
        signal iCLK   : in  std_logic;	
        signal oRESET : out std_logic
	);	
end component;

begin
--INSTANTIATIONS/CONNECTIONS
    Inst_system_controller : system_controller
        port map(
            clk => clk,
            reset_h => reset_h,
            state_btn => state_pulse,
            data_out => final_data,
            adc_busy => adc_busy,
            adc_val => adc_valid,
            adc_data => adc_data,
            adc_read => adc_read,
            adc_sel => adc_sel,
            change_ch => change_ch,
            run_clk => run_clk
        );
    
    Inst_i2c_adc_user : i2c_adc_user
        port map(
            clk => clk,
            reset_h => reset_h,
            busy_h => adc_busy,
            read_adc => adc_read,
            change_ch => change_ch,
            adc_sel => adc_sel,
            data_o => adc_data,
            data_valid => adc_valid,
            sda_adc => adc_sda,
            scl_adc => adc_scl
        );
        
    Inst_PWM : PWM
        port map(
            clk => clk,
            reset_h => reset_h,
            en => '1', 
            value_i => final_data,
            pwm_o => pwm_o
        );
        
    Inst_state_toggle : btn_debounce_toggle
        port map(
            btn_i => state_btn,
            clk => clk,
            btn_o => open,
            pulse_o => state_pulse,
            toggle_o => open
        );
        
    Inst_reset_deb : btn_debounce_toggle
        port map(
            btn_i => reset_btn,
            clk => clk,
            btn_o => reset_btn_deb,
            pulse_o => open,
            toggle_o => open
        );
        
    Inst_reset_delay : reset_delay
        port map(
            iCLK => clk,
            oRESET => reset_delay_out
        );
        
    reset_h <= reset_btn_deb and reset_delay_out;
    reset_n <= not reset_h;
end Behavioral;
