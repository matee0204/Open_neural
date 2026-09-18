----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/21/2026 09:54:25 AM
-- Design Name: 
-- Module Name: vector_register - Behavioral
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

entity vector_register is
    generic (
        DATA_WIDTH : natural := 48;
        DEPTH : natural := 128;
        VECTOR_LENGTH : natural := 8
    );
    port (
        clk_A : in std_logic;
        en_A : in std_logic;
        
        wr_en_A : in std_logic;
        address_A : in std_logic_vector(clog2(DEPTH) - 1 downto 0);
        
        data_in_A : in data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        data_out_A : out data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        clk_B : in std_logic;
        en_B : in std_logic;
        
        wr_en_B : in std_logic;
        address_B : in std_logic_vector(clog2(DEPTH) - 1 downto 0);
        
        data_in_B : in data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        data_out_B : out data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0)
    );
end vector_register;

architecture Read_first of vector_register is
    constant FULL_DATA_WIDTH : natural := DATA_WIDTH * VECTOR_LENGTH;
    signal input_data_A_packed : std_logic_vector(FULL_DATA_WIDTH - 1 downto 0);
    signal input_data_B_packed : std_logic_vector(FULL_DATA_WIDTH - 1 downto 0);
    signal output_data_A_packed : std_logic_vector(FULL_DATA_WIDTH - 1 downto 0);
    signal output_data_B_packed : std_logic_vector(FULL_DATA_WIDTH - 1 downto 0);
begin

    input_data_A_packed <= flatten(data_in_A);
    input_data_B_packed <= flatten(data_in_B);

    register_inst : entity work.Data_RAM(Read_first)
        generic map (
            WIDTH => FULL_DATA_WIDTH,
            DEPTH => DEPTH
        )
        port map (
            clk_A => clk_A,
            en_A => en_A,
            
            wr_en_A => wr_en_A,
            address_A => address_A,
            
            data_in_A => input_data_A_packed,
            data_out_A => output_data_A_packed,
            
            clk_B => clk_B,
            en_B => en_B,
            
            wr_en_B => wr_en_B,
            address_B => address_B,
            
            data_in_B => input_data_B_packed,
            data_out_B => output_data_B_packed
        );

    data_out_A <= vectorize(output_data_A_packed, DATA_WIDTH, VECTOR_LENGTH);
    data_out_B <= vectorize(output_data_B_packed, DATA_WIDTH, VECTOR_LENGTH);

end Read_first;

architecture Write_first of vector_register is
    constant FULL_DATA_WIDTH : natural := DATA_WIDTH * VECTOR_LENGTH;
    signal input_data_A_packed : std_logic_vector(FULL_DATA_WIDTH - 1 downto 0);
    signal input_data_B_packed : std_logic_vector(FULL_DATA_WIDTH - 1 downto 0);
    signal output_data_A_packed : std_logic_vector(FULL_DATA_WIDTH - 1 downto 0);
    signal output_data_B_packed : std_logic_vector(FULL_DATA_WIDTH - 1 downto 0);
begin

    input_data_A_packed <= flatten(data_in_A);
    input_data_B_packed <= flatten(data_in_B);

    register_inst : entity work.Data_RAM(Write_first)
        generic map (
            WIDTH => FULL_DATA_WIDTH,
            DEPTH => DEPTH
        )
        port map (
            clk_A => clk_A,
            en_A => en_A,
            
            wr_en_A => wr_en_A,
            address_A => address_A,
            
            data_in_A => input_data_A_packed,
            data_out_A => output_data_A_packed,
            
            clk_B => clk_B,
            en_B => en_B,
            
            wr_en_B => wr_en_B,
            address_B => address_B,
            
            data_in_B => input_data_B_packed,
            data_out_B => output_data_B_packed
        );

    data_out_A <= vectorize(output_data_A_packed, DATA_WIDTH, VECTOR_LENGTH);
    data_out_B <= vectorize(output_data_B_packed, DATA_WIDTH, VECTOR_LENGTH);

end Write_first;
