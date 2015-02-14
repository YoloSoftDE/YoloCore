library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

library arch;
use arch.types.all;

entity loader is
    port (
        clk_in          : in std_logic;

        -- SPI
        mosi            : out std_logic;
        miso            : in std_logic;
        sclk            : out std_logic;
        cs              : out std_logic;

        --heartbeat       : out std_logic;

        --btn_next        : in std_logic;

        --led_wait        : out std_logic;
        --led_waitstate   : out std_logic;
        --led_nextbtn     : out std_logic;
        ready           : out std_logic;
        reset           : in std_logic;

        data            : out word_t;
        addr            : buffer address_t;
        next_data       : out std_logic;
        -- Dbg
        state_out       : out std_logic_vector(0 to 3);
        bytes_read      : out std_logic_vector(0 to 7);
        dready          : out std_logic
        
        --HEX0            : out std_logic_vector(0 to 6)
        --HEX1            : out std_logic_vector(0 to 6)
    );
end loader;

architecture rtl of loader is
    signal sig_clk : std_logic;
    signal sig_mosi : std_logic;
    signal sig_miso : std_logic;
    signal sig_cs : std_logic;
    signal sig_sclk: std_logic;

    signal sig_dout : std_logic_vector(7 downto 0);

    signal sig_read : std_logic;
    signal sig_reset: std_logic;

    signal sig_ready : std_logic;

    signal sig_dcont : std_logic;
    signal sig_dready : std_logic;

    constant SEGOFF:std_logic_vector(0 to 6) := "1111111";
    constant SEG0 : std_logic_vector(0 to 6) := "0000001";
    constant SEG1 : std_logic_vector(0 to 6) := "1001111";
    constant SEG2 : std_logic_vector(0 to 6) := "0010010";
    constant SEG3 : std_logic_vector(0 to 6) := "0000110";
    constant SEG4 : std_logic_vector(0 to 6) := "1001100";
    constant SEG5 : std_logic_vector(0 to 6) := "0100100";
    constant SEG6 : std_logic_vector(0 to 6) := "0100000";


    type states is (WAIT_START, RST, BEGIN_READ, READ, INIT, WAIT_READ, WRITE_DATA, WAIT_READ_RELEASE, DONE);
    signal state : states := WAIT_START;
    
    signal state_id : integer;

    signal sig_addr : integer := 0;

begin

    state_out <= std_logic_vector(to_unsigned(state_id, state_out'length));

    sig_clk <= clk_in;
    
    --div : clock_divider port map (clk_in, 31, sig_clk);
    --hb : clock_divider port map (clk_in, 25000000, heartbeat);

    card : sd_controller port map (
        sig_cs, 
        sig_mosi, 
        sig_miso, 
        sig_sclk, 
        sig_read,
        sig_reset,
        data,
        sig_clk,
        sig_ready,
        sig_dready,
        sig_dcont,
        bytes_read
    );
    
    dready <= sig_dready;

    --dbg_mosi <= sig_mosi;
    --dbg_miso <= sig_miso;
    --dbg_clk <= sig_clk;
    --dbg_sclk <= sig_sclk;
    --dbg_cs <= sig_cs;
    --dbg_reset <= sig_reset;
    --dbg_read <= sig_read;
    --dbg_ready <= sig_ready;

    mosi <= sig_mosi;
    sig_miso <= miso;
    sclk <= sig_sclk;
    cs <= sig_cs;

    --led_nextbtn <= not btn_next;


    addr <= std_logic_vector(to_unsigned(sig_addr, addr'length));

    process (sig_clk, reset)
    begin
        if reset = '1' then
            state <= RST;
        elsif rising_edge(sig_clk) then
            case state is
                when WAIT_START =>
                    state_id <= 0;
                    sig_read <= '0';
                    state <= WAIT_START;
                    ready <= '0';

                when RST =>
                    state_id <= 1;

                    sig_reset <= '1';
                    sig_read <= '0';
                    sig_dcont <= '0';
                    state <= INIT;
                    sig_addr <= 0;
                    ready <= '0';
                    next_data <= '0';
                    
                when INIT =>
                    state_id <= 2;

                    sig_reset <= '0';
                    sig_read <= '0';

                    if sig_ready = '1' then
                        state <= BEGIN_READ;
                    else
                        state <= INIT;
                    end if;

                when BEGIN_READ =>
                    state_id <= 3;

                    sig_reset <= '0';
                    sig_read <= '1';

                    state <= READ;
                    

                when READ =>
                    state_id <= 4;
                    
                    sig_read <= '0';

                    sig_dcont <= '1';
                    --led_waitstate <= '0';
                    
                    state<= WAIT_READ;

                when WAIT_READ =>
                    state_id <= 5;
                    sig_read <= '0';

                    --led_waitstate <= '1';

                    sig_dcont <= '0';


                    
                    if (sig_ready = '1') then
                        state <= DONE;
                    else
    
                        if (sig_dready = '1') then
                            state <= WRITE_DATA;
                            next_data <= '1';
                        else
                            state <= WAIT_READ;
                        end if;
                    end if;
                    
              when WRITE_DATA =>
                    sig_read <= '0';
                   state_id <= 6;
                    
                   state <= WAIT_READ_RELEASE;

              when WAIT_READ_RELEASE =>
                    sig_read <= '0';
                    state_id <= 7;
                    
                    next_data <= '0';

                    --led_waitstate <= '1';

                    sig_addr <= sig_addr + 1;
                    state <= READ;


                when DONE =>
                    state_id <= 8;

                    sig_read <= '0';
                    ready <= '1';
                    state <= DONE;

            end case;


        end if;
    end process;
        
end rtl;
