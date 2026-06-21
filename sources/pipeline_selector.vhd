----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/03/2026 06:29:40 PM
-- Design Name: 
-- Module Name: pipeline_selector - Behavioral
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

entity pipeline_selector is
    generic (
        OPERATION_CODE_LENGTH : natural := 7
    );
    port (
        opcode_in : in std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0);
        
        pipeline_load_sel : out std_logic;
        pipeline_store_sel : out std_logic;
        pipeline_mov_sel : out std_logic;
        pipeline_mac_sel : out std_logic;
        pipeline_bias_quant_sel : out std_logic
    );
end pipeline_selector;

architecture Behavioral of pipeline_selector is
    constant NUM_OF_PIPELINES : natural := 5;
    constant OPERATION_NOP : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(0, OPERATION_CODE_LENGTH));
    constant OPERATION_VECTOR_LOAD : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(1, OPERATION_CODE_LENGTH));
    constant OPERATION_VECTOR_STORE : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(2, OPERATION_CODE_LENGTH));
    constant OPERATION_VECTOR_MOV : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(3, OPERATION_CODE_LENGTH));
    constant OPERATION_VECTOR_MAC : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(4, OPERATION_CODE_LENGTH));
    constant OPERATION_VECTOR_BIAS_QUANT : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(5, OPERATION_CODE_LENGTH));
    
    signal pipeline_selector_mux : std_logic_vector(NUM_OF_PIPELINES - 1 downto 0);
begin

    pipeline_load_sel <= pipeline_selector_mux(0);
    pipeline_store_sel <= pipeline_selector_mux(1);
    pipeline_mov_sel <= pipeline_selector_mux(2);
    pipeline_mac_sel <= pipeline_selector_mux(3);
    pipeline_bias_quant_sel <= pipeline_selector_mux(4);
    
    process (opcode_in) begin
        pipeline_selector_mux <= (others => '0');
        case (opcode_in) is
            when OPERATION_NOP => pipeline_selector_mux <= (others => '0'); -- Just for clarity reasons
            when OPERATION_VECTOR_LOAD => pipeline_selector_mux(0) <= '1';
            when OPERATION_VECTOR_STORE => pipeline_selector_mux(1) <= '1';
            when OPERATION_VECTOR_MOV => pipeline_selector_mux(2) <= '1';
            when OPERATION_VECTOR_MAC => pipeline_selector_mux(3) <= '1';
            when OPERATION_VECTOR_BIAS_QUANT => pipeline_selector_mux(4) <= '1';
            when others => pipeline_selector_mux <= (others => '0');
        end case;
    end process;

end Behavioral;
