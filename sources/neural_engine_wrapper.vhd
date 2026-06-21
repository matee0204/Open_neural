----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/08/2026 05:47:50 PM
-- Design Name: 
-- Module Name: neural_engine_wrapper - Behavioral
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
use work.Neural_engine.all;
use work.common_constants.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity neural_engine_wrapper is
    generic (
        INSTRUCTION_LENGTH                   : natural := 64;
        OPERATION_CODE_WIDTH                 : natural := 7;
        MEMORY_ADDRESS_WIDTH                 : natural := 32;
        REGISTER_ADDRESS_WIDTH               : natural := 16;
        REGISTER_BASE_ADDRESSES              : std_logic_vector := x"020001000000";
        REGISTER_ADDRESS_MASKS               : std_logic_vector := x"000F007F007F";
        REGISTER_ARRAY_DEPTH                 : natural := 128;
        SYSTOLIC_ARRAY_WEIGHT_ADDRESS_WIDTH  : natural := 8;
        BIAS_ADDRESS_WIDTH                   : natural := 8;
        BIAS_REGISTER_DEPTH                  : natural := 128;
        BIAS_OUTPUT_DATA_WIDTH               : natural := 32;
        ACCUMULATOR_ADDRESS_WIDTH            : natural := 8;
        ACCUMULATOR_DEPTH                    : natural := 128;
        ACCUMULATOR_OUTPUT_DATA_WIDTH        : natural := 32;
        ACCUMULATOR_MODE_LENGTH              : natural := 3;
        RESIZE_MODE_LENGTH                   : natural := 3;
        NUM_OF_VECTOR_REGISTERS              : natural := 384;
        NUM_OF_ACCUMULATOR_REGISTERS         : natural := 32;
        DATA_WIDTH                           : natural := 8;
        SYSTOLIC_ARRAY_SIZE                  : natural := 8;
        SYSTOLIC_ARRAY_OUTPUT_DATA_WIDTH     : natural := 24;
        SYSTOLIC_ARRAY_WEIGHT_REGISTER_DEPTH : natural := 2
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        instruction_valid : in std_logic;
        instruction_ready : out std_logic;
        instruction : in std_logic_vector(INSTRUCTION_LENGTH - 1 downto 0);

        memory_write_address_out_valid : out std_logic;
        memory_write_address_out_ready : in std_logic;
        memory_write_address_out : out std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);

        memory_write_data_out_valid : out std_logic;
        memory_write_data_out_ready : in std_logic;
        memory_write_data_out : out std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto 0);

        memory_read_address_out_valid : out std_logic;
        memory_read_address_out_ready : in std_logic;
        memory_read_address_out : out std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);

        memory_read_data_in_valid : in std_logic;
        memory_read_data_in_ready : out std_logic;
        memory_read_data_in : in std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto 0)
    );
end neural_engine_wrapper;

architecture Behavioral of neural_engine_wrapper is
    constant NUMBER_OF_REGISTER_BLOCKS : natural := 3;

    signal instoruction_ready_from_decoder : std_logic;
    signal opcode_valid_from_decoder : std_logic;
    signal opcode_out_from_decoder : std_logic_vector(OPERATION_CODE_WIDTH - 1 downto 0);
    signal memory_read_address_valid_from_decoder : std_logic;
    signal memory_read_address_from_decoder : std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);
    signal memory_write_address_valid_from_decoder : std_logic;
    signal memory_write_address_from_decoder : std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);
    signal register_read_address_valid_from_decoder : std_logic;
    signal register_read_address_from_decoder : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0);
    signal register_write_address_valid_from_decoder : std_logic;
    signal register_write_address_from_decoder : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0);
    signal systolic_array_selected_weight_bank_valid_from_decoder : std_logic;
    signal systolic_array_selected_weight_bank_from_decoder : std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_WIDTH - 1 downto 0);
    signal selected_accumulator_bank_write_valid_from_decoder : std_logic;
    signal selected_accumulator_bank_write_from_decoder : std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0);
    signal accumulator_mode_from_decoder : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
    signal selected_accumulator_bank_read_valid_from_decoder : std_logic;
    signal selected_accumulator_bank_read_from_decoder : std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0);
    signal selected_bias_bank_valid_from_decoder : std_logic;
    signal selected_bias_bank_from_decoder : std_logic_vector(BIAS_ADDRESS_WIDTH - 1 downto 0);
    signal resize_module_mode_valid_from_decoder : std_logic;
    signal resize_module_mode_from_decoder : std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);

    signal opcode_in_ready_from_pipeline_input_handler : std_logic;
    signal memory_read_address_ready_from_pipeline_input_handler : std_logic;
    signal memory_write_address_ready_from_pipeline_input_handler : std_logic;
    signal register_read_address_ready_from_pipeline_input_handler : std_logic;
    signal register_write_address_ready_from_pipeline_input_handler : std_logic;
    signal systolic_array_selected_weight_bank_ready_from_pipeline_input_handler : std_logic;
    signal selected_accumulator_bank_write_ready_from_pipeline_input_handler : std_logic;
    signal selected_accumulator_bank_read_ready_from_pipeline_input_handler : std_logic;
    signal selected_bias_bank_ready_from_pipeline_input_handler : std_logic;
    signal resize_module_mode_ready_from_pipeline_input_handler : std_logic;
    signal opcode_out_valid_from_pipeline_input_handler : std_logic;
    signal opcode_out_from_pipeline_input_handler : std_logic_vector(OPERATION_CODE_WIDTH - 1 downto 0);
    signal memory_read_address_out_valid_from_pipeline_input_handler : std_logic;
    signal memory_read_address_out_from_pipeline_input_handler : std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);
    signal memory_write_address_out_valid_from_pipeline_input_handler : std_logic;
    signal memory_write_address_out_from_pipeline_input_handler : std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);
    signal reg_read_address_out_valid_from_pipeline_input_handler : std_logic;
    signal reg_read_address_out_from_pipeline_input_handler : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0);
    signal reg_read_data_in_ready_from_pipeline_input_handler : std_logic;
    signal reg_read_data_out_valid_from_pipeline_input_handler : std_logic;
    signal reg_read_data_out_from_pipeline_input_handler : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
    signal reg_write_address_out_valid_from_pipeline_input_handler : std_logic;
    signal reg_write_address_out_from_pipeline_input_handler : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0);
    signal sys_array_bank_address_out_valid_from_pipeline_input_handler : std_logic;
    signal sys_array_bank_address_out_from_pipeline_input_handler : std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_WIDTH - 1 downto 0);
    signal accu_address_write_out_valid_from_pipeline_input_handler : std_logic;
    signal accu_address_write_out_from_pipeline_input_handler : std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0);
    signal accu_mode_out_from_pipeline_input_handler : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
    signal accu_address_read_out_valid_from_pipeline_input_handler : std_logic;
    signal accu_address_read_out_from_pipeline_input_handler : std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0);
    signal bias_address_out_valid_from_pipeline_input_handler : std_logic;
    signal bias_address_out_from_pipeline_input_handler : std_logic_vector(BIAS_ADDRESS_WIDTH - 1 downto 0);
    signal resize_mode_out_valid_from_pipeline_input_handler : std_logic;
    signal resize_mode_out_from_pipeline_input_handler : std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);
    signal register_write_back_address_ready_from_pipeline_input_handler : std_logic;
    signal accumulator_write_back_address_ready_from_pipeline_input_handler : std_logic;

    signal pipeline_mac_en_out_from_pipeline_handler : std_logic;
    signal pipeline_bias_quant_en_out_from_pipeline_handler : std_logic;
    signal pipeline_load_en_out_from_pipeline_handler : std_logic;
    signal pipeline_store_en_out_from_pipeline_handler : std_logic;
    signal pipeline_mov_en_out_from_pipeline_handler : std_logic;
    signal opcode_in_ready_from_pipeline_handler : std_logic;
    signal mem_read_address_in_ready_from_pipeline_handler : std_logic;
    signal mem_read_data_in_ready_from_pipeline_handler : std_logic;
    signal mem_write_address_in_ready_from_pipeline_handler : std_logic;
    signal reg_write_address_in_ready_from_pipeline_handler : std_logic;
    signal reg_read_data_in_ready_from_pipeline_handler : std_logic;
    signal sys_array_bank_address_in_ready_from_pipeline_handler : std_logic;
    signal accu_write_address_in_ready_from_pipeline_handler : std_logic;
    signal accu_mode_in_ready_from_pipeline_handler : std_logic;
    signal accu_read_address_in_ready_from_pipeline_handler : std_logic;
    signal bias_address_in_ready_from_pipeline_handler : std_logic;
    signal resize_mode_in_ready_from_pipeline_handler : std_logic;
    signal reg_data_from_resize_module_ready_from_pipeline_handler : std_logic;
    signal mem_write_address_out_valid_from_pipeline_handler : std_logic;
    signal mem_write_address_out_from_pipeline_handler : std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);
    signal mem_write_data_out_valid_from_pipeline_handler : std_logic;
    signal mem_write_data_out_from_pipeline_handler : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
    signal mem_write_data_out_from_pipeline_handler_flatten : std_logic_vector(SYSTOLIC_ARRAY_SIZE * DATA_WIDTH - 1 downto 0);
    signal memory_read_data_in_vector : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
    signal mem_read_address_out_valid_from_pipeline_handler : std_logic;
    signal mem_read_address_out_from_pipeline_handler : std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);
    signal reg_write_address_out_valid_from_pipeline_handler : std_logic;
    signal reg_write_address_out_from_pipeline_handler : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0);
    signal reg_write_data_out_valid_from_pipeline_handler : std_logic;
    signal reg_write_data_out_from_pipeline_handler : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
    signal reg_write_data_out_from_pipeline_handler_flatten : std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto 0);
    signal reg_data_out_to_mac_valid_from_pipeline_handler : std_logic;
    signal reg_data_out_to_mac_ready_from_pipeline_handler : std_logic;
    signal reg_data_out_to_mac_from_pipeline_handler : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
    signal sys_array_bank_address_out_valid_from_pipeline_handler : std_logic;
    signal sys_array_bank_address_out_from_pipeline_handler : std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_WIDTH - 1 downto 0);
    signal accu_write_address_out_valid_from_pipeline_handler : std_logic;
    signal accu_write_address_out_from_pipeline_handler : std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0);
    signal accu_mode_out_valid_from_pipeline_handler : std_logic;
    signal accu_mode_out_from_pipeline_handler : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
    signal accu_read_address_out_valid_from_pipeline_handler : std_logic;
    signal accu_read_address_out_from_pipeline_handler : std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0);
    signal bias_address_out_valid_from_pipeline_handler : std_logic;
    signal bias_address_out_from_pipeline_handler : std_logic_vector(BIAS_ADDRESS_WIDTH - 1 downto 0);
    signal resize_mode_out_valid_from_pipeline_handler : std_logic;
    signal resize_mode_out_from_pipeline_handler : std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);

    signal data_in_ready_from_systolic_array_input : std_logic;
    signal data_out_valid_from_systolic_array_input : std_logic;
    signal data_out_from_systolic_array_input : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
    
    constant SYS_ARRAY_REGISTER_INTERCONNECT_INDEX : natural := 2;
    signal weight_col_read_address_ready_from_sys_array : std_logic;
    signal weight_out_valid_from_sys_array : std_logic;
    signal weight_out_from_sys_array : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
    signal weight_col_write_address_ready_from_sys_array : std_logic;
    signal weight_in_ready_from_sys_array : std_logic;
    signal selected_weight_bank_ready_from_sys_array : std_logic;
    signal data_in_ready_from_sys_array : std_logic;
    signal result_out_valid_from_sys_array : std_logic;
    signal result_out_from_sys_array : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(SYSTOLIC_ARRAY_OUTPUT_DATA_WIDTH - 1 downto 0);
    signal weight_in_flatten_from_interconnect : std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto 0);
    signal weight_in_vectorized_from_interconnect : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);

    signal data_in_ready_from_systolic_array_output : std_logic;
    signal data_out_valid_from_systolic_array_output : std_logic;
    signal data_out_from_systolic_array_output : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(SYSTOLIC_ARRAY_OUTPUT_DATA_WIDTH - 1 downto 0);
    signal data_out_from_systolic_array_output_signed : data_vector_signed(0 to SYSTOLIC_ARRAY_SIZE - 1)(SYSTOLIC_ARRAY_OUTPUT_DATA_WIDTH - 1 downto 0);

    signal accumulator_read_address_ready_from_accumulator : std_logic;
    signal data_out_valid_from_accumulator : std_logic;
    signal data_out_from_accumulator : data_vector_signed(0 to SYSTOLIC_ARRAY_SIZE - 1)(ACCUMULATOR_OUTPUT_DATA_WIDTH - 1 downto 0);

    constant BIAS_REGISTER_INTERCONNECT_INDEX : natural := 1;
    signal bias_reg_read_address_ready_from_bias_module : std_logic;
    signal bias_reg_write_address_ready_from_bias_module : std_logic;
    signal bias_reg_data_in_ready_from_bias_module : std_logic;
    signal bias_reg_address_ready_from_bias_module : std_logic;
    signal bias_reg_data_out_valid_from_bias_module : std_logic;
    signal bias_reg_data_out_from_bias_module : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
    signal data_in_ready_from_bias_module : std_logic;
    signal data_out_valid_from_bias_module : std_logic;
    signal data_out_from_bias_module : data_vector_signed(0 to SYSTOLIC_ARRAY_SIZE - 1)(BIAS_OUTPUT_DATA_WIDTH - 1 downto 0);
    signal data_out_from_bias_module_not_signed : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(BIAS_OUTPUT_DATA_WIDTH - 1 downto 0);
    signal bias_reg_data_in_flatten_from_interconnect : std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto 0);
    signal bias_reg_data_in_vectorized_from_interconnect : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);

    signal data_in_ready_from_resize_module : std_logic;
    signal data_out_valid_from_resize_module : std_logic;
    signal data_out_from_resize_module : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
    
    constant VECTOR_REGISTER_INTERCONNECT_INDEX : natural := 0;
    signal register_read_address_ready_from_vector_register_module : std_logic;
    signal register_read_data_valid_from_vector_register_module : std_logic;
    signal register_read_data_from_vector_register_module : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
    signal register_write_address_ready_from_vector_register_module : std_logic;
    signal register_write_data_ready_from_vector_register_module : std_logic;
    signal register_write_data_flatten_from_interconnect : std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto 0);
    signal register_write_data_vectorized_from_interconnect : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);

    signal address_read_ready_from_bus_interconnect : std_logic;
    signal data_read_valid_from_bus_interconnect : std_logic;
    signal data_read_from_bus_interconnect : std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto 0);
    signal data_read_from_bus_interconnect_vectorized : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
    signal address_write_ready_from_bus_interconnect : std_logic;
    signal data_write_ready_from_bus_interconnect : std_logic;
    signal s_address_read_valid_from_bus_interconnect : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS - 1 downto 0);
    signal s_address_read_from_bus_interconnect : std_logic_vector(REGISTER_ADDRESS_WIDTH * NUMBER_OF_REGISTER_BLOCKS - 1 downto 0);
    signal s_data_read_ready_from_bus_interconnect : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS - 1 downto 0);
    signal s_address_write_valid_from_bus_interconnect : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS - 1 downto 0);
    signal s_address_write_from_bus_interconnect : std_logic_vector(REGISTER_ADDRESS_WIDTH * NUMBER_OF_REGISTER_BLOCKS - 1 downto 0);
    signal s_data_write_valid_from_bus_interconnect : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS - 1 downto 0);
    signal s_data_write_from_bus_interconnect : std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * NUMBER_OF_REGISTER_BLOCKS - 1 downto 0); 
    signal s_address_read_ready_from_register_blocks : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS - 1 downto 0);
    signal s_data_read_valid_from_register_blocks : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS - 1 downto 0);
    signal s_data_read_from_register_blocks : std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * NUMBER_OF_REGISTER_BLOCKS - 1 downto 0);
    signal s_address_write_ready_from_register_blocks : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS - 1 downto 0);
    signal s_data_write_ready_from_register_blocks : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS - 1 downto 0);
    signal address_writeback_valid_from_bus_interconnect : std_logic;
    signal address_writeback_from_bus_interconnect : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0);

begin

    instruction_ready <= instoruction_ready_from_decoder;

    instruction_decoder_inst : entity work.instruction_decoder
        generic map(
            INSTRUCTION_LENGTH                   => INSTRUCTION_LENGTH,
            OPERATION_CODE_LENGTH                => OPERATION_CODE_WIDTH,
            MEMORY_ADDRESS_LENGTH                => MEMORY_ADDRESS_WIDTH,
            REGISTER_ADDRESS_LENGTH              => REGISTER_ADDRESS_WIDTH,
            SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH => SYSTOLIC_ARRAY_WEIGHT_ADDRESS_WIDTH,
            BIAS_ADDRESS_LENGTH                  => BIAS_ADDRESS_WIDTH,
            ACCUMULATOR_ADDRESS_LENGTH           => ACCUMULATOR_ADDRESS_WIDTH,
            ACCUMULATOR_MODE_LENGTH              => ACCUMULATOR_MODE_LENGTH,
            RESIZE_MODE_LENGTH                   => RESIZE_MODE_LENGTH
        )
        port map(
            clk                                       => clk,
            rst                                       => rst,
            instruction_valid                         => instruction_valid,
            instruction_ready                         => instoruction_ready_from_decoder,
            instruction                               => instruction,
            opcode_valid                              => opcode_valid_from_decoder,
            opcode_ready                              => opcode_in_ready_from_pipeline_input_handler,
            opcode_out                                => opcode_out_from_decoder,
            memory_read_address_valid                 => memory_read_address_valid_from_decoder,
            memory_read_address_ready                 => memory_read_address_ready_from_pipeline_input_handler,
            memory_read_address                       => memory_read_address_from_decoder,
            memory_write_address_valid                => memory_write_address_valid_from_decoder,
            memory_write_address_ready                => memory_write_address_ready_from_pipeline_input_handler,
            memory_write_address                      => memory_write_address_from_decoder,
            register_read_address_valid               => register_read_address_valid_from_decoder,
            register_read_address_ready               => register_read_address_ready_from_pipeline_input_handler,
            register_read_address                     => register_read_address_from_decoder,
            register_write_address_valid              => register_write_address_valid_from_decoder,
            register_write_address_ready              => register_write_address_ready_from_pipeline_input_handler,
            register_write_address                    => register_write_address_from_decoder,
            systolic_array_selected_weight_bank_valid => systolic_array_selected_weight_bank_valid_from_decoder,
            systolic_array_selected_weight_bank_ready => systolic_array_selected_weight_bank_ready_from_pipeline_input_handler,
            systolic_array_selected_weight_bank       => systolic_array_selected_weight_bank_from_decoder,
            selected_accumulator_bank_write_valid     => selected_accumulator_bank_write_valid_from_decoder,
            selected_accumulator_bank_write_ready     => selected_accumulator_bank_write_ready_from_pipeline_input_handler,
            selected_accumulator_bank_write           => selected_accumulator_bank_write_from_decoder,
            accumulator_mode                          => accumulator_mode_from_decoder,
            selected_accumulator_bank_read_valid      => selected_accumulator_bank_read_valid_from_decoder,
            selected_accumulator_bank_read_ready      => selected_accumulator_bank_read_ready_from_pipeline_input_handler,
            selected_accumulator_bank_read            => selected_accumulator_bank_read_from_decoder,
            selected_bias_bank_valid                  => selected_bias_bank_valid_from_decoder,
            selected_bias_bank_ready                  => selected_bias_bank_ready_from_pipeline_input_handler,
            selected_bias_bank                        => selected_bias_bank_from_decoder,
            resize_module_mode_valid                  => resize_module_mode_valid_from_decoder,
            resize_module_mode_ready                  => resize_module_mode_ready_from_pipeline_input_handler,
            resize_module_mode                        => resize_module_mode_from_decoder
        );


    pipeline_input_handler : entity work.pipeline_input_handler
        generic map(
            NUM_OF_VECTOR_REGISTERS              => NUM_OF_VECTOR_REGISTERS,
            NUM_OF_ACCUMULATOR_REGISTERS         => NUM_OF_ACCUMULATOR_REGISTERS,
            OPERATION_CODE_LENGTH                => OPERATION_CODE_WIDTH,
            MEMORY_ADDRESS_LENGTH                => MEMORY_ADDRESS_WIDTH,
            REGISTER_ADDRESS_LENGTH              => REGISTER_ADDRESS_WIDTH,
            SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH => SYSTOLIC_ARRAY_WEIGHT_ADDRESS_WIDTH,
            BIAS_ADDRESS_LENGTH                  => BIAS_ADDRESS_WIDTH,
            ACCUMULATOR_ADDRESS_LENGTH           => ACCUMULATOR_ADDRESS_WIDTH,
            ACCUMULATOR_MODE_LENGTH              => ACCUMULATOR_MODE_LENGTH,
            RESIZE_MODE_LENGTH                   => RESIZE_MODE_LENGTH,
            REGISTER_VECTOR_LENGTH               => SYSTOLIC_ARRAY_SIZE,
            REGISTER_DATA_LENGTH                 => DATA_WIDTH
        )
        port map(
            clk                                       => clk,
            rst                                       => rst,
            opcode_in_valid                           => opcode_valid_from_decoder,
            opcode_in_ready                           => opcode_in_ready_from_pipeline_input_handler,
            opcode_in                                 => opcode_out_from_decoder,
            memory_read_address_valid                 => memory_read_address_valid_from_decoder,
            memory_read_address_ready                 => memory_read_address_ready_from_pipeline_input_handler,
            memory_read_address                       => memory_read_address_from_decoder,
            memory_write_address_valid                => memory_write_address_valid_from_decoder,
            memory_write_address_ready                => memory_write_address_ready_from_pipeline_input_handler,
            memory_write_address                      => memory_write_address_from_decoder,
            register_read_address_valid               => register_read_address_valid_from_decoder,
            register_read_address_ready               => register_read_address_ready_from_pipeline_input_handler,
            register_read_address                     => register_read_address_from_decoder,
            register_write_address_valid              => register_write_address_valid_from_decoder,
            register_write_address_ready              => register_write_address_ready_from_pipeline_input_handler,
            register_write_address                    => register_write_address_from_decoder,
            systolic_array_selected_weight_bank_valid => systolic_array_selected_weight_bank_valid_from_decoder,
            systolic_array_selected_weight_bank_ready => systolic_array_selected_weight_bank_ready_from_pipeline_input_handler,
            systolic_array_selected_weight_bank       => systolic_array_selected_weight_bank_from_decoder,
            selected_accumulator_bank_write_valid     => selected_accumulator_bank_write_valid_from_decoder,
            selected_accumulator_bank_write_ready     => selected_accumulator_bank_write_ready_from_pipeline_input_handler,
            selected_accumulator_bank_write           => selected_accumulator_bank_write_from_decoder,
            accumulator_mode                          => accumulator_mode_from_decoder,
            selected_accumulator_bank_read_valid      => selected_accumulator_bank_read_valid_from_decoder,
            selected_accumulator_bank_read_ready      => selected_accumulator_bank_read_ready_from_pipeline_input_handler,
            selected_accumulator_bank_read            => selected_accumulator_bank_read_from_decoder,
            selected_bias_bank_valid                  => selected_bias_bank_valid_from_decoder,
            selected_bias_bank_ready                  => selected_bias_bank_ready_from_pipeline_input_handler,
            selected_bias_bank                        => selected_bias_bank_from_decoder,
            resize_module_mode_valid                  => resize_module_mode_valid_from_decoder,
            resize_module_mode_ready                  => resize_module_mode_ready_from_pipeline_input_handler,
            resize_module_mode                        => resize_module_mode_from_decoder,

            opcode_out_valid                          => opcode_out_valid_from_pipeline_input_handler,
            opcode_out_ready                          => opcode_in_ready_from_pipeline_handler,
            opcode_out                                => opcode_out_from_pipeline_input_handler,
            memory_read_address_out_valid             => memory_read_address_out_valid_from_pipeline_input_handler,
            memory_read_address_out_ready             => mem_read_address_in_ready_from_pipeline_handler,
            memory_read_address_out                   => memory_read_address_out_from_pipeline_input_handler,
            memory_write_address_out_valid            => memory_write_address_out_valid_from_pipeline_input_handler,
            memory_write_address_out_ready            => mem_write_address_in_ready_from_pipeline_handler,
            memory_write_address_out                  => memory_write_address_out_from_pipeline_input_handler,
            reg_write_address_out_valid               => reg_write_address_out_valid_from_pipeline_input_handler,
            reg_write_address_out_ready               => reg_write_address_in_ready_from_pipeline_handler,
            reg_write_address_out                     => reg_write_address_out_from_pipeline_input_handler,
            reg_read_address_out_valid                => reg_read_address_out_valid_from_pipeline_input_handler,
            reg_read_address_out_ready                => address_read_ready_from_bus_interconnect,
            reg_read_address_out                      => reg_read_address_out_from_pipeline_input_handler,
            reg_read_data_in_valid                    => data_read_valid_from_bus_interconnect,
            reg_read_data_in_ready                    => reg_read_data_in_ready_from_pipeline_input_handler,
            reg_read_data_in                          => data_read_from_bus_interconnect_vectorized,
            reg_read_data_out_valid                   => reg_read_data_out_valid_from_pipeline_input_handler,
            reg_read_data_out_ready                   => reg_read_data_in_ready_from_pipeline_handler,
            reg_read_data_out                         => reg_read_data_out_from_pipeline_input_handler,
            sys_array_bank_address_out_valid          => sys_array_bank_address_out_valid_from_pipeline_input_handler,
            sys_array_bank_address_out_ready          => sys_array_bank_address_in_ready_from_pipeline_handler,
            sys_array_bank_address_out                => sys_array_bank_address_out_from_pipeline_input_handler,
            accu_address_write_out_valid              => accu_address_write_out_valid_from_pipeline_input_handler,
            accu_address_write_out_ready              => accu_write_address_in_ready_from_pipeline_handler,
            accu_address_write_out                    => accu_address_write_out_from_pipeline_input_handler,
            accu_mode_out                             => accu_mode_out_from_pipeline_input_handler,
            accu_address_read_out_valid               => accu_address_read_out_valid_from_pipeline_input_handler,
            accu_address_read_out_ready               => accu_read_address_in_ready_from_pipeline_handler,
            accu_address_read_out                     => accu_address_read_out_from_pipeline_input_handler,
            bias_address_out_valid                    => bias_address_out_valid_from_pipeline_input_handler,
            bias_address_out_ready                    => bias_address_in_ready_from_pipeline_handler,
            bias_address_out                          => bias_address_out_from_pipeline_input_handler,
            resize_mode_out_valid                     => resize_mode_out_valid_from_pipeline_input_handler,
            resize_mode_out_ready                     => resize_mode_in_ready_from_pipeline_handler,
            resize_mode_out                           => resize_mode_out_from_pipeline_input_handler,
            register_write_back_address_valid         => address_writeback_valid_from_bus_interconnect,
            register_write_back_address_ready         => register_write_back_address_ready_from_pipeline_input_handler,
            register_write_back_address               => address_writeback_from_bus_interconnect,
            register_write_back_ready                 => address_write_ready_from_bus_interconnect,
            accumulator_write_back_address_valid      => accu_write_address_out_valid_from_pipeline_handler,
            accumulator_write_back_address_ready      => accumulator_write_back_address_ready_from_pipeline_input_handler,
            accumulator_write_back_address            => accu_write_address_out_from_pipeline_handler,
            accumulator_write_back_ready              => '1' -- There is no such signal
        );

    mem_write_data_out_from_pipeline_handler_flatten <= flatten(mem_write_data_out_from_pipeline_handler);
    memory_read_data_in_vector <= vectorize(memory_read_data_in, DATA_WIDTH, SYSTOLIC_ARRAY_SIZE);

    memory_write_address_out_valid <= mem_write_address_out_valid_from_pipeline_handler;
    memory_write_address_out <= mem_write_address_out_from_pipeline_handler;
    memory_write_data_out_valid <= mem_write_data_out_valid_from_pipeline_handler;
    memory_write_data_out <= mem_write_data_out_from_pipeline_handler_flatten;
    memory_read_address_out_valid <= mem_read_address_out_valid_from_pipeline_handler;
    memory_read_address_out <= mem_read_address_out_from_pipeline_handler;
    memory_read_data_in_ready <= mem_read_data_in_ready_from_pipeline_handler;

    pipeline_handler_inst : entity work.pipeline_handler
        generic map(
            OPERATION_CODE_LENGTH                => OPERATION_CODE_WIDTH,
            MEMORY_ADDRESS_LENGTH                => MEMORY_ADDRESS_WIDTH,
            REGISTER_ADDRESS_LENGTH              => REGISTER_ADDRESS_WIDTH,
            SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH => SYSTOLIC_ARRAY_WEIGHT_ADDRESS_WIDTH,
            ACCUMULATOR_ADDRESS_LENGTH           => ACCUMULATOR_ADDRESS_WIDTH,
            ACCUMULATOR_MODE_LENGTH              => ACCUMULATOR_MODE_LENGTH,
            BIAS_ADDRESS_LENGTH                  => BIAS_ADDRESS_WIDTH,
            RESIZE_MODE_LENGTH                   => RESIZE_MODE_LENGTH,
            VECTOR_LENGTH                        => SYSTOLIC_ARRAY_SIZE,
            DATA_WIDTH                           => DATA_WIDTH
        )
        port map(
            clk                               => clk,
            rst                               => rst,
            pipeline_mac_en_out               => pipeline_mac_en_out_from_pipeline_handler,
            pipeline_bias_quant_en_out        => pipeline_bias_quant_en_out_from_pipeline_handler,
            pipeline_load_en_out              => pipeline_load_en_out_from_pipeline_handler,
            pipeline_store_en_out             => pipeline_store_en_out_from_pipeline_handler,
            pipeline_mov_en_out               => pipeline_mov_en_out_from_pipeline_handler,
            opcode_in_valid                   => opcode_out_valid_from_pipeline_input_handler,
            opcode_in_ready                   => opcode_in_ready_from_pipeline_handler,
            opcode_in                         => opcode_out_from_pipeline_input_handler,
            mem_write_address_in_valid        => memory_write_address_out_valid_from_pipeline_input_handler,
            mem_write_address_in_ready        => mem_write_address_in_ready_from_pipeline_handler,
            mem_write_address_in              => memory_write_address_out_from_pipeline_input_handler,
            mem_read_address_in_valid         => memory_read_address_out_valid_from_pipeline_input_handler,
            mem_read_address_in_ready         => mem_read_address_in_ready_from_pipeline_handler,
            mem_read_address_in               => memory_read_address_out_from_pipeline_input_handler,
            mem_read_data_in_valid            => memory_read_data_in_valid,
            mem_read_data_in_ready            => mem_read_data_in_ready_from_pipeline_handler,
            mem_read_data_in                  => memory_read_data_in_vector,
            reg_write_address_in_valid        => reg_write_address_out_valid_from_pipeline_input_handler,
            reg_write_address_in_ready        => reg_write_address_in_ready_from_pipeline_handler,
            reg_write_address_in              => reg_write_address_out_from_pipeline_input_handler,
            reg_read_data_in_valid            => reg_read_data_out_valid_from_pipeline_input_handler,
            reg_read_data_in_ready            => reg_read_data_in_ready_from_pipeline_handler,
            reg_read_data_in                  => reg_read_data_out_from_pipeline_input_handler,
            sys_array_bank_address_in_valid   => sys_array_bank_address_out_valid_from_pipeline_input_handler,
            sys_array_bank_address_in_ready   => sys_array_bank_address_in_ready_from_pipeline_handler,
            sys_array_bank_address_in         => sys_array_bank_address_out_from_pipeline_input_handler,
            accu_write_address_in_valid       => accu_address_write_out_valid_from_pipeline_input_handler,
            accu_write_address_in_ready       => accu_write_address_in_ready_from_pipeline_handler,
            accu_write_address_in             => accu_address_write_out_from_pipeline_input_handler,
            accu_mode_in_valid                => accu_address_write_out_valid_from_pipeline_input_handler,  -- There is no such signal
            accu_mode_in_ready                => accu_mode_in_ready_from_pipeline_handler,
            accu_mode_in                      => accu_mode_out_from_pipeline_input_handler,
            accu_read_address_in_valid        => accu_address_read_out_valid_from_pipeline_input_handler,
            accu_read_address_in_ready        => accu_read_address_in_ready_from_pipeline_handler,
            accu_read_address_in              => accu_address_read_out_from_pipeline_input_handler,
            bias_address_in_valid             => bias_address_out_valid_from_pipeline_input_handler,
            bias_address_in_ready             => bias_address_in_ready_from_pipeline_handler,
            bias_address_in                   => bias_address_out_from_pipeline_input_handler,
            resize_mode_in_valid              => resize_mode_out_valid_from_pipeline_input_handler,
            resize_mode_in_ready              => resize_mode_in_ready_from_pipeline_handler,
            resize_mode_in                    => resize_mode_out_from_pipeline_input_handler,
            reg_data_from_resize_module_valid => data_out_valid_from_resize_module,
            reg_data_from_resize_module_ready => reg_data_from_resize_module_ready_from_pipeline_handler,
            reg_data_from_resize_module       => data_out_from_resize_module,
            mem_write_address_out_valid       => mem_write_address_out_valid_from_pipeline_handler,
            mem_write_address_out_ready       => memory_write_address_out_ready,
            mem_write_address_out             => mem_write_address_out_from_pipeline_handler,
            mem_write_data_out_valid          => mem_write_data_out_valid_from_pipeline_handler,
            mem_write_data_out_ready          => memory_write_data_out_ready,
            mem_write_data_out                => mem_write_data_out_from_pipeline_handler,
            mem_read_address_out_valid        => mem_read_address_out_valid_from_pipeline_handler,
            mem_read_address_out_ready        => memory_read_address_out_ready,
            mem_read_address_out              => mem_read_address_out_from_pipeline_handler,
            reg_write_address_out_valid       => reg_write_address_out_valid_from_pipeline_handler,
            reg_write_address_out_ready       => address_write_ready_from_bus_interconnect,
            reg_write_address_out             => reg_write_address_out_from_pipeline_handler,
            reg_write_data_out_valid          => reg_write_data_out_valid_from_pipeline_handler,
            reg_write_data_out_ready          => data_write_ready_from_bus_interconnect,
            reg_write_data_out                => reg_write_data_out_from_pipeline_handler,
            reg_data_out_to_mac_valid         => reg_data_out_to_mac_valid_from_pipeline_handler,
            reg_data_out_to_mac_ready         => data_in_ready_from_systolic_array_input,
            reg_data_out_to_mac               => reg_data_out_to_mac_from_pipeline_handler,
            sys_array_bank_address_out_valid  => sys_array_bank_address_out_valid_from_pipeline_handler,
            sys_array_bank_address_out_ready  => selected_weight_bank_ready_from_sys_array,
            sys_array_bank_address_out        => sys_array_bank_address_out_from_pipeline_handler,
            accu_write_address_out_valid      => accu_write_address_out_valid_from_pipeline_handler,
            accu_write_address_out_ready      => '1',  -- There is no such signal
            accu_write_address_out            => accu_write_address_out_from_pipeline_handler,
            accu_mode_out_valid               => accu_mode_out_valid_from_pipeline_handler,
            accu_mode_out_ready               => '1',  -- There is no such signal
            accu_mode_out                     => accu_mode_out_from_pipeline_handler,
            accu_read_address_out_valid       => accu_read_address_out_valid_from_pipeline_handler,
            accu_read_address_out_ready       => '1',  -- There is no such signal
            accu_read_address_out             => accu_read_address_out_from_pipeline_handler,
            bias_address_out_valid            => bias_address_out_valid_from_pipeline_handler,
            bias_address_out_ready            => '1',  -- There is no such signal
            bias_address_out                  => bias_address_out_from_pipeline_handler,
            resize_mode_out_valid             => resize_mode_out_valid_from_pipeline_handler,
            resize_mode_out_ready             => '1',  -- There is no such signal
            resize_mode_out                   => resize_mode_out_from_pipeline_handler
        );
    

    systolic_array_input_vector_aligner_inst : entity work.systolic_array_vector_aligner(input)
        generic map(
            DATA_WIDTH    => DATA_WIDTH,
            VECTOR_LENGTH => SYSTOLIC_ARRAY_SIZE
        )
        port map(
            clk            => clk,
            rst            => rst,
            data_in_valid  => reg_data_out_to_mac_valid_from_pipeline_handler,
            data_in_ready  => data_in_ready_from_systolic_array_input,
            data_in        => reg_data_out_to_mac_from_pipeline_handler,
            data_out_valid => data_out_valid_from_systolic_array_input,
            data_out_ready => data_in_ready_from_sys_array,
            data_out       => data_out_from_systolic_array_input
        );
    
    weight_in_flatten_from_interconnect <= s_data_write_from_bus_interconnect(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * SYS_ARRAY_REGISTER_INTERCONNECT_INDEX + DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * SYS_ARRAY_REGISTER_INTERCONNECT_INDEX);
    weight_in_vectorized_from_interconnect <= vectorize(weight_in_flatten_from_interconnect, DATA_WIDTH, SYSTOLIC_ARRAY_SIZE);

    systolic_array_inst : entity work.systolic_array
        generic map(
            SYS_ARRAY_SIZE              => SYSTOLIC_ARRAY_SIZE,
            INPUT_DATA_WIDTH            => DATA_WIDTH,
            OUTPUT_DATA_WIDTH           => SYSTOLIC_ARRAY_OUTPUT_DATA_WIDTH,
            WEIGHT_REGISTER_DEPTH       => SYSTOLIC_ARRAY_WEIGHT_REGISTER_DEPTH
        )
        port map(
            clk                            => clk,
            rst                            => rst,

            weight_col_read_address_valid  => s_address_read_valid_from_bus_interconnect(SYS_ARRAY_REGISTER_INTERCONNECT_INDEX),
            weight_col_read_address_ready  => weight_col_read_address_ready_from_sys_array,
            weight_col_read_address        => s_address_read_from_bus_interconnect(SYS_ARRAY_REGISTER_INTERCONNECT_INDEX * REGISTER_ADDRESS_WIDTH + clog2(SYSTOLIC_ARRAY_WEIGHT_REGISTER_DEPTH * SYSTOLIC_ARRAY_SIZE) - 1 downto SYS_ARRAY_REGISTER_INTERCONNECT_INDEX * REGISTER_ADDRESS_WIDTH),
            weight_out_valid               => weight_out_valid_from_sys_array,
            weight_out_ready               => s_data_read_ready_from_bus_interconnect(SYS_ARRAY_REGISTER_INTERCONNECT_INDEX),
            weight_out                     => weight_out_from_sys_array,
            weight_col_write_address_valid => s_address_write_valid_from_bus_interconnect(SYS_ARRAY_REGISTER_INTERCONNECT_INDEX),
            weight_col_write_address_ready => weight_col_write_address_ready_from_sys_array,
            weight_col_write_address       => s_address_write_from_bus_interconnect(SYS_ARRAY_REGISTER_INTERCONNECT_INDEX * REGISTER_ADDRESS_WIDTH + clog2(SYSTOLIC_ARRAY_WEIGHT_REGISTER_DEPTH * SYSTOLIC_ARRAY_SIZE) - 1 downto SYS_ARRAY_REGISTER_INTERCONNECT_INDEX * REGISTER_ADDRESS_WIDTH),
            weight_in_valid                => s_data_write_valid_from_bus_interconnect(SYS_ARRAY_REGISTER_INTERCONNECT_INDEX),
            weight_in_ready                => weight_in_ready_from_sys_array,
            weight_in                      => weight_in_vectorized_from_interconnect,

            selected_weight_bank_valid     => sys_array_bank_address_out_valid_from_pipeline_handler,
            selected_weight_bank_ready     => selected_weight_bank_ready_from_sys_array,
            selected_weight_bank           => sys_array_bank_address_out_from_pipeline_handler(clog2(SYSTOLIC_ARRAY_WEIGHT_REGISTER_DEPTH) - 1 downto 0),
            data_in_valid                  => data_out_valid_from_systolic_array_input,
            data_in_ready                  => data_in_ready_from_sys_array,
            data_in                        => data_out_from_systolic_array_input,
            result_out_valid               => result_out_valid_from_sys_array,
            result_out_ready               => data_in_ready_from_systolic_array_output,
            result_out                     => result_out_from_sys_array
        );
    

    systolic_array_output_vector_aligner_inst : entity work.systolic_array_vector_aligner(output)
        generic map(
            DATA_WIDTH    => SYSTOLIC_ARRAY_OUTPUT_DATA_WIDTH,
            VECTOR_LENGTH => SYSTOLIC_ARRAY_SIZE
        )
        port map(
            clk            => clk,
            rst            => rst,
            data_in_valid  => result_out_valid_from_sys_array,
            data_in_ready  => data_in_ready_from_systolic_array_output,
            data_in        => result_out_from_sys_array,
            data_out_valid => data_out_valid_from_systolic_array_output,
            data_out_ready => '1',  -- There is no such signal
            data_out       => data_out_from_systolic_array_output
        );


    process (data_out_from_systolic_array_output)
    begin
        for i in 0 to SYSTOLIC_ARRAY_SIZE - 1 loop
            data_out_from_systolic_array_output_signed(i) <= signed(data_out_from_systolic_array_output(i));
        end loop;
    end process;

    vector_accumulator_inst : entity work.vector_accumulator
        generic map(
            INPUT_DATA_WIDTH       => SYSTOLIC_ARRAY_OUTPUT_DATA_WIDTH,
            ACCUMULATOR_DATA_WIDTH => ACCUMULATOR_OUTPUT_DATA_WIDTH,
            ACCUMULATOR_DEPTH      => ACCUMULATOR_DEPTH,
            VECTOR_LENGTH          => SYSTOLIC_ARRAY_SIZE,
            ACCUMULATOR_MODE_LENGTH => ACCUMULATOR_MODE_LENGTH
        )
        port map(
            clk                            => clk,
            rst                            => rst,
            mode                           => accu_mode_out_from_pipeline_handler,
            data_in_valid                  => data_out_valid_from_systolic_array_output,
            data_in                        => data_out_from_systolic_array_output_signed,
            accumulator_write_address      => accu_write_address_out_from_pipeline_handler(clog2(ACCUMULATOR_DEPTH) - 1 downto 0),
            accumulator_read_address_valid => accu_read_address_out_valid_from_pipeline_handler,
            accumulator_read_address_ready => accumulator_read_address_ready_from_accumulator,
            accumulator_read_address       => accu_read_address_out_from_pipeline_handler(clog2(ACCUMULATOR_DEPTH) - 1 downto 0),
            data_out_valid                 => data_out_valid_from_accumulator,
            data_out_ready                 => data_in_ready_from_bias_module,
            data_out                       => data_out_from_accumulator
        );

    bias_reg_data_in_flatten_from_interconnect <= s_data_write_from_bus_interconnect(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * BIAS_REGISTER_INTERCONNECT_INDEX + DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * BIAS_REGISTER_INTERCONNECT_INDEX);
    bias_reg_data_in_vectorized_from_interconnect <= vectorize(bias_reg_data_in_flatten_from_interconnect, DATA_WIDTH, SYSTOLIC_ARRAY_SIZE);

    vector_bias_module_inst : entity work.vector_bias_module
        generic map(
            BIAS_REGISTER_DEPTH => BIAS_REGISTER_DEPTH,
            VECTOR_LENGTH       => SYSTOLIC_ARRAY_SIZE,
            BIAS_DATA_WIDTH     => DATA_WIDTH,
            INPUT_DATA_WIDTH    => ACCUMULATOR_OUTPUT_DATA_WIDTH,
            OUTPUT_DATA_WIDTH   => BIAS_OUTPUT_DATA_WIDTH
        )
        port map(
            clk                          => clk,
            rst                          => rst,
            bias_reg_read_address_valid  => s_address_read_valid_from_bus_interconnect(BIAS_REGISTER_INTERCONNECT_INDEX),
            bias_reg_read_address_ready  => bias_reg_read_address_ready_from_bias_module,
            bias_reg_read_address        => s_address_read_from_bus_interconnect(BIAS_REGISTER_INTERCONNECT_INDEX * REGISTER_ADDRESS_WIDTH + clog2(BIAS_REGISTER_DEPTH) - 1 downto BIAS_REGISTER_INTERCONNECT_INDEX * REGISTER_ADDRESS_WIDTH),
            bias_reg_write_address_valid => s_address_write_valid_from_bus_interconnect(BIAS_REGISTER_INTERCONNECT_INDEX),
            bias_reg_write_address_ready => bias_reg_write_address_ready_from_bias_module,
            bias_reg_write_address       => s_address_write_from_bus_interconnect(BIAS_REGISTER_INTERCONNECT_INDEX * REGISTER_ADDRESS_WIDTH + clog2(BIAS_REGISTER_DEPTH) - 1 downto BIAS_REGISTER_INTERCONNECT_INDEX * REGISTER_ADDRESS_WIDTH),
            bias_reg_data_in_valid       => s_data_write_valid_from_bus_interconnect(BIAS_REGISTER_INTERCONNECT_INDEX),
            bias_reg_data_in_ready       => bias_reg_data_in_ready_from_bias_module,
            bias_reg_data_in             => bias_reg_data_in_vectorized_from_interconnect,
            bias_reg_data_out_valid      => bias_reg_data_out_valid_from_bias_module,
            bias_reg_data_out_ready      => s_data_read_ready_from_bus_interconnect(BIAS_REGISTER_INTERCONNECT_INDEX),
            bias_reg_data_out            => bias_reg_data_out_from_bias_module,

            bias_reg_address_valid       => bias_address_out_valid_from_pipeline_handler,
            bias_reg_address_ready       => bias_reg_address_ready_from_bias_module,
            bias_reg_address             => bias_address_out_from_pipeline_handler(clog2(BIAS_REGISTER_DEPTH) - 1 downto 0),
            data_in_valid                => data_out_valid_from_accumulator,
            data_in_ready                => data_in_ready_from_bias_module,
            data_in                      => data_out_from_accumulator,
            data_out_valid               => data_out_valid_from_bias_module,
            data_out_ready               => data_in_ready_from_resize_module,
            data_out                     => data_out_from_bias_module
        );
    

    process (data_out_from_bias_module)
    begin
        for i in 0 to SYSTOLIC_ARRAY_SIZE - 1 loop
            data_out_from_bias_module_not_signed(i) <= std_logic_vector(data_out_from_bias_module(i));
        end loop;
    end process;

    vector_resize_module_inst : entity work.vector_resize_module
        generic map(
            INPUT_WIDTH        => BIAS_OUTPUT_DATA_WIDTH,
            OUTPUT_WIDTH       => DATA_WIDTH,
            VECTOR_LENGTH      => SYSTOLIC_ARRAY_SIZE,
            RESIZE_MODE_LENGTH => RESIZE_MODE_LENGTH
        )
        port map(
            clk            => clk,
            rst            => rst,
            resize_mode    => resize_mode_out_from_pipeline_handler,
            data_in_valid  => data_out_valid_from_bias_module,
            data_in_ready  => data_in_ready_from_resize_module,
            data_in        => data_out_from_bias_module_not_signed,
            data_out_valid => data_out_valid_from_resize_module,
            data_out_ready => reg_data_from_resize_module_ready_from_pipeline_handler,
            data_out       => data_out_from_resize_module
        );
    
    register_write_data_flatten_from_interconnect <= s_data_write_from_bus_interconnect(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * VECTOR_REGISTER_INTERCONNECT_INDEX + DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * VECTOR_REGISTER_INTERCONNECT_INDEX);
    register_write_data_vectorized_from_interconnect <= vectorize(register_write_data_flatten_from_interconnect, DATA_WIDTH, SYSTOLIC_ARRAY_SIZE);

    vector_register_module_inst : entity work.vector_register_module
        generic map(
            DATA_WIDTH    => DATA_WIDTH,
            DEPTH         => REGISTER_ARRAY_DEPTH,
            VECTOR_LENGTH => SYSTOLIC_ARRAY_SIZE
        )
        port map(
            clk                          => clk,
            rst                          => rst,
            register_read_address_valid  => s_address_read_valid_from_bus_interconnect(VECTOR_REGISTER_INTERCONNECT_INDEX),
            register_read_address_ready  => register_read_address_ready_from_vector_register_module,
            register_read_address        => s_address_read_from_bus_interconnect(VECTOR_REGISTER_INTERCONNECT_INDEX * REGISTER_ADDRESS_WIDTH + clog2(REGISTER_ARRAY_DEPTH) - 1 downto VECTOR_REGISTER_INTERCONNECT_INDEX * REGISTER_ADDRESS_WIDTH),
            register_read_data_valid     => register_read_data_valid_from_vector_register_module,
            register_read_data_ready     => s_data_read_ready_from_bus_interconnect(VECTOR_REGISTER_INTERCONNECT_INDEX),
            register_read_data           => register_read_data_from_vector_register_module,

            register_write_address_valid => s_address_write_valid_from_bus_interconnect(VECTOR_REGISTER_INTERCONNECT_INDEX),
            register_write_address_ready => register_write_address_ready_from_vector_register_module,
            register_write_address       => s_address_write_from_bus_interconnect(VECTOR_REGISTER_INTERCONNECT_INDEX * REGISTER_ADDRESS_WIDTH + clog2(REGISTER_ARRAY_DEPTH) - 1 downto VECTOR_REGISTER_INTERCONNECT_INDEX * REGISTER_ADDRESS_WIDTH),
            register_write_data_valid    => s_data_write_valid_from_bus_interconnect(VECTOR_REGISTER_INTERCONNECT_INDEX),
            register_write_data_ready    => register_write_data_ready_from_vector_register_module,
            register_write_data          => register_write_data_vectorized_from_interconnect
        );
    
    data_read_from_bus_interconnect_vectorized <= vectorize(data_read_from_bus_interconnect, DATA_WIDTH, SYSTOLIC_ARRAY_SIZE);
    reg_write_data_out_from_pipeline_handler_flatten <= flatten(reg_write_data_out_from_pipeline_handler);
    s_address_read_ready_from_register_blocks(VECTOR_REGISTER_INTERCONNECT_INDEX) <= register_read_address_ready_from_vector_register_module;
    s_address_read_ready_from_register_blocks(BIAS_REGISTER_INTERCONNECT_INDEX) <= bias_reg_read_address_ready_from_bias_module;
    s_address_read_ready_from_register_blocks(SYS_ARRAY_REGISTER_INTERCONNECT_INDEX) <= weight_col_read_address_ready_from_sys_array;
    s_data_read_valid_from_register_blocks(VECTOR_REGISTER_INTERCONNECT_INDEX) <= register_read_data_valid_from_vector_register_module;
    s_data_read_valid_from_register_blocks(BIAS_REGISTER_INTERCONNECT_INDEX) <= bias_reg_data_out_valid_from_bias_module;
    s_data_read_valid_from_register_blocks(SYS_ARRAY_REGISTER_INTERCONNECT_INDEX) <= weight_out_valid_from_sys_array;
    s_data_read_from_register_blocks(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * VECTOR_REGISTER_INTERCONNECT_INDEX + DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * VECTOR_REGISTER_INTERCONNECT_INDEX) <= flatten(register_read_data_from_vector_register_module);
    s_data_read_from_register_blocks(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * BIAS_REGISTER_INTERCONNECT_INDEX + DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * BIAS_REGISTER_INTERCONNECT_INDEX) <= flatten(bias_reg_data_out_from_bias_module);
    s_data_read_from_register_blocks(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * SYS_ARRAY_REGISTER_INTERCONNECT_INDEX + DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * SYS_ARRAY_REGISTER_INTERCONNECT_INDEX) <= flatten(weight_out_from_sys_array);
    s_address_write_ready_from_register_blocks(VECTOR_REGISTER_INTERCONNECT_INDEX) <= register_write_address_ready_from_vector_register_module;
    s_address_write_ready_from_register_blocks(BIAS_REGISTER_INTERCONNECT_INDEX) <= bias_reg_write_address_ready_from_bias_module;
    s_address_write_ready_from_register_blocks(SYS_ARRAY_REGISTER_INTERCONNECT_INDEX) <= weight_col_write_address_ready_from_sys_array;
    s_data_write_ready_from_register_blocks(VECTOR_REGISTER_INTERCONNECT_INDEX) <= register_write_data_ready_from_vector_register_module;
    s_data_write_ready_from_register_blocks(BIAS_REGISTER_INTERCONNECT_INDEX) <= bias_reg_data_in_ready_from_bias_module;
    s_data_write_ready_from_register_blocks(SYS_ARRAY_REGISTER_INTERCONNECT_INDEX) <= weight_in_ready_from_sys_array;


    bus_interconnect_inst : entity work.bus_interconnect -- Trash mechanic if address is out of range
        generic map(
            ADDRESS_WIDTH    => REGISTER_ADDRESS_WIDTH,
            DATA_WIDTH       => DATA_WIDTH * SYSTOLIC_ARRAY_SIZE,
            NUMBER_OF_SLAVES => NUMBER_OF_REGISTER_BLOCKS,
            DEFAULT_SLAVE    => 0,
            SLAVE_BASE_ADDR  => REGISTER_BASE_ADDRESSES,
            SLAVE_ADDR_MASK  => REGISTER_ADDRESS_MASKS
        )
        port map(
            clk                     => clk,
            rst                     => rst,
            address_read_valid      => reg_read_address_out_valid_from_pipeline_input_handler,
            address_read_ready      => address_read_ready_from_bus_interconnect,
            address_read            => reg_read_address_out_from_pipeline_input_handler,
            data_read_valid         => data_read_valid_from_bus_interconnect,
            data_read_ready         => reg_read_data_in_ready_from_pipeline_input_handler,
            data_read               => data_read_from_bus_interconnect,
            address_write_valid     => reg_write_address_out_valid_from_pipeline_handler,
            address_write_ready     => address_write_ready_from_bus_interconnect,
            address_write           => reg_write_address_out_from_pipeline_handler,
            data_write_valid        => reg_write_data_out_valid_from_pipeline_handler,
            data_write_ready        => data_write_ready_from_bus_interconnect,
            data_write              => reg_write_data_out_from_pipeline_handler_flatten,

            s_address_read_valid    => s_address_read_valid_from_bus_interconnect,
            s_address_read_ready    => s_address_read_ready_from_register_blocks,
            s_address_read          => s_address_read_from_bus_interconnect,
            s_data_read_valid       => s_data_read_valid_from_register_blocks,
            s_data_read_ready       => s_data_read_ready_from_bus_interconnect,
            s_data_read             => s_data_read_from_register_blocks,
            s_address_write_valid   => s_address_write_valid_from_bus_interconnect,
            s_address_write_ready   => s_address_write_ready_from_register_blocks,
            s_address_write         => s_address_write_from_bus_interconnect,
            s_data_write_valid      => s_data_write_valid_from_bus_interconnect,
            s_data_write_ready      => s_data_write_ready_from_register_blocks,
            s_data_write            => s_data_write_from_bus_interconnect,

            address_writeback_valid => address_writeback_valid_from_bus_interconnect,
            address_writeback_ready => register_write_back_address_ready_from_pipeline_input_handler,
            address_writeback       => address_writeback_from_bus_interconnect
        );
    

end Behavioral;
