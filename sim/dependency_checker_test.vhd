----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/28/2026 07:02:08 PM
-- Design Name: 
-- Module Name: dependency_checker_test - Behavioral
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

entity dependency_checker_test is
end dependency_checker_test;

architecture Behavioral of dependency_checker_test is
    constant NUM_OF_VECTOR_REGISTERS : natural := 16;
    constant NUM_OF_ACCUMULATOR_REGISTERS : natural := 16;
    constant NUM_OF_BIAS_REGISTERS : natural := 16;

    constant VECTOR_LENGTH : natural := 8;
    constant DATA_LENGTH : natural := 8;

    constant MEMORY_ADDRESS_LENGTH : natural := 32;
    constant REGISTER_ADDRESS_LENGTH : natural := 16;
    constant SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH : natural := 8;
    constant BIAS_ADDRESS_LENGTH : natural := 8;
    constant ACCUMULATOR_ADDRESS_LENGTH : natural := 8;
    constant ACCUMULATOR_MODE_LENGTH : natural := 3;
    constant RESIZE_MODE_LENGTH : natural := 3;
    
    signal clk : std_logic;
    signal rst : std_logic;
    
    signal sym_cntr : natural := 0;

    signal memory_address_in_valid_inst : std_logic;
    signal memory_address_in_ready_inst : std_logic;
    signal memory_address_in_inst : std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
    signal memory_read_write_in_inst : std_logic;

    signal register_read_address_in_valid_inst : std_logic;
    signal register_read_address_in_ready_inst : std_logic;
    signal register_read_address_in_inst : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    signal register_write_address_in_valid_inst : std_logic;
    signal register_write_address_in_ready_inst : std_logic;
    signal register_write_address_in_inst : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);

    signal systolic_array_selected_weight_bank_in_valid_inst : std_logic;
    signal systolic_array_selected_weight_bank_in_ready_inst : std_logic;
    signal systolic_array_selected_weight_bank_in_inst : std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);

    signal selected_accumulator_bank_write_in_valid_inst : std_logic;
    signal selected_accumulator_bank_write_in_ready_inst : std_logic;
    signal selected_accumulator_bank_write_in_inst : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
    signal accumulator_mode_in_inst : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);

    signal selected_accumulator_bank_read_in_valid_inst : std_logic;
    signal selected_accumulator_bank_read_in_ready_inst : std_logic;
    signal selected_accumulator_bank_read_in_inst : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);

    signal selected_bias_bank_in_valid_inst : std_logic;
    signal selected_bias_bank_in_ready_inst : std_logic;
    signal selected_bias_bank_in_inst : std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);

    signal resize_module_mode_in_valid_inst : std_logic;
    signal resize_module_mode_in_ready_inst : std_logic;
    signal resize_module_mode_in_inst : std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);


    signal memory_address_out_valid_inst : std_logic;
    signal memory_address_out_ready_inst : std_logic;
    signal memory_address_out_inst : std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
    signal memory_read_write_out_inst : std_logic;

    signal register_read_address_out_valid_inst : std_logic;
    signal register_read_address_out_ready_inst : std_logic;
    signal register_read_address_out_inst : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    signal register_write_address_out_valid_inst : std_logic;
    signal register_write_address_out_ready_inst : std_logic;
    signal register_write_address_out_inst : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);

    signal systolic_array_selected_weight_bank_out_valid_inst : std_logic;
    signal systolic_array_selected_weight_bank_out_ready_inst : std_logic;
    signal systolic_array_selected_weight_bank_out_inst : std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);

    signal selected_accumulator_bank_write_out_valid_inst : std_logic;
    signal selected_accumulator_bank_write_out_ready_inst : std_logic;
    signal selected_accumulator_bank_write_out_inst : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
    signal accumulator_mode_out_inst : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);

    signal selected_accumulator_bank_read_out_valid_inst : std_logic;
    signal selected_accumulator_bank_read_out_ready_inst : std_logic;
    signal selected_accumulator_bank_read_out_inst : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);

    signal selected_bias_bank_out_valid_inst : std_logic;
    signal selected_bias_bank_out_ready_inst : std_logic;
    signal selected_bias_bank_out_inst : std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);

    signal resize_module_mode_out_valid_inst : std_logic;
    signal resize_module_mode_out_ready_inst : std_logic;
    signal resize_module_mode_out_inst : std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);

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
                memory_address_out_ready_inst <= '1';
                register_read_address_out_ready_inst <= '1';
                register_write_address_out_ready_inst <= '1';
                systolic_array_selected_weight_bank_out_ready_inst <= '1';
                selected_accumulator_bank_write_out_ready_inst <= '1';
                selected_accumulator_bank_read_out_ready_inst <= '1';
                selected_bias_bank_out_ready_inst <= '1';
                resize_module_mode_out_ready_inst <= '1';
                register_write_back_ready_inst <= '1';
                accumulator_write_back_ready_inst <= '1';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                memory_address_in_valid_inst <= '0';
                register_read_address_in_valid_inst <= '0';
                register_write_address_in_valid_inst <= '0';
                systolic_array_selected_weight_bank_in_valid_inst <= '0';
                selected_accumulator_bank_write_in_valid_inst <= '0';
                selected_accumulator_bank_read_in_valid_inst <= '0';
                selected_bias_bank_in_valid_inst <= '0';
                resize_module_mode_in_valid_inst <= '0';
                register_write_back_address_valid_inst <= '0';
                accumulator_write_back_address_valid_inst <= '0';
            elsif sym_cntr = 6 then
                register_write_address_in_valid_inst <= '1';
            elsif sym_cntr = 7 then
                register_write_address_in_valid_inst <= '0';
            elsif sym_cntr = 8 then
                register_write_address_in_valid_inst <= '1';
            elsif sym_cntr = 9 then
                register_write_back_address_valid_inst <= '1';
            elsif sym_cntr = 10 then
                register_write_back_address_valid_inst <= '0';
            elsif sym_cntr = 11 then
                register_write_address_in_valid_inst <= '0';
            elsif sym_cntr = 12 then
                register_read_address_in_valid_inst <= '1';
            elsif sym_cntr = 13 then
                register_read_address_in_valid_inst <= '0';
            elsif sym_cntr = 14 then
                register_read_address_in_valid_inst <= '1';
                selected_accumulator_bank_read_in_valid_inst <= '1';
            elsif sym_cntr = 15 then
                register_write_back_address_valid_inst <= '1';
            elsif sym_cntr = 16 then
                register_write_back_address_valid_inst <= '0';
            elsif sym_cntr = 17 then
                register_read_address_in_valid_inst <= '0';
                selected_accumulator_bank_read_in_valid_inst <= '0';
            elsif sym_cntr = 18 then
                selected_accumulator_bank_write_in_valid_inst <= '1';
            elsif sym_cntr = 19 then
                selected_accumulator_bank_write_in_valid_inst <= '0';
            elsif sym_cntr = 20 then
                selected_accumulator_bank_write_in_valid_inst <= '1';
            elsif sym_cntr = 21 then
                accumulator_write_back_address_valid_inst <= '1';
            elsif sym_cntr = 22 then
                accumulator_write_back_address_valid_inst <= '0';
            elsif sym_cntr = 23 then
                selected_accumulator_bank_write_in_valid_inst <= '0';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                memory_address_in_inst <= std_logic_vector(to_unsigned(1, memory_address_in_inst'length));
                memory_read_write_in_inst <= '1';
                register_read_address_in_inst <= std_logic_vector(to_unsigned(2, register_read_address_in_inst'length));
                register_write_address_in_inst <= std_logic_vector(to_unsigned(3, register_write_address_in_inst'length));
                systolic_array_selected_weight_bank_in_inst <= std_logic_vector(to_unsigned(4, systolic_array_selected_weight_bank_in_inst'length));
                selected_accumulator_bank_write_in_inst <= std_logic_vector(to_unsigned(5, selected_accumulator_bank_write_in_inst'length));
                selected_accumulator_bank_read_in_inst <= std_logic_vector(to_unsigned(6, selected_accumulator_bank_read_in_inst'length));
                accumulator_mode_in_inst <= std_logic_vector(to_unsigned(7, accumulator_mode_out_inst'length));
                selected_bias_bank_in_inst <= std_logic_vector(to_unsigned(8, selected_bias_bank_in_inst'length));
                resize_module_mode_in_inst <= std_logic_vector(to_unsigned(9, resize_module_mode_in_inst'length));
                register_write_back_address_inst <= std_logic_vector(to_unsigned(3, register_write_back_address_inst'length));
                accumulator_write_back_address_inst <=  std_logic_vector(to_unsigned(5, accumulator_write_back_address_inst'length));
            elsif sym_cntr = 14 then
                register_read_address_in_inst <= std_logic_vector(to_unsigned(3, register_read_address_in_inst'length));
            end if;
        end if;
    end process;

    tb_dependency_handler : entity work.dependency_handler
        generic map (
            NUM_OF_VECTOR_REGISTERS => NUM_OF_VECTOR_REGISTERS,
            NUM_OF_ACCUMULATOR_REGISTERS => NUM_OF_ACCUMULATOR_REGISTERS,
            NUM_OF_BIAS_REGISTERS => NUM_OF_BIAS_REGISTERS,
            
            VECTOR_LENGTH => VECTOR_LENGTH,
            DATA_LENGTH => DATA_LENGTH,
            
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
            
            memory_address_in_valid => memory_address_in_valid_inst,
            memory_address_in_ready => memory_address_in_ready_inst,
            memory_address_in => memory_address_in_inst,
            memory_read_write_in => memory_read_write_in_inst,
            
            register_read_address_in_valid => register_read_address_in_valid_inst,
            register_read_address_in_ready => register_read_address_in_ready_inst,
            register_read_address_in => register_read_address_in_inst,
            register_write_address_in_valid => register_write_address_in_valid_inst,
            register_write_address_in_ready => register_write_address_in_ready_inst,
            register_write_address_in => register_write_address_in_inst,
            
            systolic_array_selected_weight_bank_in_valid => systolic_array_selected_weight_bank_in_valid_inst,
            systolic_array_selected_weight_bank_in_ready => systolic_array_selected_weight_bank_in_ready_inst,
            systolic_array_selected_weight_bank_in => systolic_array_selected_weight_bank_in_inst,
            
            selected_accumulator_bank_write_in_valid => selected_accumulator_bank_write_in_valid_inst,
            selected_accumulator_bank_write_in_ready => selected_accumulator_bank_write_in_ready_inst,
            selected_accumulator_bank_write_in => selected_accumulator_bank_write_in_inst,
            accumulator_mode_in => accumulator_mode_in_inst,
            
            selected_accumulator_bank_read_in_valid => selected_accumulator_bank_read_in_valid_inst,
            selected_accumulator_bank_read_in_ready => selected_accumulator_bank_read_in_ready_inst,
            selected_accumulator_bank_read_in => selected_accumulator_bank_read_in_inst,
            
            selected_bias_bank_in_valid => selected_bias_bank_in_valid_inst,
            selected_bias_bank_in_ready => selected_bias_bank_in_ready_inst,
            selected_bias_bank_in => selected_bias_bank_in_inst,
            
            resize_module_mode_in_valid => resize_module_mode_in_valid_inst,
            resize_module_mode_in_ready => resize_module_mode_in_ready_inst,
            resize_module_mode_in => resize_module_mode_in_inst,
            
            
            memory_address_out_valid => memory_address_out_valid_inst,
            memory_address_out_ready => memory_address_out_ready_inst,
            memory_address_out => memory_address_out_inst,
            memory_read_write_out => memory_read_write_out_inst,
            
            register_read_address_out_valid => register_read_address_out_valid_inst,
            register_read_address_out_ready => register_read_address_out_ready_inst,
            register_read_address_out => register_read_address_out_inst,
            register_write_address_out_valid => register_write_address_out_valid_inst,
            register_write_address_out_ready => register_write_address_out_ready_inst,
            register_write_address_out => register_write_address_out_inst,
            
            systolic_array_selected_weight_bank_out_valid => systolic_array_selected_weight_bank_out_valid_inst,
            systolic_array_selected_weight_bank_out_ready => systolic_array_selected_weight_bank_out_ready_inst,
            systolic_array_selected_weight_bank_out => systolic_array_selected_weight_bank_out_inst,
            
            selected_accumulator_bank_write_out_valid => selected_accumulator_bank_write_out_valid_inst,
            selected_accumulator_bank_write_out_ready => selected_accumulator_bank_write_out_ready_inst,
            selected_accumulator_bank_write_out => selected_accumulator_bank_write_out_inst,
            accumulator_mode_out => accumulator_mode_out_inst,
            
            selected_accumulator_bank_read_out_valid => selected_accumulator_bank_read_out_valid_inst,
            selected_accumulator_bank_read_out_ready => selected_accumulator_bank_read_out_ready_inst,
            selected_accumulator_bank_read_out => selected_accumulator_bank_read_out_inst,
            
            selected_bias_bank_out_valid => selected_bias_bank_out_valid_inst,
            selected_bias_bank_out_ready => selected_bias_bank_out_ready_inst,
            selected_bias_bank_out => selected_bias_bank_out_inst,
            
            resize_module_mode_out_valid => resize_module_mode_out_valid_inst,
            resize_module_mode_out_ready => resize_module_mode_out_ready_inst,
            resize_module_mode_out => resize_module_mode_out_inst,
            
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
