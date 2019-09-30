----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/30/2019 09:46:21 AM
-- Design Name: 
-- Module Name: up_dwn_count_tbench - Behavioral
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

entity up_dwn_count_tbench is
--  Port ( );
end up_dwn_count_tbench;

architecture Behavioral of up_dwn_count_tbench is

component up_dwn_count is
    Port ( clk : in STD_LOGIC;
           UD  : in STD_LOGIC;
           R   : in STD_LOGIC;
           Y   : out std_logic_vector(3 downto 0));
end component;


signal clk : std_logic := '0';
signal UD  : std_logic := '0';
signal R   : std_logic := '0';
signal Y   : std_logic_vector(3 downto 0) := "0000";
signal count : unsigned(7 downto 0) := to_unsigned(0, 8);

begin

uut : up_dwn_count port map(clk => clk, UD => UD, R=> R, Y=> Y);

stim_proc : process
begin
    wait for 4 ns;
    clk <= not clk;
    -- triggers a periodic reset, used for testing
--    count <= count + 1;
--    if count = to_unsigned(101, 8) then
--        R <= '1';
--    end if;
--    if count = to_unsigned(103, 8) then
--        R <= '0';
--    end if;
end process;

end Behavioral;
