library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity i2c_adc_user_tb is
--  Port ( );
end i2c_adc_user_tb;

architecture Behavioral of i2c_adc_user_tb is

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

signal clk : std_logic := '0';
signal reset_h : std_logic := '1';
signal busy_h : std_logic;

signal read_adc : std_logic := '0';
signal change_ch : std_logic := '0';
signal adc_sel : std_logic_vector(1 downto 0) := "10";
signal data_o : std_logic_vector(7 downto 0);
signal data_valid : std_logic;

signal sda_adc : std_logic;
signal scl_adc : std_logic;

begin

DUT : i2c_adc_user
        port map(
            clk => clk,
            reset_h => reset_h,
            busy_h => busy_h,
            read_adc => read_adc,
            change_ch => change_ch,
            adc_sel => adc_sel,
            data_o => data_o,
            data_valid => data_valid,
            sda_adc => sda_adc,
            scl_adc => scl_adc
        );

clk <= not clk after 4 ns;

process begin --run for 120 us
    wait for 24 ns;
    reset_h <= '0';
    
    wait for 670 ns;
    change_ch <= '1';
    wait for 8 ns;
    change_ch <= '0';
    
    wait for 55 us;
    
    read_adc <= '1';
    wait for 8 ns;
    read_adc <= '0';
    
    wait;
end process;

end Behavioral;
