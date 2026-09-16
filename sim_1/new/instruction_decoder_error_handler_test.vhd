----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/27/2026 09:19:56 PM
-- Design Name: 
-- Module Name: instruction_decoder_error_handler_test - Behavioral
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

entity instruction_decoder_error_handler_test is
end instruction_decoder_error_handler_test;

architecture Behavioral of instruction_decoder_error_handler_test is
    constant OPERATION_CODE_LENGTH : natural := 7;
    
    signal rst : std_logic;
        
    signal opcode_valid_inst : std_logic;
    signal opcode_ready_inst : std_logic;
    signal opcode_inst : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0);
    
    signal error_inst : std_logic;
    signal error_ack_inst : std_logic;
begin

    process begin
        wait for 1ns;
        rst <= '0';
        wait for 12ns;
        rst <= '1';
        wait for 1ns;
        rst <= '0';
        wait;
    end process;

    process begin
        wait for 2ns;
        opcode_valid_inst <= '1';
        wait for 2ns;
        opcode_inst <= std_logic_vector(to_unsigned(2, OPERATION_CODE_LENGTH));
        wait for 1ns;
        opcode_inst <= std_logic_vector(to_unsigned(6, OPERATION_CODE_LENGTH));
        wait for 1ns;
        opcode_valid_inst <= '0';
        wait for 6ns;
        opcode_valid_inst <= '1';
        wait for 1ns;
        opcode_valid_inst <= '0';
        wait;
    end process;

    process begin
        wait for 8ns;
        error_ack_inst <= '1';
        wait for 1ns;
        error_ack_inst <= '0';
        wait;
    end process;
    

    tb_instruction_decoder_error_handler : entity work.instruction_decoder_error_handler
        generic map (
            OPERATION_CODE_LENGTH => OPERATION_CODE_LENGTH
        )
        port map (
            rst => rst,
            
            opcode_valid => opcode_valid_inst,
            opcode_ready => opcode_ready_inst,
            
            opcode => opcode_inst,
            error => error_inst,
            error_ack => error_ack_inst
        );

end Behavioral;
