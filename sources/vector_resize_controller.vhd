----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/22/2026 01:42:10 PM
-- Design Name: 
-- Module Name: vector_resize_controller - Behavioral
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

entity vector_resize_controller is
    port (
        clk : in std_logic;
        
        rst : in std_logic;
        
        saturation_en : out std_logic;
        
        data_in_valid : in std_logic;
        data_in_ready : out std_logic;
        
        data_out_valid: out std_logic;
        data_out_ready : in std_logic
    );
end vector_resize_controller;

architecture Behavioral of vector_resize_controller is
    signal data_in_valid_delay : std_logic_vector(1 downto 0);
begin

    saturation_en <= data_out_ready;
    data_in_ready <= data_out_ready;
    
    process (clk, rst) begin
        if (rst = '1') then
            data_in_valid_delay <= (others => '0');
        elsif (rising_edge(clk)) then
            data_in_valid_delay <= data_in_valid_delay(0) & data_in_valid;
        end if;
    end process;
    
    data_out_valid <= data_in_valid_delay(data_in_valid_delay'high);

end Behavioral;
