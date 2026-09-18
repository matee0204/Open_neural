----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2026 09:52:21 PM
-- Design Name: 
-- Module Name: instruction_decoder - Behavioral
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
use work.utilities.all;
use work.common_constants.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instruction_decoder is
    generic (
        INSTRUCTION_LENGTH : natural := 64;
        OPERATION_CODE_LENGTH : natural := 7;
        MEMORY_ADDRESS_LENGTH : natural := 32;
        REGISTER_ADDRESS_LENGTH : natural := 16;
        SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH : natural := 8;
        BIAS_ADDRESS_LENGTH : natural := 8;
        ACCUMULATOR_ADDRESS_LENGTH : natural := 8;
        ACCUMULATOR_MODE_LENGTH : natural := 3;
        RESIZE_MODE_LENGTH : natural := 3;
        SYS_ARRAY_INPUT_BASE_ADDRESS : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        MEM_INTERFACE_INPUT_BASE_ADDRESS : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0)
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        instruction_valid : in std_logic;
        instruction_ready : out std_logic;
        instruction : in std_logic_vector(INSTRUCTION_LENGTH - 1 downto 0);
        
        opcode_valid : out std_logic;
        opcode_ready : in std_logic;
        opcode_out : out std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0);

        memory_read_address_valid : out std_logic;
        memory_read_address_ready : in std_logic;
        memory_read_address : out std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);

        memory_write_address_valid : out std_logic;
        memory_write_address_ready : in std_logic;
        memory_write_address : out std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
        
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

        accumulator_mode_valid : out std_logic;
        accumulator_mode_ready : in std_logic;
        accumulator_mode : out std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
        
        selected_accumulator_bank_read_valid : out std_logic;
        selected_accumulator_bank_read_ready : in std_logic;
        selected_accumulator_bank_read : out std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        
        selected_bias_bank_valid : out std_logic;
        selected_bias_bank_ready : in std_logic;
        selected_bias_bank : out std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);
        
        resize_module_mode_valid : out std_logic;
        resize_module_mode_ready : in std_logic;
        resize_module_mode : out std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0)
    );
end instruction_decoder;

architecture Behavioral of instruction_decoder is
    constant PARAMETER_LENGTH : natural := INSTRUCTION_LENGTH - OPERATION_CODE_LENGTH;
    signal opcode : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0);
    signal opcode_natural : natural range 0 to NUMBER_OF_OPERATIONS - 1;
    signal opcode_reg : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0);
    signal opcode_reg_natural : natural range 0 to NUMBER_OF_OPERATIONS - 1;
    signal parameters : std_logic_vector(INSTRUCTION_LENGTH - OPERATION_CODE_LENGTH - 1 downto 0);
    signal pipeline_en : std_logic;
begin

    opcode <= instruction(INSTRUCTION_LENGTH - 1 downto INSTRUCTION_LENGTH - OPERATION_CODE_LENGTH);
    opcode_natural <= to_integer(unsigned(instruction(INSTRUCTION_LENGTH - 1 downto INSTRUCTION_LENGTH - OPERATION_CODE_LENGTH)));
    parameters <= instruction(INSTRUCTION_LENGTH - OPERATION_CODE_LENGTH - 1 downto 0);
    pipeline_en <= instruction_ready;

    process (clk, rst) begin
        if rst = '1' then
            opcode_valid <= '0';
            memory_read_address_valid <= '0';
            memory_write_address_valid <= '0';
            register_read_address_valid <= '0';
            register_write_address_valid <= '0';
            systolic_array_selected_weight_bank_valid <= '0';
            selected_accumulator_bank_write_valid <= '0';
            accumulator_mode_valid <= '0';
            selected_accumulator_bank_read_valid <= '0';
            selected_bias_bank_valid <= '0';
            resize_module_mode_valid <= '0';
        else
            if rising_edge(clk) then
                if pipeline_en = '1' then
                    opcode_valid <= instruction_valid;
                    memory_read_address_valid <= '0';
                    memory_write_address_valid <= '0';
                    register_read_address_valid <= '0';
                    register_write_address_valid <= '0';
                    systolic_array_selected_weight_bank_valid <= '0';
                    selected_accumulator_bank_write_valid <= '0';
                    accumulator_mode_valid <= '0';
                    selected_accumulator_bank_read_valid <= '0';
                    selected_bias_bank_valid <= '0';
                    resize_module_mode_valid <= '0';
                    case opcode_natural is
                        when OPERATION_VECTOR_LOAD =>
                            memory_read_address_valid <= instruction_valid;
                            register_write_address_valid <= instruction_valid;
                        when OPERATION_VECTOR_STORE =>
                            memory_write_address_valid <= instruction_valid;
                            register_read_address_valid <= instruction_valid;
                            register_write_address_valid <= instruction_valid;
                        when OPERATION_VECTOR_MOV =>
                            register_write_address_valid <= instruction_valid;
                            register_read_address_valid <= instruction_valid;
                        when OPERATION_VECTOR_MAC =>
                            register_read_address_valid <= instruction_valid;
                            register_write_address_valid <= instruction_valid;
                            systolic_array_selected_weight_bank_valid <= instruction_valid;
                            selected_accumulator_bank_write_valid <= instruction_valid;
                            accumulator_mode_valid <= instruction_valid;
                        when OPERATION_VECTOR_BIAS_QUANT =>
                            register_write_address_valid <= instruction_valid;
                            selected_accumulator_bank_read_valid <= instruction_valid;
                            selected_bias_bank_valid <= instruction_valid;
                            resize_module_mode_valid <= instruction_valid;
                        when others =>
                            memory_read_address_valid <= '0';
                            memory_write_address_valid <= '0';
                            register_read_address_valid <= '0';
                            register_write_address_valid <= '0';
                            systolic_array_selected_weight_bank_valid <= '0';
                            selected_accumulator_bank_write_valid <= '0';
                            accumulator_mode_valid <= '0';
                            selected_bias_bank_valid <= '0';
                            resize_module_mode_valid <= '0';
                    end case;
                else
                    opcode_valid <= opcode_valid;
                    memory_read_address_valid <= memory_read_address_valid;
                    memory_write_address_valid <= memory_write_address_valid;
                    register_read_address_valid <= register_read_address_valid;
                    register_write_address_valid <= register_write_address_valid;
                    systolic_array_selected_weight_bank_valid <= systolic_array_selected_weight_bank_valid;
                    selected_accumulator_bank_write_valid <= selected_accumulator_bank_write_valid;
                    accumulator_mode_valid <= accumulator_mode_valid;
                    selected_accumulator_bank_read_valid <= selected_accumulator_bank_read_valid;
                    selected_bias_bank_valid <= selected_bias_bank_valid;
                    resize_module_mode_valid <= resize_module_mode_valid;
                end if;
            end if;
        end if;
    end process;
    
    opcode_out <= opcode_reg;
    
    process (clk) begin
        if rising_edge(clk) then
            if pipeline_en = '1' then
                opcode_reg <= opcode;
                memory_read_address <= (others => '0');
                memory_write_address <= (others => '0');
                register_read_address <= (others => '0');
                register_write_address <= (others => '0');
                systolic_array_selected_weight_bank <= (others => '0');
                selected_accumulator_bank_write <= (others => '0');
                selected_accumulator_bank_read <= (others => '0');
                accumulator_mode <= (others => '0');
                selected_bias_bank <= (others => '0');
                resize_module_mode <= (others => '0');
                case opcode_natural is
                    when OPERATION_VECTOR_LOAD =>
                        memory_read_address <= parameters(PARAMETER_LENGTH - 1 downto PARAMETER_LENGTH - MEMORY_ADDRESS_LENGTH);
                        register_write_address <= parameters(PARAMETER_LENGTH - MEMORY_ADDRESS_LENGTH - 1 downto PARAMETER_LENGTH - MEMORY_ADDRESS_LENGTH - REGISTER_ADDRESS_LENGTH);
                    when OPERATION_VECTOR_STORE =>
                        memory_write_address <= parameters(PARAMETER_LENGTH - 1 downto PARAMETER_LENGTH - MEMORY_ADDRESS_LENGTH);
                        register_read_address <= parameters(PARAMETER_LENGTH - MEMORY_ADDRESS_LENGTH - 1 downto PARAMETER_LENGTH - MEMORY_ADDRESS_LENGTH - REGISTER_ADDRESS_LENGTH);
                        register_write_address <= MEM_INTERFACE_INPUT_BASE_ADDRESS;
                    when OPERATION_VECTOR_MOV =>
                        register_read_address <= parameters(PARAMETER_LENGTH - 1 downto PARAMETER_LENGTH - REGISTER_ADDRESS_LENGTH);
                        register_write_address <= parameters(PARAMETER_LENGTH - REGISTER_ADDRESS_LENGTH - 1 downto PARAMETER_LENGTH - REGISTER_ADDRESS_LENGTH - REGISTER_ADDRESS_LENGTH);
                    when OPERATION_VECTOR_MAC =>
                        register_read_address <= parameters(PARAMETER_LENGTH - 1 downto PARAMETER_LENGTH - REGISTER_ADDRESS_LENGTH);
                        register_write_address <= SYS_ARRAY_INPUT_BASE_ADDRESS;
                        selected_accumulator_bank_write <= parameters(PARAMETER_LENGTH - REGISTER_ADDRESS_LENGTH - 1 downto PARAMETER_LENGTH - REGISTER_ADDRESS_LENGTH - ACCUMULATOR_ADDRESS_LENGTH);
                        systolic_array_selected_weight_bank <= parameters(PARAMETER_LENGTH - REGISTER_ADDRESS_LENGTH - ACCUMULATOR_ADDRESS_LENGTH - 1 downto PARAMETER_LENGTH - REGISTER_ADDRESS_LENGTH - ACCUMULATOR_ADDRESS_LENGTH - SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH);
                        accumulator_mode <= parameters(PARAMETER_LENGTH - REGISTER_ADDRESS_LENGTH - ACCUMULATOR_ADDRESS_LENGTH - SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto PARAMETER_LENGTH - REGISTER_ADDRESS_LENGTH - ACCUMULATOR_ADDRESS_LENGTH - SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - ACCUMULATOR_MODE_LENGTH);
                    when OPERATION_VECTOR_BIAS_QUANT =>
                        register_write_address <= parameters(PARAMETER_LENGTH - 1 downto PARAMETER_LENGTH - REGISTER_ADDRESS_LENGTH);
                        selected_accumulator_bank_read <= parameters(PARAMETER_LENGTH - REGISTER_ADDRESS_LENGTH - 1 downto PARAMETER_LENGTH - REGISTER_ADDRESS_LENGTH - ACCUMULATOR_ADDRESS_LENGTH);
                        selected_bias_bank <= parameters(PARAMETER_LENGTH - REGISTER_ADDRESS_LENGTH - ACCUMULATOR_ADDRESS_LENGTH - 1 downto PARAMETER_LENGTH - REGISTER_ADDRESS_LENGTH - ACCUMULATOR_ADDRESS_LENGTH - BIAS_ADDRESS_LENGTH);
                        resize_module_mode <= parameters(PARAMETER_LENGTH - REGISTER_ADDRESS_LENGTH - ACCUMULATOR_ADDRESS_LENGTH - BIAS_ADDRESS_LENGTH - 1 downto PARAMETER_LENGTH - REGISTER_ADDRESS_LENGTH - ACCUMULATOR_ADDRESS_LENGTH - BIAS_ADDRESS_LENGTH - RESIZE_MODE_LENGTH);
                    when others =>
                        memory_read_address <= (others => '0');
                        memory_write_address <= (others => '0');
                        register_read_address <= (others => '0');
                        register_write_address <= (others => '0');
                        systolic_array_selected_weight_bank <= (others => '0');
                        selected_accumulator_bank_write <= (others => '0');
                        selected_accumulator_bank_read <= (others => '0');
                        selected_bias_bank <= (others => '0');
                        resize_module_mode <= (others => '0');
                end case;
            else
                opcode_reg <= opcode_reg;
                memory_read_address <= memory_read_address;
                memory_write_address <= memory_write_address;
                register_read_address <= register_read_address;
                register_write_address <= register_write_address;
                systolic_array_selected_weight_bank <= systolic_array_selected_weight_bank;
                selected_accumulator_bank_write <= selected_accumulator_bank_write;
                selected_accumulator_bank_read <= selected_accumulator_bank_read;
                accumulator_mode <= accumulator_mode;
                selected_bias_bank <= selected_bias_bank;
                resize_module_mode <= resize_module_mode;
            end if;
        end if;
    end process;
    
    opcode_reg_natural <= to_integer(unsigned(opcode_reg));

    process (opcode_reg_natural, opcode_ready, memory_read_address_ready, memory_write_address_ready, register_read_address_ready, register_write_address_ready, systolic_array_selected_weight_bank_ready,
             selected_accumulator_bank_write_ready, accumulator_mode_ready, selected_accumulator_bank_read_ready, selected_bias_bank_ready, resize_module_mode_ready, rst) begin
        case opcode_reg_natural is
            when OPERATION_VECTOR_LOAD =>
                instruction_ready <= opcode_ready and memory_read_address_ready and register_write_address_ready and not rst;
            when OPERATION_VECTOR_STORE =>
                instruction_ready <= opcode_ready and memory_write_address_ready and register_read_address_ready and register_write_address_ready and not rst;
            when OPERATION_VECTOR_MOV =>
                instruction_ready <= opcode_ready and register_write_address_ready and register_read_address_ready and not rst;
            when OPERATION_VECTOR_MAC =>
                instruction_ready <= opcode_ready and register_read_address_ready and register_write_address_ready and systolic_array_selected_weight_bank_ready and selected_accumulator_bank_write_ready and accumulator_mode_ready and not rst;
            when OPERATION_VECTOR_BIAS_QUANT =>
                instruction_ready <= opcode_ready and register_write_address_ready and selected_accumulator_bank_read_ready and selected_bias_bank_ready and resize_module_mode_ready and not rst;
            when others =>
                instruction_ready <= not rst;
        end case;
    end process;

end Behavioral;
