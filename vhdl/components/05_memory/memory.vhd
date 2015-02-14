-- Includes for entity memory
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library arch;
use arch.types.all;
use arch.model.all;

entity memory is
    -- Begin port description
    port (
        -- System clock
        clock            : in std_logic;
        -- When set to '1', the current location pointed to will be written to
        write_enable     : in std_logic;
        -- Reset
        reset            : in std_logic;
        
        -- Address source, '0' - from pc, '1' - from ir operand, '2' - from memory, '3' - init sequence
        source_select    : in std_logic_vector(1 downto 0);
        -- Address inputs
        address_source_0 : in address_t;
        address_source_1 : in address_t;
        address_source_2 : in address_t;
        address_source_3 : in address_t;
        
        -- Data in and out
        data_source_select: in std_logic;
        data_in_0        : in word_t;
        data_in_1        : in word_t;
        data_out         : out word_t
    );
    -- End port description
end entity;

architecture rtl of memory is
    type memory_t is array((2 ** ADDR_WIDTH) - 1 downto 0) of word_t;
    signal ram          : memory_t := (others => "00000000");
    
    signal address      : natural range 0 to (2 ** ADDR_WIDTH) - 1;
    signal address_temp : natural range 0 to (2 ** ADDR_WIDTH) - 1;
    
    signal data_in      : word_t;
begin

    process (source_select, address_source_0, address_source_1, address_source_2, address_source_3)
    begin
        -- Switch between the two sources
        case source_select is
            -- pc
            when "00" => address_temp <= to_integer(unsigned(address_source_0));

            -- ir operand
            when "01" => address_temp <= to_integer(unsigned(address_source_1));

            -- memory
            when "10" => address_temp <= to_integer(unsigned(address_source_2));
            
            -- loader
            when "11" => address_temp <= to_integer(unsigned(address_source_3));
            
        end case;
    end process;
    
    -- Multiplexer for data input of memory
    process (data_source_select, data_in_0, data_in_1)
    begin
        case data_source_select is
            when '0' => data_in <= data_in_0;
            
            when '1' => data_in <= data_in_1;
        end case;
    end process;
        
    process(clock)
    begin
        if (rising_edge(clock)) then
            address <= address_temp;
            
            -- Write data?
            if (write_enable = '1') then
                ram(address_temp) <= data_in;
            end if;
            
            if (reset = '1') then
                address <= 0;
                ram(0)  <= "10000000"; -- IN     A
                ram(1)  <= "00111111"; -- STORE  A, 0x1F ( 31)
                ram(2)  <= "11101010"; -- J      0x10    ( 10)
                ram(3)  <= "00011100"; -- LOAD   A, 0x1C ( 28)
                ram(4)  <= "01011101"; -- ADD    A, 0x1D ( 29)
                ram(5)  <= "10000001"; -- OUT    A
                ram(6)  <= "00111100"; -- STORE  A, 0x1C ( 28)
                ram(7)  <= "01111111"; -- SUB    A, 0x1F ( 31)
                ram(8)  <= "10101010"; -- JZ     0x10    ( 10)
                ram(9)  <= "11100011"; -- J      0x03    (  3)
                ram(10) <= "11111111"; -- LOADW  A, 0x7F (127)
                ram(11) <= "01111111"; -- -- extended --
                ram(12) <= "11100100"; -- J      0x04    (  4)
                ram(28) <= "00000000"; -- Variable
                ram(29) <= "00000001"; -- Schrittweite
                ram(31) <= "00000000"; -- Obergrenze
                ram(127)<= "00000100"; -- Untergrenze
            end if;
        end if;
    end process;

    data_out <= ram(address);
    
end rtl;