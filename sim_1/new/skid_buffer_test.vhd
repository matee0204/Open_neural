----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/13/2026 10:07:11 PM
-- Design Name: 
-- Module Name: skid_buffer_test - Behavioral
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

entity skid_buffer_test is
end skid_buffer_test;

architecture Behavioral of skid_buffer_test is
    constant DATA_WIDTH : natural := 8;
    signal clk : std_logic;
    signal rst : std_logic;
    signal skid_data_in_valid : std_logic := '0';
    signal skid_data_in_ready : std_logic;
    signal skid_data_in : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal skid_data_out_valid : std_logic;
    signal skid_data_out_ready : std_logic := '0';
    signal skid_data_out : std_logic_vector(DATA_WIDTH - 1 downto 0);
    
    signal sym_cntr : integer := 0;
begin

    process begin
        clk <= '0';
        wait for 1ns;
        clk <= '1';
        wait for 1ns;
    end process;
    
    process (clk) begin
        if rising_edge(clk) and sym_cntr < integer'high then
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
            if sym_cntr = 8 then
                skid_data_in_valid <= '1';
            elsif sym_cntr = 9 then
                skid_data_in_valid <= '0';
            elsif sym_cntr = 10 then
                skid_data_in_valid <= '1';
            elsif sym_cntr = 21 then
                skid_data_in_valid <= '0';
            elsif sym_cntr = 24 then
                skid_data_in_valid <= '1';
            elsif sym_cntr = 26 then
                skid_data_in_valid <= '0';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                skid_data_out_ready <= '1';
            elsif sym_cntr = 11 then
                skid_data_out_ready <= '0';
            elsif sym_cntr = 16 then
                skid_data_out_ready <= '1';
            elsif sym_cntr = 20 then
                skid_data_out_ready <= '0';
            elsif sym_cntr = 23 then
                skid_data_out_ready <= '1';
            elsif sym_cntr = 27 then
                skid_data_out_ready <= '0';
            elsif sym_cntr = 30 then
                skid_data_out_ready <= '1';
            elsif sym_cntr = 32 then
                skid_data_out_ready <= '0';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 8 then
                skid_data_in <= std_logic_vector(to_unsigned(1, 8));
            elsif sym_cntr = 9 then
                skid_data_in <= std_logic_vector(to_unsigned(2, 8));
            elsif sym_cntr = 10 then
                skid_data_in <= std_logic_vector(to_unsigned(3, 8));
            elsif sym_cntr = 11 then
                skid_data_in <= std_logic_vector(to_unsigned(4, 8));
            elsif sym_cntr = 12 then
                skid_data_in <= std_logic_vector(to_unsigned(5, 8));
            elsif sym_cntr = 18 then
                skid_data_in <= std_logic_vector(to_unsigned(6, 8));
            elsif sym_cntr = 19 then
                skid_data_in <= std_logic_vector(to_unsigned(7, 8));
            elsif sym_cntr = 20 then
                skid_data_in <= std_logic_vector(to_unsigned(8, 8));
            elsif sym_cntr = 24 then
                skid_data_in <= std_logic_vector(to_unsigned(9, 8));
            elsif sym_cntr = 25 then
                skid_data_in <= std_logic_vector(to_unsigned(10, 8));
            end if;
        end if;
    end process;

    skid_buffer_inst : entity work.skid_buffer
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            data_in_valid => skid_data_in_valid,
            data_in_ready => skid_data_in_ready,
            data_in => skid_data_in,
            
            data_out_valid => skid_data_out_valid,
            data_out_ready => skid_data_out_ready, 
            data_out => skid_data_out
        );

end Behavioral;
