----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/22/2026 02:23:32 PM
-- Design Name: 
-- Module Name: vector_resize_test - Behavioral
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

entity vector_resize_test is
end vector_resize_test;

architecture Behavioral of vector_resize_test is
    constant INPUT_WIDTH : natural := 8;
    constant OUTPUT_WIDTH : natural := 4;
    constant VECTOR_LENGTH : natural := 8;
    
    signal sym_cntr : natural := 0;
    
    signal clk : std_logic;
        
    signal rst : std_logic;
    
    signal inst_resize_mode : std_logic_vector(0 downto 0);
    signal inst_en : std_logic;
    
    signal inst_data_in : data_vector(0 to VECTOR_LENGTH - 1)(INPUT_WIDTH - 1 downto 0);
    
    signal inst_data_out : data_vector(0 to VECTOR_LENGTH - 1)(OUTPUT_WIDTH - 1 downto 0);
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
                inst_en <= '1';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 2 then
                inst_data_in <= (others => (others => '0'));
            elsif sym_cntr = 6 then
                inst_data_in <= (std_logic_vector(to_signed(-1, INPUT_WIDTH)),
                                 std_logic_vector(to_signed(-8, INPUT_WIDTH)),
                                 std_logic_vector(to_signed(7, INPUT_WIDTH)),
                                 std_logic_vector(to_signed(-22, INPUT_WIDTH)),
                                 std_logic_vector(to_signed(37, INPUT_WIDTH)),
                                 std_logic_vector(to_signed(-16, INPUT_WIDTH)),
                                 std_logic_vector(to_signed(15, INPUT_WIDTH)),
                                 std_logic_vector(to_signed(0, INPUT_WIDTH)));
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 6 then
                inst_resize_mode <= (others => '0');
            elsif sym_cntr = 7 then
                inst_resize_mode <= (others => '1');
            end if;
        end if;
    end process;

    tb_vector_saturation : entity work.vector_resize
        generic map (
            INPUT_WIDTH => INPUT_WIDTH,
            OUTPUT_WIDTH => OUTPUT_WIDTH,
            VECTOR_LENGTH => VECTOR_LENGTH
        )
        port map (
            clk => clk,
            
            resize_mode => inst_resize_mode,
            en => inst_en,
            
            data_in => inst_data_in,
            
            data_out => inst_data_out
        );

end Behavioral;
