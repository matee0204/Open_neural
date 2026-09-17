----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/29/2026 06:45:48 PM
-- Design Name: 
-- Module Name: neural_engine_top - Behavioral
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

entity neural_engine_top is
    generic (
        INSTRUCTION_LENGTH                           : natural := 64;
        OPERATION_CODE_WIDTH                         : natural := 7;
        MEMORY_ADDRESS_WIDTH                         : natural := 32;
        REGISTER_ADDRESS_WIDTH                       : natural := 10;
        REGISTER_ARRAY_DEPTH                         : natural := 128;
        CONTROL_SIGNAL_FIFO_DEPTH                    : natural := 16;
        SYSTOLIC_ARRAY_WEIGHT_ADDRESS_WIDTH          : natural := 8;
        BIAS_ADDRESS_WIDTH                           : natural := 8;
        BIAS_REGISTER_DEPTH                          : natural := 128;
        BIAS_OUTPUT_DATA_WIDTH                       : natural := 32;
        ACCUMULATOR_ADDRESS_WIDTH                    : natural := 8;
        ACCUMULATOR_DEPTH                            : natural := 128;
        ACCUMULATOR_OUTPUT_DATA_WIDTH                : natural := 32;
        ACCUMULATOR_MODE_LENGTH                      : natural := 3;
        RESIZE_MODE_LENGTH                           : natural := 3;
        NUM_OF_ACCUMULATOR_REGISTERS                 : natural := 32;
        DATA_WIDTH                                   : natural := 8;
        SYSTOLIC_ARRAY_SIZE                          : natural := 8;
        SYSTOLIC_ARRAY_OUTPUT_DATA_WIDTH             : natural := 24;
        SYSTOLIC_ARRAY_WEIGHT_REGISTER_DEPTH         : natural := 2
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
end neural_engine_top;

architecture Behavioral of neural_engine_top is
    constant NUMBER_OF_REGISTER_BLOCKS_TO_INTERCONNECT          : natural := 5;
    constant VECTOR_REGISTER_BASE_ADDRESS                       : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(16#0#, REGISTER_ADDRESS_WIDTH));
    constant BIAS_REGISTER_BASE_ADDRESS                         : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(16#100#, REGISTER_ADDRESS_WIDTH));
    constant SYSTOLIC_ARRAY_WEIGHT_REGISTER_BASE_ADDRESS        : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(16#200#, REGISTER_ADDRESS_WIDTH));
    constant SYSTOLIC_ARRAY_INPUT_BASE_ADDRESS                  : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(16#300#, REGISTER_ADDRESS_WIDTH));
    constant MEMORY_INTERFACE_INPUT_BASE_ADDRESS                : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(16#301#, REGISTER_ADDRESS_WIDTH));
    constant VECTOR_REGISTER_ADDRESS_MASK                       : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(16#7F#, REGISTER_ADDRESS_WIDTH));
    constant BIAS_REGISTER_ADDRESS_MASK                         : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(16#7F#, REGISTER_ADDRESS_WIDTH));
    constant SYSTOLIC_ARRAY_WEIGHT_REGISTER_ADDRESS_MASK        : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(16#F#, REGISTER_ADDRESS_WIDTH));
    constant SYSTOLIC_ARRAY_INPUT_ADDRESS_MASK                  : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(16#0#, REGISTER_ADDRESS_WIDTH));
    constant MEMORY_INTERFACE_INPUT_ADDRESS_MASK                : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0) := std_logic_vector(to_unsigned(16#0#, REGISTER_ADDRESS_WIDTH));
    constant REGISTER_BASE_ADDRESSES_TO_INTERCONNECT            : std_logic_vector(REGISTER_ADDRESS_WIDTH * NUMBER_OF_REGISTER_BLOCKS_TO_INTERCONNECT - 1 downto 0) := VECTOR_REGISTER_BASE_ADDRESS &
                                                                                                                                                                       BIAS_REGISTER_BASE_ADDRESS &
                                                                                                                                                                       SYSTOLIC_ARRAY_WEIGHT_REGISTER_BASE_ADDRESS &
                                                                                                                                                                       SYSTOLIC_ARRAY_INPUT_BASE_ADDRESS &
                                                                                                                                                                       MEMORY_INTERFACE_INPUT_BASE_ADDRESS;
    constant REGISTER_ADDRESS_MASKS_TO_INTERCONNECT             : std_logic_vector(REGISTER_ADDRESS_WIDTH * NUMBER_OF_REGISTER_BLOCKS_TO_INTERCONNECT - 1 downto 0) := VECTOR_REGISTER_ADDRESS_MASK &
                                                                                                                                                                       BIAS_REGISTER_ADDRESS_MASK &
                                                                                                                                                                       SYSTOLIC_ARRAY_WEIGHT_REGISTER_ADDRESS_MASK &
                                                                                                                                                                       SYSTOLIC_ARRAY_INPUT_ADDRESS_MASK &
                                                                                                                                                                       MEMORY_INTERFACE_INPUT_ADDRESS_MASK;

    constant NUM_OF_REGISTER_WRITER_INSTANCES                   : natural := 3;
    constant REGISTER_WRITE_INSTANCE_LOAD_INDEX                 : natural := 0;
    constant REGISTER_WRITE_INSTANCE_MOV_INDEX                  : natural := 1;
    constant REGISTER_WRITE_INSTANCE_BIAS_QUANT_INDEX           : natural := 2;
    
    constant VECTOR_REGISTER_INTERCONNECT_INDEX                 : natural := 0;
    constant BIAS_REGISTER_INTERCONNECT_INDEX                   : natural := 1;
    constant SYS_ARRAY_REGISTER_INTERCONNECT_INDEX              : natural := 2;
    constant SYS_ARRAY_INPUT_INTERCONNECT_INDEX                 : natural := 3;
    constant MEMORY_WRITE_INTERFACE_INTERCONNECT_INDEX          : natural := 4;

    constant NUMBER_OF_REGISTER_BLOCKS_TO_PIPEINE_INPUT_HANDLER : natural := 3;

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
    signal accumulator_mode_valid_from_decoder : std_logic;
    signal accumulator_mode_from_decoder : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
    signal selected_accumulator_bank_read_valid_from_decoder : std_logic;
    signal selected_accumulator_bank_read_from_decoder : std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0);
    signal selected_bias_bank_valid_from_decoder : std_logic;
    signal selected_bias_bank_from_decoder : std_logic_vector(BIAS_ADDRESS_WIDTH - 1 downto 0);
    signal resize_module_mode_valid_from_decoder : std_logic;
    signal resize_module_mode_from_decoder : std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);

    signal register_write_address_ready_lines_from_sources : std_logic_vector(NUM_OF_REGISTER_WRITER_INSTANCES - 1 downto 0);

    signal opcode_in_ready_from_pipeline_input_handler : std_logic;
    signal memory_read_address_ready_from_pipeline_input_handler : std_logic;
    signal memory_write_address_ready_from_pipeline_input_handler : std_logic;
    signal register_read_address_ready_from_pipeline_input_handler : std_logic;
    signal register_write_address_ready_from_pipeline_input_handler : std_logic;
    signal systolic_array_selected_weight_bank_ready_from_pipeline_input_handler : std_logic;
    signal selected_accumulator_bank_write_ready_from_pipeline_input_handler : std_logic;
    signal accumulator_mode_ready_from_pipeline_input_handler : std_logic;
    signal selected_accumulator_bank_read_ready_from_pipeline_input_handler : std_logic;
    signal selected_bias_bank_ready_from_pipeline_input_handler : std_logic;
    signal resize_module_mode_ready_from_pipeline_input_handler : std_logic;
    signal memory_read_address_out_valid_from_pipeline_input_handler : std_logic;
    signal memory_read_address_out_from_pipeline_input_handler : std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);
    signal memory_write_address_out_valid_from_pipeline_input_handler : std_logic;
    signal memory_write_address_out_from_pipeline_input_handler : std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);
    signal reg_read_address_out_valid_from_pipeline_input_handler : std_logic;
    signal reg_read_address_out_from_pipeline_input_handler : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0);
    signal reg_write_address_out_valid_from_pipeline_input_handler : std_logic_vector(NUM_OF_REGISTER_WRITER_INSTANCES - 1 downto 0);
    signal reg_write_address_out_from_pipeline_input_handler : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0);
    signal sys_array_bank_address_out_valid_from_pipeline_input_handler : std_logic;
    signal sys_array_bank_address_out_from_pipeline_input_handler : std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_WIDTH - 1 downto 0);
    signal accu_address_write_out_valid_from_pipeline_input_handler : std_logic;
    signal accu_address_write_out_from_pipeline_input_handler : std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0);
    signal accu_mode_out_valid_from_pipeline_input_handler : std_logic;
    signal accu_mode_out_from_pipeline_input_handler : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
    signal accu_address_read_out_valid_from_pipeline_input_handler : std_logic;
    signal accu_address_read_out_from_pipeline_input_handler : std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0);
    signal bias_address_out_valid_from_pipeline_input_handler : std_logic;
    signal bias_address_out_from_pipeline_input_handler : std_logic_vector(BIAS_ADDRESS_WIDTH - 1 downto 0);
    signal resize_mode_out_valid_from_pipeline_input_handler : std_logic;
    signal resize_mode_out_from_pipeline_input_handler : std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);
    signal register_write_back_address_ready_from_pipeline_input_handler : std_logic;
    signal accumulator_write_back_address_ready_from_pipeline_input_handler : std_logic;

    signal data_in_ready_from_memory_writer_fifo : std_logic;
    signal data_out_valid_from_memory_writer_fifo : std_logic;
    signal data_out_from_memory_writer_fifo : std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);

    signal write_address_in_ready_from_register_writer : std_logic;
    signal read_data_in_ready_from_register_writer : std_logic;
    signal write_address_out_valid_from_register_writer : std_logic;
    signal write_address_out_from_register_writer : std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);
    signal write_data_out_valid_from_register_writer : std_logic;
    signal write_data_out_from_register_writer : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
    signal write_data_out_from_register_writer_flatten : std_logic_vector(SYSTOLIC_ARRAY_SIZE * DATA_WIDTH - 1 downto 0);
    signal memory_write_data_flatten_from_interconnect : std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto 0);
    signal memory_write_data_vectorized_from_interconnect : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);

    signal memory_reader_control_signal_in_valid : std_logic;
    signal memory_reader_control_signal_in : std_logic_vector(MEMORY_ADDRESS_WIDTH + REGISTER_ADDRESS_WIDTH - 1 downto 0);
    signal data_in_ready_from_memory_read_fifo : std_logic;
    signal data_out_valid_from_memory_read_fifo : std_logic;
    signal data_out_from_memory_read_fifo : std_logic_vector(MEMORY_ADDRESS_WIDTH + REGISTER_ADDRESS_WIDTH - 1 downto 0);

    signal mem_read_address_in_ready_from_memory_reader : std_logic;
    signal mem_read_address_out_valid_from_memory_reader : std_logic;
    signal mem_read_address_out_from_memory_reader : std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);
    signal mem_data_in_ready_from_memory_reader : std_logic;
    signal reg_write_address_in_ready_from_memory_reader : std_logic;
    signal reg_write_address_out_valid_from_memory_reader : std_logic;
    signal reg_write_address_out_from_memory_reader : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0);
    signal reg_data_out_valid_from_memory_reader : std_logic;
    signal reg_data_out_from_memory_reader : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
    signal memory_read_data_in_from_memory_vectorized : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
    signal memory_read_control_signals_ready : std_logic;

    signal data_in_ready_from_systolic_array_input : std_logic;
    signal data_out_valid_from_systolic_array_input : std_logic;
    signal data_out_from_systolic_array_input : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
    
    signal data_in_ready_from_systolic_array_fifo : std_logic;
    signal data_out_valid_from_systolic_array_fifo : std_logic;
    signal data_out_from_systolic_array_fifo : std_logic_vector(clog2(SYSTOLIC_ARRAY_WEIGHT_REGISTER_DEPTH) - 1 downto 0);

    signal sys_array_input_data_flatten_from_interconnect : std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto 0);
    signal sys_array_input_data_vectorized_from_interconnect : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
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

    signal accumulator_write_control_signal_in_valid : std_logic;
    signal accumulator_write_control_signal_in : std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH + ACCUMULATOR_MODE_LENGTH - 1 downto 0);
    signal data_in_ready_from_accumulator_write_fifo : std_logic;
    signal data_out_valid_from_accumulator_write_fifo : std_logic;
    signal data_out_from_accumulator_write_fifo : std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH + ACCUMULATOR_MODE_LENGTH - 1 downto 0);

    signal data_in_ready_from_accumulator_read_fifo : std_logic;
    signal data_out_valid_from_accumulator_read_fifo : std_logic;
    signal data_out_from_accumulator_read_fifo : std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0);

    signal accumulator_mode_ready_from_accumulator : std_logic;
    signal accumulator_write_address_ready_from_accumulator : std_logic;
    signal accumulator_read_address_ready_from_accumulator : std_logic;
    signal data_out_valid_from_accumulator : std_logic;
    signal data_in_ready_from_accumulator : std_logic;
    signal data_out_from_accumulator : data_vector_signed(0 to SYSTOLIC_ARRAY_SIZE - 1)(ACCUMULATOR_OUTPUT_DATA_WIDTH - 1 downto 0);
    signal accumulator_write_control_signals_ready : std_logic;
    signal accumulator_write_back_address_valid_from_accumulator : std_logic;
    signal accumulator_write_back_address_from_accumulator : std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0);

    signal data_in_ready_from_bias_module_fifo : std_logic;
    signal data_out_valid_from_bias_module_fifo : std_logic;
    signal data_out_from_bias_module_fifo : std_logic_vector(clog2(BIAS_REGISTER_DEPTH) - 1 downto 0);

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

    signal resize_control_signal_in_valid : std_logic;
    signal resize_control_signal_in : std_logic_vector(RESIZE_MODE_LENGTH + REGISTER_ADDRESS_WIDTH - 1 downto 0);
    signal data_in_ready_from_resize_module_fifo : std_logic;
    signal data_out_valid_from_resize_module_fifo : std_logic;
    signal data_out_resize_from_module_fifo : std_logic_vector(RESIZE_MODE_LENGTH + REGISTER_ADDRESS_WIDTH - 1 downto 0);

    signal control_signals_ready_from_resize : std_logic;
    signal resize_mode_ready_from_resize_module : std_logic;
    signal write_address_in_ready_from_resize_module : std_logic;
    signal data_in_ready_from_resize_module : std_logic;
    signal write_address_out_valid_from_resize_module : std_logic;
    signal write_address_out_from_resize_module : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0);
    signal data_out_valid_from_resize_module : std_logic;
    signal data_out_from_resize_module : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
    
    signal reg_address_in_valid_lines_combined : std_logic_vector(NUM_OF_REGISTER_WRITER_INSTANCES - 1 downto 0);
    signal reg_address_in_ready_lines_from_register_writer : std_logic_vector(NUM_OF_REGISTER_WRITER_INSTANCES - 1 downto 0);
    signal reg_address_in_lines_from_combined : data_vector(0 to NUM_OF_REGISTER_WRITER_INSTANCES - 1)(REGISTER_ADDRESS_WIDTH - 1 downto 0);
    signal reg_data_in_valid_lines_combined : std_logic_vector(NUM_OF_REGISTER_WRITER_INSTANCES - 1 downto 0);
    signal reg_data_in_ready_lines_from_register_writer : std_logic_vector(NUM_OF_REGISTER_WRITER_INSTANCES - 1 downto 0);
    signal reg_data_in_lines_combined : data_matrix(0 to NUM_OF_REGISTER_WRITER_INSTANCES - 1)(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);
    signal reg_address_valid_from_register_writer : std_logic;
    signal reg_address_from_register_writer : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0);
    signal reg_data_valid_from_register_writer : std_logic;
    signal reg_data_from_register_writer : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);

    signal register_reader_control_signals_in_valid : std_logic;
    signal register_reader_control_signals_in : std_logic_vector(REGISTER_ADDRESS_WIDTH + REGISTER_ADDRESS_WIDTH - 1 downto 0);
    signal data_in_ready_from_register_reader_fifo : std_logic;
    signal data_out_valid_from_register_reader_fifo : std_logic;
    signal data_out_from_register_from_register_reader_fifo : std_logic_vector(REGISTER_ADDRESS_WIDTH + REGISTER_ADDRESS_WIDTH - 1 downto 0);

    signal register_reader_control_signals_ready : std_logic;
    signal register_read_address_in_ready_from_register_reader : std_logic;
    signal register_read_address_out_valid_from_register_reader : std_logic;
    signal register_read_address_out_from_register_reader : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0);
    signal register_write_address_in_ready_from_register_reader : std_logic;
    signal register_write_address_out_valid_from_register_reader : std_logic;
    signal register_write_address_out_from_register_reader : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0);
    signal register_data_in_ready_from_register_reader : std_logic;
    signal register_data_out_valid_from_register_reader : std_logic;
    signal register_data_out_from_register_reader : data_vector(0 to SYSTOLIC_ARRAY_SIZE - 1)(DATA_WIDTH - 1 downto 0);

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
    signal reg_write_data_out_from_pipeline_handler_flatten : std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto 0);
    signal s_address_read_valid_from_bus_interconnect : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS_TO_INTERCONNECT - 1 downto 0);
    signal s_address_read_from_bus_interconnect : std_logic_vector(REGISTER_ADDRESS_WIDTH * NUMBER_OF_REGISTER_BLOCKS_TO_INTERCONNECT - 1 downto 0);
    signal s_data_read_ready_from_bus_interconnect : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS_TO_INTERCONNECT - 1 downto 0);
    signal s_address_write_valid_from_bus_interconnect : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS_TO_INTERCONNECT - 1 downto 0);
    signal s_address_write_from_bus_interconnect : std_logic_vector(REGISTER_ADDRESS_WIDTH * NUMBER_OF_REGISTER_BLOCKS_TO_INTERCONNECT - 1 downto 0);
    signal s_data_write_valid_from_bus_interconnect : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS_TO_INTERCONNECT - 1 downto 0);
    signal s_data_write_from_bus_interconnect : std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * NUMBER_OF_REGISTER_BLOCKS_TO_INTERCONNECT - 1 downto 0); 
    signal s_address_read_ready_from_register_blocks : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS_TO_INTERCONNECT - 1 downto 0);
    signal s_data_read_valid_from_register_blocks : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS_TO_INTERCONNECT - 1 downto 0);
    signal s_data_read_from_register_blocks : std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * NUMBER_OF_REGISTER_BLOCKS_TO_INTERCONNECT - 1 downto 0);
    signal s_address_write_ready_from_register_blocks : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS_TO_INTERCONNECT - 1 downto 0);
    signal s_data_write_ready_from_register_blocks : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS_TO_INTERCONNECT - 1 downto 0);
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
            RESIZE_MODE_LENGTH                   => RESIZE_MODE_LENGTH,
            SYS_ARRAY_INPUT_BASE_ADDRESS         => SYSTOLIC_ARRAY_INPUT_BASE_ADDRESS,
            MEM_INTERFACE_INPUT_BASE_ADDRESS     => MEMORY_INTERFACE_INPUT_BASE_ADDRESS
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
            accumulator_mode_valid                    => accumulator_mode_valid_from_decoder,
            accumulator_mode_ready                    => accumulator_mode_ready_from_pipeline_input_handler,
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

    register_write_address_ready_lines_from_sources <= data_in_ready_from_resize_module_fifo & data_in_ready_from_register_reader_fifo & data_in_ready_from_memory_read_fifo;

    pipeline_input_handler : entity work.pipeline_input_handler
        generic map(
            NUM_OF_VECTOR_REGISTERS                => REGISTER_ARRAY_DEPTH,
            NUM_OF_BIAS_REGISTERS                  => BIAS_REGISTER_DEPTH,
            NUM_OF_SYSTOLIC_ARRAY_WEIGHT_REGISTERS => SYSTOLIC_ARRAY_SIZE * SYSTOLIC_ARRAY_WEIGHT_REGISTER_DEPTH,
            NUM_OF_ACCUMULATOR_REGISTERS           => NUM_OF_ACCUMULATOR_REGISTERS,

            NUM_OF_VECTOR_REGISTER_BLOCKS          => NUMBER_OF_REGISTER_BLOCKS_TO_PIPEINE_INPUT_HANDLER,
            VECTOR_REGISTER_BASE_ADDRESS           => VECTOR_REGISTER_BASE_ADDRESS,
            BIAS_REGISTER_BASE_ADDRESS             => BIAS_REGISTER_BASE_ADDRESS,
            SYS_ARRAY_REGISTER_BASE_ADDRESS        => SYSTOLIC_ARRAY_WEIGHT_REGISTER_BASE_ADDRESS,
            VECTOR_REGISTER_ADDRESS_MASK           => VECTOR_REGISTER_ADDRESS_MASK,
            BIAS_REGISTER_ADDRESS_MASK             => BIAS_REGISTER_ADDRESS_MASK,
            SYS_ARRAY_REGISTER_ADDRESS_MASK        => SYSTOLIC_ARRAY_WEIGHT_REGISTER_ADDRESS_MASK,

            OPERATION_CODE_LENGTH                  => OPERATION_CODE_WIDTH,
            MEMORY_ADDRESS_LENGTH                  => MEMORY_ADDRESS_WIDTH,
            REGISTER_ADDRESS_LENGTH                => REGISTER_ADDRESS_WIDTH,
            NUM_OF_REGISTER_WRITER_INSTANCES       => NUM_OF_REGISTER_WRITER_INSTANCES,
            SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH   => SYSTOLIC_ARRAY_WEIGHT_ADDRESS_WIDTH,
            BIAS_ADDRESS_LENGTH                    => BIAS_ADDRESS_WIDTH,
            ACCUMULATOR_ADDRESS_LENGTH             => ACCUMULATOR_ADDRESS_WIDTH,
            ACCUMULATOR_MODE_LENGTH                => ACCUMULATOR_MODE_LENGTH,
            RESIZE_MODE_LENGTH                     => RESIZE_MODE_LENGTH
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
            accumulator_mode_valid                    => accumulator_mode_valid_from_decoder,
            accumulator_mode_ready                    => accumulator_mode_ready_from_pipeline_input_handler,
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

            memory_read_address_out_valid             => memory_read_address_out_valid_from_pipeline_input_handler,
            memory_read_address_out_ready             => data_in_ready_from_memory_read_fifo,
            memory_read_address_out                   => memory_read_address_out_from_pipeline_input_handler,
            memory_write_address_out_valid            => memory_write_address_out_valid_from_pipeline_input_handler,
            memory_write_address_out_ready            => data_in_ready_from_memory_writer_fifo,
            memory_write_address_out                  => memory_write_address_out_from_pipeline_input_handler,
            reg_write_address_out_valid               => reg_write_address_out_valid_from_pipeline_input_handler,
            reg_write_address_out_ready               => register_write_address_ready_lines_from_sources,
            reg_write_address_out                     => reg_write_address_out_from_pipeline_input_handler,
            reg_read_address_out_valid                => reg_read_address_out_valid_from_pipeline_input_handler,
            reg_read_address_out_ready                => data_in_ready_from_register_reader_fifo,
            reg_read_address_out                      => reg_read_address_out_from_pipeline_input_handler,
            sys_array_bank_address_out_valid          => sys_array_bank_address_out_valid_from_pipeline_input_handler,
            sys_array_bank_address_out_ready          => data_in_ready_from_systolic_array_fifo,
            sys_array_bank_address_out                => sys_array_bank_address_out_from_pipeline_input_handler,
            accu_address_write_out_valid              => accu_address_write_out_valid_from_pipeline_input_handler,
            accu_address_write_out_ready              => data_in_ready_from_accumulator_write_fifo,
            accu_address_write_out                    => accu_address_write_out_from_pipeline_input_handler,
            accu_mode_out_valid                       => accu_mode_out_valid_from_pipeline_input_handler,
            accu_mode_out_ready                       => data_in_ready_from_accumulator_write_fifo,
            accu_mode_out                             => accu_mode_out_from_pipeline_input_handler,
            accu_address_read_out_valid               => accu_address_read_out_valid_from_pipeline_input_handler,
            accu_address_read_out_ready               => data_in_ready_from_accumulator_read_fifo,
            accu_address_read_out                     => accu_address_read_out_from_pipeline_input_handler,
            bias_address_out_valid                    => bias_address_out_valid_from_pipeline_input_handler,
            bias_address_out_ready                    => data_in_ready_from_bias_module_fifo,
            bias_address_out                          => bias_address_out_from_pipeline_input_handler,
            resize_mode_out_valid                     => resize_mode_out_valid_from_pipeline_input_handler,
            resize_mode_out_ready                     => data_in_ready_from_resize_module_fifo,
            resize_mode_out                           => resize_mode_out_from_pipeline_input_handler,
            register_write_back_address_valid         => address_writeback_valid_from_bus_interconnect,
            register_write_back_address_ready         => register_write_back_address_ready_from_pipeline_input_handler,
            register_write_back_address               => address_writeback_from_bus_interconnect,
            register_write_back_ready                 => address_write_ready_from_bus_interconnect,
            accumulator_write_back_address_valid      => accumulator_write_back_address_valid_from_accumulator,
            accumulator_write_back_address_ready      => accumulator_write_back_address_ready_from_pipeline_input_handler,
            accumulator_write_back_address            => accumulator_write_back_address_from_accumulator,
            accumulator_write_back_ready              => data_in_ready_from_accumulator
        );

    fifo_to_memory_write_interface_inst : entity work.fifo
        generic map(
            DATA_WIDTH => MEMORY_ADDRESS_WIDTH,
            FIFO_DEPTH => CONTROL_SIGNAL_FIFO_DEPTH
        )
        port map(
            clk            => clk,
            rst            => rst,

            data_in_valid  => memory_write_address_out_valid_from_pipeline_input_handler,
            data_in_ready  => data_in_ready_from_memory_writer_fifo,
            data_in        => memory_write_address_out_from_pipeline_input_handler,
            
            data_out_valid => data_out_valid_from_memory_writer_fifo,
            data_out_ready => write_address_in_ready_from_register_writer,
            data_out       => data_out_from_memory_writer_fifo
        );
    

    write_data_out_from_register_writer_flatten <= flatten(write_data_out_from_register_writer);
    memory_write_data_out <= write_data_out_from_register_writer_flatten;
    memory_write_data_out_valid <= write_data_out_valid_from_register_writer;
    memory_write_address_out <= write_address_out_from_register_writer;
    memory_write_address_out_valid <= write_address_out_valid_from_register_writer;
    memory_write_data_flatten_from_interconnect <= s_data_write_from_bus_interconnect(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * MEMORY_WRITE_INTERFACE_INTERCONNECT_INDEX + DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * MEMORY_WRITE_INTERFACE_INTERCONNECT_INDEX);
    memory_write_data_vectorized_from_interconnect <= vectorize(memory_write_data_flatten_from_interconnect, DATA_WIDTH, SYSTOLIC_ARRAY_SIZE);

    memory_write_interface_inst : entity work.memory_write_interface
        generic map(
            WRITE_ADDRESS_LENGTH => MEMORY_ADDRESS_WIDTH,
            VECTOR_LENGTH        => SYSTOLIC_ARRAY_SIZE,
            DATA_WIDTH           => DATA_WIDTH
        )
        port map(
            clk                     => clk,
            rst                     => rst,
            
            write_address_in_valid  => data_out_valid_from_memory_writer_fifo,
            write_address_in_ready  => write_address_in_ready_from_register_writer,
            write_address_in        => data_out_from_memory_writer_fifo,

            read_data_in_valid      => s_data_write_valid_from_bus_interconnect(MEMORY_WRITE_INTERFACE_INTERCONNECT_INDEX),
            read_data_in_ready      => read_data_in_ready_from_register_writer,
            read_data_in            => memory_write_data_vectorized_from_interconnect,
            
            write_address_out_valid => write_address_out_valid_from_register_writer,
            write_address_out_ready => memory_write_address_out_ready,
            write_address_out       => write_address_out_from_register_writer,
            
            write_data_out_valid    => write_data_out_valid_from_register_writer,
            write_data_out_ready    => memory_write_data_out_ready,
            write_data_out          => write_data_out_from_register_writer
        );
    

    memory_reader_control_signal_in_valid <= memory_read_address_out_valid_from_pipeline_input_handler and reg_write_address_out_valid_from_pipeline_input_handler(REGISTER_WRITE_INSTANCE_LOAD_INDEX);
    memory_reader_control_signal_in <= memory_read_address_out_from_pipeline_input_handler & reg_write_address_out_from_pipeline_input_handler;

    fifo_to_memory_reader_inst : entity work.fifo
        generic map(
            DATA_WIDTH => MEMORY_ADDRESS_WIDTH + REGISTER_ADDRESS_WIDTH,
            FIFO_DEPTH => CONTROL_SIGNAL_FIFO_DEPTH
        )
        port map(
            clk            => clk,
            rst            => rst,

            data_in_valid  => memory_reader_control_signal_in_valid,
            data_in_ready  => data_in_ready_from_memory_read_fifo,
            data_in        => memory_reader_control_signal_in,

            data_out_valid => data_out_valid_from_memory_read_fifo,
            data_out_ready => memory_read_control_signals_ready,
            data_out       => data_out_from_memory_read_fifo
        );
    

    memory_read_address_out_valid <= mem_read_address_out_valid_from_memory_reader;
    memory_read_address_out <= mem_read_address_out_from_memory_reader;
    memory_read_data_in_from_memory_vectorized <= vectorize(memory_read_data_in, DATA_WIDTH, SYSTOLIC_ARRAY_SIZE);
    memory_read_data_in_ready <= mem_data_in_ready_from_memory_reader;
    memory_read_control_signals_ready <= mem_read_address_in_ready_from_memory_reader and reg_write_address_in_ready_from_memory_reader;

    memory_read_interface_inst : entity work.memory_read_interface
        generic map(
            READ_ADDRESS_LENGTH => REGISTER_ADDRESS_WIDTH,
            WRITE_ADDRESS_LENGTH   => MEMORY_ADDRESS_WIDTH,
            VECTOR_LENGTH           => SYSTOLIC_ARRAY_SIZE,
            DATA_WIDTH              => DATA_WIDTH
        )
        port map(
            clk                         => clk,
            rst                         => rst,

            read_address_in_valid   => data_out_valid_from_memory_read_fifo,
            read_address_in_ready   => mem_read_address_in_ready_from_memory_reader,
            read_address_in         => data_out_from_memory_read_fifo(MEMORY_ADDRESS_WIDTH + REGISTER_ADDRESS_WIDTH - 1 downto REGISTER_ADDRESS_WIDTH),

            read_address_out_valid  => mem_read_address_out_valid_from_memory_reader,
            read_address_out_ready  => memory_read_address_out_ready,
            read_address_out        => mem_read_address_out_from_memory_reader,

            data_in_valid           => memory_read_data_in_valid,
            data_in_ready           => mem_data_in_ready_from_memory_reader,
            data_in                 => memory_read_data_in_from_memory_vectorized,

            write_address_in_valid  => data_out_valid_from_memory_read_fifo,
            write_address_in_ready  => reg_write_address_in_ready_from_memory_reader,
            write_address_in        => data_out_from_memory_read_fifo(REGISTER_ADDRESS_WIDTH - 1 downto 0),
            
            write_address_out_valid => reg_write_address_out_valid_from_memory_reader,
            write_address_out_ready => reg_address_in_ready_lines_from_register_writer(REGISTER_WRITE_INSTANCE_LOAD_INDEX),
            write_address_out       => reg_write_address_out_from_memory_reader,

            data_out_valid          => reg_data_out_valid_from_memory_reader,
            data_out_ready          => reg_data_in_ready_lines_from_register_writer(REGISTER_WRITE_INSTANCE_LOAD_INDEX),
            data_out                => reg_data_out_from_memory_reader
        );
    

    sys_array_input_data_flatten_from_interconnect <= s_data_write_from_bus_interconnect(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * SYS_ARRAY_INPUT_INTERCONNECT_INDEX + DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * SYS_ARRAY_INPUT_INTERCONNECT_INDEX);
    sys_array_input_data_vectorized_from_interconnect <= vectorize(sys_array_input_data_flatten_from_interconnect, DATA_WIDTH, SYSTOLIC_ARRAY_SIZE);

    systolic_array_input_vector_aligner_inst : entity work.systolic_array_vector_aligner(input)
        generic map(
            DATA_WIDTH    => DATA_WIDTH,
            VECTOR_LENGTH => SYSTOLIC_ARRAY_SIZE
        )
        port map(
            clk            => clk,
            rst            => rst,
            data_in_valid  => s_data_write_valid_from_bus_interconnect(SYS_ARRAY_INPUT_INTERCONNECT_INDEX),
            data_in_ready  => data_in_ready_from_systolic_array_input,
            data_in        => sys_array_input_data_vectorized_from_interconnect,
            data_out_valid => data_out_valid_from_systolic_array_input,
            data_out_ready => data_in_ready_from_sys_array,
            data_out       => data_out_from_systolic_array_input
        );
    
    fifo_to_systolic_array_inst : entity work.fifo
        generic map(
            DATA_WIDTH => clog2(SYSTOLIC_ARRAY_WEIGHT_REGISTER_DEPTH),
            FIFO_DEPTH => CONTROL_SIGNAL_FIFO_DEPTH
        )
        port map(
            clk            => clk,
            rst            => rst,

            data_in_valid  => sys_array_bank_address_out_valid_from_pipeline_input_handler,
            data_in_ready  => data_in_ready_from_systolic_array_fifo,
            data_in        => sys_array_bank_address_out_from_pipeline_input_handler(clog2(SYSTOLIC_ARRAY_WEIGHT_REGISTER_DEPTH) - 1 downto 0),
            
            data_out_valid => data_out_valid_from_systolic_array_fifo,
            data_out_ready => selected_weight_bank_ready_from_sys_array,
            data_out       => data_out_from_systolic_array_fifo
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

            selected_weight_bank_valid     => data_out_valid_from_systolic_array_fifo,
            selected_weight_bank_ready     => selected_weight_bank_ready_from_sys_array,
            selected_weight_bank           => data_out_from_systolic_array_fifo,
            data_in_valid                  => data_out_valid_from_systolic_array_input,
            data_in_ready                  => data_in_ready_from_sys_array,
            data_in                        => data_out_from_systolic_array_input,
            result_out_valid               => result_out_valid_from_sys_array,
            result_out_ready               => data_in_ready_from_systolic_array_output,
            result_out                     => result_out_from_sys_array
        );
    

    systolic_array_output_vector_aligner_inst : entity work.systolic_array_vector_aligner(input)
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
            data_out_ready => data_in_ready_from_accumulator,
            data_out       => data_out_from_systolic_array_output
        );

    
    accumulator_write_control_signal_in_valid <= accu_address_write_out_valid_from_pipeline_input_handler and accu_mode_out_valid_from_pipeline_input_handler;
    accumulator_write_control_signal_in <= accu_address_write_out_from_pipeline_input_handler(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0) & accu_mode_out_from_pipeline_input_handler;

    fifo_to_vector_accumulator_write_inst : entity work.fifo
        generic map(
            DATA_WIDTH => ACCUMULATOR_ADDRESS_WIDTH + ACCUMULATOR_MODE_LENGTH,
            FIFO_DEPTH => CONTROL_SIGNAL_FIFO_DEPTH
        )
        port map(
            clk            => clk,
            rst            => rst,

            data_in_valid  => accumulator_write_control_signal_in_valid,
            data_in_ready  => data_in_ready_from_accumulator_write_fifo,
            data_in        => accumulator_write_control_signal_in,

            data_out_valid => data_out_valid_from_accumulator_write_fifo,
            data_out_ready => accumulator_write_control_signals_ready,
            data_out       => data_out_from_accumulator_write_fifo
        );
    
    fifo_to_vector_accumulator_read_inst : entity work.fifo
        generic map(
            DATA_WIDTH => ACCUMULATOR_ADDRESS_WIDTH,
            FIFO_DEPTH => CONTROL_SIGNAL_FIFO_DEPTH
        )
        port map(
            clk            => clk,
            rst            => rst,

            data_in_valid  => accu_address_read_out_valid_from_pipeline_input_handler,
            data_in_ready  => data_in_ready_from_accumulator_read_fifo,
            data_in        => accu_address_read_out_from_pipeline_input_handler(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0),

            data_out_valid => data_out_valid_from_accumulator_read_fifo,
            data_out_ready => accumulator_read_address_ready_from_accumulator,
            data_out       => data_out_from_accumulator_read_fifo
        );
    
    accumulator_write_control_signals_ready <= accumulator_write_address_ready_from_accumulator and accumulator_mode_ready_from_accumulator;

    process (data_out_from_systolic_array_output) begin
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
            ACCUMULATOR_ADDRESS_WIDTH => ACCUMULATOR_ADDRESS_WIDTH,
            ACCUMULATOR_MODE_LENGTH => ACCUMULATOR_MODE_LENGTH
        )
        port map(
            clk                                  => clk,
            rst                                  => rst,
            mode_valid                           => data_out_valid_from_accumulator_write_fifo,
            mode_ready                           => accumulator_mode_ready_from_accumulator,
            mode                                 => data_out_from_accumulator_write_fifo(ACCUMULATOR_MODE_LENGTH - 1 downto 0),
            data_in_valid                        => data_out_valid_from_systolic_array_output,
            data_in_ready                        => data_in_ready_from_accumulator,
            data_in                              => data_out_from_systolic_array_output_signed,
            accumulator_write_address_valid      => data_out_valid_from_accumulator_write_fifo,
            accumulator_write_address_ready      => accumulator_write_address_ready_from_accumulator,
            accumulator_write_address            => data_out_from_accumulator_write_fifo(ACCUMULATOR_ADDRESS_WIDTH + ACCUMULATOR_MODE_LENGTH - 1 downto ACCUMULATOR_MODE_LENGTH),
            accumulator_read_address_valid       => data_out_valid_from_accumulator_read_fifo,
            accumulator_read_address_ready       => accumulator_read_address_ready_from_accumulator,
            accumulator_read_address             => data_out_from_accumulator_read_fifo,
            data_out_valid                       => data_out_valid_from_accumulator,
            data_out_ready                       => data_in_ready_from_bias_module,
            data_out                             => data_out_from_accumulator,
            accumulator_write_back_address_valid => accumulator_write_back_address_valid_from_accumulator,
            accumulator_write_back_address_ready => accumulator_write_back_address_ready_from_pipeline_input_handler,
            accumulator_write_back_address       => accumulator_write_back_address_from_accumulator
        );

    fifo_to_bias_module_inst : entity work.fifo
        generic map(
            DATA_WIDTH => clog2(BIAS_REGISTER_DEPTH),
            FIFO_DEPTH => CONTROL_SIGNAL_FIFO_DEPTH
        )
        port map(
            clk            => clk,
            rst            => rst,

            data_in_valid  => bias_address_out_valid_from_pipeline_input_handler,
            data_in_ready  => data_in_ready_from_bias_module_fifo,
            data_in        => bias_address_out_from_pipeline_input_handler(clog2(BIAS_REGISTER_DEPTH) - 1 downto 0),

            data_out_valid => data_out_valid_from_bias_module_fifo,
            data_out_ready => bias_reg_address_ready_from_bias_module,
            data_out       => data_out_from_bias_module_fifo
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

            bias_reg_address_valid       => data_out_valid_from_bias_module_fifo,
            bias_reg_address_ready       => bias_reg_address_ready_from_bias_module,
            bias_reg_address             => data_out_from_bias_module_fifo,
            data_in_valid                => data_out_valid_from_accumulator,
            data_in_ready                => data_in_ready_from_bias_module,
            data_in                      => data_out_from_accumulator,
            data_out_valid               => data_out_valid_from_bias_module,
            data_out_ready               => data_in_ready_from_resize_module,
            data_out                     => data_out_from_bias_module
        );
    
    resize_control_signal_in_valid <= resize_mode_out_valid_from_pipeline_input_handler and reg_write_address_out_valid_from_pipeline_input_handler(REGISTER_WRITE_INSTANCE_BIAS_QUANT_INDEX);
    resize_control_signal_in <= resize_mode_out_from_pipeline_input_handler & reg_write_address_out_from_pipeline_input_handler;

    fifo_to_vector_resize_module_inst : entity work.fifo
        generic map(
            DATA_WIDTH => RESIZE_MODE_LENGTH + REGISTER_ADDRESS_WIDTH,
            FIFO_DEPTH => CONTROL_SIGNAL_FIFO_DEPTH
        )
        port map(
            clk            => clk,
            rst            => rst,

            data_in_valid  => resize_control_signal_in_valid,
            data_in_ready  => data_in_ready_from_resize_module_fifo,
            data_in        => resize_control_signal_in,

            data_out_valid => data_out_valid_from_resize_module_fifo,
            data_out_ready => control_signals_ready_from_resize,
            data_out       => data_out_resize_from_module_fifo
        );
    

    process (data_out_from_bias_module)
    begin
        for i in 0 to SYSTOLIC_ARRAY_SIZE - 1 loop
            data_out_from_bias_module_not_signed(i) <= std_logic_vector(data_out_from_bias_module(i));
        end loop;
    end process;

    control_signals_ready_from_resize <= resize_mode_ready_from_resize_module and write_address_in_ready_from_resize_module;

    vector_resize_module_inst : entity work.vector_resize_module
        generic map(
            INPUT_WIDTH        => BIAS_OUTPUT_DATA_WIDTH,
            ADDRESS_WIDTH      => REGISTER_ADDRESS_WIDTH,
            OUTPUT_WIDTH       => DATA_WIDTH,
            VECTOR_LENGTH      => SYSTOLIC_ARRAY_SIZE,
            RESIZE_MODE_LENGTH => RESIZE_MODE_LENGTH
        )
        port map(
            clk                     => clk,
            rst                     => rst,
            resize_mode_valid       => data_out_valid_from_resize_module_fifo,
            resize_mode_ready       => resize_mode_ready_from_resize_module,
            resize_mode             => data_out_resize_from_module_fifo(RESIZE_MODE_LENGTH + REGISTER_ADDRESS_WIDTH - 1 downto REGISTER_ADDRESS_WIDTH),
            write_address_in_valid  => data_out_valid_from_resize_module_fifo,
            write_address_in_ready  => write_address_in_ready_from_resize_module,
            write_address_in        => data_out_resize_from_module_fifo(REGISTER_ADDRESS_WIDTH - 1 downto 0),
            data_in_valid           => data_out_valid_from_bias_module,
            data_in_ready           => data_in_ready_from_resize_module,
            data_in                 => data_out_from_bias_module_not_signed,
            write_address_out_valid => write_address_out_valid_from_resize_module,
            write_address_out_ready => reg_address_in_ready_lines_from_register_writer(REGISTER_WRITE_INSTANCE_BIAS_QUANT_INDEX),
            write_address_out       => write_address_out_from_resize_module,
            data_out_valid          => data_out_valid_from_resize_module,
            data_out_ready          => reg_data_in_ready_lines_from_register_writer(REGISTER_WRITE_INSTANCE_BIAS_QUANT_INDEX),
            data_out                => data_out_from_resize_module
        );
    
    reg_address_in_valid_lines_combined(REGISTER_WRITE_INSTANCE_LOAD_INDEX) <= reg_write_address_out_valid_from_memory_reader;
    reg_address_in_valid_lines_combined(REGISTER_WRITE_INSTANCE_MOV_INDEX) <=  register_write_address_out_valid_from_register_reader;
    reg_address_in_valid_lines_combined(REGISTER_WRITE_INSTANCE_BIAS_QUANT_INDEX) <= write_address_out_valid_from_resize_module;

    reg_address_in_lines_from_combined(REGISTER_WRITE_INSTANCE_LOAD_INDEX) <= reg_write_address_out_from_memory_reader;
    reg_address_in_lines_from_combined(REGISTER_WRITE_INSTANCE_MOV_INDEX) <= register_write_address_out_from_register_reader;
    reg_address_in_lines_from_combined(REGISTER_WRITE_INSTANCE_BIAS_QUANT_INDEX) <= write_address_out_from_resize_module;

    reg_data_in_valid_lines_combined(REGISTER_WRITE_INSTANCE_LOAD_INDEX) <= reg_data_out_valid_from_memory_reader;
    reg_data_in_valid_lines_combined(REGISTER_WRITE_INSTANCE_MOV_INDEX) <= register_data_out_valid_from_register_reader;
    reg_data_in_valid_lines_combined(REGISTER_WRITE_INSTANCE_BIAS_QUANT_INDEX) <= data_out_valid_from_resize_module;

    reg_data_in_lines_combined(REGISTER_WRITE_INSTANCE_LOAD_INDEX) <= reg_data_out_from_memory_reader;
    reg_data_in_lines_combined(REGISTER_WRITE_INSTANCE_MOV_INDEX) <= register_data_out_from_register_reader;
    reg_data_in_lines_combined(REGISTER_WRITE_INSTANCE_BIAS_QUANT_INDEX) <= data_out_from_resize_module;

    register_writer_inst : entity work.register_writer
        generic map(
            REG_ADDRESS_LENGTH                          => REGISTER_ADDRESS_WIDTH,
            NUM_OF_REGISTER_WRITER_INSTANCES            => NUM_OF_REGISTER_WRITER_INSTANCES,
            VECTOR_LENGTH                               => SYSTOLIC_ARRAY_SIZE,
            DATA_WIDTH                                  => DATA_WIDTH,
            REGISTER_WRITE_INSTANCE_LOAD_INDEX          => REGISTER_WRITE_INSTANCE_LOAD_INDEX,
            REGISTER_WRITE_INSTANCE_MOV_INDEX           => REGISTER_WRITE_INSTANCE_MOV_INDEX,
            REGISTER_WRITE_INSTANCE_BIAS_QUANT_INDEX    => REGISTER_WRITE_INSTANCE_BIAS_QUANT_INDEX
        )
        port map(
            clk                        => clk,
            rst                        => rst,

            reg_address_in_valid_lines => reg_address_in_valid_lines_combined,
            reg_address_in_ready_lines => reg_address_in_ready_lines_from_register_writer,
            reg_address_in_lines       => reg_address_in_lines_from_combined,

            reg_data_in_valid_lines    => reg_data_in_valid_lines_combined,
            reg_data_in_ready_lines    => reg_data_in_ready_lines_from_register_writer,
            reg_data_in_lines          => reg_data_in_lines_combined,

            reg_address_valid          => reg_address_valid_from_register_writer,
            reg_address_ready          => address_write_ready_from_bus_interconnect,
            reg_address                => reg_address_from_register_writer,

            reg_data_valid             => reg_data_valid_from_register_writer,
            reg_data_ready             => data_write_ready_from_bus_interconnect,
            reg_data                   => reg_data_from_register_writer
        );

    register_reader_control_signals_in_valid <= reg_read_address_out_valid_from_pipeline_input_handler and reg_write_address_out_valid_from_pipeline_input_handler(REGISTER_WRITE_INSTANCE_MOV_INDEX);
    register_reader_control_signals_in <= reg_read_address_out_from_pipeline_input_handler & reg_write_address_out_from_pipeline_input_handler;

    fifo_to_register_reader : entity work.fifo
        generic map (
            DATA_WIDTH => REGISTER_ADDRESS_WIDTH + REGISTER_ADDRESS_WIDTH, -- read address, write address
            FIFO_DEPTH => CONTROL_SIGNAL_FIFO_DEPTH
        )
        port map (
            clk            => clk,
            rst            => rst,

            data_in_valid  => register_reader_control_signals_in_valid,
            data_in_ready  => data_in_ready_from_register_reader_fifo,
            data_in        => register_reader_control_signals_in,

            data_out_valid => data_out_valid_from_register_reader_fifo,
            data_out_ready => register_reader_control_signals_ready,
            data_out       => data_out_from_register_from_register_reader_fifo
        );
    
    register_reader_control_signals_ready <= register_read_address_in_ready_from_register_reader and register_write_address_in_ready_from_register_reader;
    
    register_reader_inst : entity work.memory_read_interface
        generic map(
            WRITE_ADDRESS_LENGTH    => REGISTER_ADDRESS_WIDTH,
            READ_ADDRESS_LENGTH     => REGISTER_ADDRESS_WIDTH,
            VECTOR_LENGTH           => SYSTOLIC_ARRAY_SIZE,
            DATA_WIDTH              => DATA_WIDTH
        )
        port map(
            clk                        => clk,
            rst                        => rst,

            read_address_in_valid  => data_out_valid_from_register_reader_fifo,
            read_address_in_ready  => register_read_address_in_ready_from_register_reader,
            read_address_in        => data_out_from_register_from_register_reader_fifo(REGISTER_ADDRESS_WIDTH + REGISTER_ADDRESS_WIDTH - 1 downto REGISTER_ADDRESS_WIDTH),

            read_address_out_valid => register_read_address_out_valid_from_register_reader,
            read_address_out_ready => address_read_ready_from_bus_interconnect,
            read_address_out       => register_read_address_out_from_register_reader,

            write_address_in_valid => data_out_valid_from_register_reader_fifo,
            write_address_in_ready => register_write_address_in_ready_from_register_reader,
            write_address_in => data_out_from_register_from_register_reader_fifo(REGISTER_ADDRESS_WIDTH - 1 downto 0),

            write_address_out_valid => register_write_address_out_valid_from_register_reader,
            write_address_out_ready => reg_address_in_ready_lines_from_register_writer(REGISTER_WRITE_INSTANCE_MOV_INDEX),
            write_address_out => register_write_address_out_from_register_reader,

            data_in_valid     => data_read_valid_from_bus_interconnect,
            data_in_ready     => register_data_in_ready_from_register_reader,
            data_in           => data_read_from_bus_interconnect_vectorized,

            data_out_valid    => register_data_out_valid_from_register_reader,
            data_out_ready    => reg_data_in_ready_lines_from_register_writer(REGISTER_WRITE_INSTANCE_MOV_INDEX),
            data_out          => register_data_out_from_register_reader
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
    reg_write_data_out_from_pipeline_handler_flatten <= flatten(reg_data_from_register_writer);

    s_address_read_ready_from_register_blocks(VECTOR_REGISTER_INTERCONNECT_INDEX) <= register_read_address_ready_from_vector_register_module;
    s_address_read_ready_from_register_blocks(BIAS_REGISTER_INTERCONNECT_INDEX) <= bias_reg_read_address_ready_from_bias_module;
    s_address_read_ready_from_register_blocks(SYS_ARRAY_REGISTER_INTERCONNECT_INDEX) <= weight_col_read_address_ready_from_sys_array;
    s_address_read_ready_from_register_blocks(SYS_ARRAY_INPUT_INTERCONNECT_INDEX) <= '1';
    s_address_read_ready_from_register_blocks(MEMORY_WRITE_INTERFACE_INTERCONNECT_INDEX) <= '1';

    s_data_read_valid_from_register_blocks(VECTOR_REGISTER_INTERCONNECT_INDEX) <= register_read_data_valid_from_vector_register_module;
    s_data_read_valid_from_register_blocks(BIAS_REGISTER_INTERCONNECT_INDEX) <= bias_reg_data_out_valid_from_bias_module;
    s_data_read_valid_from_register_blocks(SYS_ARRAY_REGISTER_INTERCONNECT_INDEX) <= weight_out_valid_from_sys_array;
    s_data_read_valid_from_register_blocks(SYS_ARRAY_INPUT_INTERCONNECT_INDEX) <= '0';
    s_data_read_valid_from_register_blocks(MEMORY_WRITE_INTERFACE_INTERCONNECT_INDEX) <= '0';

    s_data_read_from_register_blocks(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * VECTOR_REGISTER_INTERCONNECT_INDEX + DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * VECTOR_REGISTER_INTERCONNECT_INDEX) <= flatten(register_read_data_from_vector_register_module);
    s_data_read_from_register_blocks(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * BIAS_REGISTER_INTERCONNECT_INDEX + DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * BIAS_REGISTER_INTERCONNECT_INDEX) <= flatten(bias_reg_data_out_from_bias_module);
    s_data_read_from_register_blocks(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * SYS_ARRAY_REGISTER_INTERCONNECT_INDEX + DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * SYS_ARRAY_REGISTER_INTERCONNECT_INDEX) <= flatten(weight_out_from_sys_array);
    s_data_read_from_register_blocks(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * SYS_ARRAY_INPUT_INTERCONNECT_INDEX + DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * SYS_ARRAY_INPUT_INTERCONNECT_INDEX) <= (others => '0');
    s_data_read_from_register_blocks(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * MEMORY_WRITE_INTERFACE_INTERCONNECT_INDEX + DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto DATA_WIDTH * SYSTOLIC_ARRAY_SIZE * MEMORY_WRITE_INTERFACE_INTERCONNECT_INDEX) <= (others => '0');

    s_address_write_ready_from_register_blocks(VECTOR_REGISTER_INTERCONNECT_INDEX) <= register_write_address_ready_from_vector_register_module;
    s_address_write_ready_from_register_blocks(BIAS_REGISTER_INTERCONNECT_INDEX) <= bias_reg_write_address_ready_from_bias_module;
    s_address_write_ready_from_register_blocks(SYS_ARRAY_REGISTER_INTERCONNECT_INDEX) <= weight_col_write_address_ready_from_sys_array;
    s_address_write_ready_from_register_blocks(SYS_ARRAY_INPUT_INTERCONNECT_INDEX) <= '1';
    s_address_write_ready_from_register_blocks(MEMORY_WRITE_INTERFACE_INTERCONNECT_INDEX) <= '1';

    s_data_write_ready_from_register_blocks(VECTOR_REGISTER_INTERCONNECT_INDEX) <= register_write_data_ready_from_vector_register_module;
    s_data_write_ready_from_register_blocks(BIAS_REGISTER_INTERCONNECT_INDEX) <= bias_reg_data_in_ready_from_bias_module;
    s_data_write_ready_from_register_blocks(SYS_ARRAY_REGISTER_INTERCONNECT_INDEX) <= weight_in_ready_from_sys_array;
    s_data_write_ready_from_register_blocks(SYS_ARRAY_INPUT_INTERCONNECT_INDEX) <= data_in_ready_from_systolic_array_input;
    s_data_write_ready_from_register_blocks(MEMORY_WRITE_INTERFACE_INTERCONNECT_INDEX) <= read_data_in_ready_from_register_writer;

    bus_interconnect_inst : entity work.bus_interconnect
        generic map(
            ADDRESS_WIDTH    => REGISTER_ADDRESS_WIDTH,
            DATA_WIDTH       => DATA_WIDTH * SYSTOLIC_ARRAY_SIZE,
            NUMBER_OF_SLAVES => NUMBER_OF_REGISTER_BLOCKS_TO_INTERCONNECT,
            SLAVE_BASE_ADDR  => REGISTER_BASE_ADDRESSES_TO_INTERCONNECT,
            SLAVE_ADDR_MASK  => REGISTER_ADDRESS_MASKS_TO_INTERCONNECT
        )
        port map(
            clk                     => clk,
            rst                     => rst,
            address_read_valid      => register_read_address_out_valid_from_register_reader,
            address_read_ready      => address_read_ready_from_bus_interconnect,
            address_read            => register_read_address_out_from_register_reader,
            data_read_valid         => data_read_valid_from_bus_interconnect,
            data_read_ready         => register_data_in_ready_from_register_reader,
            data_read               => data_read_from_bus_interconnect,
            address_write_valid     => reg_address_valid_from_register_writer,
            address_write_ready     => address_write_ready_from_bus_interconnect,
            address_write           => reg_address_from_register_writer,
            data_write_valid        => reg_data_valid_from_register_writer,
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
