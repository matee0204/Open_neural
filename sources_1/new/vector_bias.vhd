----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/08/2026 10:11:26 PM
-- Design Name: 
-- Module Name: vector_bias - Behavioral
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

entity vector_bias is
    generic (
        BIAS_REGISTER_DEPTH : natural := 128;
        
        VECTOR_LENGTH : natural := 8;
        BIAS_DATA_WIDTH : natural := 8;
        INPUT_DATA_WIDTH : natural := 32;
        OUTPUT_DATA_WIDTH : natural := 32
    );
    port (
        clk : in std_logic;

        en : in std_logic;

        bias_reg_read_write_address : in std_logic_vector(clog2(BIAS_REGISTER_DEPTH) - 1 downto 0);
        bias_reg_write_en : in std_logic;
        bias_reg_data_in : in data_vector(0 to VECTOR_LENGTH - 1)(BIAS_DATA_WIDTH - 1 downto 0);
        bias_reg_data_out : out data_vector(0 to VECTOR_LENGTH - 1)(BIAS_DATA_WIDTH - 1 downto 0);
        
        bias_reg_address : in std_logic_vector(clog2(BIAS_REGISTER_DEPTH) - 1 downto 0);
        data_in : in data_vector_signed(0 to VECTOR_LENGTH - 1)(INPUT_DATA_WIDTH - 1 downto 0);
        data_out : out data_vector_signed(0 to VECTOR_LENGTH - 1)(OUTPUT_DATA_WIDTH - 1 downto 0)
    );
end vector_bias;

architecture Behavioral of vector_bias is
    signal bias_reg_out_B : data_vector(0 to VECTOR_LENGTH - 1)(BIAS_DATA_WIDTH - 1 downto 0);
    signal bias_reg_data_out_signed : data_vector_signed(0 to VECTOR_LENGTH - 1)(BIAS_DATA_WIDTH - 1 downto 0);
    signal data_out_from_adder : data_vector_signed(0 to VECTOR_LENGTH - 1)(OUTPUT_DATA_WIDTH - 1 downto 0);
    signal data_in_delay : data_vector_signed(0 to VECTOR_LENGTH - 1)(INPUT_DATA_WIDTH - 1 downto 0);
begin

    process (clk) begin
        if rising_edge(clk) then
            if en = '1' then
                data_in_delay <= data_in;
            end if;
        end if;
    end process;

    bias_register_inst : entity work.vector_register(Read_first)
        generic map(
            DATA_WIDTH    => BIAS_DATA_WIDTH,
            DEPTH         => BIAS_REGISTER_DEPTH,
            VECTOR_LENGTH => VECTOR_LENGTH
        )
        port map(
            clk_A      => clk,
            en_A       => '1',
            wr_en_A    => bias_reg_write_en,
            address_A  => bias_reg_read_write_address,
            data_in_A  => bias_reg_data_in,
            data_out_A => bias_reg_data_out,
            clk_B      => clk,
            en_B       => '1',
            wr_en_B    => '0',
            address_B  => bias_reg_address,
            data_in_B  => (others => (others => '0')),
            data_out_B => bias_reg_out_B
        );
    
    process (bias_reg_out_B) begin
        for i in 0 to VECTOR_LENGTH - 1 loop
            bias_reg_data_out_signed(i) <= signed(bias_reg_out_B(i));
        end loop;
    end process;

    bias_adder_inst : entity work.vector_adder
        generic map(
            INPUT_A_DATA_WIDTH => BIAS_DATA_WIDTH,
            INPUT_B_DATA_WIDTH => INPUT_DATA_WIDTH,
            OUTPUT_DATA_WIDTH  => OUTPUT_DATA_WIDTH,
            VECTOR_LENGTH      => VECTOR_LENGTH
        )
        port map(
            data_in_A  => bias_reg_data_out_signed,
            data_in_B  => data_in_delay,
            result_out => data_out_from_adder
        );
    
    process (clk) begin
        if rising_edge(clk) then
            if en = '1' then
                data_out <= data_out_from_adder;
            else
                data_out <= data_out;
            end if;
        end if;
    end process;

end Behavioral;
