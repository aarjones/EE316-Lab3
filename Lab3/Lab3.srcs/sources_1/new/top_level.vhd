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
        adc_data_o: out std_logic_vector(7 downto 0);
        
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
signal state_reset : std_logic;

--ADC Related
signal adc_data : std_logic_vector(7 downto 0);
signal adc_sel : std_logic_vector(1 downto 0);
signal adc_busy : std_logic;

--Clock related
signal run_clk : std_logic;

--COMPONENTS
component system_controller is
    port(
	   --General Inputs
		clk          : in    std_logic;                     --125 MHz
		reset_h      : in    std_logic;                     --active-high reset
		state_btn    : in    std_logic;                     --change states, expects pulse
		
		--ADC Connections
		adc_sel      : out   std_logic_vector(1 downto 0);  --which adc channel to use
		
		--Clock Connections
		run_clk      : out   std_logic                      --should the clock be on
	);
end component;

component i2c_adc_user is
    generic(
        ADC_ADDRESS : std_logic_vector(6 downto 0) := "1001000"
    );
	port(
	   --GENERAL 
	   clk        : in  std_logic;                     --clock input
	   reset_h_in : in  std_logic;                     --active-high reset
	   state_btn  : in  std_logic;                     --a pulse for when states change
	   busy_h     : out std_logic;                     --busy signal
		
	   --FOR ADC
	   adc_sel    : in  std_logic_vector(1 downto 0);  --Which ADC input to use
	   data_o     : out std_logic_vector(7 downto 0);  --The data read from the ADC
		
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
	   constant CNTR_MAX : std_logic_vector(15 downto 0) := X"00FF"
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
            adc_sel => adc_sel,
            run_clk => run_clk
        );
    
    Inst_i2c_adc_user : i2c_adc_user
        port map(
            clk => clk,
            reset_h_in => reset_h,
			state_btn => state_pulse,
            busy_h => adc_busy,
            adc_sel => adc_sel,
            data_o => adc_data,
            sda_adc => adc_sda,
            scl_adc => adc_scl
        );
        
    Inst_PWM : PWM
        port map(
            clk => clk,
            reset_h => reset_h,
            en => '1', 
            value_i => adc_data,
            pwm_o => pwm_o
        );
        
    Inst_state_toggle : btn_debounce_toggle
        port map(
            btn_i => state_btn,
            clk => clk,
            btn_o => state_reset,
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
        
    adc_data_o <= adc_data;
    reset_h <= reset_btn_deb or reset_delay_out;
    reset_n <= not reset_h;
    clock_o <= run_clk;
end Behavioral;
