----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/30/2026 08:15:57 PM
-- Design Name: 
-- Module Name: systolic_array_row - Behavioral
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

entity systolic_array_row is
    generic (
        SYS_ARRAY_SIZE : natural := 8;
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
        weight_address : in std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH * SYS_ARRAY_SIZE) - 1 downto 0);
        
        selected_weight_bank : in std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH) - 1 downto 0);
        
        data_in : in std_logic_vector(INPUT_DATA_WIDTH - 1 downto 0);
        
        partial_result_in : in data_vector(0 to SYS_ARRAY_SIZE - 1)(OUTPUT_DATA_WIDTH - 1 downto 0);
        
        result_out : out data_vector(0 to SYS_ARRAY_SIZE - 1)(OUTPUT_DATA_WIDTH - 1 downto 0)
    );
    
end systolic_array_row;

architecture Behavioral of systolic_array_row is
    signal data_cascade : data_vector(1 to SYS_ARRAY_SIZE - 1)(INPUT_DATA_WIDTH - 1 downto 0);
    signal weight_write_enables : std_logic_vector(SYS_ARRAY_SIZE - 1 downto 0);
    signal weight_buffer_selector : std_logic_vector(clog2(SYS_ARRAY_SIZE) - 1 downto 0);
    signal weight_outs : data_vector(0 to SYS_ARRAY_SIZE - 1)(INPUT_DATA_WIDTH - 1 downto 0);
begin

    weight_buffer_selector <= weight_address(clog2(WEIGHT_REGISTER_DEPTH * SYS_ARRAY_SIZE) - 1 downto clog2(WEIGHT_REGISTER_DEPTH));
    
    process (weight_buffer_selector, weight_write_en, weight_outs) begin
        weight_write_enables <= (others => '0');
        weight_write_enables(to_integer(unsigned(weight_buffer_selector))) <= weight_write_en;
        weight_out <= weight_outs(to_integer(unsigned(weight_buffer_selector)));
    end process;

    sys_array_elment_first : entity work.systolic_array_element
        generic map (
            INPUT_DATA_WIDTH => INPUT_DATA_WIDTH,
            OUTPUT_DATA_WIDTH => OUTPUT_DATA_WIDTH,
            WEIGHT_REGISTER_DEPTH => WEIGHT_REGISTER_DEPTH
        )
        port map(
            clk => clk,
            en => en,
            
            weight_write_en => weight_write_enables(0),
            weight_in => weight_in,
            weight_out => weight_outs(0),
            weight_address => weight_address(clog2(WEIGHT_REGISTER_DEPTH) - 1 downto 0),
            
            selected_weight_bank => selected_weight_bank,
            
            data_in => data_in,
            
            partial_result_in => partial_result_in(0),
            
            result_out => result_out(0),
            
            data_cascade_out => data_cascade(1)
        );
            
    sys_array_element_gen : for i in 1 to SYS_ARRAY_SIZE - 2 generate
        sys_array_elment : entity work.systolic_array_element
            generic map (
                INPUT_DATA_WIDTH => INPUT_DATA_WIDTH,
                OUTPUT_DATA_WIDTH => OUTPUT_DATA_WIDTH,
                WEIGHT_REGISTER_DEPTH => WEIGHT_REGISTER_DEPTH
            )
            port map(
                clk => clk,
                en => en,
                
                weight_write_en => weight_write_enables(i),
                weight_in => weight_in,
                weight_out => weight_outs(i),
                weight_address => weight_address(clog2(WEIGHT_REGISTER_DEPTH) - 1 downto 0),
            
                selected_weight_bank => selected_weight_bank,
                
                data_in => data_cascade(i),
                
                partial_result_in => partial_result_in(i),
                
                result_out => result_out(i),
                
                data_cascade_out => data_cascade(i + 1)
            );
    end generate;
    
    sys_array_elment_last : entity work.systolic_array_element
        generic map (
            INPUT_DATA_WIDTH => INPUT_DATA_WIDTH,
            OUTPUT_DATA_WIDTH => OUTPUT_DATA_WIDTH,
            WEIGHT_REGISTER_DEPTH => WEIGHT_REGISTER_DEPTH
        )
        port map(
            clk => clk,
            en => en,
            
            weight_write_en => weight_write_enables(SYS_ARRAY_SIZE - 1),
            weight_in => weight_in,
            weight_out => weight_outs(SYS_ARRAY_SIZE - 1),
            weight_address => weight_address(clog2(WEIGHT_REGISTER_DEPTH) - 1 downto 0),
            
            selected_weight_bank => selected_weight_bank,
            
            data_in => data_cascade(SYS_ARRAY_SIZE - 1),
            
            partial_result_in => partial_result_in(SYS_ARRAY_SIZE - 1),
            
            result_out => result_out(SYS_ARRAY_SIZE - 1)
        );

end Behavioral;
