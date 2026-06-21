----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2026 05:21:47 PM
-- Design Name: 
-- Module Name: pipeline_load - Behavioral
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

entity pipeline_load is
    generic (
        REGISTER_ADDRESS_LENGTH : natural := 16;
        MEMORY_ADDRESS_LENGTH : natural := 32;
        VECTOR_LENGTH : natural := 8;
        DATA_WIDTH : natural := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        en : in std_logic;
        
        pipeline_en_out : out std_logic;
        
        mem_read_address_in_valid : in std_logic;
        mem_read_address_in_ready : out std_logic;
        mem_read_address_in : in std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
        
        mem_read_address_out_valid : out std_logic;
        mem_read_address_out_ready : in std_logic;
        mem_read_address_out : out std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
        
        mem_data_in_valid : in std_logic;
        mem_data_in_ready : out std_logic;
        mem_data_in : in data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        reg_write_address_in_valid : in std_logic;
        reg_write_address_in_ready : out std_logic;
        reg_write_address_in : in std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        reg_write_address_out_valid : out std_logic;
        reg_write_address_out_ready : in std_logic;
        reg_write_address_out : out std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        reg_data_out_valid : out std_logic;
        reg_data_out_ready : in std_logic;
        reg_data_out : out data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0)
    );
end pipeline_load;

architecture Behavioral of pipeline_load is
    signal mem_read_address_d : std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
    signal mem_read_address_valid_d : std_logic;
    signal reg_write_address_d: std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    signal reg_write_address_valid_d : std_logic;
    signal mem_data_valid_d : std_logic;
    signal mem_data_d : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
    signal pipeline_reg_en : std_logic;
    signal pipeline_mem_en : std_logic;
    signal mem_read_in_progress : std_logic;
begin

    pipeline_reg_en <= reg_write_address_out_ready and reg_data_out_ready;
    pipeline_mem_en <= mem_read_address_out_ready;
    mem_read_address_in_ready <= pipeline_mem_en and not mem_read_in_progress and not rst;
    reg_write_address_in_ready <= pipeline_reg_en and not mem_read_in_progress and not rst;
    mem_data_in_ready <= pipeline_reg_en and not rst;
    pipeline_en_out <= pipeline_reg_en and pipeline_mem_en;

    mem_read_address_out <= mem_read_address_d;
    
    process (clk) begin
        if rising_edge(clk) then
            if pipeline_mem_en = '1' then
                mem_read_address_d <= mem_read_address_in;
            else
                mem_read_address_d <= mem_read_address_d;
            end if;
        end if;
    end process;

    reg_write_address_out <= reg_write_address_d;
    reg_data_out <= mem_data_d;
    
    process (clk) begin
        if rising_edge(clk) then
            if pipeline_reg_en = '1' then
                mem_data_d <= mem_data_in;
                if mem_read_in_progress = '0' then
                    reg_write_address_d <= reg_write_address_in;
                else
                    reg_write_address_d <= reg_write_address_d;
                end if;
            else
                reg_write_address_d <= reg_write_address_d;
                mem_data_d <= mem_data_d;
            end if;
        end if;
    end process;

    mem_read_address_out_valid <= mem_read_address_valid_d;

    process (clk, rst) begin
        if rst = '1' then
            mem_read_address_valid_d <= '0';
        else
            if rising_edge(clk) then
                if pipeline_mem_en = '1' then
                    mem_read_address_valid_d <= mem_read_address_in_valid and en and not mem_read_in_progress;
                else
                    mem_read_address_valid_d <= mem_read_address_valid_d;
                end if;
            end if;
        end if;
    end process;

    reg_data_out_valid <= mem_data_valid_d;
    reg_write_address_out_valid <= mem_data_valid_d and reg_write_address_valid_d;

    process (clk, rst) begin
        if rst = '1' then
            reg_write_address_valid_d <= '0';
            mem_data_valid_d <= '0';
        else
            if rising_edge(clk) then
                if pipeline_reg_en = '1' then
                    mem_data_valid_d <= mem_data_in_valid;
                    if mem_read_in_progress = '0' then
                        reg_write_address_valid_d <= reg_write_address_in_valid and en;
                    else
                        reg_write_address_valid_d <= reg_write_address_valid_d;
                    end if;
                else
                    reg_write_address_valid_d <= reg_write_address_valid_d;
                    mem_data_valid_d <= mem_data_valid_d;
                end if;
            end if;
        end if;
    end process;
    
    process (clk, rst) begin
        if rst = '1' then
            mem_read_in_progress <= '0';
        else
            if rising_edge(clk) then
                if pipeline_reg_en = '1' and pipeline_mem_en = '1' then
                    if mem_data_in_valid = '1' then
                        mem_read_in_progress <= '0';
                    elsif mem_read_address_in_valid = '1' and en = '1' then
                        mem_read_in_progress <= '1';
                    else
                        mem_read_in_progress <= mem_read_in_progress;
                    end if;
                else
                    mem_read_in_progress <= mem_read_in_progress;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
