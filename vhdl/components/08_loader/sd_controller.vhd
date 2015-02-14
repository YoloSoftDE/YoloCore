library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sd_controller is
port (
	cs : out std_logic;
	mosi : out std_logic;
	miso : in std_logic;
	sclk : out std_logic;

	rd : in std_logic;
	reset : in std_logic;
	dout : out std_logic_vector(7 downto 0);
	clk : in std_logic;	-- twice the SPI clk
	ready : out std_logic;

	dready : out std_logic;
	dcontinue : in std_logic;
    --Dbg
    br : out std_logic_vector(0 to 7)
);

end sd_controller;

architecture rtl of sd_controller is
type states is (
-- # INIT START
	RST,
	INIT,							-- Send 80 Clock Cycles with CS=1 for card startup sequence
	CMD_RESET,        -- CMD0  (GO_IDLE as first cmd executes a reset)
	CMD_APP,          -- CMD55 (Next command is application specific) 
	ACMD_GETVOLTAGE,  -- ACMD41 (Identify Operating Voltage of Card)
	POLL_CMD,					-- Repeat ACMD41 while card is busy
	CMD_SETBLKLEN,    -- CMD16 (Set BlockLen in bytes)
	IDLE,							-- wait for read 
-- # INIT DONE
	READ_BLOCK,				-- Request Block
	READ_BLOCK_WAIT,	-- Wait for Block start
	READ_BLOCK_DATA,  -- Receive Data
	READ_BLOCK_CRC,		-- Receive CRC
	SEND_CMD,
	RECEIVE_BYTE_WAIT,
	RECEIVE_BYTE,
	RECEIVE_WAITNEXT  -- Wait for signal to continue with next byte
);


-- one start byte, plus x bytes of data, plus two FF end bytes (CRC)
constant BLOCKLEN : integer := 131; -- (1 + 128 + 2)


signal state, return_state : states := RST;
signal sclk_sig : std_logic := '0';
signal cmd_out : std_logic_vector(55 downto 0);
signal recv_data : std_logic_vector(7 downto 0);
signal address : std_logic_vector(31 downto 0);
signal cmd_mode : std_logic := '1';
signal response_mode : std_logic := '1';
signal data_sig : std_logic_vector(7 downto 0) := x"00";

begin
  
	process(clk,reset)
		variable byte_counter : integer range 0 to BLOCKLEN;
		variable bit_counter : integer range 0 to 160;
	begin

        br <= std_logic_vector(to_unsigned(byte_counter, br'length));
    
		if rising_edge(clk) then
			if (reset='1') then
				state <= RST;
				sclk_sig <= '0';
				ready <= '0';
			else
				case state is
				
				when RST =>
					sclk_sig <= '0';
					cmd_out <= (others => '1');
					address <= x"00000000";
					byte_counter := 0;
					cmd_mode <= '1'; -- 0=data, 1=command
					response_mode <= '1';	-- 0=data, 1=command
					bit_counter := 160;
					cs <= '1';
					dready <= '0';
					state <= INIT;
				
				when INIT =>		-- CS=1, send 80 clocks, CS=0
					if (bit_counter = 0) then
						cs <= '0';
						state <= CMD_RESET;
					else
						bit_counter := bit_counter - 1;
						sclk_sig <= not sclk_sig;
					end if;	
				
				when CMD_RESET =>
					cmd_out <= x"FF400000000095";
					bit_counter := 55;
					return_state <= CMD_APP;
					state <= SEND_CMD;

				when CMD_APP =>
					cmd_out <= x"FF770000000001";	-- 55d OR 40h = 77h
					bit_counter := 55;
					return_state <= ACMD_GETVOLTAGE;
					state <= SEND_CMD;
				
				when ACMD_GETVOLTAGE =>
					cmd_out <= x"FF690000000001";	-- 41d OR 40h = 69h
					bit_counter := 55;
					return_state <= POLL_CMD;
					state <= SEND_CMD;
				
				when CMD_SETBLKLEN =>
					cmd_out <= x"FF" & x"50" & std_logic_vector(to_unsigned(BLOCKLEN, 32)) & x"01";
					bit_counter := 55;
					return_state <= IDLE;
					state <= SEND_CMD;

				when POLL_CMD =>
					-- parse R1(FLAG_BUSY)
					if (recv_data(0) = '0') then
						state <= CMD_SETBLKLEN;
					else
						state <= CMD_APP;
					end if;
        	
				when IDLE => 
					if (rd = '1') then
						state <= READ_BLOCK;
						ready <= '0';
					else
						state <= IDLE;
						ready <= '1';
					end if;
				
				when READ_BLOCK =>
					cmd_out <= x"FF" & x"51" & address & x"FF";
					bit_counter := 55;
					return_state <= READ_BLOCK_WAIT;
					state <= SEND_CMD;
				
				when READ_BLOCK_WAIT =>
					if (sclk_sig='1' and miso='0') then
						--state <= READ_BLOCK_DATA;
						byte_counter := BLOCKLEN;
						bit_counter := 7;
						return_state <= READ_BLOCK_DATA;
						state <= RECEIVE_BYTE;
					end if;
					sclk_sig <= not sclk_sig;

				when READ_BLOCK_DATA =>
					if (byte_counter = 0) then
						bit_counter := 7;
						return_state <= READ_BLOCK_CRC;
						state <= RECEIVE_BYTE;
					else
						byte_counter := byte_counter - 1;
						return_state <= READ_BLOCK_DATA;
						bit_counter := 7;
						--state <= RECEIVE_BYTE;
						state <= RECEIVE_WAITNEXT;
					end if;
			
				when READ_BLOCK_CRC =>
					bit_counter := 7;
					return_state <= IDLE;
					address <= std_logic_vector(unsigned(address) + x"200");
					state <= RECEIVE_BYTE;
        	
				when SEND_CMD =>
					if (sclk_sig = '1') then
						if (bit_counter = 0) then
							state <= RECEIVE_BYTE_WAIT;
						else
							bit_counter := bit_counter - 1;
							cmd_out <= cmd_out(54 downto 0) & '1';
						end if;
					end if;
					sclk_sig <= not sclk_sig;
				
				when RECEIVE_BYTE_WAIT =>
					if (sclk_sig = '1') then
						if (miso = '0') then
							recv_data <= (others => '0');
							if (response_mode='0') then
								bit_counter := 3; -- already read bits 7..4
							else
								bit_counter := 6; -- already read bit 7
							end if;
							state <= RECEIVE_BYTE;
						end if;
					end if;
					sclk_sig <= not sclk_sig;

				when RECEIVE_BYTE =>
					if (sclk_sig = '1') then
						recv_data <= recv_data(6 downto 0) & miso;
						if (bit_counter = 0) then
							state <= return_state;								-- Return to waitnext
							dout <= recv_data(6 downto 0) & miso;
						else
							bit_counter := bit_counter - 1;
						end if;
					end if;
					sclk_sig <= not sclk_sig;


				when RECEIVE_WAITNEXT =>
					if (dcontinue = '1') then
						dready <= '0';
						state <= RECEIVE_BYTE;
					else
						dready <= '1';
						state <= RECEIVE_WAITNEXT;
					end if;
					

				when others => state <= IDLE;
        end case;
      end if;
    end if;
  end process;

  sclk <= sclk_sig;
  mosi <= cmd_out(55) when cmd_mode='1' else data_sig(7);
  
end rtl;


