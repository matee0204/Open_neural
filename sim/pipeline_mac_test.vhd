----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/28/2026 08:10:32 PM
-- Design Name: 
-- Module Name: pipeline_mac_test - Behavioral
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

entity pipeline_mac_test is
end pipeline_mac_test;

architecture Behavioral of pipeline_mac_test is
    constant REGISTER_ADDRESS_LENGTH : natural := 16;
    constant SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH : natural := 8;
    constant ACCUMULATOR_ADDRESS_LENGTH : natural := 8;
    constant ACCUMULATOR_MODE_LENGTH : natural := 3;
    constant VECTOR_LENGTH : natural := 8;
    constant DATA_WIDTH : natural := 8;
    
    signal clk : std_logic;
    signal rst : std_logic;
        
    signal sym_cntr : natural := 0;

    signal en_inst : std_logic;

    signal pipeline_en_out_inst : std_logic;

    signal reg_data_in_valid_inst : std_logic;
    signal reg_data_in_ready_inst : std_logic;
    signal reg_data_in_inst : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);

    signal reg_data_out_valid_inst : std_logic;
    signal reg_data_out_ready_inst : std_logic;
    signal reg_data_out_inst : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);

    signal sys_array_bank_address_in_valid_inst : std_logic;
    signal sys_array_bank_address_in_ready_inst : std_logic;
    signal sys_array_bank_address_in_inst : std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);

    signal sys_array_bank_address_out_valid_inst : std_logic;
    signal sys_array_bank_address_out_ready_inst : std_logic;
    signal sys_array_bank_address_out_inst : std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);

    signal accu_address_in_valid_inst : std_logic;
    signal accu_address_in_ready_inst : std_logic;
    signal accu_address_in_inst : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);

    signal accu_address_out_valid_inst : std_logic;
    signal accu_address_out_ready_inst : std_logic;
    signal accu_address_out_inst : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);

    signal accu_mode_in_valid_inst : std_logic;
    signal accu_mode_in_ready_inst : std_logic;
    signal accu_mode_in_inst : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);

    signal accu_mode_out_valid_inst : std_logic;
    signal accu_mode_out_ready_inst : std_logic;
    signal accu_mode_out_inst : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
    
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
            if sym_cntr = 4 then
                reg_data_in_valid_inst <= '0';
                sys_array_bank_address_in_valid_inst <= '0';
                accu_address_in_valid_inst <= '0';
                accu_mode_in_valid_inst <= '0';
            elsif sym_cntr = 5 then
                reg_data_in_valid_inst <= '1';
            elsif sym_cntr = 6 then
                reg_data_in_valid_inst <= '0';
                sys_array_bank_address_in_valid_inst <= '1';
            elsif sym_cntr = 7 then
                sys_array_bank_address_in_valid_inst <= '0';
                accu_address_in_valid_inst <= '1';
            elsif sym_cntr = 8 then
                accu_address_in_valid_inst <= '0';
                accu_mode_in_valid_inst <= '1';
            elsif sym_cntr = 9 then
                accu_mode_in_valid_inst <= '0';
            elsif sym_cntr = 30 then
                reg_data_in_valid_inst <= '1';
            elsif sym_cntr = 31 then
                reg_data_in_valid_inst <= '0';
                sys_array_bank_address_in_valid_inst <= '1';
            elsif sym_cntr = 32 then
                sys_array_bank_address_in_valid_inst <= '0';
                accu_address_in_valid_inst <= '1';
            elsif sym_cntr = 33 then
                accu_address_in_valid_inst <= '0';
                accu_mode_in_valid_inst <= '1';
            elsif sym_cntr = 34 then
                accu_mode_in_valid_inst <= '0';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                reg_data_out_ready_inst <= '1';
                sys_array_bank_address_out_ready_inst <= '1';
                accu_address_out_ready_inst <= '1';
                accu_mode_out_ready_inst <= '1';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                reg_data_in_inst <= (others => (others => '0'));
                sys_array_bank_address_in_inst <= std_logic_vector(to_unsigned(1, sys_array_bank_address_in_inst'length));
                accu_address_in_inst <= std_logic_vector(to_unsigned(2, accu_address_in_inst'length));
                accu_mode_in_inst <= std_logic_vector(to_unsigned(3, accu_mode_in_inst'length));
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 4 then
                en_inst <= '0';
            elsif sym_cntr = 5 then
                en_inst <= '1';
            elsif sym_cntr = 30 then
                en_inst <= '0';
            end if;
        end if;
    end process;

    tb_pipeline_mac : entity work.pipeline_mac
        generic map (
            REGISTER_ADDRESS_LENGTH => REGISTER_ADDRESS_LENGTH,
            SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH => SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH,
            ACCUMULATOR_ADDRESS_LENGTH => ACCUMULATOR_ADDRESS_LENGTH,
            ACCUMULATOR_MODE_LENGTH => ACCUMULATOR_MODE_LENGTH,
            VECTOR_LENGTH => VECTOR_LENGTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            en => en_inst,
            
            pipeline_en_out => pipeline_en_out_inst,
            
            reg_data_in_valid => reg_data_in_valid_inst,
            reg_data_in_ready => reg_data_in_ready_inst,
            reg_data_in => reg_data_in_inst,
            
            reg_data_out_valid => reg_data_out_valid_inst,
            reg_data_out_ready => reg_data_out_ready_inst,
            reg_data_out => reg_data_out_inst,
            
            sys_array_bank_address_in_valid => sys_array_bank_address_in_valid_inst,
            sys_array_bank_address_in_ready => sys_array_bank_address_in_ready_inst,
            sys_array_bank_address_in => sys_array_bank_address_in_inst,
            
            sys_array_bank_address_out_valid => sys_array_bank_address_out_valid_inst,
            sys_array_bank_address_out_ready => sys_array_bank_address_out_ready_inst,
            sys_array_bank_address_out => sys_array_bank_address_out_inst,
            
            accu_address_in_valid => accu_address_in_valid_inst,
            accu_address_in_ready => accu_address_in_ready_inst,
            accu_address_in => accu_address_in_inst,
            
            accu_address_out_valid => accu_address_out_valid_inst,
            accu_address_out_ready => accu_address_out_ready_inst,
            accu_address_out => accu_address_out_inst,
            
            accu_mode_in_valid => accu_mode_in_valid_inst,
            accu_mode_in_ready => accu_mode_in_ready_inst,
            accu_mode_in => accu_mode_in_inst,
            
            accu_mode_out_valid => accu_mode_out_valid_inst,
            accu_mode_out_ready => accu_mode_out_ready_inst,
            accu_mode_out => accu_mode_out_inst
        );

end Behavioral;
