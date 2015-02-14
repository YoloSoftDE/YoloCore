--
-- Architecture dependant information library file
--

-- Begin model informations
package model is
    -- Size of an word, also size of the data bus
    constant DATA_WIDTH : natural := 8;
    -- Size of an address in memory, also size of the address bus
    constant ADDR_WIDTH : natural := 7;
end model;
-- End model informations

-- Includes for types package
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library arch;
use arch.model.all;

-- Begin arch type definitions
package types is
    -- Type for a word aka. the data bus
    subtype word_t    is std_logic_vector((DATA_WIDTH-1) downto 0);
    -- Type for the address bus
    subtype address_t is std_logic_vector((ADDR_WIDTH-1) downto 0);
    -- Type for the opcode (3 bits)
    subtype opcode_t  is std_logic_vector(2 downto 0);
    -- Type for the data part of an instruction (equals address_t)
    subtype operand_t is std_logic_vector(4 downto 0);
end types;
-- End arch type definitions