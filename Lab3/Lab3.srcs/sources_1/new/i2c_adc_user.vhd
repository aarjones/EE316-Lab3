library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity i2c_adc_user is
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
		adc_sel     : in  std_logic_vector(1 downto 0);  --Which ADC input to use
		data_o      : out std_logic_vector(7 downto 0);  --The data read from the ADC

		-- I2C Connections
		sda_adc    : inout std_logic;                   --i2c data
		scl_adc    : inout std_logic                    --i2c clock
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
	type stateType is (init, read, change_channel, busy_high);
	signal reset_h: std_logic;
	signal state : stateType := init;     --state machine vars
	signal count : integer range 0 to 7;
	signal reset_cnt : unsigned(23 DOWNTO 0):=X"000000";
	signal reset_delayed : std_logic;
	
	--command signals
	signal rw : std_logic;
	signal data_rd : std_logic_vector(7 downto 0);
	
	--i2c master signals
	signal reset_n     : std_logic;                    --active-low reset
	signal i2c_enable  : std_logic;                    --enable/start the i2c_master component
	signal i2c_address : std_logic_vector(7 downto 0); --Ignore the MSB when connecting to i2c component
	signal i2c_data    : std_logic_vector(7 downto 0); --data to write
	signal i2c_busy    : std_logic;                    --is the i2c component busy?
	
	begin
	
	reset_h <= reset_h_in or reset_delayed;
	reset_n <= not reset_h;
	data_o <= data_rd;
	
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
            if reset_h_in = '1' or state_btn = '1' then
                state <= init;
                busy_h <= '1';
				count <= 0;
			else
                case(state) is
                    when init =>
                        rw         <= '0';                --first command should be to write
                        busy_h     <= '1';                --we can't accept more commands
                        state <= change_channel;          --move to the correct channel
                        
					when change_channel =>
                        rw <= '0';
                        i2c_data <= "010000" & adc_sel;
                        i2c_enable <= '1';
                        if i2c_busy = '1' then
                            state <= busy_high;
                        end if;
                        
					when busy_high =>
                        i2c_enable <= '0';
                        if i2c_busy = '0' then
							if count < 7 then
								count <= count + 1;
								state <= change_channel;
							else
								state <= read;
							end if;
                        end if;	
						
                    when read => 
                        rw         <= '1';                --we're reading
                        i2c_enable <= '1';                --turn on the i2c master
                end case;
           end if;
        end if;

--		--ADC Delay Reset
--		if state_btn = '1' then
--			reset_cnt <= (others => '0');
--		end if;

--		--LCD Delay
--		IF reset_cnt /= X"AFFFFF" THEN --hardware
--			reset_cnt <= reset_cnt + 1;	
--			reset_delayed <= '1';	
--		ELSE
--			reset_delayed <= '0';	
--		END IF;

    end process;
end behavioral;