----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2019 09:05:16 AM
-- Design Name: 
-- Module Name: alu - Behavioral
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

------------------------------------
-- Select codes for ALU
-- 00001 SUM
-- 00010 ASR
-- 00100 product
-- 01000 XOR
-- 10000 A > B
------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
    Port ( A : in  STD_LOGIC_VECTOR (1 downto 0);
           B : in  STD_LOGIC_VECTOR (1 downto 0);
           S : in  STD_LOGIC_VECTOR (4 downto 0);
           Y : out STD_LOGIC_VECTOR (3 downto 0));
end alu;

architecture Behavioral of alu is

signal A_signed : signed(1 downto 0);
signal B_signed : signed(1 downto 0);
signal A_unsigned : unsigned(1 downto 0);
signal B_unsigned : unsigned(1 downto 0);

signal sum : unsigned(3 downto 0);
signal ASR : signed(3 downto 0);
signal operation : std_logic_vector(3 downto 0);
signal prod : unsigned(3 downto 0);
signal comp : signed(3 downto 0);

begin

A_signed <= signed(A);
B_signed <= signed(B);
A_unsigned <= unsigned(A);
B_unsigned <= unsigned(b);

sum <= "00" & A_unsigned + B_unsigned;
ASR <= "00" & shift_right(A_signed, to_integer(B_unsigned));
operation <= "00" & A XOR B;
comp <= "0001" when A_signed > B_signed else "0000";
prod <= A_unsigned * B_unsigned;

with S select
    Y <= std_logic_vector(sum)  when "00001",
         std_logic_vector(ASR)  when "00010",
         std_logic_vector(prod) when "00100",
         operation when "01000",
         std_logic_vector(comp) when "10000",
         "0000" when others;

end Behavioral;
