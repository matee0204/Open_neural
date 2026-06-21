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

package common_constants is
    constant ACCUMULATOR_MODE_SELECTOR_LENGTH : natural := 1;
    constant ACCUMULATOR_MODE_ACCUMULATE : natural := 0;
    constant ACCUMULATOR_MODE_OVERRIDE : natural := 1;
    constant RESIZE_MODE_LENGTH : natural := 1;
end package;