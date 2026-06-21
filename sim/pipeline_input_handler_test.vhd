----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/21/2026 07:38:31 PM
-- Design Name: 
-- Module Name: pipeline_input_handler_test - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pipeline_input_handler_test is
end pipeline_input_handler_test;

architecture Behavioral of pipeline_input_handler_test is
    constant NUM_OF_VECTOR_REGISTERS : natural := 128;
    constant NUM_OF_ACCUMULATOR_REGISTERS : natural := 128;

    constant OPERATION_CODE_LENGTH : natural := 7;
    constant MEMORY_ADDRESS_LENGTH : natural := 32;
    constant REGISTER_ADDRESS_LENGTH : natural := 16;
    constant SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH : natural := 8;
    constant BIAS_ADDRESS_LENGTH : natural := 8;
    constant ACCUMULATOR_ADDRESS_LENGTH : natural := 8;
    constant ACCUMULATOR_MODE_LENGTH : natural := 3;
    constant RESIZE_MODE_LENGTH : natural := 3;

    constant REGISTER_VECTOR_LENGTH : natural := 8;
    constant REGISTER_DATA_LENGTH : natural := 8;
    
    signal clk : std_logic;
    signal rst : std_logic;
        
    signal sym_cntr : natural := 0;

    signal opcode_in_valid_inst : std_logic;
    signal opcode_in_ready_inst : std_logic;
    signal opcode_in_inst : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0);

    signal memory_address_valid_inst : std_logic;
    signal memory_address_ready_inst : std_logic;
    signal memory_address_inst : std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);

    signal register_read_address_valid_inst : std_logic;
    signal register_read_address_ready_inst : std_logic;
    signal register_read_address_inst : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    signal register_write_address_valid_inst : std_logic;
    signal register_write_address_ready_inst : std_logic;
    signal register_write_address_inst : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);

    signal systolic_array_selected_weight_bank_valid_inst : std_logic;
    signal systolic_array_selected_weight_bank_ready_inst : std_logic;
    signal systolic_array_selected_weight_bank_inst : std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);

    signal selected_accumulator_bank_write_valid_inst : std_logic;
    signal selected_accumulator_bank_write_ready_inst : std_logic;
    signal selected_accumulator_bank_write_inst : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
    signal accumulator_mode_inst : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);

    signal selected_accumulator_bank_read_valid_inst : std_logic;
    signal selected_accumulator_bank_read_ready_inst : std_logic;
    signal selected_accumulator_bank_read_inst : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);

    signal selected_bias_bank_valid_inst : std_logic;
    signal selected_bias_bank_ready_inst : std_logic;
    signal selected_bias_bank_inst : std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);

    signal resize_module_mode_valid_inst : std_logic;
    signal resize_module_mode_ready_inst : std_logic;
    signal resize_module_mode_inst : std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);


    signal opcode_out_valid_inst : std_logic;
    signal opcode_out_ready_inst : std_logic;
    signal opcode_out_inst : std_logic_vector(OPERATION_CODE_LENGTH - 1 downto 0);

    signal memory_address_out_valid_inst : std_logic;
    signal memory_address_out_ready_inst : std_logic;
    signal memory_address_out_inst : std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);

    signal reg_write_address_out_valid_inst : std_logic;
    signal reg_write_address_out_ready_inst : std_logic;
    signal reg_write_address_out_inst : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);



    signal reg_read_address_out_valid_inst : std_logic;
    signal reg_read_address_out_ready_inst : std_logic;
    signal reg_read_address_out_inst : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);

    signal reg_read_data_in_valid_inst : std_logic;
    signal reg_read_data_in_ready_inst : std_logic;
    signal reg_read_data_in_inst : data_vector(0 to REGISTER_VECTOR_LENGTH)(REGISTER_DATA_LENGTH - 1 downto 0);

    signal reg_read_data_out_valid_inst : std_logic;
    signal reg_read_data_out_ready_inst : std_logic;
    signal reg_read_data_out_inst : data_vector(0 to REGISTER_VECTOR_LENGTH)(REGISTER_DATA_LENGTH - 1 downto 0);

    signal sys_array_bank_address_out_valid_inst : std_logic;
    signal sys_array_bank_address_out_ready_inst : std_logic;
    signal sys_array_bank_address_out_inst : std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);

    signal accu_address_write_out_valid_inst : std_logic;
    signal accu_address_write_out_ready_inst : std_logic;
    signal accu_address_write_out_inst : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
    signal accu_mode_out_inst : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);

    signal accu_address_read_out_valid_inst : std_logic;
    signal accu_address_read_out_ready_inst : std_logic;
    signal accu_address_read_out_inst : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);

    signal bias_address_out_valid_inst : std_logic;
    signal bias_address_out_ready_inst : std_logic;
    signal bias_address_out_inst : std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);

    signal resize_mode_out_valid_inst : std_logic;
    signal resize_mode_out_ready_inst : std_logic;
    signal resize_mode_out_inst : std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);



    signal register_write_back_address_valid_inst : std_logic;
    signal register_write_back_address_ready_inst : std_logic;
    signal register_write_back_address_inst : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    signal register_write_back_ready_inst : std_logic;

    signal accumulator_write_back_address_valid_inst : std_logic;
    signal accumulator_write_back_address_ready_inst : std_logic;
    signal accumulator_write_back_address_inst : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
    signal accumulator_write_back_ready_inst : std_logic;
begin

    process begin
        clk <= '0';
        wait for 1ns;
        clk <= '1';
        wait for 1ns;
    end process;
    
    process begin
        rst <= '1';
        wait for 10ns;
        rst <= '0';
        wait;
    end process;
    
    process (clk) begin
        if rising_edge(clk) and sym_cntr < natural'high then
            sym_cntr <= sym_cntr + 1;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                opcode_out_ready_inst <= '1';
                memory_address_out_ready_inst <= '1';
                reg_write_address_out_ready_inst <= '1';
                reg_read_address_out_ready_inst <= '1';
                reg_read_data_out_ready_inst <= '1';
                sys_array_bank_address_out_ready_inst <= '1';
                accu_address_write_out_ready_inst <= '1';
                accu_address_read_out_ready_inst <= '1';
                bias_address_out_ready_inst <= '1';
                resize_mode_out_ready_inst <= '1';
                register_write_back_ready_inst <= '1';
                accumulator_write_back_ready_inst <= '1';
            elsif sym_cntr = 71 then
                opcode_out_ready_inst <= '0';
            elsif sym_cntr = 72 then
                opcode_out_ready_inst <= '1';
                memory_address_out_ready_inst <= '0';
            elsif sym_cntr = 73 then
                memory_address_out_ready_inst <= '1';
                reg_write_address_out_ready_inst <= '0';
            elsif sym_cntr = 74 then
                reg_write_address_out_ready_inst <= '1';
                reg_read_address_out_ready_inst <= '0';
            elsif sym_cntr = 75 then
                reg_read_address_out_ready_inst <= '1';
                reg_read_data_out_ready_inst <= '0';
            elsif sym_cntr = 76 then
                reg_read_data_out_ready_inst <= '1';
                sys_array_bank_address_out_ready_inst <= '0';
            elsif sym_cntr = 77 then
                sys_array_bank_address_out_ready_inst <= '1';
                accu_address_write_out_ready_inst <= '0';
            elsif sym_cntr = 78 then
                accu_address_write_out_ready_inst <= '1';
                accu_address_read_out_ready_inst <= '0';
            elsif sym_cntr = 79 then
                accu_address_read_out_ready_inst <= '1';
                bias_address_out_ready_inst <= '0';
            elsif sym_cntr = 80 then
                bias_address_out_ready_inst <= '1';
                resize_mode_out_ready_inst <= '0';
            elsif sym_cntr = 81 then
                resize_mode_out_ready_inst <= '1';
                register_write_back_ready_inst <= '0';
            elsif sym_cntr = 82 then
                register_write_back_ready_inst <= '1';
                accumulator_write_back_ready_inst <= '0';
            elsif sym_cntr = 83 then
                accumulator_write_back_ready_inst <= '1';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                opcode_in_valid_inst <= '0';
                memory_address_valid_inst <= '0';
                register_read_address_valid_inst <= '0';
                register_write_address_valid_inst <= '0';
                systolic_array_selected_weight_bank_valid_inst <= '0';
                selected_accumulator_bank_write_valid_inst <= '0';
                selected_accumulator_bank_read_valid_inst <= '0';
                selected_bias_bank_valid_inst <= '0';
                resize_module_mode_valid_inst <= '0';
            elsif sym_cntr = 6 then
                opcode_in_valid_inst <= '1';
            elsif sym_cntr = 7 then
                opcode_in_valid_inst <= '0';
            elsif sym_cntr = 11 then
                memory_address_valid_inst <= '1';
            elsif sym_cntr = 12 then
                memory_address_valid_inst <= '0';
            elsif sym_cntr = 16 then
                register_read_address_valid_inst <= '1';
            elsif sym_cntr = 17 then
                register_read_address_valid_inst <= '0';
            elsif sym_cntr = 21 then
                register_write_address_valid_inst <= '1';
            elsif sym_cntr = 22 then
                register_write_address_valid_inst <= '0';
            elsif sym_cntr = 26 then
                systolic_array_selected_weight_bank_valid_inst <= '1';
            elsif sym_cntr = 27 then
                systolic_array_selected_weight_bank_valid_inst <= '0';
            elsif sym_cntr = 31 then
                selected_accumulator_bank_write_valid_inst <= '1';
            elsif sym_cntr = 32 then
                selected_accumulator_bank_write_valid_inst <= '0';
            elsif sym_cntr = 36 then
                selected_accumulator_bank_read_valid_inst <= '1';
            elsif sym_cntr = 37 then
                selected_accumulator_bank_read_valid_inst <= '0';
            elsif sym_cntr = 41 then
                selected_bias_bank_valid_inst <= '1';
            elsif sym_cntr = 42 then
                selected_bias_bank_valid_inst <= '0';
            elsif sym_cntr = 46 then
                resize_module_mode_valid_inst <= '1';
            elsif sym_cntr = 47 then
                resize_module_mode_valid_inst <= '0';
            elsif sym_cntr = 51 then
                register_write_address_valid_inst <= '1';
            elsif sym_cntr = 52 then
                register_write_address_valid_inst <= '0';
            elsif sym_cntr = 53 then
                register_read_address_valid_inst <= '1';
            elsif sym_cntr = 54 then
                register_read_address_valid_inst <= '0';
            elsif sym_cntr = 55 then
                systolic_array_selected_weight_bank_valid_inst <= '1';
            elsif sym_cntr = 56 then
                systolic_array_selected_weight_bank_valid_inst <= '0';
            elsif sym_cntr = 57 then
                selected_bias_bank_valid_inst <= '1';
            elsif sym_cntr = 58 then
                selected_bias_bank_valid_inst <= '0';
            elsif sym_cntr = 61 then
                register_read_address_valid_inst <= '1';
            elsif sym_cntr = 62 then
                register_read_address_valid_inst <= '0';
            elsif sym_cntr = 63 then
                selected_accumulator_bank_write_valid_inst <= '1';
            elsif sym_cntr = 64 then
                selected_accumulator_bank_write_valid_inst <= '0';
            elsif sym_cntr = 65 then
                selected_accumulator_bank_read_valid_inst <= '1';
            elsif sym_cntr = 66 then
                selected_accumulator_bank_read_valid_inst <= '0';
            elsif sym_cntr = 69 then
                selected_accumulator_bank_read_valid_inst <= '1';
            elsif sym_cntr = 70 then
                selected_accumulator_bank_read_valid_inst <= '0';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                register_write_back_address_valid_inst <= '0';
                accumulator_write_back_address_valid_inst <= '0';
            elsif sym_cntr = 59 then
                register_write_back_address_valid_inst <= '1';
            elsif sym_cntr = 60 then
                register_write_back_address_valid_inst <= '0';
            elsif sym_cntr = 67 then
                accumulator_write_back_address_valid_inst <= '1';
            elsif sym_cntr = 68 then
                accumulator_write_back_address_valid_inst <= '0';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                reg_read_data_in_valid_inst <= '0';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                register_write_address_inst <= (others => '0');
                register_read_address_inst <= std_logic_vector(to_unsigned(1, register_read_address_inst'length));
                systolic_array_selected_weight_bank_inst <= std_logic_vector(to_unsigned(1, systolic_array_selected_weight_bank_inst'length));
                selected_bias_bank_inst <= std_logic_vector(to_unsigned(1, selected_bias_bank_inst'length));
            elsif sym_cntr = 51 then
                register_write_address_inst <= std_logic_vector(to_unsigned(1, register_write_address_inst'length));
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                selected_accumulator_bank_write_inst <= (others => '0');
                selected_accumulator_bank_read_inst <= std_logic_vector(to_unsigned(1, selected_accumulator_bank_read_inst'length));
            elsif sym_cntr = 63 then
                selected_accumulator_bank_write_inst <= std_logic_vector(to_unsigned(1, selected_accumulator_bank_write_inst'length));
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                register_write_back_address_inst <= std_logic_vector(to_unsigned(1, register_write_back_address_inst'length));
                accumulator_write_back_address_inst <= std_logic_vector(to_unsigned(1, accumulator_write_back_address_inst'length));
            end if;
        end if;
    end process;

    tb_pipeline_input_handler : entity work.pipeline_input_handler
        generic map (
            NUM_OF_VECTOR_REGISTERS => NUM_OF_VECTOR_REGISTERS,
            NUM_OF_ACCUMULATOR_REGISTERS => NUM_OF_ACCUMULATOR_REGISTERS,
            
            OPERATION_CODE_LENGTH => OPERATION_CODE_LENGTH,
            MEMORY_ADDRESS_LENGTH => MEMORY_ADDRESS_LENGTH,
            REGISTER_ADDRESS_LENGTH => REGISTER_ADDRESS_LENGTH,
            SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH => SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH,
            BIAS_ADDRESS_LENGTH => BIAS_ADDRESS_LENGTH,
            ACCUMULATOR_ADDRESS_LENGTH => ACCUMULATOR_ADDRESS_LENGTH,
            ACCUMULATOR_MODE_LENGTH => ACCUMULATOR_MODE_LENGTH,
            RESIZE_MODE_LENGTH => RESIZE_MODE_LENGTH,
            
            REGISTER_VECTOR_LENGTH => REGISTER_VECTOR_LENGTH,
            REGISTER_DATA_LENGTH => REGISTER_DATA_LENGTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            opcode_in_valid => opcode_in_valid_inst,
            opcode_in_ready => opcode_in_ready_inst,
            opcode_in => opcode_in_inst,
            
            memory_address_valid => memory_address_valid_inst,
            memory_address_ready => memory_address_ready_inst,
            memory_address => memory_address_inst,
            
            register_read_address_valid => register_read_address_valid_inst,
            register_read_address_ready => register_read_address_ready_inst,
            register_read_address => register_read_address_inst,
            register_write_address_valid => register_write_address_valid_inst,
            register_write_address_ready => register_write_address_ready_inst,
            register_write_address => register_write_address_inst,
            
            systolic_array_selected_weight_bank_valid => systolic_array_selected_weight_bank_valid_inst,
            systolic_array_selected_weight_bank_ready => systolic_array_selected_weight_bank_ready_inst,
            systolic_array_selected_weight_bank => systolic_array_selected_weight_bank_inst,
            
            selected_accumulator_bank_write_valid => selected_accumulator_bank_write_valid_inst,
            selected_accumulator_bank_write_ready => selected_accumulator_bank_write_ready_inst,
            selected_accumulator_bank_write => selected_accumulator_bank_write_inst,
            accumulator_mode => accumulator_mode_inst,
            
            selected_accumulator_bank_read_valid => selected_accumulator_bank_read_valid_inst,
            selected_accumulator_bank_read_ready => selected_accumulator_bank_read_ready_inst,
            selected_accumulator_bank_read => selected_accumulator_bank_read_inst,
            
            selected_bias_bank_valid => selected_bias_bank_valid_inst,
            selected_bias_bank_ready => selected_bias_bank_ready_inst,
            selected_bias_bank => selected_bias_bank_inst,
            
            resize_module_mode_valid => resize_module_mode_valid_inst,
            resize_module_mode_ready => resize_module_mode_ready_inst,
            resize_module_mode => resize_module_mode_inst,
            
            
            opcode_out_valid => opcode_out_valid_inst,
            opcode_out_ready => opcode_out_ready_inst,
            opcode_out => opcode_out_inst,
            
            memory_address_out_valid => memory_address_out_valid_inst,
            memory_address_out_ready => memory_address_out_ready_inst,
            memory_address_out => memory_address_out_inst,
            
            reg_write_address_out_valid => reg_write_address_out_valid_inst,
            reg_write_address_out_ready => reg_write_address_out_ready_inst,
            reg_write_address_out => reg_write_address_out_inst,
            
            
            
            reg_read_address_out_valid => reg_read_address_out_valid_inst,
            reg_read_address_out_ready => reg_read_address_out_ready_inst,
            reg_read_address_out => reg_read_address_out_inst,
            
            reg_read_data_in_valid => reg_read_data_in_valid_inst,
            reg_read_data_in_ready => reg_read_data_in_ready_inst,
            reg_read_data_in => reg_read_data_in_inst,
            
            reg_read_data_out_valid => reg_read_data_out_valid_inst,
            reg_read_data_out_ready => reg_read_data_out_ready_inst,
            reg_read_data_out => reg_read_data_out_inst,
            
            sys_array_bank_address_out_valid => sys_array_bank_address_out_valid_inst,
            sys_array_bank_address_out_ready => sys_array_bank_address_out_ready_inst,
            sys_array_bank_address_out => sys_array_bank_address_out_inst,
            
            accu_address_write_out_valid => accu_address_write_out_valid_inst,
            accu_address_write_out_ready => accu_address_write_out_ready_inst,
            accu_address_write_out => accu_address_write_out_inst,
            accu_mode_out => accu_mode_out_inst,
            
            accu_address_read_out_valid => accu_address_read_out_valid_inst,
            accu_address_read_out_ready => accu_address_read_out_ready_inst,
            accu_address_read_out => accu_address_read_out_inst,
            
            bias_address_out_valid => bias_address_out_valid_inst,
            bias_address_out_ready => bias_address_out_ready_inst,
            bias_address_out => bias_address_out_inst,
            
            resize_mode_out_valid => resize_mode_out_valid_inst,
            resize_mode_out_ready => resize_mode_out_ready_inst,
            resize_mode_out => resize_mode_out_inst,
            
            
            
            register_write_back_address_valid => register_write_back_address_valid_inst,
            register_write_back_address_ready => register_write_back_address_ready_inst,
            register_write_back_address => register_write_back_address_inst,
            register_write_back_ready => register_write_back_ready_inst,
            
            accumulator_write_back_address_valid => accumulator_write_back_address_valid_inst,
            accumulator_write_back_address_ready => accumulator_write_back_address_ready_inst,
            accumulator_write_back_address => accumulator_write_back_address_inst,
            accumulator_write_back_ready => accumulator_write_back_ready_inst
        );

end Behavioral;
