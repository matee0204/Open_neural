----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/14/2026 03:49:33 PM
-- Design Name: 
-- Module Name: vector_register_controller - Behavioral
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

entity vector_register_controller is
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        register_read_address_valid : in std_logic;
        register_read_address_ready : out std_logic;
        
        register_read_data_valid : out std_logic;
        register_read_data_ready : in std_logic;
        
        register_write_address_valid : in std_logic;
        register_write_address_ready : out std_logic;
        
        register_write_data_valid : in std_logic;
        register_write_data_ready : out std_logic;
        
        register_write_en : out std_logic
    );
end vector_register_controller;

architecture Behavioral of vector_register_controller is
    signal pipeline_read_en : std_logic;
    signal register_read_valid_d : std_logic;
begin

    pipeline_read_en <= register_read_data_ready;
    register_read_address_ready <= pipeline_read_en;
    register_write_address_ready <= not(register_write_address_valid and not register_write_data_valid);
    register_write_data_ready <= not(not register_write_address_valid and register_write_data_valid);
    
    register_write_en <= register_write_address_valid and register_write_data_valid;
    
    register_read_data_valid <= register_read_valid_d;
    
    process (clk, rst) begin
        if rst = '1' then
            register_read_valid_d <= '0';
        else
            if rising_edge(clk) then
                register_read_valid_d <= register_read_address_valid;
            end if;
        end if;
    end process;

end Behavioral;
