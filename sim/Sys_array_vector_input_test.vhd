----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/03/2026 07:54:30 PM
-- Design Name: 
-- Module Name: Sys_array_vector_input_test - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity Sys_array_vector_input_test is
end Sys_array_vector_input_test;

architecture Behavioral of Sys_array_vector_input_test is
    constant VECTOR_LENGTH : natural := 8;
    constant DATA_WIDTH : natural  := 8;
    
    signal sys_array_input_vector : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
    signal sys_array_output_vector : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
    
    signal clk : std_logic;
    signal rst : std_logic;
    
    signal sys_array_input_valid : std_logic;
    signal sys_array_input_ready : std_logic;
    signal sys_array_output_valid : std_logic;
    signal sys_array_output_ready : std_logic;
    
    signal sym_cntr : natural := 0;
begin
    process begin
        clk <= '0';
        wait for 1ns;
        clk <= '1';
        wait for 1ns;
    end process;
    
    process (clk) begin
        if rising_edge(clk) and sym_cntr < natural'high then
            sym_cntr <= sym_cntr + 1;
        end if;
    end process;
    
    process begin
        rst <= '1';
        wait for 10ns;
        rst <= '0';
        wait;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 6 then
                for i in 0 to sys_array_input_vector'length - 1 loop
                    sys_array_input_vector(i) <= std_logic_vector(to_unsigned(i+1, DATA_WIDTH));
                end loop;
            elsif sym_cntr = 7 then
                for i in 0 to sys_array_input_vector'length - 1 loop
                    sys_array_input_vector(i) <= std_logic_vector(to_unsigned(i+8, DATA_WIDTH));
                end loop;
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 0 then
                sys_array_input_valid <= '0';
            elsif sym_cntr = 6 then
                sys_array_input_valid <= '1';
            elsif sym_cntr = 8 then
                sys_array_input_valid <= '0';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 0 then
                sys_array_output_ready <= '0';
            elsif sym_cntr = 5 then
                sys_array_output_ready <= '1';
            elsif sym_cntr = 12 then
                sys_array_output_ready <= '0';
            elsif sym_cntr = 14 then
                sys_array_output_ready <= '1';
            end if;
        end if;
    end process;

    tb_sys_array_input : entity work.Sys_array_vector_input
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            VECTOR_LENGTH => VECTOR_LENGTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            data_in_valid => sys_array_input_valid,
            data_in_ready => sys_array_input_ready,
            data_in => sys_array_input_vector,
            
            data_out_valid => sys_array_output_valid,
            data_out_ready => sys_array_output_ready, 
            data_out => sys_array_output_vector
        );
     
end Behavioral;
