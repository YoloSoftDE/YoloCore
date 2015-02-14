-- Includes for test of entity arithmetic logic unit
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library arch;
use arch.types.all;
use arch.model.all;

use work.all;

entity ap006 is 
    port(
        operation : in std_logic_vector(1 downto 0);
        a         : in word_t;
        b         : in word_t;
        y         : out word_t
    );
end entity;

architecture rtl of ap006 is
begin

    alu: arithmetic_logic_unit
        port map(
            operation,
            a,
            b,
            y
        );

end rtl;