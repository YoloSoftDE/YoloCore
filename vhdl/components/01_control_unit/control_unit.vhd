-- Includes for entity control_unit
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library arch;
use arch.types.all;
use arch.model.all;

entity control_unit is
    -- Begin port description
    port (
        -- Controller clock
        clock                           : in std_logic;
        
        -- Externals
        reset                           : in std_logic;
        input_ready                     : in std_logic;
        
        -- Program counter
        program_counter_load_enable     : out std_logic;
        program_counter_source_select   : out std_logic_vector(1 downto 0);
        
        -- Memory
        memory_address_source_select    : out std_logic_vector(1 downto 0);
        memory_reset                    : out std_logic;
        memory_write_enable             : out std_logic;
        memory_data_source_select       : out std_logic;
        
        -- Arithmetic logic unit
        arithmetic_logic_unit_operation : out std_logic_vector(1 downto 0);
        
        -- Accumulator
        accumulator_flag_pos            : in std_logic;
        accumulator_flag_zero           : in std_logic;
        accumulator_load_enable         : out std_logic;
        accumulator_source_select       : out std_logic_vector(1 downto 0);
        
        -- Instruction register
        instruction_register_opcode     : in opcode_t;
        instruction_register_operand    : in operand_t;
        instruction_register_load_enable: out std_logic;
        
        -- I/O
        output_enable                   : out std_logic;
        
        -- Loader
        loader_load                     : out std_logic;
        loader_ready                    : in std_logic;
        
        state_out                       : out std_logic_vector(0 to 4);
        clock_source                    : out std_logic
    );
    -- End port description
end entity;

architecture rtl of control_unit is

	type state_type is (sReset,
                        sLoadNextInstruction, sPrepare, sDetermine, sWaitForData, sAdvance,
                        sExtendedLoad, sExtendedSlowDown, sExtendedPrepare, sExtendedDetermine, sExtendedWaitForData,
                        sInstructionLoad, sInstructionStore, 
                        sInstructionLoadWide, sInstructionStoreWide,
                        sInstructionAdd, sInstructionSub, sInstructionNand, 
                        sInstructionIn, sInstructionInReleaseButton, sInstructionOut, 
                        sInstructionJumpOnZero, sInstructionJumpOnPositive, sInstructionJump,
                        sLoadProgram);
	signal state    : state_type := sReset;
    signal state_id : integer;

begin
    
    state_out <= std_logic_vector(to_unsigned(state_id, state_out'length));

    -- State transistions
	process (clock, reset, accumulator_flag_zero, accumulator_flag_pos)
	begin
		if reset = '1' then
            state <= sReset;
		elsif (rising_edge(clock)) then
			case state is                     
				when sReset =>
                    state_id <= 1;
                    state <= sLoadProgram;
                    
                when sLoadProgram =>
                    state_id <= 2;
                    
                    if (loader_ready = '1') then
                        state <= sLoadNextInstruction;
                    else
                        state <= sLoadProgram;
                    end if;
                    
                when sLoadNextInstruction =>
                    state_id <= 3;
                    
                    state <= sPrepare;
                    
                when sPrepare =>
                    state_id <= 4;
                    
                    state <= sDetermine;
                    
                when sDetermine =>
                    state_id <= 5;
                    
                    state <= sWaitForData;
                    
                when sWaitForData =>
                    state_id <= 6;
                    
                
                    case instruction_register_opcode is
                        when "000" =>
                            state <= sInstructionLoad;
                            
                        when "001" =>
                            state <= sInstructionStore;
                            
                        when "010" =>
                            state <= sInstructionAdd;
                            
                        when "011" =>
                            state <= sInstructionSub;
                            
                        when "100" =>
                            
                            case instruction_register_operand is
                                when "00000" =>
                                    state <= sInstructionIn;
                                    
                                when "00001" =>
                                    state <= sInstructionOut;
                                    
                                when others =>
                                    state <= sInstructionNand;
                            end case;
                            
                        when "101" =>
                            state <= sInstructionJumpOnZero;
                            
                        when "110" =>
                            state <= sInstructionJumpOnPositive;
                            
                        when "111" =>
                            case instruction_register_operand is
                                when "11111" =>
                                    state <= sExtendedLoad;
                                
                                when others =>
                                    state <= sInstructionJump;
                            end case;
                    end case;
                
                when sAdvance =>
                    state_id <= 7;
                    
                    state <= sLoadNextInstruction;
                    
                when sExtendedLoad =>
                    state_id <= 8;
                    
                    state <= sExtendedSlowDown;
                    
                when sExtendedSlowDown =>
                    state_id <= 9;
                    
                    state <= sExtendedPrepare;
                    
                when sExtendedPrepare =>
                    state_id <= 10;
                    
                    state <= sExtendedDetermine;
                    
                when sExtendedDetermine =>
                    state_id <= 11;
                    
                    state <= sExtendedWaitForData;
                    
                when sExtendedWaitForData =>
                    state_id <= 12;
                    
                    
                    case instruction_register_opcode(2) is
                        when '0' =>
                            state <= sInstructionLoadWide;
                        
                        when '1' =>
                            state <= sInstructionStoreWide;
                    end case;
                    
                when sInstructionLoad =>
                    state_id <= 13;
                    
                    state <= sAdvance;
                    
                when sInstructionStore =>
                    state_id <= 14;
                    
                    state <= sAdvance;
                    
                when sInstructionLoadWide =>
                    state_id <= 15;
                    
                    state <= sAdvance;
                
                when sInstructionStoreWide =>
                    state_id <= 16;
                    
                    state <= sAdvance;
                    
                when sInstructionAdd =>
                    state_id <= 17;
                    
                    state <= sAdvance;
                    
                when sInstructionSub =>
                    state_id <= 18;
                    
                    state <= sAdvance;
                    
                when sInstructionNand =>
                    state_id <= 19;
                    
                    state <= sAdvance;
                    
                when sInstructionIn =>
                    state_id <= 20;
                    
                    if (input_ready = '1') then
                        state <= sInstructionInReleaseButton;
                    end if;
                    
                when sInstructionInReleaseButton =>
                    state_id <= 21;
                    
                    if (input_ready = '0') then
                        state <= sAdvance;
                    end if;
                    
                when sInstructionOut =>
                    state_id <= 22;
                    
                    state <= sAdvance;
                    
                when sInstructionJumpOnZero =>
                    state_id <= 23;
                    
                    state <= sLoadNextInstruction;
                    
                when sInstructionJumpOnPositive =>
                    state_id <= 24;
                    
                    state <= sLoadNextInstruction;
                    
                when sInstructionJump =>
                    state_id <= 25;
                    
                    state <= sLoadNextInstruction;
                
			end case;
		end if;
	end process;

	-- States
	process (state, accumulator_flag_zero, accumulator_flag_pos)
	begin
		case state is        
			when sReset =>

                clock_source                    <= '0';
                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "11"; -- Address from loader
                memory_reset                    <= '0';  -- TODO: remove!
                memory_write_enable             <= '0';  -- Needs to be zero (loader is using it)
                memory_data_source_select       <= '1';  -- Data from loader
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0';
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '1'; -- LOAD!!!!
                
            when sLoadProgram =>

                -- Program counter
                program_counter_load_enable     <= '1'; -- Reset program counter
                program_counter_source_select   <= "10";-- to zero
                -- Memory
                memory_address_source_select    <= "11"; -- Address from loader
                memory_reset                    <= '0';
                memory_write_enable             <= '0';  -- Needs to be zero (loader is using it)
                memory_data_source_select       <= '1';  -- Data from loader
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0';
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                

            when sLoadNextInstruction =>

                clock_source                    <= '1';
                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "00"; -- Memory needs to load the data behind the current program counter address
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0';
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                
            when sPrepare =>

                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "00";
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0';
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '1'; -- Make the instruction register load the new instruction
                -- I/O
                output_enable                   <= '0'; 
                -- Loader
                loader_load                     <= '0';
                
            when sDetermine =>

                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "01"; -- Let the memory (pre)load the data behind the address shipped with the instructions operand
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0';
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                
            when sWaitForData =>

                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "01";
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0'; 
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                
            when sExtendedLoad =>

                -- Program counter
                program_counter_load_enable     <= '1';  -- Increase program counter
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "00"; -- Memory needs to load the data behind the current program counter address
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0';
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                
            when sExtendedSlowDown =>

                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "00";
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0';
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '1'; -- Make the instruction register load the new instruction
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                
            when sExtendedPrepare =>

                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "00";
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0';
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '1'; -- Make the instruction register load the new instruction
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                
            when sExtendedDetermine =>

                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "10"; -- Let the memory (pre)load the data behind the address shipped with the instructions operand
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0';
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                
            when sExtendedWaitForData =>

                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "10";
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0'; 
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                
            when sInstructionLoad =>

                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "01"; -- Keep the source select set to ir
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '1'; -- Make the accumulator load 
                accumulator_source_select       <= "01";-- from the Memory output
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                
            when sInstructionLoadWide =>

                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "10"; -- Keep the source select set to the memory (7 bit address)
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '1'; -- Make the accumulator load 
                accumulator_source_select       <= "01";-- from the Memory output
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
            
            when sInstructionStore =>

                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "01"; -- Keep the source select set to ir
                memory_reset                    <= '0';
                memory_write_enable             <= '1'; -- Let the memory load the data from the accumulator output
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0';
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                
            when sInstructionStoreWide =>

                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "10"; -- Keep the source select set to the memory (7 bit address part)
                memory_reset                    <= '0';
                memory_write_enable             <= '1'; -- Let the memory load the data from the accumulator output
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0';
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                
            when sInstructionAdd =>

                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "01"; -- Keep the source select set to ir
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";-- Add operation
                -- Accumulator
                accumulator_load_enable         <= '1'; -- Make the accumulator load
                accumulator_source_select       <= "00";-- the alu result
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                
            when sInstructionSub =>

                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "01"; -- Keep the source select set to ir
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "01";-- Sub operation
                -- Accumulator
                accumulator_load_enable         <= '1'; -- Make the accumulator load
                accumulator_source_select       <= "00";-- the alu result
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                
            when sInstructionNand =>

                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "01"; -- Keep the source select set to ir
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "10";-- Nand operation
                -- Accumulator
                accumulator_load_enable         <= '1'; -- Make the accumulator load
                accumulator_source_select       <= "00";-- the alu result
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                
            when sInstructionIn =>

                clock_source                    <= '0';
                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "00";
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '1'; -- Make the accumulator load
                accumulator_source_select       <= "10";-- the input 
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                
            when sInstructionInReleaseButton =>

                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "00";
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                instruction_register_load_enable<= '0';
                accumulator_load_enable         <= '0';
                accumulator_source_select       <= "00";
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                
            when sInstructionOut =>

                -- Program counter
                program_counter_load_enable     <= '0';
                program_counter_source_select   <= "00";
                -- Memory
                memory_address_source_select    <= "00";
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0'; 
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '1'; -- Enable output display
                -- Loader
                loader_load                     <= '0';
                
            when sInstructionJumpOnZero =>

                -- Program counter
                if (accumulator_flag_zero = '1') then
                    program_counter_load_enable     <= '1';
                    program_counter_source_select   <= "01";
                else
                    program_counter_load_enable     <= '1';
                    program_counter_source_select   <= "00";
                end if;
                -- Memory
                memory_address_source_select    <= "00";
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0'; 
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
                
            when sInstructionJumpOnPositive =>

                -- Program counter
                if (accumulator_flag_pos = '1') then
                    program_counter_load_enable     <= '1';
                    program_counter_source_select   <= "01";
                else
                    program_counter_load_enable     <= '1';
                    program_counter_source_select   <= "00";
                end if;
                -- Memory
                memory_address_source_select    <= "00";
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0'; 
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';

            when sInstructionJump =>

                -- Program counter
                program_counter_load_enable     <= '1';  -- Tell the program counter to load
                program_counter_source_select   <= "01"; -- the value provided by the instruction register (opcode)
                -- Memory
                memory_address_source_select    <= "00";
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0'; 
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
            
            when sAdvance =>
            
                -- Program counter
                program_counter_load_enable     <= '1';  -- Tell the program counter  
                program_counter_source_select   <= "00"; -- to increment by one
                -- Memory
                memory_address_source_select    <= "00";
                memory_reset                    <= '0';
                memory_write_enable             <= '0';
                memory_data_source_select       <= '0';
                -- Arithmetic logic unit
                arithmetic_logic_unit_operation <= "00";
                -- Accumulator
                accumulator_load_enable         <= '0'; 
                accumulator_source_select       <= "00";
                instruction_register_load_enable<= '0';
                -- I/O
                output_enable                   <= '0';
                -- Loader
                loader_load                     <= '0';
            
		end case;
	end process;
end rtl;