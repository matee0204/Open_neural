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
    generic (
        VECTOR_RESIZE_DELAY : natural := 2
    );
    port (
        clk : in std_logic;
        
        rst : in std_logic;
        
        saturation_en : out std_logic;
        
        data_in_valid : in std_logic;
        data_in_ready : out std_logic;

        resize_mode_valid : in std_logic;
        resize_mode_ready : out std_logic;

        write_address_in_valid : in std_logic;
        write_address_in_ready : out std_logic;
        
        data_out_valid: out std_logic;
        data_out_ready : in std_logic;

        write_address_out_valid : out std_logic;
        write_address_out_ready : in std_logic
    );
end vector_resize_controller;

architecture Behavioral of vector_resize_controller is
    signal data_in_valid_delay : std_logic_vector(VECTOR_RESIZE_DELAY - 1 downto 0);
    signal write_address_in_valid_delay : std_logic_vector(VECTOR_RESIZE_DELAY - 1 downto 0);
    signal is_there_control_without_data : std_logic;
begin

    saturation_en <= data_out_ready and write_address_out_ready;
    data_in_ready <= saturation_en;
    write_address_in_ready <= saturation_en;
    is_there_control_without_data <= resize_mode_valid and not data_in_valid;
    resize_mode_ready <= not is_there_control_without_data and not rst;
    
    process (clk, rst) begin
        if (rst = '1') then
            data_in_valid_delay <= (others => '0');
            write_address_in_valid_delay <= (others => '0');
        elsif (rising_edge(clk)) then
            data_in_valid_delay <= data_in_valid_delay(data_in_valid_delay'high - 1 downto 0) & data_in_valid;
            write_address_in_valid_delay <= write_address_in_valid_delay(write_address_in_valid_delay'high - 1 downto 0) & write_address_in_valid;
        end if;
    end process;
    
    data_out_valid <= data_in_valid_delay(data_in_valid_delay'high);
    write_address_out_valid <= write_address_in_valid_delay(write_address_in_valid_delay'high);

end Behavioral;
