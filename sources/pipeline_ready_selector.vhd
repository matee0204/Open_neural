----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/10/2026 04:26:31 PM
-- Design Name: 
-- Module Name: pipeline_ready_selector - Behavioral
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

entity pipeline_ready_selector is
    generic (
        PIPELINE_READY_VECTOR_LENGTH : natural := 6;
        OPERATION_CODE_LENGTH : natural := 7
    );
    port (
        opcode_in : in std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0);
        
        pipeline_ready_vector : in std_logic_vector(PIPELINE_READY_VECTOR_LENGTH - 1 downto 0);
        
        pipeline_ready_out : out std_logic
    );
        
end pipeline_ready_selector;

architecture Behavioral of pipeline_ready_selector is
    constant OPERATION_NOP : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(0, OPERATION_CODE_LENGTH));
    constant OPERATION_VECTOR_LOAD : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(1, OPERATION_CODE_LENGTH));
    constant OPERATION_VECTOR_STORE : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(2, OPERATION_CODE_LENGTH));
    constant OPERATION_VECTOR_MOV : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(3, OPERATION_CODE_LENGTH));
    constant OPERATION_VECTOR_MAC : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(4, OPERATION_CODE_LENGTH));
    constant OPERATION_VECTOR_BIAS_QUANT : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(5, OPERATION_CODE_LENGTH));
begin

    process (opcode_in, pipeline_ready_vector) begin
        case (opcode_in) is
            when OPERATION_NOP => pipeline_ready_out <= pipeline_ready_vector(0);
            when OPERATION_VECTOR_LOAD => pipeline_ready_out <= pipeline_ready_vector(1);
            when OPERATION_VECTOR_STORE => pipeline_ready_out <= pipeline_ready_vector(2);
            when OPERATION_VECTOR_MOV => pipeline_ready_out <= pipeline_ready_vector(3);
            when OPERATION_VECTOR_MAC => pipeline_ready_out <= pipeline_ready_vector(4);
            when OPERATION_VECTOR_BIAS_QUANT => pipeline_ready_out <= pipeline_ready_vector(5);
            when others => pipeline_ready_out <= '1';
        end case;
    end process;

end Behavioral;
