-- Includes for test of entity memory
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library arch;
use arch.types.all;
use arch.model.all;

use work.all;

entity ap012 is 
    port(
        -- System clock
        clock            : in std_logic;
        -- When set to '1', the current location pointed to will be written to
        write_enable     : in std_logic;
        -- Reset
        reset            : in std_logic;
        
        -- Address source, '0' - from pc, '1' - from ir
        source_select    : in std_logic;
        -- Address inputs
        address_source_0 : in address_t;
        address_source_1 : in address_t;
        
        -- Data in and out
        data_in          : in word_t;
        data_out         : out word_t
    );
end entity;

architecture rtl of ap012 is
begin

    mem: memory
        port map(
            clock,
            write_enable,
            reset,
            source_select,
            address_source_0,
            address_source_1,
            data_in,
            data_out
        );

end rtl;