----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/21/2026 10:33:52 PM
-- Design Name: 
-- Module Name: instruction_decoder_error_handler - Behavioral
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

entity instruction_decoder_error_handler is
    generic (
        OPERATION_CODE_LENGTH : natural := 7;
        constant NUMBER_OF_VALID_OPCODES : natural := 6
    );
    port (
        rst : in std_logic;
        
        opcode_valid : in std_logic;
        opcode_ready : out std_logic;
        opcode : in std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0);
        
        error : out std_logic;
        error_ack : in std_logic
    );
end instruction_decoder_error_handler;

architecture Behavioral of instruction_decoder_error_handler is
begin

    opcode_ready <= not error and not rst;

    process (rst, opcode_valid, opcode, error_ack) begin
        if (rst) then
            error <= '0';
        else
            if opcode_valid = '1' and opcode >= std_logic_vector(to_unsigned(NUMBER_OF_VALID_OPCODES, opcode'length)) then
                error <= '1';
            elsif error_ack = '1' then
                error <= '0';
            end if;
        end if;
    end process;

end Behavioral;
