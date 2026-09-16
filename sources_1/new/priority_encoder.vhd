----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2026 07:11:34 PM
-- Design Name: 
-- Module Name: priority_encoder - Behavioral
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
use work.neural_engine.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity priority_encoder is
    generic (
        WIDTH : natural := 3
    );
    port (
        data_in : in std_logic_vector(WIDTH - 1 downto 0);
        
        data_out : out std_logic_vector(clog2(WIDTH) - 1 downto 0);
        has_one : out std_logic
    );
end priority_encoder;

architecture Behavioral of priority_encoder is
begin

    process(data_in)
    begin
        if data_in = std_logic_vector(to_unsigned(0, data_in'length)) then
            has_one <= '0';
            data_out <= std_logic_vector(to_unsigned(0, data_out'length));
        else
            has_one <= '1';
            for i in WIDTH - 1 downto 0 loop
                if data_in(i) = '1' then
                    data_out <= std_logic_vector(to_unsigned(i, data_out'length));
                    exit;
                end if;
            end loop;
        end if;
    end process;

end Behavioral;
