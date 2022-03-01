LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

entity counter is
    port (
        clk     : in std_logic;
        reset   : in std_logic;
        freq    : in std_logic_vector(7 downto 0); -- 255 down to 0 
        en      : in std_logic;                    -- only output clock when enabl is high
        clk_out : out std_logic;
    );
end counter;

architecture counter_logic of counter is
signal max_count : integer range 41667 to 125000;
signal freq_cnt : integer range 0 to 125000;
signal count : integer range 0 to 125000;

begin
freq_cnt <= (255 - to_integer(unsigned(freq, 8))) * 326;

process(clk,reset)
   begin
    if (rising_edge(clk)) then
        if (reset='1') then
            clk_out <= '0';
            max_count <= 41667 + freq_cnt;
        else
            count <= count + 1;
            if count = max_count then
                count <= 0;
                clk_out <= not clk_out;
                max_count <= 41667 + freq_cnt;
            end if;
        end if;
    end if;
    counter <= counter_down;
   end process;

end counter_logic;