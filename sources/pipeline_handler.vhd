----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/23/2026 08:16:08 PM
-- Design Name: 
-- Module Name: pipeline_handler - Behavioral
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
use work.neural_engine.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pipeline_handler is
    generic (
        OPERATION_CODE_LENGTH : natural := 7;
        
        MEMORY_ADDRESS_LENGTH : natural := 32;
        REGISTER_ADDRESS_LENGTH : natural := 16;
        SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH : natural := 8;
        ACCUMULATOR_ADDRESS_LENGTH : natural := 8;
        ACCUMULATOR_MODE_LENGTH : natural := 3;
        BIAS_ADDRESS_LENGTH : natural := 8;
        RESIZE_MODE_LENGTH : natural := 3;
        
        VECTOR_LENGTH : natural := 8;
        DATA_WIDTH : natural := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        pipeline_mac_en_out : out std_logic;
        pipeline_bias_quant_en_out : out std_logic;
        pipeline_load_en_out : out std_logic;
        pipeline_store_en_out : out std_logic;
        pipeline_mov_en_out : out std_logic;
        
        opcode_in_valid : in std_logic; -- @suppress "Unused port: opcode_in_valid is not used in work.pipeline_handler(Behavioral)"
        opcode_in_ready : out std_logic;
        opcode_in : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0);
        
        mem_write_address_in_valid : in std_logic;
        mem_write_address_in_ready : out std_logic;
        mem_write_address_in : in std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
        
        mem_read_address_in_valid : in std_logic;
        mem_read_address_in_ready : out std_logic;
        mem_read_address_in : in std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
        
        mem_read_data_in_valid : in std_logic;
        mem_read_data_in_ready : out std_logic;
        mem_read_data_in : in data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        reg_write_address_in_valid : in std_logic;
        reg_write_address_in_ready : out std_logic;
        reg_write_address_in : in std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        reg_read_data_in_valid : in std_logic;
        reg_read_data_in_ready : out std_logic;
        reg_read_data_in : in data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        sys_array_bank_address_in_valid : in std_logic;
        sys_array_bank_address_in_ready : out std_logic;
        sys_array_bank_address_in : in std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);
        
        accu_write_address_in_valid : in std_logic;
        accu_write_address_in_ready : out std_logic;
        accu_write_address_in : in std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        
        accu_mode_in_valid : in std_logic;
        accu_mode_in_ready : out std_logic;
        accu_mode_in : in std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
        
        accu_read_address_in_valid : in std_logic;
        accu_read_address_in_ready : out std_logic;
        accu_read_address_in : in std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        
        bias_address_in_valid : in std_logic;
        bias_address_in_ready : out std_logic;
        bias_address_in : in std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);
        
        resize_mode_in_valid : in std_logic;
        resize_mode_in_ready : out std_logic;
        resize_mode_in : in std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);
        
        reg_data_from_resize_module_valid : in std_logic;
        reg_data_from_resize_module_ready : out std_logic;
        reg_data_from_resize_module : in data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        mem_write_address_out_valid : out std_logic;
        mem_write_address_out_ready : in std_logic;
        mem_write_address_out : out std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
        
        mem_write_data_out_valid : out std_logic;
        mem_write_data_out_ready : in std_logic;
        mem_write_data_out : out data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        mem_read_address_out_valid : out std_logic;
        mem_read_address_out_ready : in std_logic;
        mem_read_address_out : out std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
        
        reg_write_address_out_valid : out std_logic;
        reg_write_address_out_ready : in std_logic;
        reg_write_address_out : out std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        reg_write_data_out_valid : out std_logic;
        reg_write_data_out_ready : in std_logic;
        reg_write_data_out : out data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        reg_data_out_to_mac_valid : out std_logic;
        reg_data_out_to_mac_ready : in std_logic;
        reg_data_out_to_mac : out data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        sys_array_bank_address_out_valid : out std_logic;
        sys_array_bank_address_out_ready : in std_logic;
        sys_array_bank_address_out : out std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);
        
        accu_write_address_out_valid : out std_logic;
        accu_write_address_out_ready : in std_logic;
        accu_write_address_out : out std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        
        accu_mode_out_valid : out std_logic;
        accu_mode_out_ready : in std_logic;
        accu_mode_out : out std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
        
        accu_read_address_out_valid : out std_logic;
        accu_read_address_out_ready : in std_logic;
        accu_read_address_out : out std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        
        bias_address_out_valid : out std_logic;
        bias_address_out_ready : in std_logic;
        bias_address_out : out std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);
        
        resize_mode_out_valid : out std_logic;
        resize_mode_out_ready : in std_logic;
        resize_mode_out : out std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0)
    );
end pipeline_handler;

architecture Behavioral of pipeline_handler is
    constant PIPELINE_READY_VECTOR_LENGTH : natural := 6;

    signal pipeline_reg_data_in_ready_vector : std_logic_vector(PIPELINE_READY_VECTOR_LENGTH - 1 downto 0);
    signal pipeline_ready_out_from_reg_data_in_ready_selector : std_logic;
    signal pipeline_ready : std_logic;
    
    signal pipeline_reg_write_address_in_ready_vector : std_logic_vector(PIPELINE_READY_VECTOR_LENGTH - 1 downto 0);
    signal pipeline_ready_out_from_reg_write_address_in_ready_selector : std_logic;

    signal pipeline_load_sel_from_pipeline_selector : std_logic;
    signal pipeline_store_sel_from_pipeline_selector : std_logic; 
    signal pipeline_mov_sel_from_pipeline_selector : std_logic;
    signal pipeline_mac_sel_from_pipeline_selector : std_logic;
    signal pipeline_bias_quant_sel_from_pipeline_selector : std_logic;

    signal pipeline_en_out_from_load : std_logic;
    signal mem_read_address_ready_from_load : std_logic;
    signal mem_read_address_out_valid_from_load : std_logic;
    signal mem_read_address_out_from_load : std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
    signal mem_read_data_in_ready_from_load : std_logic;
    signal reg_write_address_in_ready_from_load : std_logic;
    signal reg_write_address_out_valid_from_load : std_logic;
    signal reg_write_address_out_from_load : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    signal reg_data_out_valid_from_load : std_logic;
    signal reg_data_out_from_load : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);

    signal pipeline_en_out_from_store : std_logic;
    signal mem_write_address_in_ready_from_store : std_logic;
    signal reg_read_data_in_ready_from_store : std_logic;
    signal write_address_out_valid_from_store : std_logic;
    signal write_address_out_from_store : std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
    signal write_data_out_valid_from_store : std_logic;
    signal write_data_out_from_store : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
    
    signal pipeline_en_out_from_mov : std_logic;
    signal reg_write_address_in_ready_from_mov : std_logic;
    signal reg_read_data_in_ready_from_mov : std_logic;
    signal reg_write_address_out_valid_from_mov : std_logic;
    signal reg_write_address_out_from_mov : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    signal reg_write_data_out_valid_from_mov : std_logic;
    signal reg_write_data_out_from_mov : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);

    signal pipeline_en_from_mac : std_logic;
    signal reg_data_in_ready_from_mac : std_logic;
    signal sys_array_bank_address_in_ready_from_mac : std_logic;
    signal accu_address_in_ready_from_mac : std_logic;
    signal accu_mode_in_ready_from_mac : std_logic;
    signal reg_data_out_valid_from_mac : std_logic;
    signal reg_data_out_from_mac : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
    signal sys_array_bank_address_out_valid_from_mac : std_logic;
    signal sys_array_bank_address_out_from_mac : std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);
    signal accu_address_out_valid_from_mac : std_logic;
    signal accu_address_out_from_mac : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
    signal accu_mode_out_valid_from_mac : std_logic;
    signal accu_mode_out_from_mac : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
    
    signal pipeline_en_out_from_bias_quant : std_logic;
    signal accu_read_address_in_ready_from_bias_quant : std_logic;
    signal bias_address_in_ready_from_bias_quant : std_logic;
    signal resize_mode_in_ready_from_bias_quant : std_logic;
    signal reg_write_address_in_ready_from_bias_quant : std_logic;
    signal accu_address_out_valid_from_bias_quant : std_logic;
    signal accu_address_out_from_bias_quant : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
    signal bias_address_out_valid_from_bias_quant : std_logic;
    signal bias_address_out_from_bias_quant : std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);
    signal resize_mode_out_valid_from_bias_quant : std_logic;
    signal resize_mode_out_from_bias_quant : std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);
    signal reg_write_address_out_valid_from_bias_quant : std_logic;
    signal reg_write_address_out_from_bias_quant : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    signal reg_write_data_in_ready_from_bias_quant : std_logic;
    signal reg_write_data_out_valid_from_bias_quant : std_logic;
    signal reg_write_data_out_from_bias_quant : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
    
    signal load_reg_address_ready_from_register_writer : std_logic;
    signal load_reg_data_ready_from_register_writer : std_logic;
    signal mov_reg_address_ready_from_register_writer : std_logic;
    signal mov_reg_data_ready_from_register_writer : std_logic;
    signal bias_quant_reg_address_ready_from_register_writer : std_logic;
    signal bias_quant_reg_data_ready_from_register_writer : std_logic;
    signal reg_address_valid_from_register_writer : std_logic;
    signal reg_address_from_register_writer : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    signal reg_data_valid_from_register_writer : std_logic;
    signal reg_data_from_register_writer : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
    
begin

    pipeline_ready <= mem_write_address_in_ready_from_store and
                       mem_read_address_ready_from_load and
                       mem_read_data_in_ready_from_load and
                       pipeline_ready_out_from_reg_write_address_in_ready_selector and
                       pipeline_ready_out_from_reg_data_in_ready_selector and
                       sys_array_bank_address_in_ready_from_mac and
                       accu_address_in_ready_from_mac and
                       accu_mode_in_ready_from_mac and
                       accu_read_address_in_ready_from_bias_quant and
                       bias_address_in_ready_from_bias_quant and
                       resize_mode_in_ready_from_bias_quant and
                       reg_write_data_in_ready_from_bias_quant;

    pipeline_load_en_out <= pipeline_en_out_from_load;
    pipeline_store_en_out <= pipeline_en_out_from_store;
    pipeline_mov_en_out <= pipeline_en_out_from_mov;

    pipeline_reg_data_in_ready_vector <= '1' &
                                         reg_data_in_ready_from_mac &
                                         reg_read_data_in_ready_from_mov &
                                         reg_read_data_in_ready_from_store &
                                         '1' &
                                         '1';
                                         
    reg_read_data_in_ready <= pipeline_ready_out_from_reg_data_in_ready_selector;

    pipeline_reg_data_in_ready_selector : entity work.pipeline_ready_selector
        generic map (
            PIPELINE_READY_VECTOR_LENGTH => PIPELINE_READY_VECTOR_LENGTH,
            OPERATION_CODE_LENGTH => OPERATION_CODE_LENGTH
        )
        port map (
            opcode_in => opcode_in,
            
            pipeline_ready_vector => pipeline_reg_data_in_ready_vector,
            
            pipeline_ready_out => pipeline_ready_out_from_reg_data_in_ready_selector
        );

    pipeline_reg_write_address_in_ready_vector <= reg_write_address_in_ready_from_bias_quant &
                                                  '1' & 
                                                  reg_write_address_in_ready_from_mov &
                                                  '1' & 
                                                  reg_write_address_in_ready_from_load &
                                                  '1';
                                                  
    reg_write_address_in_ready <= pipeline_ready_out_from_reg_write_address_in_ready_selector;

    pipeline_reg_write_address_in_ready_selector : entity work.pipeline_ready_selector
        generic map (
            PIPELINE_READY_VECTOR_LENGTH => PIPELINE_READY_VECTOR_LENGTH,
            OPERATION_CODE_LENGTH => OPERATION_CODE_LENGTH
        )
        port map (
            opcode_in => opcode_in,
            
            pipeline_ready_vector => pipeline_reg_write_address_in_ready_vector,
            
            pipeline_ready_out => pipeline_ready_out_from_reg_write_address_in_ready_selector
        );

    opcode_in_ready <= '1';

    pipeline_selector_inst : entity work.pipeline_selector
        generic map (
            OPERATION_CODE_LENGTH => OPERATION_CODE_LENGTH
        )
        port map (
            opcode_in => opcode_in,
        
            pipeline_load_sel => pipeline_load_sel_from_pipeline_selector,
            pipeline_store_sel => pipeline_store_sel_from_pipeline_selector,
            pipeline_mov_sel => pipeline_mov_sel_from_pipeline_selector,
            pipeline_mac_sel => pipeline_mac_sel_from_pipeline_selector,
            pipeline_bias_quant_sel => pipeline_bias_quant_sel_from_pipeline_selector
        );

    mem_read_address_in_ready <= mem_read_address_ready_from_load;
    mem_read_data_in_ready <= mem_read_data_in_ready_from_load;
    mem_read_address_out_valid <= mem_read_address_out_valid_from_load;
    mem_read_address_out <= mem_read_address_out_from_load;

    pipeline_load_inst : entity work.pipeline_load
        generic map (
            REGISTER_ADDRESS_LENGTH => REGISTER_ADDRESS_LENGTH,
            MEMORY_ADDRESS_LENGTH => MEMORY_ADDRESS_LENGTH,
            VECTOR_LENGTH => VECTOR_LENGTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            en => pipeline_load_sel_from_pipeline_selector,
            
            pipeline_en_out => pipeline_en_out_from_load,
            
            mem_read_address_in_valid => mem_read_address_in_valid,
            mem_read_address_in_ready => mem_read_address_ready_from_load,
            mem_read_address_in => mem_read_address_in,
            
            mem_read_address_out_valid => mem_read_address_out_valid_from_load,
            mem_read_address_out_ready => mem_read_address_out_ready,
            mem_read_address_out => mem_read_address_out_from_load,
            
            mem_data_in_valid => mem_read_data_in_valid,
            mem_data_in_ready => mem_read_data_in_ready_from_load,
            mem_data_in => mem_read_data_in,
            
            reg_write_address_in_valid => reg_write_address_in_valid,
            reg_write_address_in_ready => reg_write_address_in_ready_from_load,
            reg_write_address_in => reg_write_address_in,
            
            reg_write_address_out_valid => reg_write_address_out_valid_from_load,
            reg_write_address_out_ready => load_reg_address_ready_from_register_writer,
            reg_write_address_out => reg_write_address_out_from_load,
            
            reg_data_out_valid => reg_data_out_valid_from_load,
            reg_data_out_ready => load_reg_data_ready_from_register_writer,
            reg_data_out => reg_data_out_from_load
        );
        
    mem_write_address_in_ready <= mem_write_address_in_ready_from_store;
    mem_write_address_out_valid <= write_address_out_valid_from_store;
    mem_write_address_out <= write_address_out_from_store;
    mem_write_data_out_valid <= write_data_out_valid_from_store;
    mem_write_data_out <= write_data_out_from_store;

    pipeline_store_inst : entity work.pipeline_mov
        generic map (
            WRITE_ADDRESS_LENGTH => MEMORY_ADDRESS_LENGTH,
            VECTOR_LENGTH => VECTOR_LENGTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            en => pipeline_store_sel_from_pipeline_selector,
            
            pipeline_en_out => pipeline_en_out_from_store,
            
            write_address_in_valid => mem_write_address_in_valid,
            write_address_in_ready => mem_write_address_in_ready_from_store,
            write_address_in => mem_write_address_in,
            
            read_data_in_valid => reg_read_data_in_valid,
            read_data_in_ready => reg_read_data_in_ready_from_store,
            read_data_in => reg_read_data_in,
            
            write_address_out_valid => write_address_out_valid_from_store,
            write_address_out_ready => mem_write_address_out_ready,
            write_address_out => write_address_out_from_store,
            
            write_data_out_valid => write_data_out_valid_from_store,
            write_data_out_ready => mem_write_data_out_ready,
            write_data_out => write_data_out_from_store
        );

    pipeline_mov_inst : entity work.pipeline_mov
        generic map (
            WRITE_ADDRESS_LENGTH => REGISTER_ADDRESS_LENGTH,
            VECTOR_LENGTH => VECTOR_LENGTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            en => pipeline_mov_sel_from_pipeline_selector,
            
            pipeline_en_out => pipeline_en_out_from_mov,
            
            write_address_in_valid => reg_write_address_in_valid,
            write_address_in_ready => reg_write_address_in_ready_from_mov,
            write_address_in => reg_write_address_in,
            
            read_data_in_valid => reg_read_data_in_valid,
            read_data_in_ready => reg_read_data_in_ready_from_mov,
            read_data_in => reg_read_data_in,
            
            write_address_out_valid => reg_write_address_out_valid_from_mov,
            write_address_out_ready => mov_reg_address_ready_from_register_writer,
            write_address_out => reg_write_address_out_from_mov,
            
            write_data_out_valid => reg_write_data_out_valid_from_mov,
            write_data_out_ready => mov_reg_data_ready_from_register_writer,
            write_data_out => reg_write_data_out_from_mov
        );

    pipeline_mac_en_out <= pipeline_en_from_mac;
    reg_data_out_to_mac_valid <= reg_data_out_valid_from_mac;
    reg_data_out_to_mac <= reg_data_out_from_mac;
    sys_array_bank_address_in_ready <= sys_array_bank_address_in_ready_from_mac;
    sys_array_bank_address_out_valid <= sys_array_bank_address_out_valid_from_mac;
    sys_array_bank_address_out <= sys_array_bank_address_out_from_mac;
    accu_write_address_in_ready <= accu_address_in_ready_from_mac;
    accu_write_address_out_valid <= accu_address_out_valid_from_mac;
    accu_write_address_out <= accu_address_out_from_mac;
    accu_mode_in_ready <= accu_mode_in_ready_from_mac;
    accu_mode_out_valid <= accu_mode_out_valid_from_mac;
    accu_mode_out <= accu_mode_out_from_mac;

    pipeline_mac_inst : entity work.pipeline_mac
        generic map (
            SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH => SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH,
            ACCUMULATOR_ADDRESS_LENGTH => ACCUMULATOR_ADDRESS_LENGTH,
            ACCUMULATOR_MODE_LENGTH => ACCUMULATOR_MODE_LENGTH,
            VECTOR_LENGTH => VECTOR_LENGTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            en => pipeline_mac_sel_from_pipeline_selector,
            
            pipeline_en_out => pipeline_en_from_mac,
            
            reg_data_in_valid => reg_read_data_in_valid,
            reg_data_in_ready => reg_data_in_ready_from_mac,
            reg_data_in => reg_read_data_in,
            
            reg_data_out_valid => reg_data_out_valid_from_mac,
            reg_data_out_ready => reg_data_out_to_mac_ready,
            reg_data_out => reg_data_out_from_mac,
            
            sys_array_bank_address_in_valid => sys_array_bank_address_in_valid,
            sys_array_bank_address_in_ready => sys_array_bank_address_in_ready_from_mac,
            sys_array_bank_address_in => sys_array_bank_address_in,
            
            sys_array_bank_address_out_valid => sys_array_bank_address_out_valid_from_mac,
            sys_array_bank_address_out_ready => sys_array_bank_address_out_ready,
            sys_array_bank_address_out => sys_array_bank_address_out_from_mac,
            
            accu_address_in_valid => accu_write_address_in_valid,
            accu_address_in_ready => accu_address_in_ready_from_mac,
            accu_address_in => accu_write_address_in,
            
            accu_address_out_valid => accu_address_out_valid_from_mac,
            accu_address_out_ready => accu_write_address_out_ready,
            accu_address_out => accu_address_out_from_mac,
            
            accu_mode_in_valid => accu_mode_in_valid,
            accu_mode_in_ready => accu_mode_in_ready_from_mac,
            accu_mode_in => accu_mode_in,
            
            accu_mode_out_valid => accu_mode_out_valid_from_mac,
            accu_mode_out_ready => accu_mode_out_ready,
            accu_mode_out => accu_mode_out_from_mac
        );
    
    pipeline_bias_quant_en_out <= pipeline_en_out_from_bias_quant;
    accu_read_address_in_ready <= accu_read_address_in_ready_from_bias_quant;
    accu_read_address_out_valid <= accu_address_out_valid_from_bias_quant;
    accu_read_address_out <= accu_address_out_from_bias_quant;
    bias_address_in_ready <= bias_address_in_ready_from_bias_quant;
    bias_address_out_valid <= bias_address_out_valid_from_bias_quant;
    bias_address_out <= bias_address_out_from_bias_quant;
    resize_mode_in_ready <= resize_mode_in_ready_from_bias_quant;
    resize_mode_out_valid <= resize_mode_out_valid_from_bias_quant;
    resize_mode_out <= resize_mode_out_from_bias_quant;
    reg_data_from_resize_module_ready <= reg_write_data_in_ready_from_bias_quant;
        
    pipeline_bias_quant_inst : entity work.pipeline_bias_quant
        generic map (
            REGISTER_ADDRESS_LENGTH => REGISTER_ADDRESS_LENGTH,
            ACCUMULATOR_ADDRESS_LENGTH => ACCUMULATOR_ADDRESS_LENGTH,
            BIAS_ADDRESS_LENGTH => BIAS_ADDRESS_LENGTH,
            RESIZE_MODE_LENGTH => RESIZE_MODE_LENGTH,
            VECTOR_LENGTH => VECTOR_LENGTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            en => pipeline_bias_quant_sel_from_pipeline_selector,
            
            pipeline_en_out => pipeline_en_out_from_bias_quant,
            
            accu_address_in_valid => accu_read_address_in_valid,
            accu_address_in_ready => accu_read_address_in_ready_from_bias_quant,
            accu_address_in => accu_read_address_in,
            
            accu_address_out_valid => accu_address_out_valid_from_bias_quant,
            accu_address_out_ready => accu_read_address_out_ready,
            accu_address_out => accu_address_out_from_bias_quant,
            
            bias_address_in_valid => bias_address_in_valid,
            bias_address_in_ready => bias_address_in_ready_from_bias_quant,
            bias_address_in => bias_address_in,
            
            bias_address_out_valid => bias_address_out_valid_from_bias_quant,
            bias_address_out_ready => bias_address_out_ready,
            bias_address_out => bias_address_out_from_bias_quant,
            
            resize_mode_in_valid => resize_mode_in_valid,
            resize_mode_in_ready => resize_mode_in_ready_from_bias_quant,
            resize_mode_in => resize_mode_in,
            
            resize_mode_out_valid => resize_mode_out_valid_from_bias_quant,
            resize_mode_out_ready => resize_mode_out_ready,
            resize_mode_out => resize_mode_out_from_bias_quant,
            
            reg_write_address_in_valid => reg_write_address_in_valid,
            reg_write_address_in_ready => reg_write_address_in_ready_from_bias_quant,
            reg_write_address_in => reg_write_address_in,
            
            reg_write_address_out_valid => reg_write_address_out_valid_from_bias_quant,
            reg_write_address_out_ready => bias_quant_reg_address_ready_from_register_writer,
            reg_write_address_out => reg_write_address_out_from_bias_quant,
            
            reg_write_data_in_valid => reg_data_from_resize_module_valid,
            reg_write_data_in_ready => reg_write_data_in_ready_from_bias_quant,
            reg_write_data_in => reg_data_from_resize_module,
            
            reg_write_data_out_valid => reg_write_data_out_valid_from_bias_quant,
            reg_write_data_out_ready => bias_quant_reg_data_ready_from_register_writer,
            reg_write_data_out => reg_write_data_out_from_bias_quant
        );

    reg_write_data_out_valid <= reg_data_valid_from_register_writer;
    reg_write_data_out <= reg_data_from_register_writer;
    reg_write_address_out_valid <= reg_address_valid_from_register_writer;
    reg_write_address_out <= reg_address_from_register_writer;
    
    register_writer_inst : entity work.register_writer
        generic map (
            REG_ADDRESS_LENGTH => REGISTER_ADDRESS_LENGTH,
        
            VECTOR_LENGTH => VECTOR_LENGTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            load_reg_address_valid => reg_write_address_out_valid_from_load,
            load_reg_address_ready => load_reg_address_ready_from_register_writer,
            load_reg_address => reg_write_address_out_from_load,
            
            load_reg_data_valid => reg_data_out_valid_from_load,
            load_reg_data_ready => load_reg_data_ready_from_register_writer,
            load_reg_data => reg_data_out_from_load,
            
            mov_reg_address_valid => reg_write_address_out_valid_from_mov,
            mov_reg_address_ready => mov_reg_address_ready_from_register_writer,
            mov_reg_address => reg_write_address_out_from_mov,
            
            mov_reg_data_valid => reg_write_data_out_valid_from_mov,
            mov_reg_data_ready => mov_reg_data_ready_from_register_writer,
            mov_reg_data => reg_write_data_out_from_mov,
            
            bias_quant_reg_address_valid => reg_write_address_out_valid_from_bias_quant,
            bias_quant_reg_address_ready => bias_quant_reg_address_ready_from_register_writer,
            bias_quant_reg_address => reg_write_address_out_from_bias_quant,
            
            bias_quant_reg_data_valid => reg_write_data_out_valid_from_bias_quant,
            bias_quant_reg_data_ready => bias_quant_reg_data_ready_from_register_writer,
            bias_quant_reg_data => reg_write_data_out_from_bias_quant,
            
            reg_address_valid => reg_address_valid_from_register_writer,
            reg_address_ready => reg_write_address_out_ready,
            reg_address => reg_address_from_register_writer,
            
            reg_data_valid => reg_data_valid_from_register_writer,
            reg_data_ready => reg_write_data_out_ready,
            reg_data => reg_data_from_register_writer
        );

end Behavioral;
