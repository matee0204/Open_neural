----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/19/2026 09:01:07 PM
-- Design Name: 
-- Module Name: systoli_array_element_test - Behavioral
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
use work.utilities.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity systolic_array_element_test is
end systolic_array_element_test;

architecture Behavioral of systolic_array_element_test is
    constant IN_DATA_WIDTH : natural := 8;
    constant OUT_DATA_WIDTH : natural := 32;
    constant WEIGHT_REGISTER_DEPTH : natural := 2;
    signal clk : std_logic;
    signal sym_cntr : natural := 0;
    signal inst_en : std_logic := '0';
    
    signal inst_weight_write_en : std_logic := '0';
    signal inst_weight_in : std_logic_vector(IN_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal inst_weight_out : std_logic_vector(IN_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal inst_weight_address : std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH) - 1 downto 0) := (others => '0');
    
    signal inst_selected_weight_bank : std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH) - 1 downto 0);
    
    signal inst_data_in : std_logic_vector(IN_DATA_WIDTH - 1 downto 0) := (others => '0');
    
    signal inst_partial_result_in : std_logic_vector(OUT_DATA_WIDTH - 1 downto 0) := (others => '0');
    
    signal inst_result_out : std_logic_vector(OUT_DATA_WIDTH - 1 downto 0);
    
    signal inst_data_cascade_out : std_logic_vector(IN_DATA_WIDTH - 1 downto 0);
begin
    process begin
        clk <= '0';
        wait for 1ns;
        clk <= '1';
        wait for 1ns;
    end process;
    
    process (clk) begin
        if rising_edge(clk) and sym_cntr < natural'high then
            sym_cntr <= sym_cntr + 1;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                inst_weight_write_en <= '1';
                inst_weight_in <= std_logic_vector(to_signed(-2, inst_weight_in'length));
            elsif sym_cntr = 6 then
                inst_weight_address <= std_logic_vector(to_unsigned(1, inst_weight_address'length));
                inst_weight_in <= std_logic_vector(to_unsigned(3, inst_weight_in'length));
            elsif sym_cntr = 7 then
                inst_weight_write_en <= '0';
            elsif sym_cntr = 9 then
                inst_weight_address <= std_logic_vector(to_unsigned(0, inst_weight_address'length));
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 21 then
                inst_selected_weight_bank <= std_logic_vector(to_unsigned(0, inst_selected_weight_bank'length));
            elsif sym_cntr >= 22 then
                inst_selected_weight_bank <= std_logic_vector(unsigned(inst_selected_weight_bank) + 1);
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 9 then
                inst_data_in <= std_logic_vector(to_unsigned(2, inst_data_in'length));
                inst_partial_result_in <= std_logic_vector(to_unsigned(10, inst_partial_result_in'length));
            elsif sym_cntr = 14 then
                inst_en <= '1';
                inst_data_in <= std_logic_vector(to_unsigned(5, inst_data_in'length));
            elsif sym_cntr = 17 then
                inst_en <= '0';
                inst_partial_result_in <= std_logic_vector(to_unsigned(12, inst_partial_result_in'length));
            elsif sym_cntr >= 22 then
                inst_en <= '1';
                inst_data_in <= std_logic_vector(unsigned(inst_data_in) + 1);
                inst_partial_result_in <= std_logic_vector(unsigned(inst_partial_result_in) + 1);
            end if;
        end if;
    end process;
    
    tb_sys_array_element : entity work.systolic_array_element
        generic map (
            INPUT_DATA_WIDTH => IN_DATA_WIDTH,
            OUTPUT_DATA_WIDTH => OUT_DATA_WIDTH,
            WEIGHT_REGISTER_DEPTH => WEIGHT_REGISTER_DEPTH
        )
        port map (
            clk => clk,
            en => inst_en,
        
            weight_write_en => inst_weight_write_en,
            weight_in => inst_weight_in,
            weight_out => inst_weight_out,
            weight_address => inst_weight_address,
        
            selected_weight_bank => inst_selected_weight_bank,
            
            data_in => inst_data_in,
            
            partial_result_in => inst_partial_result_in,
            
            result_out => inst_result_out,
            
            data_cascade_out => inst_data_cascade_out
        );


end Behavioral;
