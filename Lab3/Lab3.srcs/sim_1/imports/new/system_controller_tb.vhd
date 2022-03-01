library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity system_controller_tb is
--  Port ( );
end system_controller_tb;

architecture Behavioral of system_controller_tb is
signal clk : std_logic := '0';
signal reset_h : std_logic := '1';
signal state_btn : std_logic := '0';

signal data_out : std_logic_vector(7 downto 0) := (others => '0');

signal adc_busy : std_logic:= '1';    
signal adc_val : std_logic:= '0';
signal adc_data : std_logic_vector(7 downto 0) := (others => '0');
signal adc_read : std_logic:= '0';
signal adc_sel : std_logic_vector(1 downto 0) := (others => '0');
signal change_ch : std_logic:= '0';

signal run_clk : std_logic;

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

begin

    DUT : system_controller
        port map(
            clk => clk,
            reset_h => reset_h,
            state_btn => state_btn,
            data_out => data_out,
            adc_busy => adc_busy,
            adc_val => adc_val,
            adc_data => adc_data,
            adc_read => adc_read,
            adc_sel => adc_sel,
            change_ch => change_ch,
            run_clk => run_clk
        );

    clk <= not clk after 4 ns; --125 MHz
    
    process begin
    wait for 20 ns; --wait for reset
    
    --turn off reset; simulate adc not busy; should change channel and then move to adc0 state after adc_busy goes high
    reset_h <= '0';
    adc_busy <= '0';
    wait for 24 ns;
    adc_busy <= '1';
    wait for 24 ns;
    
    --sample in each state
    for i in 0 to 10 loop
        --read data
        adc_busy <= '0';
        wait for 16 ns;
        adc_busy <= '1';
        wait for 24 ns;
        adc_data <= std_logic_vector(to_unsigned(i, 8));
        adc_val <= '1';
        adc_busy <= '0';
        wait for 8 ns;
        adc_val <= '0';
        wait for 16 ns;
        
        --change states
        state_btn <= '1';
        wait for 8 ns;
        state_btn <= '0';
        wait for 16 ns;
        adc_busy <= '1';
        wait for 24 ns;
        adc_busy <= '0';
        wait for 16 ns;
        
    end loop;
    
    reset_h <= '1';
    adc_busy <= '1';
    wait for 16 ns;    
    
    wait; 
    end process;

end Behavioral;
