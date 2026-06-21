----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/28/2026 04:03:58 PM
-- Design Name: 
-- Module Name: pipeline_mov_test - Behavioral
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

entity pipeline_mov_test is
end pipeline_mov_test;

architecture Behavioral of pipeline_mov_test is
    constant READ_ADDRESS_LENGTH : natural := 16;
    constant WRITE_ADDRESS_LENGTH : natural := 16;
    constant VECTOR_LENGTH : natural := 8;
    constant DATA_WIDTH : natural := 8;
    
    signal clk : std_logic;
    signal rst : std_logic;
        
    signal sym_cntr : natural := 0;

    signal en_inst : std_logic;

    signal pipeline_en_out_inst : std_logic;

    signal write_address_in_valid_inst : std_logic;
    signal write_address_in_ready_inst : std_logic;
    signal write_address_in_inst : std_logic_vector(WRITE_ADDRESS_LENGTH - 1 downto 0);

    signal read_data_in_valid_inst : std_logic;
    signal read_data_in_ready_inst : std_logic;
    signal read_data_in_inst : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);

    signal write_address_out_valid_inst : std_logic;
    signal write_address_out_ready_inst : std_logic;
    signal write_address_out_inst : std_logic_vector(WRITE_ADDRESS_LENGTH - 1 downto 0);

    signal write_data_out_valid_inst : std_logic;
    signal write_data_out_ready_inst : std_logic;
    signal write_data_out_inst : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
    
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
                write_address_in_valid_inst <= '0';
                read_data_in_valid_inst <= '0';
            elsif sym_cntr = 5 then
                read_data_in_valid_inst <= '1';
            elsif sym_cntr = 6 then
                read_data_in_valid_inst <= '0';
                write_address_in_valid_inst <= '1';
            elsif sym_cntr = 7 then
                write_address_in_valid_inst <= '0';
            elsif sym_cntr = 11 then
                read_data_in_valid_inst <= '1';
            elsif sym_cntr = 12 then
                read_data_in_valid_inst <= '0';
                write_address_in_valid_inst <= '1';
            elsif sym_cntr = 13 then
                write_address_in_valid_inst <= '0';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                write_address_out_ready_inst <= '1';
                write_data_out_ready_inst <= '1';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                write_address_in_inst <= std_logic_vector(to_unsigned(1, write_address_in_inst'length));
                read_data_in_inst <= (others => (others => '0'));
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

    tb_pipeline_mov : entity work.pipeline_mov
        generic map (
            WRITE_ADDRESS_LENGTH => WRITE_ADDRESS_LENGTH,
            VECTOR_LENGTH => VECTOR_LENGTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            en => en_inst,
            
            pipeline_en_out => pipeline_en_out_inst,
            
            write_address_in_valid => write_address_in_valid_inst,
            write_address_in_ready => write_address_in_ready_inst,
            write_address_in => write_address_in_inst,
            
            read_data_in_valid => read_data_in_valid_inst,
            read_data_in_ready => read_data_in_ready_inst,
            read_data_in => read_data_in_inst,
            
            write_address_out_valid => write_address_out_valid_inst,
            write_address_out_ready => write_address_out_ready_inst,
            write_address_out => write_address_out_inst,
            
            write_data_out_valid => write_data_out_valid_inst,
            write_data_out_ready => write_data_out_ready_inst,
            write_data_out => write_data_out_inst
        );

end Behavioral;
