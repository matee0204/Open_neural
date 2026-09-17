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

entity memory_read_interface is
    generic (
        READ_ADDRESS_LENGTH : natural := 16;
        WRITE_ADDRESS_LENGTH : natural := 32;
        VECTOR_LENGTH : natural := 8;
        DATA_WIDTH : natural := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        read_address_in_valid : in std_logic;
        read_address_in_ready : out std_logic;
        read_address_in : in std_logic_vector(WRITE_ADDRESS_LENGTH - 1 downto 0);
        
        read_address_out_valid : out std_logic;
        read_address_out_ready : in std_logic;
        read_address_out : out std_logic_vector(WRITE_ADDRESS_LENGTH - 1 downto 0);
        
        write_address_in_valid : in std_logic;
        write_address_in_ready : out std_logic;
        write_address_in : in std_logic_vector(READ_ADDRESS_LENGTH - 1 downto 0);
        
        write_address_out_valid : out std_logic;
        write_address_out_ready : in std_logic;
        write_address_out : out std_logic_vector(READ_ADDRESS_LENGTH - 1 downto 0);
        
        data_in_valid : in std_logic;
        data_in_ready : out std_logic;
        data_in : in data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        data_out_valid : out std_logic;
        data_out_ready : in std_logic;
        data_out : out data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0)
    );
end memory_read_interface;

architecture Behavioral of memory_read_interface is
    signal read_address_d : std_logic_vector(WRITE_ADDRESS_LENGTH - 1 downto 0);
    signal read_address_valid_d : std_logic;
    signal write_address_d: std_logic_vector(READ_ADDRESS_LENGTH - 1 downto 0);
    signal write_address_valid_d : std_logic;
    signal data_valid_d : std_logic;
    signal data_d : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
    signal pipeline_write_en : std_logic;
    signal pipeline_read_en : std_logic;
    signal read_in_progress : std_logic;
begin

    pipeline_write_en <= write_address_out_ready and data_out_ready;
    pipeline_read_en <= read_address_out_ready;
    read_address_in_ready <= pipeline_read_en and not read_in_progress and not rst;
    write_address_in_ready <= pipeline_write_en and not read_in_progress and not rst;
    data_in_ready <= pipeline_write_en and not rst;

    read_address_out <= read_address_d;
    
    process (clk) begin
        if rising_edge(clk) then
            if pipeline_read_en = '1' then
                read_address_d <= read_address_in;
            else
                read_address_d <= read_address_d;
            end if;
        end if;
    end process;

    write_address_out <= write_address_d;
    data_out <= data_d;
    
    process (clk) begin
        if rising_edge(clk) then
            if pipeline_write_en = '1' then
                data_d <= data_in;
                if read_in_progress = '0' then
                    write_address_d <= write_address_in;
                else
                    write_address_d <= write_address_d;
                end if;
            else
                write_address_d <= write_address_d;
                data_d <= data_d;
            end if;
        end if;
    end process;

    read_address_out_valid <= read_address_valid_d;

    process (clk, rst) begin
        if rst = '1' then
            read_address_valid_d <= '0';
        else
            if rising_edge(clk) then
                if pipeline_read_en = '1' then
                    read_address_valid_d <= read_address_in_valid and not read_in_progress;
                else
                    read_address_valid_d <= read_address_valid_d;
                end if;
            end if;
        end if;
    end process;

    data_out_valid <= data_valid_d;
    write_address_out_valid <= data_valid_d and write_address_valid_d;

    process (clk, rst) begin
        if rst = '1' then
            write_address_valid_d <= '0';
            data_valid_d <= '0';
        else
            if rising_edge(clk) then
                if pipeline_write_en = '1' then
                    data_valid_d <= data_in_valid;
                    if read_in_progress = '0' then
                        write_address_valid_d <= write_address_in_valid;
                    else
                        write_address_valid_d <= write_address_valid_d;
                    end if;
                else
                    write_address_valid_d <= write_address_valid_d;
                    data_valid_d <= data_valid_d;
                end if;
            end if;
        end if;
    end process;
    
    process (clk, rst) begin
        if rst = '1' then
            read_in_progress <= '0';
        else
            if rising_edge(clk) then
                if pipeline_write_en = '1' and pipeline_read_en = '1' then
                    if data_in_valid = '1' then
                        read_in_progress <= '0';
                    elsif read_address_in_valid = '1' then
                        read_in_progress <= '1';
                    else
                        read_in_progress <= read_in_progress;
                    end if;
                else
                    read_in_progress <= read_in_progress;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
