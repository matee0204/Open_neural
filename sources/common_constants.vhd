----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/06/2026 07:44:35 PM
-- Design Name: 
-- Module Name: common_constants - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

package common_constants is
    constant OPERATION_NOP : natural := 0;
    constant OPERATION_VECTOR_LOAD : natural := 1;
    constant OPERATION_VECTOR_STORE : natural := 2;
    constant OPERATION_VECTOR_MOV : natural := 3;
    constant OPERATION_VECTOR_MAC : natural := 4;
    constant OPERATION_VECTOR_BIAS_QUANT : natural := 5;
    constant NUMBER_OF_OPERATIONS : natural := 6;
end package;