-- Includes for entity program_counter
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library arch;
use arch.types.all;
use arch.model.all;

entity program_counter is
    -- Begin port description
    port (
        -- Controller clock
        clock           : in std_logic;
        -- Enabled the next load cycle when '1' on clock rising edge
        load_enable     : in std_logic;
        -- Source select where to load the new value from (inc, imm or reset)
        source_select   : in std_logic_vector(1 downto 0);
        -- Immediate value as pc source
        source_immediate: in address_t;
        
        -- Current program counter value
        y               : out address_t
    );
    -- End port description
end entity;

architecture rtl of program_counter is

    signal current_value : integer := 0;
    attribute keep : boolean;
    attribute keep of current_value : signal is true;

begin

    y <= std_logic_vector(to_unsigned(current_value, y'length));
    
    
    
    process(clock)
    begin
        if (rising_edge(clock)) then
            -- Load a new pc value?
            if (load_enable = '1') then
                -- Switch between the 3 different "sources"
                case source_select is
                    -- Inrement
                    when "00" => current_value <= current_value + 1;
                    
                    -- Immediate value
                    when "01" => current_value <= to_integer(unsigned(source_immediate));
                    
                    -- Reset to zero
                    when "10" => current_value <= 0;
                    
                    -- This case should normally NEVER happen -> hardfault
                    when others => current_value <= 0;
                end case;
            end if;
        end if;
    end process;
    
end rtl;