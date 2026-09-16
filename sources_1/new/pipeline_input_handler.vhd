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
use work.common_constants.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pipeline_input_handler is
    generic (
        NUM_OF_VECTOR_REGISTERS : natural := 128;
        NUM_OF_BIAS_REGISTERS : natural := 128;
        NUM_OF_SYSTOLIC_ARRAY_WEIGHT_REGISTERS : natural := 16;
        NUM_OF_ACCUMULATOR_REGISTERS : natural := 128;
        NUM_OF_VECTOR_REGISTER_BLOCKS : natural := 3;
        REGISTER_ADDRESS_LENGTH : natural := 16;

        VECTOR_REGISTER_BASE_ADDRESS : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0) := (others => '0');
        BIAS_REGISTER_BASE_ADDRESS : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0) := (others => '0');
        SYS_ARRAY_REGISTER_BASE_ADDRESS : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0) := (others => '0');

        VECTOR_REGISTER_ADDRESS_MASK : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0) := (others => '0');
        BIAS_REGISTER_ADDRESS_MASK : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0) := (others => '0');
        SYS_ARRAY_REGISTER_ADDRESS_MASK : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0) := (others => '0');
        
        OPERATION_CODE_LENGTH : natural := 7;
        MEMORY_ADDRESS_LENGTH : natural := 32;
        NUM_OF_REGISTER_WRITER_INSTANCES : natural := 3;
        SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH : natural := 8;
        BIAS_ADDRESS_LENGTH : natural := 8;
        ACCUMULATOR_ADDRESS_LENGTH : natural := 8;
        ACCUMULATOR_MODE_LENGTH : natural := 3;
        RESIZE_MODE_LENGTH : natural := 3
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

        accumulator_mode_valid : in std_logic;
        accumulator_mode_ready : out std_logic;
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
        
        
        memory_read_address_out_valid : out std_logic;
        memory_read_address_out_ready : in std_logic;
        memory_read_address_out : out std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
        
        memory_write_address_out_valid : out std_logic;
        memory_write_address_out_ready : in std_logic;
        memory_write_address_out : out std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
        
        reg_write_address_out_valid : out std_logic_vector(NUM_OF_REGISTER_WRITER_INSTANCES - 1 downto 0);
        reg_write_address_out_ready : in std_logic_vector(NUM_OF_REGISTER_WRITER_INSTANCES - 1 downto 0);
        reg_write_address_out : out std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        reg_read_address_out_valid : out std_logic;
        reg_read_address_out_ready : in std_logic;
        reg_read_address_out : out std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        sys_array_bank_address_out_valid : out std_logic;
        sys_array_bank_address_out_ready : in std_logic;
        sys_array_bank_address_out : out std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);
        
        accu_address_write_out_valid : out std_logic;
        accu_address_write_out_ready : in std_logic;
        accu_address_write_out : out std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);

        accu_mode_out_valid : out std_logic;
        accu_mode_out_ready : in std_logic;
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
    constant SIGNAL_DELAY : natural := 2;
    
    signal reg_write_pipeline_ready : std_logic;
    signal accumulator_write_pipeline_ready : std_logic;

    signal reg_write_address_ready_mux : std_logic;
    signal reg_write_address_valid_demux : std_logic_vector(NUM_OF_REGISTER_WRITER_INSTANCES - 1 downto 0);
            
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
    
    signal data_ready_from_opcode_delay : std_logic;
    signal data_valid_from_opcode_delay : std_logic;
    signal data_from_opcode_delay : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0);
    signal data_from_opcode_delay_natural : natural range 0 to NUMBER_OF_OPERATIONS - 1;

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

    signal data_ready_from_accu_mode_delay : std_logic;
    signal data_valid_from_accu_mode_delay : std_logic;
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
begin

    opcode_in_ready <= data_ready_from_opcode_delay and not rst;
    data_from_opcode_delay_natural <= to_integer(unsigned(data_from_opcode_delay));

    process(data_from_opcode_delay_natural, reg_write_address_out_ready) begin
        case (data_from_opcode_delay_natural) is
            when OPERATION_VECTOR_LOAD => reg_write_address_ready_mux <= reg_write_address_out_ready(NUM_OF_REGISTER_WRITER_INSTANCES - 3);
            when OPERATION_VECTOR_STORE => reg_write_address_ready_mux <= reg_write_address_out_ready(NUM_OF_REGISTER_WRITER_INSTANCES - 2);
            when OPERATION_VECTOR_MOV => reg_write_address_ready_mux <= reg_write_address_out_ready(NUM_OF_REGISTER_WRITER_INSTANCES - 2);
            when OPERATION_VECTOR_MAC => reg_write_address_ready_mux <= reg_write_address_out_ready(NUM_OF_REGISTER_WRITER_INSTANCES - 2);
            when OPERATION_VECTOR_BIAS_QUANT => reg_write_address_ready_mux <= reg_write_address_out_ready(NUM_OF_REGISTER_WRITER_INSTANCES - 1);
            when others => reg_write_address_ready_mux <= '1';
        end case;
    end process;

    process(data_from_opcode_delay_natural, data_valid_from_reg_write_address_delay) begin
        reg_write_address_valid_demux <= (others => '0');
        case (data_from_opcode_delay_natural) is
            when OPERATION_VECTOR_LOAD => reg_write_address_valid_demux(NUM_OF_REGISTER_WRITER_INSTANCES - 3) <= data_valid_from_reg_write_address_delay;
            when OPERATION_VECTOR_STORE => reg_write_address_valid_demux(NUM_OF_REGISTER_WRITER_INSTANCES - 2) <= data_valid_from_reg_write_address_delay;
            when OPERATION_VECTOR_MOV => reg_write_address_valid_demux(NUM_OF_REGISTER_WRITER_INSTANCES - 2) <= data_valid_from_reg_write_address_delay;
            when OPERATION_VECTOR_MAC => reg_write_address_valid_demux(NUM_OF_REGISTER_WRITER_INSTANCES - 2) <= data_valid_from_reg_write_address_delay;
            when OPERATION_VECTOR_BIAS_QUANT => reg_write_address_valid_demux(NUM_OF_REGISTER_WRITER_INSTANCES - 1) <= data_valid_from_reg_write_address_delay;
            when others => reg_write_address_valid_demux <= (others => '0');
        end case;
    end process;

    reg_write_pipeline_ready <= reg_write_address_ready_mux;
    accumulator_write_pipeline_ready <= accu_address_write_out_ready;

    dependency_handler_inst : entity work.dependency_handler
        generic map (
            NUM_OF_REGISTERS => NUM_OF_VECTOR_REGISTERS + NUM_OF_BIAS_REGISTERS + NUM_OF_SYSTOLIC_ARRAY_WEIGHT_REGISTERS,
            REGISTER_ADDRESS_LENGTH => REGISTER_ADDRESS_LENGTH,
            ACCUMULATOR_ADDRESS_LENGTH => ACCUMULATOR_ADDRESS_LENGTH,
            NUM_OF_ACCUMULATOR_REGISTERS => NUM_OF_ACCUMULATOR_REGISTERS,
            NUM_OF_VECTOR_REGISTER_BLOCKS => NUM_OF_VECTOR_REGISTER_BLOCKS,

            VECTOR_REGISTER_BASE_ADDRESS => VECTOR_REGISTER_BASE_ADDRESS,
            BIAS_REGISTER_BASE_ADDRESS => BIAS_REGISTER_BASE_ADDRESS,
            SYS_ARRAY_REGISTER_BASE_ADDRESS => SYS_ARRAY_REGISTER_BASE_ADDRESS,

            VECTOR_REGISTER_ADDRESS_MASK => VECTOR_REGISTER_ADDRESS_MASK,
            BIAS_REGISTER_ADDRESS_MASK => BIAS_REGISTER_ADDRESS_MASK,
            SYS_ARRAY_REGISTER_ADDRESS_MASK => SYS_ARRAY_REGISTER_ADDRESS_MASK,

            VECTOR_REGISTER_MOD_OFFSET => std_logic_vector(to_unsigned(0, REGISTER_ADDRESS_LENGTH)),
            BIAS_REGISTER_MOD_OFFSET => std_logic_vector(to_unsigned(NUM_OF_VECTOR_REGISTERS, REGISTER_ADDRESS_LENGTH)),
            SYS_ARRAY_REGISTER_MOD_OFFSET => std_logic_vector(to_unsigned(NUM_OF_VECTOR_REGISTERS + NUM_OF_BIAS_REGISTERS, REGISTER_ADDRESS_LENGTH))
        )
        port map (
            clk => clk,
            rst => rst,
            
            pipeline_start_en => pipeline_start_en_from_depcheck,
            
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
            systolic_array_selected_weight_bank_in => std_logic_vector(resize(unsigned(systolic_array_selected_weight_bank), REGISTER_ADDRESS_LENGTH)) and SYS_ARRAY_REGISTER_BASE_ADDRESS,
            
            selected_bias_bank_in_valid => selected_bias_bank_valid,
            selected_bias_bank_in_ready => selected_bias_bank_in_ready_from_depcheck,
            selected_bias_bank_in => std_logic_vector(resize(unsigned(selected_bias_bank), REGISTER_ADDRESS_LENGTH)) and SYS_ARRAY_REGISTER_BASE_ADDRESS,
            
            register_write_back_address_valid => register_write_back_address_valid,
            register_write_back_address_ready => register_write_back_address_ready,
            register_write_back_address => register_write_back_address,
            register_write_back_ready => register_write_back_ready,
            
            selected_accumulator_bank_write_in_valid => selected_accumulator_bank_write_valid,
            selected_accumulator_bank_write_in_ready => selected_accumulator_bank_write_in_ready_from_depcheck,
            selected_accumulator_bank_write_in => selected_accumulator_bank_write,
            
            selected_accumulator_bank_read_in_valid => selected_accumulator_bank_read_valid,
            selected_accumulator_bank_read_in_ready => selected_accumulator_bank_read_in_ready_from_depcheck,
            selected_accumulator_bank_read_in => selected_accumulator_bank_read,
            
            accumulator_write_back_address_valid => accumulator_write_back_address_valid,
            accumulator_write_back_address_ready => accumulator_write_back_address_ready,
            accumulator_write_back_address => accumulator_write_back_address,
            accumulator_write_back_ready => accumulator_write_back_ready
        );    
        
    opcode_delay_inst : entity work.data_delay_for_pipeline_input_handler
        generic map(
            DATA_LENGTH => OPERATION_CODE_LENGTH,
            DELAY_LENGTH => SIGNAL_DELAY
        )
        port map(
            clk            => clk,
            rst            => rst,

            input_en       => pipeline_start_en_from_depcheck,

            data_in_valid  => opcode_in_valid,
            data_in_ready  => data_ready_from_opcode_delay,
            data_in        => opcode_in,

            data_out_valid => data_valid_from_opcode_delay,
            data_out_ready => reg_write_address_ready_mux,
            data_out       => data_from_opcode_delay
        );
    

    memory_read_address_ready <= data_ready_from_memory_read_address_delay;
    memory_read_address_out_valid <= data_valid_from_memory_read_address_delay;
    memory_read_address_out <= data_from_memory_read_address_delay;
        
    memory_read_address_delay_inst : entity work.data_delay_for_pipeline_input_handler
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
        
    memory_write_address_delay_inst : entity work.data_delay_for_pipeline_input_handler
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
        
    register_read_address_ready <= data_ready_from_reg_read_address_delay;
    reg_read_address_out_valid <= data_valid_from_reg_read_address_delay;
    reg_read_address_out <= data_from_reg_read_address_delay;
        
    register_read_address_delay_inst : entity work.data_delay_for_pipeline_input_handler
        generic map (
            DATA_LENGTH => REGISTER_ADDRESS_LENGTH,
            DELAY_LENGTH => SIGNAL_DELAY
        )
        port map (
            clk => clk,
            rst => rst,
            
            input_en => pipeline_start_en_from_depcheck,
            
            data_in_valid => register_read_address_valid,
            data_in_ready => data_ready_from_reg_read_address_delay,
            data_in => register_read_address,
    
            data_out_valid => data_valid_from_reg_read_address_delay,
            data_out_ready => reg_read_address_out_ready,
            data_out => data_from_reg_read_address_delay
        );
    
    register_write_address_ready <= data_ready_from_reg_write_address_delay;
    reg_write_address_out_valid <= reg_write_address_valid_demux;
    reg_write_address_out <= data_from_reg_write_address_delay;
    
    register_write_address_delay_inst : entity work.data_delay_for_pipeline_input_handler
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
            data_out_ready => reg_write_address_ready_mux,
            data_out => data_from_reg_write_address_delay
        );
        
    systolic_array_selected_weight_bank_ready <= data_ready_from_systolic_array_selected_weight_bank_delay;
    sys_array_bank_address_out_valid <= data_valid_from_systolic_array_selected_weight_bank_delay;
    sys_array_bank_address_out <= data_from_systolic_array_selected_weight_bank_delay;
    
    systolic_array_selected_weight_bank_delay_inst : entity work.data_delay_for_pipeline_input_handler
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
        
    selected_accumulator_bank_write_ready <= data_ready_from_selected_accumulator_bank_write_delay;
    accu_address_write_out_valid <= data_valid_from_selected_accumulator_bank_write_delay;
    accu_address_write_out <= data_from_selected_accumulator_bank_write_delay;
        
    selected_accumulator_bank_write_delay_inst : entity work.data_delay_for_pipeline_input_handler
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
        
    accumulator_mode_ready <= data_ready_from_accu_mode_delay;
    accu_mode_out_valid <= data_valid_from_accu_mode_delay;
    accu_mode_out <= data_from_accu_mode_delay;
        
    accumulator_mode_delay_inst : entity work.data_delay_for_pipeline_input_handler
        generic map (
            DATA_LENGTH => ACCUMULATOR_MODE_LENGTH,
            DELAY_LENGTH => SIGNAL_DELAY
        )
        port map (
            clk => clk,
            rst => rst,
            
            input_en => pipeline_start_en_from_depcheck,
            
            data_in_valid => accumulator_mode_valid,
            data_in_ready => data_ready_from_accu_mode_delay,
            data_in => accumulator_mode,
            
            data_out_valid => data_valid_from_accu_mode_delay,
            data_out_ready => accu_mode_out_ready,
            data_out => data_from_accu_mode_delay
        );
        
    selected_accumulator_bank_read_ready <= data_ready_from_selected_accumulator_bank_read_delay;
    accu_address_read_out_valid <= data_valid_from_selected_accumulator_bank_read_delay;
    accu_address_read_out <= data_from_selected_accumulator_bank_read_delay;
        
    selected_accumulator_bank_read_delay_inst : entity work.data_delay_for_pipeline_input_handler
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
        
    selected_bias_bank_ready <= data_ready_from_selected_bias_bank_delay;
    bias_address_out_valid <= data_valid_from_selected_bias_bank_delay;
    bias_address_out <= data_from_selected_bias_bank_delay;
        
    selected_bias_bank_delay_inst : entity work.data_delay_for_pipeline_input_handler
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
        
    resize_mode_delay_inst : entity work.data_delay_for_pipeline_input_handler
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
