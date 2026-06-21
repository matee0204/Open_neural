----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/05/2026 08:04:43 PM
-- Design Name: 
-- Module Name: bias_quant_pipeline_test - Behavioral
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

entity bias_quant_pipeline_test is
end bias_quant_pipeline_test;

architecture Behavioral of bias_quant_pipeline_test is
    constant REGISTER_ADDRESS_LENGTH : natural := 16;
    constant ACCUMULATOR_ADDRESS_LENGTH : natural := 8;
    constant BIAS_ADDRESS_LENGTH : natural := 8;
    constant RESIZE_MODE_LENGTH : natural := 3;
    constant VECTOR_LENGTH : natural := 8;
    constant DATA_WIDTH : natural := 8;
    
    signal clk : std_logic;
    signal rst : std_logic;
        
    signal sym_cntr : natural := 0;

    signal en_inst : std_logic;

    signal pipeline_en_out_inst : std_logic;
        
    signal accu_address_in_valid_inst : std_logic;
    signal accu_address_in_ready_inst : std_logic;
    signal accu_address_in_inst : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
    
    signal accu_address_out_valid_inst : std_logic;
    signal accu_address_out_ready_inst : std_logic;
    signal accu_address_out_inst : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
    
    signal bias_address_in_valid_inst : std_logic;
    signal bias_address_in_ready_inst : std_logic;
    signal bias_address_in_inst : std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);
    
    signal bias_address_out_valid_inst : std_logic;
    signal bias_address_out_ready_inst : std_logic;
    signal bias_address_out_inst : std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);
    
    signal resize_mode_in_valid_inst : std_logic;
    signal resize_mode_in_ready_inst : std_logic;
    signal resize_mode_in_inst : std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);
    
    signal resize_mode_out_valid_inst : std_logic;
    signal resize_mode_out_ready_inst : std_logic;
    signal resize_mode_out_inst : std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);
    
    signal reg_write_address_in_valid_inst : std_logic;
    signal reg_write_address_in_ready_inst : std_logic;
    signal reg_write_address_in_inst : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    
    signal reg_write_address_out_valid_inst : std_logic;
    signal reg_write_address_out_ready_inst : std_logic;
    signal reg_write_address_out_inst : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    
    signal reg_write_data_in_valid_inst : std_logic;
    signal reg_write_data_in_ready_inst : std_logic;
    signal reg_write_data_in_inst : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
    
    signal reg_write_data_out_valid_inst : std_logic;
    signal reg_write_data_out_ready_inst : std_logic;
    signal reg_write_data_out_inst : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);

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
                accu_address_in_valid_inst <= '0';
                bias_address_in_valid_inst <= '0';
                resize_mode_in_valid_inst <= '0';
                reg_write_address_in_valid_inst <= '0';
                reg_write_data_in_valid_inst <= '0';
            elsif sym_cntr = 5 then
                accu_address_in_valid_inst <= '1';
            elsif sym_cntr = 6 then
                accu_address_in_valid_inst <= '0';
                bias_address_in_valid_inst <= '1';
            elsif sym_cntr = 7 then
                bias_address_in_valid_inst <= '0';
                resize_mode_in_valid_inst <= '1';
            elsif sym_cntr = 8 then
                resize_mode_in_valid_inst <= '0';
                reg_write_address_in_valid_inst <= '1';
            elsif sym_cntr = 9 then
                reg_write_address_in_valid_inst <= '0';
                reg_write_data_in_valid_inst <= '1';
            elsif sym_cntr = 10 then
                reg_write_data_in_valid_inst <= '0';
            elsif sym_cntr = 30 then
                accu_address_in_valid_inst <= '1';
            elsif sym_cntr = 31 then
                accu_address_in_valid_inst <= '0';
                bias_address_in_valid_inst <= '1';
            elsif sym_cntr = 32 then
                bias_address_in_valid_inst <= '0';
                resize_mode_in_valid_inst <= '1';
            elsif sym_cntr = 33 then
                resize_mode_in_valid_inst <= '0';
                reg_write_address_in_valid_inst <= '1';
            elsif sym_cntr = 34 then
                reg_write_address_in_valid_inst <= '0';
                reg_write_data_in_valid_inst <= '1';
            elsif sym_cntr = 35 then
                reg_write_data_in_valid_inst <= '0';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                accu_address_out_ready_inst <= '1';
                bias_address_out_ready_inst <= '1';
                resize_mode_out_ready_inst <= '1';
                reg_write_address_out_ready_inst <= '1';
                reg_write_data_out_ready_inst <= '1';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                accu_address_in_inst <= std_logic_vector(to_unsigned(1, accu_address_in_inst'length));
                bias_address_in_inst <= std_logic_vector(to_unsigned(2, bias_address_in_inst'length));
                resize_mode_in_inst <= std_logic_vector(to_unsigned(3, resize_mode_in_inst'length));
                reg_write_address_in_inst <= std_logic_vector(to_unsigned(4, reg_write_address_in_inst'length));
                reg_write_data_in_inst <= (others => (others => '0'));
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

    tb_pipeline_bias_quant : entity work.pipeline_bias_quant
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
            
            en => en_inst,
            
            pipeline_en_out => pipeline_en_out_inst,
            
            accu_address_in_valid => accu_address_in_valid_inst,
            accu_address_in_ready => accu_address_in_ready_inst,
            accu_address_in => accu_address_in_inst,
            
            accu_address_out_valid => accu_address_out_valid_inst,
            accu_address_out_ready => accu_address_out_ready_inst,
            accu_address_out => accu_address_out_inst,
            
            bias_address_in_valid => bias_address_in_valid_inst,
            bias_address_in_ready => bias_address_in_ready_inst,
            bias_address_in => bias_address_in_inst,
            
            bias_address_out_valid => bias_address_out_valid_inst,
            bias_address_out_ready => bias_address_out_ready_inst,
            bias_address_out => bias_address_out_inst,
            
            resize_mode_in_valid => resize_mode_in_valid_inst,
            resize_mode_in_ready => resize_mode_in_ready_inst,
            resize_mode_in => resize_mode_in_inst,
            
            resize_mode_out_valid => resize_mode_out_valid_inst,
            resize_mode_out_ready => resize_mode_out_ready_inst,
            resize_mode_out => resize_mode_out_inst,
            
            reg_write_address_in_valid => reg_write_address_in_valid_inst,
            reg_write_address_in_ready => reg_write_address_in_ready_inst,
            reg_write_address_in => reg_write_address_in_inst,
            
            reg_write_address_out_valid => reg_write_address_out_valid_inst,
            reg_write_address_out_ready => reg_write_address_out_ready_inst,
            reg_write_address_out => reg_write_address_out_inst,
                
            reg_write_data_in_valid => reg_write_data_in_valid_inst,
            reg_write_data_in_ready => reg_write_data_in_ready_inst,
            reg_write_data_in => reg_write_data_in_inst,
            
            reg_write_data_out_valid => reg_write_data_out_valid_inst,
            reg_write_data_out_ready => reg_write_data_out_ready_inst,
            reg_write_data_out => reg_write_data_out_inst
        );

end Behavioral;
