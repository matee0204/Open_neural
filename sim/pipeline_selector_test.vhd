----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/03/2026 06:58:37 PM
-- Design Name: 
-- Module Name: pipeline_selector_test - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pipeline_selector_test is
end pipeline_selector_test;

architecture Behavioral of pipeline_selector_test is
    constant OPERATION_CODE_LENGTH : natural := 7;
    constant OPERATION_NOP : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(0, OPERATION_CODE_LENGTH));
    constant OPERATION_VECTOR_LOAD : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(1, OPERATION_CODE_LENGTH));
    constant OPERATION_VECTOR_STORE : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(2, OPERATION_CODE_LENGTH));
    constant OPERATION_VECTOR_MOV : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(3, OPERATION_CODE_LENGTH));
    constant OPERATION_VECTOR_MAC : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(4, OPERATION_CODE_LENGTH));
    constant OPERATION_VECTOR_BIAS_QUANT : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(5, OPERATION_CODE_LENGTH));
    
    signal clk : std_logic;
    signal rst : std_logic;
        
    signal sym_cntr : natural := 0;

    signal opcode_in_inst : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0);

    signal pipeline_load_sel_inst : std_logic;
    signal pipeline_store_sel_inst : std_logic;
    signal pipeline_mov_sel_inst : std_logic;
    signal pipeline_mac_sel_inst : std_logic;
    signal pipeline_bias_quant_sel_inst : std_logic;
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
            if sym_cntr = 5 then
                opcode_in_inst <= OPERATION_NOP;
            elsif sym_cntr = 6 then
                opcode_in_inst <= OPERATION_VECTOR_LOAD;
            elsif sym_cntr = 7 then
                opcode_in_inst <= OPERATION_VECTOR_STORE;
            elsif sym_cntr = 8 then
                opcode_in_inst <= OPERATION_VECTOR_MOV;
            elsif sym_cntr = 9 then
                opcode_in_inst <= OPERATION_VECTOR_MAC;
            elsif sym_cntr = 10 then
                opcode_in_inst <= OPERATION_VECTOR_BIAS_QUANT;
            elsif sym_cntr = 11 then
                opcode_in_inst <= (others => '1');
            end if;
        end if;
    end process;

    tb_pipeline_selector : entity work.pipeline_selector
    generic map(
        OPERATION_CODE_LENGTH => OPERATION_CODE_LENGTH
    )
    port map (
        clk => clk,
        rst => rst,
        
        opcode_in => opcode_in_inst,
        
        pipeline_load_sel => pipeline_load_sel_inst,
        pipeline_store_sel => pipeline_store_sel_inst,
        pipeline_mov_sel => pipeline_mov_sel_inst,
        pipeline_mac_sel => pipeline_mac_sel_inst,
        pipeline_bias_quant_sel => pipeline_bias_quant_sel_inst
    );

end Behavioral;
