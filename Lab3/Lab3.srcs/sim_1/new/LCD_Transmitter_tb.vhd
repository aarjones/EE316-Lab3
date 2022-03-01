----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2022 02:06:25 PM
-- Design Name: 
-- Module Name: LCD_Transmitter_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity LCD_Transmitter_tb is
--  Port ( );
end LCD_Transmitter_tb;

architecture Behavioral of LCD_Transmitter_tb is

component LCD_Transmitter IS
	GENERIC (
		CONSTANT input_clock : integer := 125_000_000); 
	PORT(
		clk       : IN    STD_LOGIC;                     --system clock
		reset_n   : IN    STD_LOGIC;
		
		run_clk   : IN    STD_LOGIC;  --is the clock on
		adc_sel   : IN    STD_LOGIC_VECTOR(1 DOWNTO 0); 
		
		sda       : inout std_logic;                     --i2c data
		scl       : inout std_logic                      --i2c clock
    );                   
END component;

signal clk : std_logic := '0';
signal reset_n : std_logic := '0';
signal run_clk : std_logic := '0';
signal adc_sel : std_logic_vector(1 downto 0) := "00";
signal sda : std_logic;
signal scl : std_logic;

begin
DUT : LCD_Transmitter
    port map(
            clk => clk,
            reset_n => reset_n,
            run_clk => run_clk,
            adc_sel => adc_sel,
            sda => sda,
            scl => scl
        );

clk <= not clk after 4 ns;

process begin

wait for 100 ns;
reset_n <= '1';
wait for 10 ms;

wait;
end process;


end Behavioral;
