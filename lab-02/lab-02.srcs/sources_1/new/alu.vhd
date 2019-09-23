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
           S : in  STD_LOGIC_VECTOR (3 downto 0);
           Y : out STD_LOGIC_VECTOR (3 downto 0));
end alu;

architecture Behavioral of alu is

signal A_signed        : signed(1 downto 0);
signal B_signed        : signed(1 downto 0);
signal A_signed_sum    : signed(3 downto 0);
signal B_signed_sum    : signed(3 downto 0);
signal A_unsigned      : unsigned(1 downto 0);
signal B_unsigned      : unsigned(1 downto 0);

signal sum : signed(3 downto 0);
signal ASR : std_logic_vector(3 downto 0);
signal operation : std_logic_vector(3 downto 0);
signal prod : unsigned(3 downto 0);
signal comp : signed(3 downto 0);

begin

A_signed <= signed(A);
B_signed <= signed(B);

A_signed_sum <= to_signed(to_integer(A_signed), 4);
B_signed_sum <= to_signed(to_integer(B_signed), 4);

A_unsigned <= unsigned(A);
B_unsigned <= unsigned(b);

sum <= A_signed_sum + B_signed_sum;
ASR <= "00" & A when B="00" else "00" & A(1) & A(1);
operation <= "00" & (A XOR B);
comp <= "0001" when A_unsigned > B_unsigned else "0000";
prod <= A_unsigned * B_unsigned;

with S select
    Y <= std_logic_vector(sum)  when "0001",
         ASR                    when "0010",
         std_logic_vector(prod) when "0100",
         operation              when "1000",
         std_logic_vector(comp) when "0000",
         "0000"                 when others;

end Behavioral;
