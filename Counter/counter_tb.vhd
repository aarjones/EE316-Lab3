library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity counter_tb is
end counter_tb;

architecture Behavioral of counter_tb is

    component counter
    port ( clk     : in std_logic;
        reset   : in std_logic;
        freq    : in std_logic_vector(7 downto 0); -- 255 down to 0 
        clk_en  : in std_logic;                    -- only output clock when enabl is high
        count   : out std_logic_vector(7 downto 0);
    );

    signal reset, clk: std_logic;
    signal counter:std_logic_vector(7 downto 0);

    begin
    dut: DOWN_COUNTER port map (clk => clk, reset=>reset, counter => counter);
    -- Clock process definitions
    clock_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- Stimulus process
    stim_proc: process
    begin        
    -- hold reset state for 100 ns.
        reset <= '1';
    wait for 20 ns;    
        reset <= '0';
    wait;
    end process;
end Behavioral;