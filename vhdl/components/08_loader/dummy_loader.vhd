library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

library arch;
use arch.types.all;

entity dummy_loader is
    port (
        clk_in          : in std_logic;

        -- SPI
        mosi            : out std_logic;
        miso            : in std_logic;
        sclk            : out std_logic;
        cs              : out std_logic;
        ready           : out std_logic;
        reset           : in std_logic;

        data            : out word_t;
        addr            : buffer address_t;
        next_data       : out std_logic;
        state_out       : out std_logic_vector(0 to 3)
    );
end dummy_loader;

architecture rtl of dummy_loader is

    type states is (sReset, sTask1, sTask2, sDone);
    signal state : states := sReset;

begin

    mosi        <= '0';
    sclk        <= '0';
    cs          <= '0';
    data        <= "00000000";
    addr        <= "0000000";
    next_data   <= '0';
    state_out   <= "1111";

    process (clk_in, reset)
    begin
        if reset = '1' then
            state <= sReset;
        elsif rising_edge(clk_in) then
            case state is 
                when sReset =>
                    state <= sTask1;
                    
                when sTask1 =>
                    state <= sTask2;
                    
                when sTask2 =>
                    state <= sDone;
                    
                when sDone =>
                    state <= sDone;
            end case;            
        end if;
    end process;
    
    process(state)
    begin
        case state is                
            when sDone =>
                ready <= '1';
            
            when others =>
                ready <= '0';
        end case;
    end process;
        
end rtl;
