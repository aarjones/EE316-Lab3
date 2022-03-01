library ieee;
use ieee.std_logic_1164.all;

library work;

entity i2c_user_logic is
	port(
		clk      : in    std_logic;                     --clock input
		reset_h  : in    std_logic;                     --active-high reset
		data_hex : in    std_logic_vector(15 downto 0); --the data to display on the seven segments
		address_hex : in std_logic_vector(7 downto 0);  --The address to display.
		
		sda      : inout std_logic;                     --i2c data
		scl      : inout std_logic                      --i2c clock
	);
end i2c_user_logic;

architecture behavioral of i2c_user_logic is
	component i2c_master is
		GENERIC(
			input_clk : INTEGER := 50_000_000; --input clock speed from user logic in Hz
			bus_clk   : INTEGER := 50_000);    --speed the i2c bus (scl) will run at in Hz
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
	type stateType is (start, ready, data_valid, busy_high, repeat);
	signal state, next_state  : stateType := start;            --state machine vars
	signal byteSel            : integer range 0 to 12 := 0;    --current byte to send
	signal address_sel        : std_logic;                     --current address
	
	--Operating multiple i2c devices
	signal first  : std_logic;                         --is this the first run through (repeat config data)
	signal addr_1 : std_logic_vector(7 downto 0);      --address of device 1
	signal addr_2 : std_logic_vector(7 downto 0);      --address of device 2
	signal data_disp : std_logic_vector(15 downto 0);
	
	--i2c master signals
	signal reset_n     : std_logic;                    --active-low reset
	signal i2c_enable  : std_logic;                    --enable/start the i2c_master component
	signal i2c_address : std_logic_vector(7 downto 0); --Ignore the MSB when connecting to i2c component
	signal i2c_data    : std_logic_vector(7 downto 0); --data to write
	signal i2c_busy    : std_logic;                    --is the i2c component busy?
	
	begin
	
	reset_n <= not reset_h;
	state <= next_state;
	addr_1 <= x"70"; --show data
	addr_2 <= x"71"; --show address
	
	Inst_i2c_master : i2c_master
		port map(
			clk       => clk,
			reset_n   => reset_n,
			ena       => i2c_enable,
			addr      => i2c_address(6 downto 0),
			rw        => '0',          --we're only writing
			data_wr   => i2c_data,
			busy      => i2c_busy,
			data_rd   => open,         --we're only writing
			ack_error => open,         --we're only writing
			sda       => sda,
			scl       => scl
		);
	
	--Main State Machine
	process(clk) 
	begin
		if rising_edge(clk) then
			if reset_h = '1' then
				next_state  <= start; --move to the starting state
				byteSel     <= 0;     --reset the counter
				address_sel <= '0';
				first       <= '1';   --re-run configs
			else
				case(state) is 
					when start =>
						i2c_enable <= '0'; --don't start the i2c transaction
						next_state <= ready;
						
					when ready =>
						if i2c_busy = '0' then       --if we can go to the next transaction
							i2c_enable <= '1';        --enable the i2c controller
							next_state <= data_valid; --and move to the next state
						end if;
						
					when data_valid =>
						if i2c_busy = '1' then       --if the transaction has started
							i2c_enable <= '0';        --reset the enable signal
							next_state <= busy_high;  --and move to the next state
						end if;
						
					when busy_high => 
						if i2c_busy = '0' then       --once the i2c transaction has completed
							next_state <= repeat;     --move to the next state
						end if;
						
					when repeat =>
						if byteSel < 12 then               --If we're not at the top
							byteSel     <= byteSel + 1;     --increment 
						elsif first = '1' then             --otherwise, if this is the first run through
							byteSel     <= 0;               --go back to the beginning
							address_sel <= not address_sel; --with the second address
							first       <= '0';             --and clear the first flag
						else                               --otherwise, this is a normal repeat
							byteSel <= 9;                   --so go back to the repeating bytes
							address_sel <= not address_sel; --and change addresses
						end if;
						next_state <= start;
						
				end case;
			end if;
		end if;
	end process;
	
	--Multiplexor for current address
	process(address_sel)
	begin
		case(address_sel) is
			when '0' => i2c_address <= addr_2; data_disp <= x"00" & address_hex;
			when '1' => i2c_address <= addr_1; data_disp <= data_hex;
			when others => null;
		end case;
	end process;
	
	--Multiplexor for current byte
	process(byteSel, data_hex)
	begin
		case byteSel is
			when 0      => i2c_data <= X"76";
			when 1      => i2c_data <= X"76";
			when 2      => i2c_data <= X"76";
			when 3      => i2c_data <= X"7A";
			when 4      => i2c_data <= X"FF";
			when 5      => i2c_data <= X"77";
			when 6      => i2c_data <= X"00";
			when 7      => i2c_data <= X"79"; --Repeat here
			when 8      => i2c_data <= X"00";
			when 9      => i2c_data <= X"0"&data_disp(15 downto 12);
			when 10     => i2c_data <= X"0"&data_disp(11 downto 8);
			when 11     => i2c_data <= X"0"&data_disp(7  downto 4);
			when 12     => i2c_data <= X"0"&data_disp(3  downto 0);
			when others => i2c_data <= X"76";
		end case;
	end process;

end behavioral;