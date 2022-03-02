library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_gen is
    port (
        clk : in std_logic;
        reset : in std_logic;
        freq : in std_logic_vector(7 downto 0);
        en : in std_logic;
        clk_out : out std_logic
    );
end clock_gen;

architecture behavioral of clock_gen is
signal cnt : integer;
signal current_value : integer;
signal clock_toggler : std_logic := '0';

begin

    current_value <= 41000 + 425 * to_integer(unsigned(freq));
    
    process(clk, current_value)
        begin
        if (rising_edge(clk)) then
            if (en = '1') then
                if cnt >= current_value then
                    clock_toggler <= not clock_toggler;
                    cnt <= 0;
                else
                    cnt <= cnt + 1;
                end if;
            end if;
        end if;
    end process;
clk_out <= clock_toggler;
end behavioral;