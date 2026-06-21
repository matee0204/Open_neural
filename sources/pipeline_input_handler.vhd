----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/13/2026 06:41:03 PM
-- Design Name: 
-- Module Name: pipeline_input_handler - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pipeline_input_handler is
    generic (
        NUM_OF_VECTOR_REGISTERS : natural := 128;
        NUM_OF_ACCUMULATOR_REGISTERS : natural := 128;
        
        OPERATION_CODE_LENGTH : natural := 7;
        MEMORY_ADDRESS_LENGTH : natural := 32;
        REGISTER_ADDRESS_LENGTH : natural := 16;
        SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH : natural := 8;
        BIAS_ADDRESS_LENGTH : natural := 8;
        ACCUMULATOR_ADDRESS_LENGTH : natural := 8;
        ACCUMULATOR_MODE_LENGTH : natural := 3;
        RESIZE_MODE_LENGTH : natural := 3;
        
        REGISTER_VECTOR_LENGTH : natural := 8;
        REGISTER_DATA_LENGTH : natural := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        opcode_in_valid : in std_logic;
        opcode_in_ready : out std_logic;
        opcode_in : in std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0);
        
        memory_read_address_valid : in std_logic;
        memory_read_address_ready : out std_logic;
        memory_read_address : in std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
        
        memory_write_address_valid : in std_logic;
        memory_write_address_ready : out std_logic;
        memory_write_address : in std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
        
        register_read_address_valid : in std_logic;
        register_read_address_ready : out std_logic;
        register_read_address : in std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        register_write_address_valid : in std_logic;
        register_write_address_ready : out std_logic;
        register_write_address : in std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        systolic_array_selected_weight_bank_valid : in std_logic;
        systolic_array_selected_weight_bank_ready : out std_logic;
        systolic_array_selected_weight_bank : in std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);
        
        selected_accumulator_bank_write_valid : in std_logic;
        selected_accumulator_bank_write_ready : out std_logic;
        selected_accumulator_bank_write : in std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        accumulator_mode : in std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
        
        selected_accumulator_bank_read_valid : in std_logic;
        selected_accumulator_bank_read_ready : out std_logic;
        selected_accumulator_bank_read : in std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        
        selected_bias_bank_valid : in std_logic;
        selected_bias_bank_ready : out std_logic;
        selected_bias_bank : in std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);
        
        resize_module_mode_valid : in std_logic;
        resize_module_mode_ready : out std_logic;
        resize_module_mode : in std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);
        
        
        opcode_out_valid : out std_logic;
        opcode_out_ready : in std_logic;
        opcode_out : out std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0);
        
        memory_read_address_out_valid : out std_logic;
        memory_read_address_out_ready : in std_logic;
        memory_read_address_out : out std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
        
        memory_write_address_out_valid : out std_logic;
        memory_write_address_out_ready : in std_logic;
        memory_write_address_out : out std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
        
        reg_write_address_out_valid : out std_logic;
        reg_write_address_out_ready : in std_logic;
        reg_write_address_out : out std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        
        
        reg_read_address_out_valid : out std_logic;
        reg_read_address_out_ready : in std_logic;
        reg_read_address_out : out std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        reg_read_data_in_valid : in std_logic;
        reg_read_data_in_ready : out std_logic;
        reg_read_data_in : in data_vector(0 to REGISTER_VECTOR_LENGTH - 1)(REGISTER_DATA_LENGTH - 1 downto 0);
        
        reg_read_data_out_valid : out std_logic;
        reg_read_data_out_ready : in std_logic;
        reg_read_data_out : out data_vector(0 to REGISTER_VECTOR_LENGTH - 1)(REGISTER_DATA_LENGTH - 1 downto 0);
        
        sys_array_bank_address_out_valid : out std_logic;
        sys_array_bank_address_out_ready : in std_logic;
        sys_array_bank_address_out : out std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);
        
        accu_address_write_out_valid : out std_logic;
        accu_address_write_out_ready : in std_logic;
        accu_address_write_out : out std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        accu_mode_out : out std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
        
        accu_address_read_out_valid : out std_logic;
        accu_address_read_out_ready : in std_logic;
        accu_address_read_out : out std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        
        bias_address_out_valid : out std_logic;
        bias_address_out_ready : in std_logic;
        bias_address_out : out std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);
        
        resize_mode_out_valid : out std_logic;
        resize_mode_out_ready : in std_logic;
        resize_mode_out : out std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);
        
        
        
        register_write_back_address_valid : in std_logic;
        register_write_back_address_ready : out std_logic;
        register_write_back_address : in std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        register_write_back_ready : in std_logic;
        
        accumulator_write_back_address_valid : in std_logic;
        accumulator_write_back_address_ready : out std_logic;
        accumulator_write_back_address : in std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        accumulator_write_back_ready : in std_logic
    );
end pipeline_input_handler;

architecture Behavioral of pipeline_input_handler is
    constant REGISTER_READ_ADDRESS_DELAY : natural := 1;
    constant SIGNAL_DELAY : natural := 6;
    
    signal reg_write_pipeline_ready : std_logic;
    signal accumulator_write_pipeline_ready : std_logic;
    
    signal data_ready_from_opcode_delay : std_logic;
    signal data_valid_from_opcode_delay : std_logic;
    signal data_from_opcode_delay : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0);
            
    signal data_ready_from_memory_read_address_delay : std_logic;
    signal data_valid_from_memory_read_address_delay : std_logic;
    signal data_from_memory_read_address_delay : std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
            
    signal data_ready_from_memory_write_address_delay : std_logic;
    signal data_valid_from_memory_write_address_delay : std_logic;
    signal data_from_memory_write_address_delay : std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
    
    signal register_read_address_in_ready_from_depcheck : std_logic;
    signal register_write_address_in_ready_from_depcheck : std_logic;
    signal systolic_array_selected_weight_bank_in_ready_from_depcheck : std_logic;
    signal selected_accumulator_bank_write_in_ready_from_depcheck : std_logic;
    signal selected_accumulator_bank_read_in_ready_from_depcheck : std_logic;
    signal selected_bias_bank_in_ready_from_depcheck : std_logic;
    signal pipeline_start_en_from_depcheck : std_logic;
    
    signal data_ready_from_reg_read_address_delay : std_logic;
    signal data_valid_from_reg_read_address_delay : std_logic;
    signal data_from_reg_read_address_delay : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    
    signal data_ready_from_reg_write_address_delay : std_logic;
    signal data_valid_from_reg_write_address_delay : std_logic;
    signal data_from_reg_write_address_delay : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    
    signal data_ready_from_systolic_array_selected_weight_bank_delay : std_logic;
    signal data_valid_from_systolic_array_selected_weight_bank_delay : std_logic;
    signal data_from_systolic_array_selected_weight_bank_delay : std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);
    
    signal data_ready_from_selected_accumulator_bank_write_delay : std_logic;
    signal data_valid_from_selected_accumulator_bank_write_delay : std_logic;
    signal data_from_selected_accumulator_bank_write_delay : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
    signal data_from_accu_mode_delay : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
    
    signal data_ready_from_selected_accumulator_bank_read_delay : std_logic;
    signal data_valid_from_selected_accumulator_bank_read_delay : std_logic;
    signal data_from_selected_accumulator_bank_read_delay : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
    
    signal data_ready_from_selected_bias_bank_delay : std_logic;
    signal data_valid_from_selected_bias_bank_delay : std_logic;
    signal data_from_selected_bias_bank_delay : std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);
    
    signal data_ready_from_resize_mode_delay : std_logic;
    signal data_valid_from_resize_mode_delay : std_logic;
    signal data_from_resize_mode_delay : std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);
    
    signal register_address_ready_from_reg_reader : std_logic;
begin

    reg_write_pipeline_ready <= reg_write_address_out_ready;
    accumulator_write_pipeline_ready <= accu_address_write_out_ready;

    dependency_handler_inst : entity work.dependency_handler
        generic map (
            NUM_OF_VECTOR_REGISTERS => NUM_OF_VECTOR_REGISTERS,
            NUM_OF_ACCUMULATOR_REGISTERS => NUM_OF_ACCUMULATOR_REGISTERS,
            
            REGISTER_ADDRESS_LENGTH => REGISTER_ADDRESS_LENGTH,
            SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH => SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH,
            BIAS_ADDRESS_LENGTH => BIAS_ADDRESS_LENGTH,
            ACCUMULATOR_ADDRESS_LENGTH => ACCUMULATOR_ADDRESS_LENGTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            vector_register_pipeline_ready => reg_write_pipeline_ready,
            accumulator_pipeline_ready => accumulator_write_pipeline_ready,
            
            register_read_address_in_valid => register_read_address_valid,
            register_read_address_in_ready => register_read_address_in_ready_from_depcheck,
            register_read_address_in => register_read_address,
            register_write_address_in_valid => register_write_address_valid,
            register_write_address_in_ready => register_write_address_in_ready_from_depcheck,
            register_write_address_in => register_write_address,
            
            systolic_array_selected_weight_bank_in_valid => systolic_array_selected_weight_bank_valid,
            systolic_array_selected_weight_bank_in_ready => systolic_array_selected_weight_bank_in_ready_from_depcheck,
            systolic_array_selected_weight_bank_in => systolic_array_selected_weight_bank,
            
            selected_accumulator_bank_write_in_valid => selected_accumulator_bank_write_valid,
            selected_accumulator_bank_write_in_ready => selected_accumulator_bank_write_in_ready_from_depcheck,
            selected_accumulator_bank_write_in => selected_accumulator_bank_write,
            
            selected_accumulator_bank_read_in_valid => selected_accumulator_bank_read_valid,
            selected_accumulator_bank_read_in_ready => selected_accumulator_bank_read_in_ready_from_depcheck,
            selected_accumulator_bank_read_in => selected_accumulator_bank_read,
            
            selected_bias_bank_in_valid => selected_bias_bank_valid,
            selected_bias_bank_in_ready => selected_bias_bank_in_ready_from_depcheck,
            selected_bias_bank_in => selected_bias_bank,
            
            pipeline_start_en => pipeline_start_en_from_depcheck,
            
            register_write_back_address_valid => register_write_back_address_valid,
            register_write_back_address_ready => register_write_back_address_ready,
            register_write_back_address => register_write_back_address,
            register_write_back_ready => register_write_back_ready,
            
            accumulator_write_back_address_valid => accumulator_write_back_address_valid,
            accumulator_write_back_address_ready => accumulator_write_back_address_ready,
            accumulator_write_back_address => accumulator_write_back_address,
            accumulator_write_back_ready => accumulator_write_back_ready
        );
        
    opcode_in_ready <= data_ready_from_opcode_delay;
    opcode_out_valid <= data_valid_from_opcode_delay;
    opcode_out <= data_from_opcode_delay;
    
    opcode_delay_inst : entity work.data_delay
        generic map (
            DATA_LENGTH => OPERATION_CODE_LENGTH,
            DELAY_LENGTH => SIGNAL_DELAY
        )
        port map (
            clk => clk,
            rst => rst,
            
            input_en => pipeline_start_en_from_depcheck,
            
            data_in_valid => opcode_in_valid,
            data_in_ready => data_ready_from_opcode_delay,
            data_in => opcode_in,
    
            data_out_valid => data_valid_from_opcode_delay,
            data_out_ready => opcode_out_ready,
            data_out => data_from_opcode_delay
        );
    
        
    memory_read_address_ready <= data_ready_from_memory_read_address_delay;
    memory_read_address_out_valid <= data_valid_from_memory_read_address_delay;
    memory_read_address_out <= data_from_memory_read_address_delay;
        
    memory_read_address_delay_inst : entity work.data_delay
        generic map (
            DATA_LENGTH => MEMORY_ADDRESS_LENGTH,
            DELAY_LENGTH => SIGNAL_DELAY
        )
        port map (
            clk => clk,
            rst => rst,
            
            input_en => pipeline_start_en_from_depcheck,
            
            data_in_valid => memory_read_address_valid,
            data_in_ready => data_ready_from_memory_read_address_delay,
            data_in => memory_read_address,
    
            data_out_valid => data_valid_from_memory_read_address_delay,
            data_out_ready => memory_read_address_out_ready,
            data_out => data_from_memory_read_address_delay
        );
    
        
    memory_write_address_ready <= data_ready_from_memory_write_address_delay;
    memory_write_address_out_valid <= data_valid_from_memory_write_address_delay;
    memory_write_address_out <= data_from_memory_write_address_delay;
        
    memory_write_address_delay_inst : entity work.data_delay
        generic map (
            DATA_LENGTH => MEMORY_ADDRESS_LENGTH,
            DELAY_LENGTH => SIGNAL_DELAY
        )
        port map (
            clk => clk,
            rst => rst,
            
            input_en => pipeline_start_en_from_depcheck,
            
            data_in_valid => memory_write_address_valid,
            data_in_ready => data_ready_from_memory_write_address_delay,
            data_in => memory_write_address,
    
            data_out_valid => data_valid_from_memory_write_address_delay,
            data_out_ready => memory_write_address_out_ready,
            data_out => data_from_memory_write_address_delay
        );
        
    register_read_address_ready <= data_ready_from_reg_read_address_delay and register_read_address_in_ready_from_depcheck;
        
    register_read_address_delay_inst : entity work.data_delay
        generic map (
            DATA_LENGTH => REGISTER_ADDRESS_LENGTH,
            DELAY_LENGTH => REGISTER_READ_ADDRESS_DELAY
        )
        port map (
            clk => clk,
            rst => rst,
            
            input_en => pipeline_start_en_from_depcheck,
            
            data_in_valid => register_read_address_valid,
            data_in_ready => data_ready_from_reg_read_address_delay,
            data_in => register_read_address,
    
            data_out_valid => data_valid_from_reg_read_address_delay,
            data_out_ready => register_address_ready_from_reg_reader,
            data_out => data_from_reg_read_address_delay
        );
        
    register_reader_inst : entity work.register_reader
        generic map (
            REGISTER_ADDRESS_LENGTH => REGISTER_ADDRESS_LENGTH,
            VECTOR_LENGTH => REGISTER_VECTOR_LENGTH,
            DATA_WIDTH => REGISTER_DATA_LENGTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            register_address_in_valid => data_valid_from_reg_read_address_delay,
            register_address_in_ready => register_address_ready_from_reg_reader,
            register_address_in => data_from_reg_read_address_delay,
            
            register_address_out_valid => reg_read_address_out_valid,
            register_address_out_ready => reg_read_address_out_ready,
            register_address_out => reg_read_address_out,
            
            register_data_in_valid => reg_read_data_in_valid,
            register_data_in_ready => reg_read_data_in_ready, 
            register_data_in => reg_read_data_in,
            
            register_data_out_valid => reg_read_data_out_valid,
            register_data_out_ready => reg_read_data_out_ready, 
            register_data_out => reg_read_data_out
        );
    
    register_write_address_ready <= data_ready_from_reg_write_address_delay and register_write_address_in_ready_from_depcheck;
    reg_write_address_out_valid <= data_valid_from_reg_write_address_delay;
    reg_write_address_out <= data_from_reg_write_address_delay;
    
    register_write_address_delay_inst : entity work.data_delay
        generic map (
            DATA_LENGTH => REGISTER_ADDRESS_LENGTH,
            DELAY_LENGTH => SIGNAL_DELAY
        )
        port map (
            clk => clk,
            rst => rst,
            
            input_en => pipeline_start_en_from_depcheck,
            
            data_in_valid => register_write_address_valid,
            data_in_ready => data_ready_from_reg_write_address_delay,
            data_in => register_write_address,
    
            data_out_valid => data_valid_from_reg_write_address_delay,
            data_out_ready => reg_write_address_out_ready,
            data_out => data_from_reg_write_address_delay
        );
        
    systolic_array_selected_weight_bank_ready <= data_ready_from_systolic_array_selected_weight_bank_delay and systolic_array_selected_weight_bank_in_ready_from_depcheck;
    sys_array_bank_address_out_valid <= data_valid_from_systolic_array_selected_weight_bank_delay;
    sys_array_bank_address_out <= data_from_systolic_array_selected_weight_bank_delay;
    
    systolic_array_selected_weight_bank_delay_inst : entity work.data_delay
        generic map (
            DATA_LENGTH => SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH,
            DELAY_LENGTH => SIGNAL_DELAY
        )
        port map (
            clk => clk,
            rst => rst,
            
            input_en => pipeline_start_en_from_depcheck,
            
            data_in_valid => systolic_array_selected_weight_bank_valid,
            data_in_ready => data_ready_from_systolic_array_selected_weight_bank_delay,
            data_in => systolic_array_selected_weight_bank,
    
            data_out_valid => data_valid_from_systolic_array_selected_weight_bank_delay,
            data_out_ready => sys_array_bank_address_out_ready,
            data_out => data_from_systolic_array_selected_weight_bank_delay
        );
        
    selected_accumulator_bank_write_ready <= data_ready_from_selected_accumulator_bank_write_delay and selected_accumulator_bank_write_in_ready_from_depcheck;
    accu_address_write_out_valid <= data_valid_from_selected_accumulator_bank_write_delay;
    accu_address_write_out <= data_from_selected_accumulator_bank_write_delay;
        
    selected_accumulator_bank_write_delay_inst : entity work.data_delay
        generic map (
            DATA_LENGTH => ACCUMULATOR_ADDRESS_LENGTH,
            DELAY_LENGTH => SIGNAL_DELAY
        )
        port map (
            clk => clk,
            rst => rst,
            
            input_en => pipeline_start_en_from_depcheck,
            
            data_in_valid => selected_accumulator_bank_write_valid,
            data_in_ready => data_ready_from_selected_accumulator_bank_write_delay,
            data_in => selected_accumulator_bank_write,
    
            data_out_valid => data_valid_from_selected_accumulator_bank_write_delay,
            data_out_ready => accu_address_write_out_ready,
            data_out => data_from_selected_accumulator_bank_write_delay
        );
        
    accu_mode_out <= data_from_accu_mode_delay;
        
    accumulator_mode_delay_inst : entity work.data_delay
        generic map (
            DATA_LENGTH => ACCUMULATOR_MODE_LENGTH,
            DELAY_LENGTH => SIGNAL_DELAY
        )
        port map (
            clk => clk,
            rst => rst,
            
            input_en => pipeline_start_en_from_depcheck,
            
            data_in_valid => '0',
            data_in => accumulator_mode,
    
            data_out_ready => accu_address_write_out_ready,
            data_out => data_from_accu_mode_delay
        );
        
    selected_accumulator_bank_read_ready <= data_ready_from_selected_accumulator_bank_read_delay and selected_accumulator_bank_read_in_ready_from_depcheck;
    accu_address_read_out_valid <= data_valid_from_selected_accumulator_bank_read_delay;
    accu_address_read_out <= data_from_selected_accumulator_bank_read_delay;
        
    selected_accumulator_bank_read_delay_inst : entity work.data_delay
        generic map (
            DATA_LENGTH => ACCUMULATOR_ADDRESS_LENGTH,
            DELAY_LENGTH => SIGNAL_DELAY
        )
        port map (
            clk => clk,
            rst => rst,
            
            input_en => pipeline_start_en_from_depcheck,
            
            data_in_valid => selected_accumulator_bank_read_valid,
            data_in_ready => data_ready_from_selected_accumulator_bank_read_delay,
            data_in => selected_accumulator_bank_read,
    
            data_out_valid => data_valid_from_selected_accumulator_bank_read_delay,
            data_out_ready => accu_address_read_out_ready,
            data_out => data_from_selected_accumulator_bank_read_delay
        );
        
    selected_bias_bank_ready <= data_ready_from_selected_bias_bank_delay and selected_bias_bank_in_ready_from_depcheck;
    bias_address_out_valid <= data_valid_from_selected_bias_bank_delay;
    bias_address_out <= data_from_selected_bias_bank_delay;
        
    selected_bias_bank_delay_inst : entity work.data_delay
        generic map (
            DATA_LENGTH => BIAS_ADDRESS_LENGTH,
            DELAY_LENGTH => SIGNAL_DELAY
        )
        port map (
            clk => clk,
            rst => rst,
            
            input_en => pipeline_start_en_from_depcheck,
            
            data_in_valid => selected_bias_bank_valid,
            data_in_ready => data_ready_from_selected_bias_bank_delay,
            data_in => selected_bias_bank,
    
            data_out_valid => data_valid_from_selected_bias_bank_delay,
            data_out_ready => bias_address_out_ready,
            data_out => data_from_selected_bias_bank_delay
        );
        
    resize_module_mode_ready <= data_ready_from_resize_mode_delay;
    resize_mode_out_valid <= data_valid_from_resize_mode_delay;
    resize_mode_out <= data_from_resize_mode_delay;
        
    resize_mode_delay_inst : entity work.data_delay
        generic map (
            DATA_LENGTH => RESIZE_MODE_LENGTH,
            DELAY_LENGTH => SIGNAL_DELAY
        )
        port map (
            clk => clk,
            rst => rst,
            
            input_en => pipeline_start_en_from_depcheck,
            
            data_in_valid => resize_module_mode_valid,
            data_in_ready => data_ready_from_resize_mode_delay,
            data_in => resize_module_mode,
    
            data_out_valid => data_valid_from_resize_mode_delay,
            data_out_ready => resize_mode_out_ready,
            data_out => data_from_resize_mode_delay
        );

end Behavioral;
