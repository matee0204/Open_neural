----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/08/2026 06:39:51 PM
-- Design Name: 
-- Module Name: vector_adder - Behavioral
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

entity vector_adder is
    generic (
        INPUT_A_DATA_WIDTH : natural := 24;
        INPUT_B_DATA_WIDTH : natural := 32;
        OUTPUT_DATA_WIDTH : natural := 32;
        VECTOR_LENGTH : natural := 8
    );
    port (        
        data_in_A : in data_vector_signed(VECTOR_LENGTH - 1 downto 0)(INPUT_A_DATA_WIDTH - 1 downto 0);
        
        data_in_B : in data_vector_signed(VECTOR_LENGTH - 1 downto 0)(INPUT_B_DATA_WIDTH - 1 downto 0);
        
        result_out : out data_vector_signed(VECTOR_LENGTH - 1 downto 0)(OUTPUT_DATA_WIDTH - 1 downto 0)
    );
end vector_adder;

architecture Behavioral of vector_adder is
    signal data_in_A_extended_signed : data_vector_signed(VECTOR_LENGTH - 1 downto 0)(OUTPUT_DATA_WIDTH - 1 downto 0);
    signal data_in_B_extended_signed : data_vector_signed(VECTOR_LENGTH - 1 downto 0)(OUTPUT_DATA_WIDTH - 1 downto 0);
begin
   
    process (data_in_A, data_in_B) begin
        for i in 0 to VECTOR_LENGTH - 1 loop
            data_in_A_extended_signed(i) <= resize(signed(data_in_A(i)), OUTPUT_DATA_WIDTH);
            data_in_B_extended_signed(i) <= resize(signed(data_in_B(i)), OUTPUT_DATA_WIDTH);
        end loop;
    end process;
    
    process (data_in_A_extended_signed, data_in_B_extended_signed) begin
        for i in 0 to VECTOR_LENGTH - 1 loop
            result_out(i) <= data_in_A_extended_signed(i) + data_in_B_extended_signed(i);
        end loop;
    end process;

end Behavioral;
