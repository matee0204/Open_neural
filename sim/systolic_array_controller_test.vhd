----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/08/2026 02:31:35 PM
-- Design Name: 
-- Module Name: systolic_array_controller_test - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity systolic_array_controller_test is
end systolic_array_controller_test;

architecture Behavioral of systolic_array_controller_test is
    constant SYS_ARRAY_WIDTH : natural := 8;
    
    signal clk, rst : std_logic;
    signal inst_en : std_logic;
    signal sym_cntr : natural := 0;
    
    signal inst_weight_write_en_in : std_logic;
    signal inst_weight_write_en_out : std_logic;
    signal weight_write_ready : std_logic;
    
    signal inst_pipeline_en : std_logic;
    
    signal inst_data_in_valid : std_logic;
    signal inst_data_in_ready : std_logic;
    
    signal inst_result_out_valid : std_logic;
    signal inst_result_out_ready : std_logic;
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
    
    process begin
        wait for 3ns;
        rst <= '1';
        wait for 4ns;
        rst <= '0';
        wait;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 1 then
                inst_weight_write_en_in <= '0';
            elsif sym_cntr = 6 then
                inst_weight_write_en_in <= '1';
            elsif sym_cntr = 7 then
                inst_weight_write_en_in <= '0';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 1 then
                inst_data_in_valid <= '0';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 1 then
                inst_result_out_ready <= '0';
            elsif sym_cntr = 5 then
                inst_result_out_ready <= '1';
            elsif sym_cntr = 6 then
                inst_result_out_ready <= '0';
            elsif sym_cntr = 8 then
                inst_result_out_ready <= '1';
            end if;
        end if;
    end process;

    tb_systolic_array_constroller : entity work.systolic_array_controller
        generic map (
            SYS_ARRAY_WIDTH => SYS_ARRAY_WIDTH
        )
        port map (
        clk => clk,
        rst => rst,
        
        weight_write_en_in => inst_weight_write_en_in,
        weight_write_en_out => inst_weight_write_en_out,
        weight_write_ready => weight_write_ready,
        
        pipeline_en => inst_pipeline_en,
        
        data_in_valid => inst_data_in_valid,
        data_in_ready => inst_data_in_ready,
        
        result_out_valid => inst_result_out_valid,
        result_out_ready => inst_result_out_ready
        );

end Behavioral;
