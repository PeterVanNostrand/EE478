----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/14/2019 09:08:55 AM
-- Design Name: 
-- Module Name: lab4 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity lab4 is
    Port ( clk : in STD_LOGIC;
           start : in STD_LOGIC;
           mclk : out STD_LOGIC;
           bclk : out STD_LOGIC;
           mute : out STD_LOGIC;
           pblrc : out STD_LOGIC;
           pbdat : out STD_LOGIC);
end lab4;

architecture Behavioral of lab4 is
    component ssm2603_i2s
        Port (
            clk    : in  STD_LOGIC;
            r_data : in  STD_LOGIC_VECTOR (23 downto 0);
            l_data : in  STD_LOGIC_VECTOR (23 downto 0);
            bclk   : out STD_LOGIC;
            pbdat  : out STD_LOGIC;
            pblrc  : out STD_LOGIC;
            mclk   : out STD_LOGIC;
            mute   : out STD_LOGIC;
            ready  : out STD_LOGIC
        );
    end component;
    
    signal mclk_sig : std_logic;
    signal l_data, r_data : std_logic_vector(23 downto 0) := (others => '0');
    signal ready : std_logic;
    
    signal clk_count : unsigned(23 downto 0) := to_unsigned(0, 24);
    signal clk_1hz   : std_logic := '0';
    
    signal tone_terminal_count : unsigned (6 downto 0);
    signal tone_counter        : unsigned (6 downto 0);
    
    constant COUNT_C5 : unsigned(6 downto 0) := to_unsigned(92, 7);
    constant COUNT_E5 : unsigned(6 downto 0) := to_unsigned(73, 7);
    constant COUNT_G5 : unsigned(6 downto 0) := to_unsigned(61, 7);
    constant COUNT_C6 : unsigned(6 downto 0) := to_unsigned(46, 7);
    
    type state_type is (IDLE, NOTE1, NOTE2, NOTE3, NOTE4);
    signal state : state_type := IDLE;
begin
    codec : ssm2603_i2s port map(
        clk => clk,
        mclk => mclk_sig,
        bclk => bclk,
        mute => mute,
        pblrc => pblrc,
        pbdat => pbdat,
        l_data => l_data,
        r_data => r_data,
        ready => ready
    );
    mclk <= mclk_sig;

    clk_divide : process(mclk_sig)
    begin
        if rising_edge(mclk_sig) then       
            if clk_count = to_unsigned(12288000, 24) then
                clk_count <= to_unsigned(0, 24); -- reset the clock counter to 0
                clk_1hz <= '1';
            else
                clk_count <= clk_count + 1; -- count the clock ticks
                clk_1hz <= '0';
            end if;
        end if;
    end process;
    
    tone_counter_proc : process(mclk_sig)
    begin
    if rising_edge(mclk_sig) then
        if ready = '1' then
            if tone_counter = tone_terminal_count then
                tone_counter <= to_unsigned(0, 7);
            else
                tone_counter <= tone_counter + 1;
            end if;
        end if;
    end if;
    end process;
    
    l_data <= (others => '0') when tone_counter < (tone_terminal_count / 2) else X"0FFFFF";
    r_data <= (others => '0') when tone_counter < (tone_terminal_count / 2) else X"0FFFFF";
    
    state_proce : process(mclk_sig)
    begin
        if rising_edge(mclk_sig) then
        case state is
            when IDLE =>
                tone_terminal_count <= (others => '0');
                if start = '1' then
                    state <= NOTE1;
                end if;
            when NOTE1 =>
                tone_terminal_count <= COUNT_C5;
                if clk_1hz = '1' then
                    state <= NOTE2;
                end if;
            when NOTE2 =>
                tone_terminal_count <= COUNT_E5;
                if clk_1hz = '1' then
                    state <= NOTE3;
                end if;
            when NOTE3 =>
                tone_terminal_count <= COUNT_G5;
                if clk_1hz = '1' then
                    state <= NOTE4;
                end if;
            when NOTE4 =>
                tone_terminal_count <= COUNT_C6;
                if clk_1hz = '1' then
                    state <= IDLE;
                end if;
            end case;
        end if;
    end process;
end Behavioral;
