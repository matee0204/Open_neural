----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/01/2026 01:19:32 PM
-- Design Name: 
-- Module Name: systolic_array_block - Behavioral
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

entity systolic_array_block is
    generic (
        SYS_ARRAY_SIZE : natural := 8;
        INPUT_DATA_WIDTH : natural := 8;
        OUTPUT_DATA_WIDTH : natural := 32;
        WEIGHT_REGISTER_DEPTH : natural := 2;
        DATA_IN_DELAY : natural := 2
    );
    port (
        clk : in std_logic;
        en : in std_logic;
    
        weight_write_en : in std_logic;
        weight_in : in data_vector(0 to SYS_ARRAY_SIZE - 1)(INPUT_DATA_WIDTH - 1 downto 0);
        weight_out : out data_vector(0 to SYS_ARRAY_SIZE - 1)(INPUT_DATA_WIDTH - 1 downto 0);
        weight_col_address : in std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH * SYS_ARRAY_SIZE) - 1 downto 0);
        
        selected_weight_bank : in std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH) - 1 downto 0);
        
        data_in : in data_vector(0 to SYS_ARRAY_SIZE - 1)(INPUT_DATA_WIDTH - 1 downto 0);
        
        result_out : out data_vector(0 to SYS_ARRAY_SIZE - 1)(OUTPUT_DATA_WIDTH - 1 downto 0)
    );
end systolic_array_block;

architecture Behavioral of systolic_array_block is
    type row_connection_t is array(1 to SYS_ARRAY_SIZE - 1) of data_vector(0 to SYS_ARRAY_SIZE - 1)(OUTPUT_DATA_WIDTH - 1 downto 0);
    type data_delay_t is array(0 to DATA_IN_DELAY - 1) of data_vector(0 to SYS_ARRAY_SIZE - 1)(INPUT_DATA_WIDTH - 1 downto 0);
    signal row_connections_data : row_connection_t;
    signal data_input_delay : data_delay_t;
begin

    process (clk) begin
        if rising_edge(clk) then
            if en = '1' then
                data_input_delay(0) <= data_in;
                for i in 1 to DATA_IN_DELAY - 1 loop
                    data_input_delay(i) <= data_input_delay(i - 1);
                end loop;
            else
                data_input_delay <= data_input_delay;
            end if;
        end if;
    end process;
    
    first_sys_array_row_inst : entity work.systolic_array_row
        generic map (
            SYS_ARRAY_SIZE => SYS_ARRAY_SIZE,
            INPUT_DATA_WIDTH => INPUT_DATA_WIDTH,
            OUTPUT_DATA_WIDTH => OUTPUT_DATA_WIDTH,
            WEIGHT_REGISTER_DEPTH => WEIGHT_REGISTER_DEPTH
        )
        port map (
            clk => clk,
            en => en,
        
            weight_write_en => weight_write_en,
            weight_in => weight_in(0),
            weight_out => weight_out(0),
            weight_address => weight_col_address,
            
            selected_weight_bank => selected_weight_bank,
            
            data_in => data_input_delay(DATA_IN_DELAY - 1)(0),
            
            partial_result_in => (others => (others => '0')),
            
            result_out => row_connections_data(1)
        );

    sys_array_row_gen : for i in 1 to SYS_ARRAY_SIZE - 2 generate
        sys_array_row_inst : entity work.systolic_array_row
            generic map (
                SYS_ARRAY_SIZE => SYS_ARRAY_SIZE,
                INPUT_DATA_WIDTH => INPUT_DATA_WIDTH,
                OUTPUT_DATA_WIDTH => OUTPUT_DATA_WIDTH,
                WEIGHT_REGISTER_DEPTH => WEIGHT_REGISTER_DEPTH
            )
            port map (
                clk => clk,
                en => en,
            
                weight_write_en => weight_write_en,
                weight_in => weight_in(i),
                weight_out => weight_out(i),
                weight_address => weight_col_address,
                
                selected_weight_bank => selected_weight_bank,
                
                data_in => data_input_delay(DATA_IN_DELAY - 1)(i),
                
                partial_result_in => row_connections_data(i),
                
                result_out => row_connections_data(i + 1)
            );
    end generate;
    
    last_sys_array_row_inst : entity work.systolic_array_row
        generic map (
            SYS_ARRAY_SIZE => SYS_ARRAY_SIZE,
            INPUT_DATA_WIDTH => INPUT_DATA_WIDTH,
            OUTPUT_DATA_WIDTH => OUTPUT_DATA_WIDTH,
            WEIGHT_REGISTER_DEPTH => WEIGHT_REGISTER_DEPTH
        )
        port map (
            clk => clk,
            en => en,
        
            weight_write_en => weight_write_en,
            weight_in => weight_in(SYS_ARRAY_SIZE - 1),
            weight_out => weight_out(SYS_ARRAY_SIZE - 1),
            weight_address => weight_col_address,
            
            selected_weight_bank => selected_weight_bank,
            
            data_in => data_input_delay(DATA_IN_DELAY - 1)(SYS_ARRAY_SIZE - 1),
            
            partial_result_in => row_connections_data(SYS_ARRAY_SIZE - 1),
            
            result_out => result_out
        );
        
end Behavioral;
