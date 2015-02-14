-- Includes for test of entity instruction register
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library arch;
use arch.types.all;
use arch.model.all;

use work.all;

entity ap008 is 
    port(
        clock         : in std_logic;
        load_enable   : in std_logic;
        instruction   : in word_t;
        opcode        : out opcode_t;
        operand       : out operand_t
    );
end entity;

architecture rtl of ap008 is
begin

    ir: instruction_register
        port map(
            clock,
            load_enable,
            instruction,
            opcode,
            operand
        );

end rtl;