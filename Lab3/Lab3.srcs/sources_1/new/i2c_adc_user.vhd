library ieee;
use ieee.std_logic_1164.all;

library work;

entity i2c_adc_user is
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
end i2c_adc_user;

architecture behavioral of i2c_adc_user is
	component i2c_master is
		GENERIC(
			input_clk : INTEGER := 125_000_000; --input clock speed from user logic in Hz
			bus_clk   : INTEGER := 400_000);    --speed the i2c bus (scl) will run at in Hz
		PORT(
			clk       : IN     STD_LOGIC;                    --system clock
			reset_n   : IN     STD_LOGIC;                    --active low reset
			ena       : IN     STD_LOGIC;                    --latch in command
			addr      : IN     STD_LOGIC_VECTOR(6 DOWNTO 0); --address of target slave
			rw        : IN     STD_LOGIC;                    --'0' is write, '1' is read
			data_wr   : IN     STD_LOGIC_VECTOR(7 DOWNTO 0); --data to write to slave
			busy      : OUT    STD_LOGIC;                    --indicates transaction in progress
			data_rd   : OUT    STD_LOGIC_VECTOR(7 DOWNTO 0); --data read from slave
			ack_error : BUFFER STD_LOGIC;                    --flag if improper acknowledge from slave
			sda       : INOUT  STD_LOGIC;                    --serial data output of i2c bus
			scl       : INOUT  STD_LOGIC);                   --serial clock output of i2c bus
	END component;

	--general signals
	type stateType is (init, ready, read, change_channel, busy_high);
	signal state, next_state  : stateType := init;     --state machine vars
	
	--command signals
	signal rw : std_logic;
	signal sampled : std_logic;
	signal data_rd : std_logic_vector(7 downto 0);
	
	--i2c master signals
	signal reset_n     : std_logic;                    --active-low reset
	signal i2c_enable  : std_logic;                    --enable/start the i2c_master component
	signal i2c_address : std_logic_vector(7 downto 0); --Ignore the MSB when connecting to i2c component
	signal i2c_data    : std_logic_vector(7 downto 0); --data to write
	signal i2c_busy    : std_logic;                    --is the i2c component busy?
	
	begin
	
	reset_n <= not reset_h;
	
	Inst_i2c_master : i2c_master
		port map(
			clk       => clk,
			reset_n   => reset_n,
			ena       => i2c_enable,
			addr      => ADC_ADDRESS,
			rw        => rw,
			data_wr   => i2c_data,
			busy      => i2c_busy,
			data_rd   => data_rd,
			ack_error => open,         --don't care
			sda       => sda_adc,
			scl       => scl_adc
		);
	
	--Main State Machine
	process(clk) 
	begin
        if rising_edge(clk) then
            if reset_h = '1' then
                next_state <= init;
                data_valid <= '0';
                busy_h     <= '1';
                data_o     <= (others => '0');
            else
                case state is
                    when init =>
                        rw         <= '0';                --first command should be to read
                        data_valid <= '0';                --the output data is not valid
                        data_o     <= (others => '0');    --reset the output data
                        sampled    <= '1';                --don't sample the i2c master
                        busy_h     <= '1';                --we can't accept more commands
                        next_state <= ready;              --move to the ready state
                        
                    when ready => 
                        busy_h     <= '0';                --we can accept new commands
                        if sampled = '0' then             --if we haven't sampled the data
                            sampled <= '1';               --do it
                            data_o  <= data_rd;           --do it
                        end if;
                        if change_ch = '1' then           --if we need to send a command
                            next_state <= change_channel; --do it
                            busy_h <= '1';                --we can't accept new commands
                        elsif read_adc = '1' then         --if we need to read from the adc
                            next_state <= read;           --do it
                            busy_h     <= '1';            --we can't accept new commands
                        end if;
                        
                    when read => 
                        rw         <= '1';                --we're reading
                        i2c_enable <= '1';                --turn on the i2c master
                        sampled    <= '0';                --we haven't sampled the data
                        if i2c_busy = '1' then
                            next_state <= busy_high;
                        end if;
                        
                    when change_channel =>
                        rw <= '0';
                        i2c_data <= "000000" & adc_sel;
                        i2c_enable <= '1';
                        if i2c_busy = '1' then
                            next_state <= busy_high;
                        end if;
                    
                    when busy_high =>
                        i2c_enable <= '0';
                        if i2c_busy = '0' then
                            next_state <= ready;
                        end if;
                    
                end case;
           end if;
        end if;
    end process;
end behavioral;