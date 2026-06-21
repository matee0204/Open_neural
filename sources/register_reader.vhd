----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/26/2026 12:54:49 PM
-- Design Name: 
-- Module Name: register_reader - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_reader is
    generic (
        REGISTER_ADDRESS_LENGTH : natural := 16;
        VECTOR_LENGTH : natural := 8;
        DATA_WIDTH : natural := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        register_address_in_valid : in std_logic;
        register_address_in_ready : out std_logic;
        register_address_in : in std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        register_address_out_valid : out std_logic;
        register_address_out_ready : in std_logic;
        register_address_out : out std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        register_data_in_valid : in std_logic;
        register_data_in_ready : out std_logic;
        register_data_in : in data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        register_data_out_valid : out std_logic;
        register_data_out_ready : in std_logic;
        register_data_out : out data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0)
    );
end register_reader;

architecture Behavioral of register_reader is
    signal register_address_valid_d : std_logic;
    signal register_address_d : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    signal register_data_valid_d : std_logic;
    signal register_data_d : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
    
    signal pipeline_en : std_logic;
begin

    pipeline_en <= register_address_out_ready and register_data_out_ready; 
    
    register_address_in_ready <= pipeline_en;
    register_data_in_ready <= pipeline_en;

    register_address_out <= register_address_d;
    register_data_out <= register_data_d;

    process (clk) begin
        if rising_edge(clk) then
            if pipeline_en = '1' then
                register_address_d <= register_address_in;
                register_data_d <= register_data_in;
            else
                register_address_d <= register_address_d;
                register_data_d <= register_data_d;
            end if;
        end if;
    end process;

    register_address_out_valid <= register_address_valid_d;
    register_data_out_valid <= register_data_valid_d;

    process (clk, rst) begin
        if rst = '1' then
            register_address_valid_d <= '0';
            register_data_valid_d <= '0';
        else
            if rising_edge(clk) then
                if pipeline_en = '1' then
                    register_address_valid_d <= register_address_in_valid;
                    register_data_valid_d <= register_data_in_valid;
                else
                    register_address_valid_d <= register_address_valid_d;
                    register_data_valid_d <= register_data_valid_d;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
