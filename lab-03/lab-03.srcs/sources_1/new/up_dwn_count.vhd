----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/30/2019 09:16:39 AM
-- Design Name: 
-- Module Name: up_dwn_count - Behavioral
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

entity up_dwn_count is
    Port ( clk : in STD_LOGIC;
           UD  : in STD_LOGIC;
           R   : in STD_LOGIC;
           Y   : out std_logic_vector(3 downto 0));
end up_dwn_count;

architecture Behavioral of up_dwn_count is

signal clk_count : unsigned(26 downto 0) := to_unsigned(0, 27);
signal counter   : signed(3 downto 0) := "0000";
signal clk_1hz   : std_logic := '0';

begin

clk_divide : process(clk)
begin
    if rising_edge(clk) then
        clk_count <= clk_count + 1; -- count the clock ticks
        
        if clk_count = to_unsigned(62500000, 27) then -- ever7 62,500,000 cycles (125MHz -> 1Hz) (set to 10 for sim w/ tbench)
            clk_count <= to_unsigned(0, 27); -- reset the clock counter to 0
            clk_1hz <= NOT clk_1hz; -- flip the slow clock
        end if;
    end if;
end process;

count_proc : process(clk_1hz, R)
begin
    if rising_edge(clk_1hz) then
        if UD = '1' and counter /= "0111" then -- counting up, not at max value
            counter <= counter + 1;
        elsif UD = '0' and counter /= "1000" then -- counting down, not at min value
            counter <= counter - 1;

        else -- otherwise, do nothing
            counter <= counter + 0;
        end if;
    end if;
    
    if R = '1' then -- override counting logic and set output to 0
        counter <= "0000";
    end if;
end process;

Y <= std_logic_vector(counter);

end Behavioral;
