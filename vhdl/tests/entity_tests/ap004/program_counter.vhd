-- Includes for test of entity program_counter
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library arch;
use arch.types.all;
use arch.model.all;

use work.all;

entity ap004 is 
    port(
        clock           : in std_logic;
        load_enable     : in std_logic;
        source_select   : in std_logic_vector(1 downto 0);
        source_immediate: in address_t;
        y               : out address_t 
    );
end entity;

architecture rtl of ap004 is
begin

    pc: program_counter
        port map(
            clock,
            load_enable,
            source_select,
            source_immediate,
            y
        );

end rtl;