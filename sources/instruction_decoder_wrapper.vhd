----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2026 11:57:45 AM
-- Design Name: 
-- Module Name: instruction_decoder_wrapper - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instruction_decoder_wrapper is
    generic (
        INSTRUCTION_LENGTH : natural := 64;
        OPERATION_CODE_LENGTH : natural := 7;
        MEMORY_ADDRESS_LENGTH : natural := 32;
        REGISTER_ADDRESS_LENGTH : natural := 16;
        SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH : natural := 8;
        BIAS_ADDRESS_LENGTH : natural := 8;
        ACCUMULATOR_ADDRESS_LENGTH : natural := 8;
        ACCUMULATOR_MODE_LENGTH : natural := 3;
        RESIZE_MODE_LENGTH : natural := 3
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        instruction_valid : in std_logic;
        instruction_ready : out std_logic;
        instruction : in std_logic_vector(INSTRUCTION_LENGTH - 1 downto 0);
        
        memory_address_valid : out std_logic;
        memory_address_ready : in std_logic;
        memory_address : out std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
        memory_read_write : out std_logic;
        
        register_read_address_valid : out std_logic;
        register_read_address_ready : in std_logic;
        register_read_address : out std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        register_write_address_valid : out std_logic;
        register_write_address_ready : in std_logic;
        register_write_address : out std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        systolic_array_selected_weight_bank_valid : out std_logic;
        systolic_array_selected_weight_bank_ready : in std_logic;
        systolic_array_selected_weight_bank : out std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);
        
        selected_accumulator_bank_write_valid : out std_logic;
        selected_accumulator_bank_write_ready : in std_logic;
        selected_accumulator_bank_write : out std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        accumulator_mode : out std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
        
        selected_accumulator_bank_read_valid : out std_logic;
        selected_accumulator_bank_read_ready : in std_logic;
        selected_accumulator_bank_read : out std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        
        selected_bias_bank_valid : out std_logic;
        selected_bias_bank_ready : in std_logic;
        selected_bias_bank : out std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);
        
        resize_module_mode_valid : out std_logic;
        resize_module_mode_ready : in std_logic;
        resize_module_mode : out std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);
        
        error : out std_logic;
        error_ack: in std_logic
    
    );
end instruction_decoder_wrapper;

architecture Behavioral of instruction_decoder_wrapper is
    signal opcode : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0);
    signal error_handler_opcode_ready : std_logic;
    signal instruction_decoder_instruction_ready : std_logic;
begin

    instruction_ready <= instruction_decoder_instruction_ready and error_handler_opcode_ready;
    opcode <= instruction(INSTRUCTION_LENGTH - 1 downto INSTRUCTION_LENGTH - OPERATION_CODE_LENGTH);

    instruction_decoder_inst : entity work.instruction_decoder
        generic map(
            INSTRUCTION_LENGTH => INSTRUCTION_LENGTH,
            OPERATION_CODE_LENGTH => OPERATION_CODE_LENGTH,
            MEMORY_ADDRESS_LENGTH => MEMORY_ADDRESS_LENGTH,
            REGISTER_ADDRESS_LENGTH => REGISTER_ADDRESS_LENGTH,
            SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH => SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH,
            BIAS_ADDRESS_LENGTH => BIAS_ADDRESS_LENGTH,
            ACCUMULATOR_ADDRESS_LENGTH => ACCUMULATOR_ADDRESS_LENGTH,
            ACCUMULATOR_MODE_LENGTH => ACCUMULATOR_MODE_LENGTH,
            RESIZE_MODE_LENGTH => RESIZE_MODE_LENGTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            instruction_valid => instruction_valid,
            instruction_ready => instruction_decoder_instruction_ready,
            instruction => instruction,
            
            memory_address_valid => memory_address_valid,
            memory_address_ready => memory_address_ready,
            memory_address => memory_address,
            memory_read_write => memory_read_write,
            
            register_read_address_valid => register_read_address_valid,
            register_read_address_ready => register_read_address_ready,
            register_read_address => register_read_address,
            register_write_address_valid => register_write_address_valid,
            register_write_address_ready => register_write_address_ready,
            register_write_address => register_write_address,
            
            systolic_array_selected_weight_bank_valid => systolic_array_selected_weight_bank_valid,
            systolic_array_selected_weight_bank_ready => systolic_array_selected_weight_bank_ready,
            systolic_array_selected_weight_bank => systolic_array_selected_weight_bank,
            
            selected_accumulator_bank_write_valid => selected_accumulator_bank_write_valid,
            selected_accumulator_bank_write_ready => selected_accumulator_bank_write_ready,
            selected_accumulator_bank_write => selected_accumulator_bank_write,
            accumulator_mode => accumulator_mode,
            
            selected_accumulator_bank_read_valid => selected_accumulator_bank_read_valid,
            selected_accumulator_bank_read_ready => selected_accumulator_bank_read_ready,
            selected_accumulator_bank_read => selected_accumulator_bank_read,
            
            selected_bias_bank_valid => selected_bias_bank_valid,
            selected_bias_bank_ready => selected_bias_bank_ready,
            selected_bias_bank => selected_bias_bank,
            
            resize_module_mode_valid => resize_module_mode_valid,
            resize_module_mode_ready => resize_module_mode_ready,
            resize_module_mode => resize_module_mode
        );

        instruction_decoder_error_handler_inst : entity work.instruction_decoder_error_handler
        generic map (
            OPERATION_CODE_LENGTH => OPERATION_CODE_LENGTH
        )
        port map (
            rst => rst,
            
            opcode_valid => instruction_valid,
            opcode_ready => error_handler_opcode_ready,
            opcode => opcode,
            
            error => error,
            error_ack => error_ack
        );

end Behavioral;
