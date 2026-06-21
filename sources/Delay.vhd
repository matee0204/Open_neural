----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/30/2025 09:15:54 PM
-- Design Name: 
-- Module Name: Delay - Behavioral
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

entity Delay is
    generic (
        WIDTH : natural := 8;
        DELAY : natural := 1
    );
    port (
        clk : in std_logic;
        
        en : in std_logic;
        
        data_in : in std_logic_vector(WIDTH - 1 downto 0);
        
        data_out : out std_logic_vector(WIDTH - 1 downto 0)
     );
end Delay;

architecture Behavioral of Delay is
    type delay_array_type is array(0 to DELAY - 1) of std_logic_vector(WIDTH - 1 downto 0);
    signal delay_array : delay_array_type;
begin

    process (clk) begin
        if rising_edge(clk) then
            if en = '1' then
                delay_array(0) <= data_in;
                for i in 1 to DELAY - 1 loop
                    delay_array(i) <= delay_array(i - 1);
                end loop;
            else
                for i in 0 to DELAY - 1 loop
                    delay_array(i) <= delay_array(i);
                end loop;
            end if;
        end if;
    end process;
    
    data_out <= delay_array(DELAY - 1);

end Behavioral;
