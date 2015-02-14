-- Includes for entity accumulator
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library arch;
use arch.types.all;
use arch.model.all;

entity accumulator is
    -- Begin port description
    port (
        -- System clock
        clock           : in std_logic;
        
        -- Load enable
        load_enable     : in std_logic;
        
        -- Select of the input source for load operations, "00" - source_alu, "01" - source_memory, "10" - source_in
        source_select   : in std_logic_vector(1 downto 0);
        -- Load data sources
        data_source_0   : in word_t;
        data_source_1   : in word_t;
        data_source_2   : in word_t;
        
        -- Current accumulator value
        y               : out word_t;
        -- Flags
        flag_pos        : out std_logic;
        flag_zero       : out std_logic
    );
    -- End port description
end entity;

architecture rtl of accumulator is

    attribute keep : boolean;

    signal current_value : signed((DATA_WIDTH-1) downto 0);
    attribute keep of current_value : signal is true;
    
    signal flag_pos_keep : std_logic;
    attribute keep of flag_pos_keep : signal is true;
    
    signal flag_zero_keep : std_logic;
    attribute keep of flag_zero_keep : signal is true;
    
    signal prefetch_value : signed((DATA_WIDTH-1) downto 0);

begin

    y         <= std_logic_vector(current_value);
    flag_pos  <= flag_pos_keep;
    flag_zero <= flag_zero_keep;
    
    process(source_select, data_source_0, data_source_1, data_source_2)
    begin
        case source_select is
            -- Source ALU
            when "00" => prefetch_value <= signed(data_source_0);
            
            -- Source Memory
            when "01" => prefetch_value <= signed(data_source_1);
            
            -- Source Input
            when "10" => prefetch_value <= signed(data_source_2);
            
            -- This shoudl normally NEVER happen -> hardfault
            when others => prefetch_value <= to_signed(0, prefetch_value'length);
        end case;
    end process;
    
    process(clock)
    begin
        if (rising_edge(clock)) then
            if (load_enable = '1') then
                current_value <= prefetch_value;
            end if;
        end if;
    end process;
    
    process(current_value)
    begin
        if (current_value >= 0) then
            flag_pos_keep <= '1';
        else
            flag_pos_keep <= '0';
        end if;
        
        if (current_value = 0) then
            flag_zero_keep <= '1';
        else
            flag_zero_keep <= '0';
        end if;
    end process;
    
end rtl;