-- Includes for test of entity accumulator
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library arch;
use arch.types.all;
use arch.model.all;

entity ap010 is 
    port(
        clock           : in std_logic;
        load_enable     : in std_logic;
        data            : in word_t;
        y               : out word_t;
        flag_pos        : out std_logic;
        flag_zero       : out std_logic
    );
end entity;

architecture rtl of ap010 is
   
    -- Import of component accumulator (06_accumulator) 
    component accumulator is
        port (
            clock           : in std_logic;
            load_enable     : in std_logic;
            source_select   : in std_logic_vector(1 downto 0);
            data_source_0   : in word_t;
            data_source_1   : in word_t;
            data_source_2   : in word_t;
            y               : out word_t;
            flag_pos        : out std_logic;
            flag_zero       : out std_logic
        );
    end component;
    -- End import accumulator    

begin

    acc: accumulator
        port map(
            clock,
            load_enable,
            "00",
            data,
            "00000000", -- We are not facing the multiplexer is this test
            "00000000",
            y,
            flag_pos,
            flag_zero
        );

end rtl;