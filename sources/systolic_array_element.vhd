----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/08/2026 09:05:34 PM
-- Design Name: 
-- Module Name: systolic_array_element - Behavioral
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

entity systolic_array_element is
    generic (
        INPUT_DATA_WIDTH : natural := 8;
        OUTPUT_DATA_WIDTH : natural := 32;
        WEIGHT_REGISTER_DEPTH : natural := 2
    );
    port (
        clk : in std_logic;
        en : in std_logic;
    
        weight_write_en : in std_logic;
        weight_in : in std_logic_vector(INPUT_DATA_WIDTH - 1 downto 0);
        weight_out : out std_logic_vector(INPUT_DATA_WIDTH - 1 downto 0);
        weight_address : in std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH) - 1 downto 0);
        
        selected_weight_bank : in std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH) - 1 downto 0);
        
        data_in : in std_logic_vector(INPUT_DATA_WIDTH - 1 downto 0);
        
        partial_result_in : in std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0);
        
        result_out : out std_logic_vector(OUTPUT_DATA_WIDTH - 1 downto 0);
        
        data_cascade_out : out std_logic_vector(INPUT_DATA_WIDTH - 1 downto 0)
    );
end systolic_array_element;

architecture Behavioral of systolic_array_element is
    signal weight_memory_out : std_logic_vector(INPUT_DATA_WIDTH - 1 downto 0);
    signal MADD_out : signed(OUTPUT_DATA_WIDTH - 1 downto 0);
begin    
    process (clk) begin
        if rising_edge(clk) then
            if en = '1' then
                data_cascade_out <= data_in;
            else
                data_cascade_out <= data_cascade_out;
            end if;
        end if;
    end process;
    
    weight_ram_inst : entity work.Data_RAM(Read_first)
        generic map (
            DEPTH => WEIGHT_REGISTER_DEPTH,
            WIDTH => INPUT_DATA_WIDTH
        )
        port map (
            clk_A => clk,
            en_A => '1',
            
            wr_en_A => weight_write_en,
            address_A => weight_address,
            
            data_in_A => weight_in,
            data_out_A => weight_out,
            
            clk_B => clk,
            en_B => '1',
            
            wr_en_B => '0',
            address_B => selected_weight_bank,
            
            data_in_B => (others => '0'),
            data_out_B => weight_memory_out
        );

    MADD_inst : entity work.MADD
        generic map (
            INPUT_DATA_WIDTH => INPUT_DATA_WIDTH,
            OUTPUT_DATA_WIDTH => OUTPUT_DATA_WIDTH
        )
        port map(
            clk => clk,
            en => en,
            
            data_in => signed(data_in),
            weight_in => signed(weight_memory_out),
            partial_result_in => signed(partial_result_in),
            
            data_out => MADD_out
        );
        
    result_out <= std_logic_vector(MADD_out);

end Behavioral;
