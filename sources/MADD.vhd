----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/08/2026 08:36:49 PM
-- Design Name: 
-- Module Name: MADD - Behavioral
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

entity MADD is
    generic (
        INPUT_DATA_WIDTH : natural := 8;
        OUTPUT_DATA_WIDTH : natural := 32
    );
    port (
        clk : in std_logic;
        en : in std_logic;
        
        data_in : in signed(INPUT_DATA_WIDTH - 1 downto 0);
        weight_in : in signed(INPUT_DATA_WIDTH - 1 downto 0);
        partial_result_in : in signed(OUTPUT_DATA_WIDTH - 1 downto 0);
        
        data_out : out signed(OUTPUT_DATA_WIDTH - 1 downto 0)
    );
end MADD;

architecture Behavioral of MADD is
begin

    process (clk) begin
        if rising_edge(clk) then
            if en = '1' then
                data_out <= resize((data_in * weight_in), data_out'length) + partial_result_in;
            else
                data_out <= data_out;
            end if;
        end if;
    end process;

end Behavioral;
