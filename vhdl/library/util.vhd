library ieee;
use  ieee.std_logic_1164.all;
use  ieee.std_logic_unsigned.all;

entity clock_divider is
    port (
        clk_in  : IN std_logic;
        divider : IN integer;
        clk_out : OUT std_logic
    );

end clock_divider;


architecture rtl of clock_divider is

    signal clk_count : integer := 0;
    signal clk : std_logic;

begin

    clk_out <= clk;

    process (clk_in)
    begin
      
        if rising_edge(clk_in) then
            if (clk_count >= divider) then
                clk_count <= 0;
                clk <= NOT clk;
            else
                clk_count <= clk_count + 1;
            end if;
        end if;
      
    end process;
 
end rtl;
