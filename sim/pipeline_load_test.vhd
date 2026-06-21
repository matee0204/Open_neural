----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/25/2026 07:59:22 PM
-- Design Name: 
-- Module Name: pipeline_load_test - Behavioral
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

entity pipeline_load_test is
end pipeline_load_test;

architecture Behavioral of pipeline_load_test is
    constant REGISTER_ADDRESS_LENGTH : natural := 16;
    constant MEMORY_ADDRESS_LENGTH : natural := 32;
    constant VECTOR_LENGTH : natural := 8;
    constant DATA_WIDTH : natural := 8;
    
    signal clk : std_logic;
    signal rst : std_logic;
        
    signal sym_cntr : natural := 0;

    signal en_inst : std_logic;

    signal pipeline_en_out_inst : std_logic;

    signal mem_read_address_in_valid_inst : std_logic;
    signal mem_read_address_in_ready_inst : std_logic;
    signal mem_read_address_in_inst : std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);

    signal mem_read_address_out_valid_inst : std_logic;
    signal mem_read_address_out_ready_inst : std_logic;
    signal mem_read_address_out_inst : std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);

    signal mem_data_in_valid_inst : std_logic;
    signal mem_data_in_ready_inst : std_logic;
    signal mem_data_in_inst : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);

    signal reg_write_address_in_valid_inst : std_logic;
    signal reg_write_address_in_ready_inst : std_logic;
    signal reg_write_address_in_inst : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);

    signal reg_write_address_out_valid_inst : std_logic;
    signal reg_write_address_out_ready_inst : std_logic;
    signal reg_write_address_out_inst : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);

    signal reg_data_out_valid_inst : std_logic;
    signal reg_data_out_ready_inst : std_logic;
    signal reg_data_out_inst : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
begin

    process begin
        clk <= '0';
        wait for 1ns;
        clk <= '1';
        wait for 1ns;
    end process;
    
    process begin
        rst <= '1';
        wait for 10ns;
        rst <= '0';
        wait;
    end process;
    
    process (clk) begin
        if rising_edge(clk) and sym_cntr < natural'high then
            sym_cntr <= sym_cntr + 1;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 4 then
                mem_read_address_in_valid_inst <= '0';
                mem_data_in_valid_inst <= '0';
                reg_write_address_in_valid_inst <= '0';
            elsif sym_cntr = 5 then
                mem_read_address_in_valid_inst <= '1';
                reg_write_address_in_valid_inst <= '1';
            elsif sym_cntr = 8 then
                mem_data_in_valid_inst <= '1';
            elsif sym_cntr = 9 then
                mem_data_in_valid_inst <= '0';
            elsif sym_cntr = 10 then
                mem_read_address_in_valid_inst <= '0';
                reg_write_address_in_valid_inst <= '0';
            elsif sym_cntr = 12 then
                mem_data_in_valid_inst <= '1';
            elsif sym_cntr = 13 then
                mem_data_in_valid_inst <= '0';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 3 then
                mem_read_address_out_ready_inst <= '0';
                reg_write_address_out_ready_inst <= '0';
                reg_data_out_ready_inst <= '0';
            elsif sym_cntr = 4 then
                mem_read_address_out_ready_inst <= '1';
                reg_write_address_out_ready_inst <= '1';
                reg_data_out_ready_inst <= '1';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                mem_read_address_in_inst <= std_logic_vector(to_unsigned(1, mem_read_address_in_inst'length));
                mem_data_in_inst <= (others => (others => '0'));
                reg_write_address_in_inst <= std_logic_vector(to_unsigned(2, reg_write_address_in_inst'length));
            elsif sym_cntr = 6 then
                mem_read_address_in_inst <= std_logic_vector(to_unsigned(2, mem_read_address_in_inst'length));
                reg_write_address_in_inst <= std_logic_vector(to_unsigned(3, reg_write_address_in_inst'length));
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 4 then
                en_inst <= '0';
            elsif sym_cntr = 5 then
                en_inst <= '1';
            elsif sym_cntr = 10 then
                en_inst <= '0';
            end if;
        end if;
    end process;


    tb_pipeline_load : entity work.pipeline_load
        generic map (
            REGISTER_ADDRESS_LENGTH => REGISTER_ADDRESS_LENGTH,
            MEMORY_ADDRESS_LENGTH => MEMORY_ADDRESS_LENGTH,
            VECTOR_LENGTH => VECTOR_LENGTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            en => en_inst,
            
            pipeline_en_out => pipeline_en_out_inst,
            
            mem_read_address_in_valid => mem_read_address_in_valid_inst,
            mem_read_address_in_ready => mem_read_address_in_ready_inst,
            mem_read_address_in => mem_read_address_in_inst,
            
            mem_read_address_out_valid => mem_read_address_out_valid_inst,
            mem_read_address_out_ready => mem_read_address_out_ready_inst,
            mem_read_address_out => mem_read_address_out_inst,
            
            mem_data_in_valid => mem_data_in_valid_inst,
            mem_data_in_ready => mem_data_in_ready_inst,
            mem_data_in => mem_data_in_inst,
            
            reg_write_address_in_valid => reg_write_address_in_valid_inst,
            reg_write_address_in_ready => reg_write_address_in_ready_inst,
            reg_write_address_in => reg_write_address_in_inst,
            
            reg_write_address_out_valid => reg_write_address_out_valid_inst,
            reg_write_address_out_ready => reg_write_address_out_ready_inst,
            reg_write_address_out => reg_write_address_out_inst,
            
            reg_data_out_valid => reg_data_out_valid_inst,
            reg_data_out_ready => reg_data_out_ready_inst,
            reg_data_out => reg_data_out_inst
        );

end Behavioral;
