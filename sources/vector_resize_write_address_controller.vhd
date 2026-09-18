----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/14/2026 07:41:18 PM
-- Design Name: 
-- Module Name: vector_resize_write_address_controller - Behavioral
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

entity vector_resize_write_address_controller is
    generic (
        ADDRESS_WIDTH : natural := 32;
        VECTOR_RESIZE_DELAY : natural := 2
    );
    port (
        clk : in std_logic;

        en : in std_logic;

        write_address_in : in std_logic_vector(ADDRESS_WIDTH - 1 downto 0);

        write_address_out : out std_logic_vector(ADDRESS_WIDTH - 1 downto 0)
    );
end vector_resize_write_address_controller;

architecture Behavioral of vector_resize_write_address_controller is
    signal write_address_delay : data_vector(0 to VECTOR_RESIZE_DELAY - 1)(ADDRESS_WIDTH - 1 downto 0);
begin

    process (clk) begin
        if rising_edge(clk) then
            if en = '1' then
                write_address_delay(0) <= write_address_in;
                for i in 1 to VECTOR_RESIZE_DELAY - 1 loop
                    write_address_delay(i) <= write_address_delay(i - 1);
                end loop;
            else
                write_address_delay <= write_address_delay;
            end if;
        end if;
    end process;

    write_address_out <= write_address_delay(VECTOR_RESIZE_DELAY - 1);

end Behavioral;
