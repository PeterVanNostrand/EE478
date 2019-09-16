----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2019 10:01:59 AM
-- Design Name: 
-- Module Name: alu_tbench - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu_tbench is
--  Port ( );
end alu_tbench;

architecture Behavioral of alu_tbench is

component alu is
        Port ( A : in  STD_LOGIC_VECTOR (1 downto 0);
               B : in  STD_LOGIC_VECTOR (1 downto 0);
               S : in  STD_LOGIC_VECTOR (4 downto 0);
               Y : out STD_LOGIC_VECTOR (3 downto 0));
end component;

signal A, B : STD_LOGIC_VECTOR (1 downto 0);
signal S : STD_LOGIC_VECTOR(4 downto 0);
signal Y : STD_LOGIC_VECTOR (3 downto 0);
signal expected : STD_LOGIC_VECTOR(3 downto 0);

begin

uut : alu port map(A=>A, B=>B, S=>S, Y=>Y);

stim_proc : process
begin
    -- testing sum
    wait for 200 ns;
        S <= "00001";
        A <= "00";
        B <= "00";
        expected <= "0000";
    wait for 100 ns;
        A <= "11";
        B <= "11";
        expected <= "0110";
    wait for 100 ns;
        A <= "10";
        B <= "01";
        expected <= "0011";
    wait for 100 ns;
        S <= "00000";
        A <= "00";
        B <= "00";
        expected <= "0000";
        
    -- testing ASR
    wait for 200 ns;
        S <= "00010";
        A <= "10";
        B <= "01";
        expected <= "0011";
    wait for 100 ns;
        A <= "01";
        B <= "10";
        expected <= "0000";
    wait for 100 ns;
        A <= "11";
        B <= "00";
        expected <= "0011";
    wait for 100 ns;
        S <= "00000";
        A <= "00";
        B <= "00";
        expected <= "0000";
    
    -- testing multiplicaiton
    wait for 200 ns;
        S <= "00100";
        A <= "00";
        B <= "11";
        expected <= "0000";
    wait for 100 ns;
        A <= "01";
        B <= "01";
        expected <= "0001";
    wait for 100 ns;
        A <= "11";
        B <= "11";
        expected <= "1001";
    wait for 100 ns;
        S <= "00000";
        A <= "00";
        B <= "00";
        expected <= "0000";
        
    -- testing A XOR B
    wait for 200 ns;
        S <= "01000";
        A <= "00";
        B <= "00";
        expected <= "0000";
    wait for 100 ns;
        A <= "10";
        B <= "01";
        expected <= "0011";
    wait for 100 ns;
        A <= "11";
        B <= "10";
        expected <= "0001";
    wait for 100 ns;
        S <= "00000";
        A <= "00";
        B <= "00";
        expected <= "0000";
        
    -- testing A > B
    wait for 200 ns;
        S <= "10000";
        A <= "00";
        B <= "00";
        expected <= "0000";
    wait for 100 ns;
        A <= "01";
        B <= "00";
        expected <= "0001";
    wait for 100 ns;
        A <= "00";
        B <= "10";
        expected <= "0000";
    wait for 100 ns;
        A <= "11";
        B <= "10";
        expected <= "0001";
    wait for 100 ns;
        S <= "00000";
        A <= "00";
        B <= "00";
        expected <= "0000";
    wait;
end process stim_proc;

end Behavioral;
