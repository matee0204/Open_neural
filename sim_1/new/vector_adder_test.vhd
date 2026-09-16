----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/20/2026 09:13:46 PM
-- Design Name: 
-- Module Name: vector_adder_test - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vector_adder_test is
end vector_adder_test;

architecture Behavioral of vector_adder_test is
    constant INPUT_A_DATA_WIDTH : natural := 32;
    constant INPUT_B_DATA_WIDTH : natural := 48;
    constant OUTPUT_DATA_WIDTH : natural := 48;
    constant VECTOR_LENGTH : natural := 8;
    signal sym_cntr : natural := 0;
    
    signal data_in_A_inst : data_vector_signed(VECTOR_LENGTH - 1 downto 0)(INPUT_A_DATA_WIDTH - 1 downto 0);
    
    signal data_in_B_inst : data_vector_signed(VECTOR_LENGTH - 1 downto 0)(INPUT_B_DATA_WIDTH - 1 downto 0);
    
    signal result_out_inst : data_vector_signed(VECTOR_LENGTH - 1 downto 0)(OUTPUT_DATA_WIDTH - 1 downto 0);
begin
    
    process (clk) begin
        if rising_edge(clk) and sym_cntr < natural'high then
            sym_cntr <= sym_cntr + 1;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if (sym_cntr = 5) then
                data_in_A_inst <= (others => to_signed(-1, INPUT_A_DATA_WIDTH));
            elsif (sym_cntr = 6) then
                data_in_B_inst <= (others => to_signed(2, INPUT_B_DATA_WIDTH));
            elsif (sym_cntr = 7) then
                data_in_A_inst <= (others => to_signed(1, INPUT_A_DATA_WIDTH));
                data_in_B_inst <= (others => to_signed(-2, INPUT_B_DATA_WIDTH));
            elsif (sym_cntr = 8) then
                data_in_A_inst <= (others => to_signed(-1, INPUT_A_DATA_WIDTH));
                data_in_B_inst <= (others => to_signed(2, INPUT_B_DATA_WIDTH));
            end if;
        end if;
    end process;
    
    tb_vector_adder : entity work.vector_adder
        generic map (
            INPUT_A_DATA_WIDTH => INPUT_A_DATA_WIDTH,
            INPUT_B_DATA_WIDTH => INPUT_B_DATA_WIDTH,
            OUTPUT_DATA_WIDTH => OUTPUT_DATA_WIDTH,
            VECTOR_LENGTH => VECTOR_LENGTH
        )
        port map (            
            data_in_A => data_in_A_inst,
            
            data_in_B => data_in_B_inst,
            
            result_out => result_out_inst
        );

end Behavioral;
