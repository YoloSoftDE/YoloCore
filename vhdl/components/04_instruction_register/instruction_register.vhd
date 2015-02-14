-- Includes for entity instruction_register
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library arch;
use arch.types.all;
use arch.model.all;

entity instruction_register is
    -- Begin port description
    port (
        -- Controller clock
        clock         : in std_logic;
        -- Enabled the next load cycle when '1' on clock rising edge
        load_enable   : in std_logic;
        -- Word mapped from memory to extract opcode and data from
        instruction   : in word_t;
        
        -- Extracted opcode bits
        opcode        : out opcode_t;
        -- Extracted operand bits
        operand       : out operand_t
    );
    -- End port description
end entity;

architecture rtl of instruction_register is

    attribute keep : boolean;

    signal opcode_keep: opcode_t := "000";
    attribute keep of opcode_keep : signal is true;

    signal operand_keep: operand_t := "00000";
    attribute keep of operand_keep : signal is true;

begin

    opcode  <= opcode_keep;
    operand <= operand_keep;

    process(clock)
    begin
        if (rising_edge(clock)) then
            if (load_enable = '1') then
                opcode_keep  <= instruction(7 downto 5);
                operand_keep <= instruction(4 downto 0);
            end if;
        end if;
    end process;
    
end rtl;