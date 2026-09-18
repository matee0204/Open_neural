----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2026 01:18:38 PM
-- Design Name: 
-- Module Name: resize_unit - Behavioral
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
use work.utilities.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity resize_unit is
    generic (
        INPUT_WIDTH : natural := 32;
        OUTPUT_WIDTH : natural := 8
    );
    port (
        clk : in std_logic;
        
        en : in std_logic;
        
        data_in : in std_logic_vector(INPUT_WIDTH - 1 downto 0);
        
        data_out : out std_logic_vector(OUTPUT_WIDTH - 1 downto 0)
    );
end resize_unit;

architecture Saturation of resize_unit is
    signal upper_part_contains_one : std_logic;
    signal upper_part_contains_zero : std_logic;
    signal negative_positive : std_logic;
begin

    process (data_in) begin
        upper_part_contains_one <= or(data_in(INPUT_WIDTH - 1 downto OUTPUT_WIDTH - 1));
        upper_part_contains_zero <= not (and(data_in(INPUT_WIDTH - 1 downto OUTPUT_WIDTH - 1)));
        negative_positive <= data_in(INPUT_WIDTH - 1);
    end process;

    process (clk) begin
        if (rising_edge(clk)) then
            if (en = '1') then
                if (negative_positive = '1') then
                    if (upper_part_contains_zero = '1') then
                        data_out <= (others => '0');
                        data_out(OUTPUT_WIDTH - 1) <= '1';
                    else
                        data_out <= data_in(OUTPUT_WIDTH - 1 downto 0);
                    end if;
                else
                    if (upper_part_contains_one = '1') then
                        data_out <= (others => '1');
                        data_out(OUTPUT_WIDTH - 1) <= '0';
                    else
                        data_out <= data_in(OUTPUT_WIDTH - 1 downto 0);
                    end if;
                end if;
            else
                data_out <= data_out;
            end if;
        end if;
    end process;

end Saturation;


architecture Truncation of resize_unit is
begin

    process (clk) begin
        if (rising_edge(clk)) then
            if (en = '1') then
                data_out <= data_in(OUTPUT_WIDTH - 1 downto 0);
            else
                data_out <= data_out;
            end if;
        end if;
    end process;

end Truncation;