-- Includes for entity arithmetic_logic_unit
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library arch;
use arch.types.all;
use arch.model.all;

entity arithmetic_logic_unit is
    -- Begin port description
    port (
        -- Selected operation to run / calculate
        operation : in std_logic_vector(1 downto 0);
        -- Operands
        a         : in word_t;
        b         : in word_t;
        -- Compution result
        y         : out word_t
    );
    -- End port description
end entity;

architecture rtl of arithmetic_logic_unit is

    signal operand_a : signed((DATA_WIDTH-1) downto 0);
    signal operand_b : signed((DATA_WIDTH-1) downto 0);
    signal result    : signed((DATA_WIDTH-1) downto 0) := "00000000";

begin

    operand_a <= signed(a);
    operand_b <= signed(b);
    y         <= std_logic_vector(result);
    
    process(operand_a, operand_b, operation)
    begin
        -- Select operation to use
        case operation is
            -- Addition
            when "00" => result <= operand_b + operand_a;
            
            -- Subtraction
            when "01" => result <= operand_b - operand_a;
            
            -- Nand
            when "10" => result <= operand_b nand operand_a;
            
            -- Should normally NEVER happen -> hard fault
            when others => result <= to_signed(0, result'length);
        end case;
    end process;
    
end rtl;