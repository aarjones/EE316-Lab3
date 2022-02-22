library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity system_controller is
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
end system_controller;

architecture behavioral of system_controller is
	type stateType is (init, adc0, adc0clk, adc1, adc1clk, adc2, adc3, adc3clk);
	
	--For State Machine
	signal state, next_state : stateType := init;
	
	--Command signals
	signal to_change : std_logic; --should we change channels on the ADC?
	signal move_states : std_logic; --should we move states after the ADC isn't busy?
	
	begin
	
	state <= next_state;
	
	--Process for state machine
	process(clk) begin
		if rising_edge(clk) then
			if reset_h = '0' then
				case(state) is 
					when init =>
					   adc_sel   <= "00";            --go to channel 0
					   change_ch <= '1';             --send the latch to change channels
					   adc_read  <= '0';             --don't read from the adc
					   run_clk   <= '0';             --turn off the clock
					   to_change <= '1';             --prepare to change channels
					   data_out  <= (others => '0'); --reset output data
					   move_states <= '0';           --don't keep moving states
					   if adc_busy = '1' then        --if the adc has sent the command to change states
					       next_state <= adc0;       --move to the adc0 state
					   end if;
					   
					when adc0 =>
					   run_clk   <= '0';                             --turn off the clock
					   move_states <= '0';                           --don't keep moving states
					   if to_change = '1' and adc_busy = '0' then    --if we need to change channels
					       change_ch <= '1';                         --do it
					   elsif to_change = '1' and adc_busy = '1' then --otherwise, if the adc is busy and we should change channels
					       to_change <= '0';                         --the channel is already being changed, so remove the flag
					       change_ch <= '0';                         --and stop sending the command
					   elsif adc_busy = '0' then                     --if te adc is not busy
					       adc_read <= '1';                          --read it
					   else                                          --otherwise
					       adc_read <= '0';                          --reset the flag
					   end if;
					   if adc_val = '1' then                         --if the adc data is valid
					       data_out <= adc_data;                     --sample it
					   end if;
					   if state_btn = '1' then                       --if we need to change states
					       adc_read <= '0';                          --stop reading
					       to_change <= '0';                         --and change the channel
					       move_states <= '1';                       --we will need to move states
					   end if;
					   if move_states = '1' then
					       next_state <= adc0clk;
					   end if;
					
					when adc0clk =>
					   run_clk   <= '1';                             --turn on the clock
					   move_states <= '0';                           --don't keep moving states
					   if to_change = '1' and adc_busy = '0' then    --if we need to change channels
					       change_ch <= '1';                         --do it
					   elsif to_change = '1' and adc_busy = '1' then --otherwise, if the adc is busy and we should change channels
					       to_change <= '0';                         --the channel is already being changed, so remove the flag
					       change_ch <= '0';                         --and stop sending the command
					   elsif adc_busy = '0' then                     --if te adc is not busy
					       adc_read <= '1';                          --read it
					   else                                          --otherwise
					       adc_read <= '0';                          --reset the flag
					   end if;
					   if adc_val = '1' then                         --if the adc data is valid
					       data_out <= adc_data;                     --sample it
					   end if;
					   if state_btn = '1' then                       --if we need to change states
					       adc_sel     <= "01";                      --change adc channels
					       adc_read <= '0';                          --stop reading
					       to_change   <= '1';                       --we will need to change channels
					       move_states <= '1';                       --we will need to move states
					   end if;
					   if move_states = '1' then
					       next_state <= adc1;
					   end if;
					   
					when adc1 =>
					   run_clk   <= '0';                             --turn off the clock
					   move_states <= '0';                           --don't keep moving states
					   if to_change = '1' and adc_busy = '0' then    --if we need to change channels
					       change_ch <= '1';                         --do it
					   elsif to_change = '1' and adc_busy = '1' then --otherwise, if the adc is busy and we should change channels
					       to_change <= '0';                         --the channel is already being changed, so remove the flag
					       change_ch <= '0';                         --and stop sending the command
					   elsif adc_busy = '0' then                     --if te adc is not busy
					       adc_read <= '1';                          --read it
					   else                                          --otherwise
					       adc_read <= '0';                          --reset the flag
					   end if;
					   if adc_val = '1' then                         --if the adc data is valid
					       data_out <= adc_data;                     --sample it
					   end if;
					   if state_btn = '1' then                       --if we need to change states
					       adc_sel     <= "01";
					       adc_read <= '0';                          --stop reading
					       to_change   <= '1';                       --we will need to change channels
					       move_states <= '1';                       --we will need to move states
					   end if;
					   if move_states = '1' then
					       next_state <= adc1clk;
					   end if;
					
					when adc1clk =>
					   run_clk   <= '1';                             --turn on the clock
					   move_states <= '0';                           --don't keep moving states
					   if to_change = '1' and adc_busy = '0' then    --if we need to change channels
					       change_ch <= '1';                         --do it
					   elsif to_change = '1' and adc_busy = '1' then --otherwise, if the adc is busy and we should change channels
					       to_change <= '0';                         --the channel is already being changed, so remove the flag
					       change_ch <= '0';                         --and stop sending the command
					   elsif adc_busy = '0' then                     --if te adc is not busy
					       adc_read <= '1';                          --read it
					   else                                          --otherwise
					       adc_read <= '0';                          --reset the flag
					   end if;
					   if adc_val = '1' then                         --if the adc data is valid
					       data_out <= adc_data;                     --sample it
					   end if;
					   if state_btn = '1' then                       --if we need to change states
					       adc_sel     <= "10";
					       adc_read <= '0';                          --stop reading
					       to_change   <= '1';                       --we will need to change channels
					       move_states <= '1';                       --we will need to move states
					   end if;
					   if move_states = '1' then
					       next_state <= adc2;
					   end if;
					
					when adc2 =>
					   run_clk   <= '0';                             --turn off the clock
					   move_states <= '0';                           --don't keep moving states
					   if to_change = '1' and adc_busy = '0' then    --if we need to change channels
					       change_ch <= '1';                         --do it
					   elsif to_change = '1' and adc_busy = '1' then --otherwise, if the adc is busy and we should change channels
					       to_change <= '0';                         --the channel is already being changed, so remove the flag
					       change_ch <= '0';                         --and stop sending the command
					   elsif adc_busy = '0' then                     --if te adc is not busy
					       adc_read <= '1';                          --read it
					   else                                          --otherwise
					       adc_read <= '0';                          --reset the flag
					   end if;
					   if adc_val = '1' then                         --if the adc data is valid
					       data_out <= adc_data;                     --sample it
					   end if;
					   if state_btn = '1' then                       --if we need to change states
					       adc_sel     <= "11";
					       adc_read <= '0';                          --stop reading
					       to_change   <= '1';                       --we will need to change channels
					       move_states <= '1';                       --we will need to move states
					   end if;
					   if move_states = '1' then
					       next_state <= adc3;
					   end if;
					
					when adc3 =>
					   run_clk   <= '0';                             --turn off the clock
					   move_states <= '0';                           --don't keep moving states
					   if to_change = '1' and adc_busy = '0' then    --if we need to change channels
					       change_ch <= '1';                         --do it
					   elsif to_change = '1' and adc_busy = '1' then --otherwise, if the adc is busy and we should change channels
					       to_change <= '0';                         --the channel is already being changed, so remove the flag
					       change_ch <= '0';                         --and stop sending the command
					   elsif adc_busy = '0' then                     --if te adc is not busy
					       adc_read <= '1';                          --read it
					   else                                          --otherwise
					       adc_read <= '0';                          --reset the flag
					   end if;
					   if adc_val = '1' then                         --if the adc data is valid
					       data_out <= adc_data;                     --sample it
					   end if;
					   if state_btn = '1' then                       --if we need to change states
					       adc_sel     <= "11";
					       adc_read <= '0';                          --stop reading
					       to_change   <= '1';                       --we will need to change channels
					       move_states <= '1';                       --we will need to move states
					   end if;
					   if move_states = '1' then
					       next_state <= adc3clk;
					   end if;
					
					when adc3clk =>
					   run_clk   <= '1';                             --turn on the clock
					   move_states <= '0';                           --don't keep moving states
					   if to_change = '1' and adc_busy = '0' then    --if we need to change channels
					       change_ch <= '1';                         --do it
					   elsif to_change = '1' and adc_busy = '1' then --otherwise, if the adc is busy and we should change channels
					       to_change <= '0';                         --the channel is already being changed, so remove the flag
					       change_ch <= '0';                         --and stop sending the command
					   elsif adc_busy = '0' then                     --if te adc is not busy
					       adc_read <= '1';                          --read it
					   else                                          --otherwise
					       adc_read <= '0';                          --reset the flag
					   end if;
					   if adc_val = '1' then                         --if the adc data is valid
					       data_out <= adc_data;                     --sample it
					   end if;
					   if state_btn = '1' then                       --if we need to change states
					       adc_sel     <= "00";
					       adc_read <= '0';                          --stop reading
					       to_change   <= '1';                       --we will need to change channels
					       move_states <= '1';                       --we will need to move states
					   end if;
					   if move_states = '1' then
					       next_state <= adc0;
					   end if;
					
				end case;
			elsif reset_h = '1' then
				next_state <= init;
				move_states <= '0';
				to_change   <= '1';
				adc_sel     <= "00";
				change_ch   <= '0';
				run_clk     <= '0';
			end if;
		end if;
	end process;
end behavioral;