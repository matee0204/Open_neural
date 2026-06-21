----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/21/2026 04:23:11 PM
-- Design Name: 
-- Module Name: instruction_decoder_test - Behavioral
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
use work.common_constants.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instruction_decoder_test is
end instruction_decoder_test;

architecture Behavioral of instruction_decoder_test is
    constant INSTRUCTION_LENGTH : natural := 64;
    constant OPERATION_CODE_LENGTH : natural := 7;
    constant MEMORY_ADDRESS_LENGTH : natural := 32;
    constant REGISTER_ADDRESS_LENGTH : natural := 16;
    constant SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH : natural := 8;
    constant BIAS_ADDRESS_LENGTH : natural := 8;
    constant ACCUMULATOR_ADDRESS_LENGTH : natural := 8;
    constant ACCUMULATOR_MODE_LENGTH : natural := 3;
    constant RESIZE_MODE_LENGTH : natural := 3;
        
    signal sym_cntr : natural := 0;
    
    signal clk : std_logic;
    signal rst : std_logic;
    
    signal instruction_valid_inst : std_logic;
    signal instruction_ready_inst : std_logic;
    signal instruction_inst : std_logic_vector(INSTRUCTION_LENGTH - 1 downto 0);

    signal memory_address_valid_inst : std_logic;
    signal memory_address_ready_inst : std_logic;
    signal memory_address_inst : std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);
    signal memory_read_write_inst : std_logic;
        
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
                memory_address_ready_inst <= '1';
                register_read_address_ready_inst <= '1';
                register_write_address_ready_inst <= '1';
                systolic_array_selected_weight_bank_ready_inst <= '1';
                selected_accumulator_bank_write_ready_inst <= '1';
                selected_accumulator_bank_read_ready_inst <= '1';
                selected_bias_bank_ready_inst <= '1';
                resize_module_mode_ready_inst <= '1';
            elsif sym_cntr = 14 or sym_cntr = 22 or sym_cntr = 30 or sym_cntr = 38 or sym_cntr = 46 then
                resize_module_mode_ready_inst <= '1';
                memory_address_ready_inst <= '0';
            elsif sym_cntr = 15 or sym_cntr = 23 or sym_cntr = 31 or sym_cntr = 39 or sym_cntr = 47 then
                memory_address_ready_inst <= '1';
                register_write_address_ready_inst <= '0';
            elsif sym_cntr = 16 or sym_cntr = 24 or sym_cntr = 32 or sym_cntr = 40 or sym_cntr = 48 then
                register_write_address_ready_inst <= '1';
                register_read_address_ready_inst <= '0';
            elsif sym_cntr = 17 or sym_cntr = 25 or sym_cntr = 33 or sym_cntr = 41 or sym_cntr = 49 then
                register_read_address_ready_inst <= '1';
                systolic_array_selected_weight_bank_ready_inst <= '0';
            elsif sym_cntr = 18 or sym_cntr = 26 or sym_cntr = 34 or sym_cntr = 42 or sym_cntr = 50 then
                systolic_array_selected_weight_bank_ready_inst <= '1';
                selected_accumulator_bank_write_ready_inst <= '0';
            elsif sym_cntr = 19 or sym_cntr = 27 or sym_cntr = 35 or sym_cntr = 43 or sym_cntr = 51 then
                selected_accumulator_bank_write_ready_inst <= '1';
                selected_accumulator_bank_read_ready_inst <= '0';
            elsif sym_cntr = 20 or sym_cntr = 28 or sym_cntr = 36 or sym_cntr = 44 or sym_cntr = 52 then
                selected_accumulator_bank_read_ready_inst <= '1';
                selected_bias_bank_ready_inst <= '0';
            elsif sym_cntr = 21 or sym_cntr = 29 or sym_cntr = 37 or sym_cntr = 45 or sym_cntr = 53 then
                selected_bias_bank_ready_inst <= '1';
                resize_module_mode_ready_inst <= '0';
            elsif sym_cntr = 54 then
                resize_module_mode_ready_inst <= '1';
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 6 then
                instruction_inst <= x"0000000000000000";
                instruction_valid_inst <= '1';
            elsif sym_cntr = 7 then
                instruction_inst <= x"0300000003000200";
            elsif sym_cntr = 8 then
                instruction_inst <= x"0500000003000200";
            elsif sym_cntr = 9 then
                instruction_inst <= x"0700030002000000";
            elsif sym_cntr = 10 then
                instruction_inst <= x"0900030303400000";
            elsif sym_cntr = 11 then
                instruction_inst <= x"0B00030303400000";
            elsif sym_cntr = 12 then
                instruction_valid_inst <= '0';
            elsif sym_cntr = 14 then
                instruction_inst <= x"0300000003000200";
                instruction_valid_inst <= '1';
            elsif sym_cntr = 22 then
                instruction_inst <= x"0500000003000200";
            elsif sym_cntr = 30 then
                instruction_inst <= x"0700030002000000";
            elsif sym_cntr = 38 then
                instruction_inst <= x"0900030303400000";
            elsif sym_cntr = 46 then
                instruction_inst <= x"0B00030303400000";
            elsif sym_cntr = 55 then
                instruction_valid_inst <= '0';
            end if;
        end if;
    end process;

    tb_instruction_decoder : entity work.instruction_decoder
        generic map (
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
            
            instruction_valid => instruction_valid_inst,
            instruction_ready => instruction_ready_inst,
            instruction => instruction_inst,
            
            memory_address_valid => memory_address_valid_inst,
            memory_address_ready => memory_address_ready_inst,
            memory_address => memory_address_inst,
            memory_read_write => memory_read_write_inst,
            
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
            resize_module_mode => resize_module_mode_inst
        );
    

end Behavioral;
