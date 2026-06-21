----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/04/2026 10:33:45 AM
-- Design Name: 
-- Module Name: pipeline_store - Behavioral
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

entity pipeline_store is
    generic (
        REGISTER_ADDRESS_LENGTH : natural := 16;
        MEMORY_ADDRESS_LENGTH : natural := 32;
        VECTOR_LENGTH : natural := 8;
        DATA_WIDTH : natural := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        reg_read_address_in_valid : in std_logic;
        reg_read_address_in_ready : out std_logic;
        reg_read_address_in : in std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        reg_read_address_out_valid : out std_logic;
        reg_read_address_out_ready : in std_logic;
        reg_read_address_out : out std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        reg_data_in_valid : in std_logic;
        reg_data_in_ready : out std_logic;
        reg_data_in : in data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        reg_data_out_valid : out std_logic;
        reg_data_out_ready : in std_logic;
        reg_data_out : out data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        mem_write_address_in_valid : in std_logic;
        mem_write_address_in_ready : out std_logic;
        mem_write_address_in : in std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
        
        mem_write_address_out_valid : out std_logic;
        mem_write_address_out_ready : in std_logic;
        mem_write_address_out : out std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0)
    );
end pipeline_store;

architecture Behavioral of pipeline_store is
    constant MEM_WRITE_DELAY_LENGTH : natural := 3;
    signal pipeline_en : std_logic;
    signal reg_read_address_d : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    signal reg_read_address_valid_d : std_logic;
    signal reg_data_d : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
    signal reg_data_valid_d : std_logic;
    signal mem_write_address_d : data_vector(0 to MEM_WRITE_DELAY_LENGTH - 1)(MEMORY_ADDRESS_LENGTH - 1 downto 0);
    signal mem_write_address_valid_d : std_logic_vector(MEM_WRITE_DELAY_LENGTH - 1 downto 0);
begin
 
    pipeline_en <= mem_write_address_out_ready and reg_data_out_ready and reg_read_address_out_ready;
    reg_read_address_in_ready <= pipeline_en;
    reg_data_in_ready <= pipeline_en;
    mem_write_address_in_ready <= pipeline_en;
    
    reg_read_address_out <= reg_read_address_d;
    reg_data_out <= reg_data_d;
    mem_write_address_out <= mem_write_address_d(MEM_WRITE_DELAY_LENGTH - 1);
    
    process (clk) begin
        if rising_edge(clk) then
            if pipeline_en = '1' then
                reg_read_address_d <= reg_read_address_in;
                reg_data_d <= reg_data_in;
                mem_write_address_d(0) <= mem_write_address_in;
                for i in 1 to MEM_WRITE_DELAY_LENGTH - 1 loop
                    mem_write_address_d(i) <= mem_write_address_d(i - 1);
                end loop;
            else
                reg_read_address_d <= reg_read_address_d;
                reg_data_d <= reg_data_d;
                mem_write_address_d <= mem_write_address_d;
            end if;
        end if;
    end process;
    
    reg_read_address_out_valid <= reg_read_address_valid_d;
    reg_data_out_valid <= reg_data_valid_d;
    mem_write_address_out_valid <= mem_write_address_valid_d(MEM_WRITE_DELAY_LENGTH - 1);
    
    process (clk, rst) begin
        if (rst) then
            reg_read_address_valid_d <= '0';
            reg_data_valid_d <= '0';
            mem_write_address_valid_d <= (others => '0');
        else
            if rising_edge(clk) then
                if pipeline_en = '1' then
                    reg_read_address_valid_d <= reg_read_address_in_valid;
                    reg_data_valid_d <= reg_data_in_valid;
                    mem_write_address_valid_d <= mem_write_address_valid_d(MEM_WRITE_DELAY_LENGTH - 2 downto 0) & mem_write_address_in_valid;
                else
                    reg_read_address_valid_d <= reg_read_address_valid_d;
                    reg_data_valid_d <= reg_data_valid_d;
                    mem_write_address_valid_d <= mem_write_address_valid_d;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
