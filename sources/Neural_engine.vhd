----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/02/2026 04:32:42 PM
-- Design Name: 
-- Module Name: Neural_engine - 
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
use IEEE.STD_LOGIC_1164.std_logic_vector;
use IEEE.STD_LOGIC_1164.std_logic;
use IEEE.NUMERIC_STD.ALL;

package Neural_engine is
    type data_vector is array (natural range <>) of std_logic_vector;
    type data_vector_signed is array (natural range <>) of signed;
    type data_vector_unsigned is array (natural range <>) of unsigned;
    function clog2(n : natural) return natural;
    function flatten(v : data_vector) return std_logic_vector;
    function vectorize(s : std_logic_vector; data_width : natural; vector_length : natural) return data_vector;
end package;

package body Neural_engine is    
    function clog2(n : natural) return natural is
        variable r : natural := 0;
        variable v : natural := n - 1;
    begin
        while v > 0 loop
            v := v / 2;
            r := r + 1;
        end loop;
        return r;
    end function;

    function flatten(v : data_vector) return std_logic_vector is
        constant size : natural := v'length * v(0)'length;
        variable temp : std_logic_vector(size - 1 downto 0);
    begin
        for i in 0 to v'length - 1 loop
            temp(v(0)'length * i + v(0)'length - 1 downto v(0)'length * i) := v(i);
        end loop;
        return temp;
    end function;

    function vectorize(s : std_logic_vector; data_width : natural; vector_length : natural) return data_vector is
        variable temp : data_vector(0 to vector_length - 1)(data_width - 1 downto 0);
    begin
        for i in 0 to vector_length - 1 loop
            temp(i) := s(data_width * i + data_width - 1 downto data_width * i);
        end loop;
        return temp;
    end function;

end Neural_engine;