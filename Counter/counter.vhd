library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
port (
clk : in std_logic;
reset : in std_logic;
freq : in std_logic_vector(7 downto 0);
en : in std_logic;
clk_out : out std_logic
);
end counter;

architecture counter_logic of counter is
signal cnt_out : unsigned(19 downto 0) := (others => '0');
signal counter : integer;
signal increment : integer := 327; -- (delta 2 - delta 1) / 255
signal delta_1 : integer := 125000; -- delta 1 constant: ( .5 * ( 1/1500 ) ) / sys_period
signal clock_toggler : std_logic := '0';

begin
    COUNTER : process(clk, reset)
    begin
    if (rising_edge(clk)) then
        if (freq = '1') then
            counter <= (delta_1 + increment * to_integer(unsigned(en))) / 2;
            cnt_out <= cnt_out + 1;
            if (cnt_out = to_unsigned(counter, 20)) then
                clock_toggler <= not(clock_toggler); -- toggle clock output
                cnt_out <= (others => '0');
            end if;
        end if;
    end if;
end process;
clk_out <= clock_toggler;
end counter_logic;