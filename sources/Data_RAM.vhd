----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/10/2026 07:35:10 PM
-- Design Name: 
-- Module Name: Data_RAM - Behavioral
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

entity Data_RAM is
    generic (
        WIDTH : natural := 8;
        DEPTH : natural := 2
    );
    port (
        clk_A : in std_logic;
        en_A : in std_logic;
        
        wr_en_A : in std_logic;
        address_A : in std_logic_vector(clog2(DEPTH) - 1 downto 0);
        
        data_in_A : in std_logic_vector(WIDTH - 1 downto 0);
        data_out_A : out std_logic_vector(WIDTH - 1 downto 0);
        
        clk_B : in std_logic;
        en_B : in std_logic;
        
        wr_en_B : in std_logic;
        address_B : in std_logic_vector(clog2(DEPTH) - 1 downto 0);
        
        data_in_B : in std_logic_vector(WIDTH - 1 downto 0);
        data_out_B : out std_logic_vector(WIDTH - 1 downto 0)
    );
end Data_RAM;

architecture Read_first of Data_RAM is
    type RAM_t is array(0 to DEPTH - 1) of std_logic_vector(WIDTH - 1 downto 0);
    signal RAM_arr : RAM_t;
    signal address_int_A : integer range 0 to DEPTH - 1;
    signal address_int_B : integer range 0 to DEPTH - 1;
begin
    
    address_int_A <= to_integer(unsigned(address_A));
    address_int_B <= to_integer(unsigned(address_B));
    
    process (clk_A, clk_B) begin
        if rising_edge(clk_A) then
            if en_A = '1' then
                data_out_A <= RAM_arr(address_int_A);
                if wr_en_A = '1' then
                    RAM_arr(address_int_A) <= data_in_A;
                end if;
            else
                data_out_A <= data_out_A;
            end if;
        end if;
        
        if rising_edge(clk_B) then
            if en_B = '1' then
                data_out_B <= RAM_arr(address_int_B);
                if wr_en_B = '1' then
                    RAM_arr(address_int_B) <= data_in_B;
                end if;
            else
                data_out_B <= data_out_B;
            end if;
        end if;
    end process;

end Read_first;

architecture Write_first of Data_RAM is
    type RAM_t is array(0 to DEPTH - 1) of std_logic_vector(WIDTH - 1 downto 0);
    signal RAM_arr : RAM_t;
    signal address_int_A : integer range 0 to DEPTH - 1;
    signal address_int_B : integer range 0 to DEPTH - 1;
begin
    
    address_int_A <= to_integer(unsigned(address_A));
    address_int_B <= to_integer(unsigned(address_B));
    
    process (clk_A, clk_B) begin
        if rising_edge(clk_A) then
            if en_A = '1' then
                if wr_en_A = '1' then
                    RAM_arr(address_int_A) <= data_in_A;
                    data_out_A <= data_in_A;
                else
                    data_out_A <= RAM_arr(address_int_A);
                end if;
            else
                data_out_A <= data_out_A;
            end if;
        end if;
        
        if rising_edge(clk_B) then
            if en_B = '1' then
                if wr_en_B = '1' then
                    RAM_arr(address_int_B) <= data_in_B;
                    data_out_B <= data_in_B;
                else
                    data_out_B <= RAM_arr(address_int_B);
                end if;
            else
                data_out_B <= data_out_B;
            end if;
        end if;
    end process;

end Write_first;
