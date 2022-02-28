library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity system_controller is
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
end system_controller;

architecture behavioral of system_controller is
	type stateType is (init, adc0, adc0clk, adc1, adc1clk, adc2, adc3, adc3clk);
	
	--For State Machine
	signal state, next_state : stateType := init;
	
	begin
	
	state <= next_state;
	
	--Process for state machine
	process(clk) begin
		if rising_edge(clk) then
			if reset_h = '0' then
				case(state) is 
					when init =>
						adc_sel <= "00";              --start at channel 0
						run_clk <= '0';               --don't run the clock
						next_state <= adc0;           --move to the next state
					   
					when adc0 =>
						adc_sel <= "00";              --Channel 0
						run_clk <= '0';               --don't run the clock
						if state_btn = '1' then
							next_state <= adc0clk;    --move to the next state
						end if;
					
					when adc0clk =>
					    adc_sel <= "00";              --Channel 0
						run_clk <= '1';               --run the clock
						if state_btn = '1' then
							next_state <= adc1;       --move to the next state
						end if;
					   
					when adc1 =>
					    adc_sel <= "01";              --Channel 1
						run_clk <= '0';     	      --don't run the clock
						if state_btn = '1' then
							next_state <= adc1clk;    --move to the next state
						end if;
					
					when adc1clk =>
					    adc_sel <= "01";              --Channel 1
						run_clk <= '1';               --run the clock
						if state_btn = '1' then
							next_state <= adc2;       --move to the next state
						end if;
					
					when adc2 =>
					    adc_sel <= "10";              --Channel 2
						run_clk <= '0';               --don't run the clock
						if state_btn = '1' then
							next_state <= adc3;       --move to the next state
						end if;
					
					when adc3 =>
					    adc_sel <= "11";              --Channel 3
						run_clk <= '0';               --don't run the clock
						if state_btn = '1' then
							next_state <= adc3clk;    --move to the next state
						end if;
					
					when adc3clk =>
					    adc_sel <= "11";              --Channel 2
						run_clk <= '1';               --run the clock
						if state_btn = '1' then
							next_state <= adc0;       --move to the next state
						end if;
					
				end case;
			elsif reset_h = '1' then
				adc_sel <= "00";       --start at channel 0
				run_clk <= '0';        --don't run the clock
				next_state <= init ;    --move to the next state
			end if;
		end if;
	end process;
end behavioral;