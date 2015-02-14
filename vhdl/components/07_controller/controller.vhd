library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library arch;
use arch.types.all;
use arch.model.all;

use work.all;

library util;
use util.all;

entity controller is
    -- Begin port description
    port(
        clock_board : in std_logic;
        --clock : in std_logic;

        -- I/O
        input       : in word_t;
        output      : out word_t;
        input_ready : in std_logic;
        
        -- Reset
        reset       : in std_logic;
        
        -- SPI
        mosi        : out std_logic;
        miso        : in std_logic;
        sclk        : out std_logic;
        cs          : out std_logic;
        
        -- Debugging
        state_cu    : out std_logic_vector(0 to 4);
        state_ld    : out std_logic_vector(0 to 3);
        ld_addr     : out std_logic_vector(0 to 7);
        dready      : out std_logic
    );
    -- End port description
end entity;

architecture rtl of controller is
    
    --
    -- Signals
    --
    
    -- generic
    signal clock                            : std_logic;
    signal clock_source                     : std_logic := '0';
    
    -- io
    signal output_enable                    : std_logic;
    signal output_buffer                    : std_logic_vector(7 downto 0) := "00000000";
    
    -- program_counter
    signal program_counter_load_enable      : std_logic;
    signal program_counter_source_select    : std_logic_vector(1 downto 0);
    signal program_counter_y                : address_t;
    signal program_counter_immediate_in     : address_t;
    
    -- instruction_register
    signal instruction_register_operand     : operand_t;
    signal instruction_register_opcode      : opcode_t;
    signal instruction_register_load_enable : std_logic;
    
    -- memory
    signal memory_reset                     : std_logic;
    signal memory_write_enable              : std_logic;
    signal memory_write_enable_1            : std_logic;
    signal memory_write_enable_2            : std_logic;
    signal memory_data_y                    : word_t;
    signal memory_address_source_select     : std_logic_vector(1 downto 0);
    signal memory_address_source_1          : address_t;
    signal memory_address_source_2          : address_t;
    signal memory_address_source_3          : address_t;
    signal memory_data_source_select        : std_logic;
    
    -- accumulator
    signal accumulator_load_enable          : std_logic;
    signal accumulator_source_select        : std_logic_vector(1 downto 0);
    signal accumulator_flag_pos             : std_logic;
    signal accumulator_flag_zero            : std_logic;
    signal accumulator_y                    : word_t;
    
    -- arithmetic_logic_unit
    signal arithmetic_logic_unit_operation  : std_logic_vector(1 downto 0);
    signal arithmetic_logic_unit_y          : word_t;
    
    -- loader
    signal loader_load                      : std_logic := '0';
    signal loader_ready                     : std_logic;
    signal loader_data                      : word_t;
    
begin

    cd: clock_divider
        port map(
            clock_board,
            1000000, -- 100000
            clock
        );

    control: control_unit
        port map(
            -- External mappings
            clock,
            not reset,
            not input_ready,
            -- Program counter
            program_counter_load_enable,
            program_counter_source_select,
            -- Memory
            memory_address_source_select,
            memory_reset,
            memory_write_enable_1,
            memory_data_source_select,
            -- Arithmetic logic unit
            arithmetic_logic_unit_operation,
            -- Accumulator
            accumulator_flag_pos,
            accumulator_flag_zero,
            accumulator_load_enable,
            accumulator_source_select,
            -- Instruction register
            instruction_register_opcode,
            instruction_register_operand,
            instruction_register_load_enable,
            -- I/O
            output_enable,
            -- Loader
            loader_load,
            loader_ready,
            -- Debug
            state_cu,
            clock_source
        );
        
    -- Compatibility mappings
    -- ---
    -- Address extension for standard commands from 5-Bit to 7-Bit
    program_counter_immediate_in(6 downto 5) <= "00";
    program_counter_immediate_in(4 downto 0) <= instruction_register_operand;
    -- End
    
    pc: program_counter 
        port map(
            clock,
            program_counter_load_enable,
            program_counter_source_select,
            program_counter_immediate_in,
            program_counter_y
        );
        
    ir: instruction_register
        port map(
            clock,
            instruction_register_load_enable,
            memory_data_y,
            instruction_register_opcode,
            instruction_register_operand
        );
        
    alu: arithmetic_logic_unit
        port map(
            arithmetic_logic_unit_operation,
            memory_data_y,
            accumulator_y,
            arithmetic_logic_unit_y
        );
    
    -- Compatibility mappings
    -- ---
    -- Address extension for standard commands from 5-Bit to 7-Bit    
    memory_address_source_1(6 downto 5) <= "00";
    memory_address_source_1(4 downto 0) <= instruction_register_operand;
    
    memory_address_source_2(6 downto 5) <= instruction_register_opcode(1 downto 0);
    memory_address_source_2(4 downto 0) <= instruction_register_operand;
    -- End
    
    memory_write_enable <= memory_write_enable_1 or memory_write_enable_2;

    --ld_addr <= memory_address_source_3;

    ld: loader
        port map(
            clock,
            -- SPI
            mosi,
            miso,
            sclk,
            cs,
            -- Control Unit
            loader_ready,
            loader_load,
            -- Memory
            loader_data,
            memory_address_source_3,
            memory_write_enable_2,
            -- Debug
            state_ld,
            ld_addr,
            dready
        );
        
    mem: memory
        port map(
            clock,
            memory_write_enable,
            memory_reset,
            -- Address
            memory_address_source_select,
            program_counter_y,
            memory_address_source_1,
            memory_address_source_2,
            memory_address_source_3,
            -- Data in
            memory_data_source_select,
            accumulator_y,
            loader_data,
            -- Out
            memory_data_y
        );
        
    acc: accumulator
        port map(
            clock,
            accumulator_load_enable,
            accumulator_source_select,
            arithmetic_logic_unit_y,
            memory_data_y,
            input,
            accumulator_y,
            accumulator_flag_pos,
            accumulator_flag_zero
        );
        
    process(accumulator_y, output_enable)
    begin
        if (output_enable = '1') then
            output_buffer <= accumulator_y;
        end if;
    end process;
    
    output <= output_buffer;
    
end rtl;
    