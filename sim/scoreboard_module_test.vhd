----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/12/2026 03:13:00 PM
-- Design Name: 
-- Module Name: scoreboard_module_test - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity scoreboard_module_test is
end scoreboard_module_test;

architecture Behavioral of scoreboard_module_test is
    constant READ : natural := 1;
    constant WRITE : natural := 0;
    constant NUM_OF_REGISTERS : natural := 8;
    constant WRITE_ADDRESS_LENGTH : natural := 16;
    constant READ_ADDRESS_LENGTH : natural := 16;
    constant WRITE_BACK_ADDRESS_LENGTH : natural := 16;
        
    signal sym_cntr : natural := 0;
        
    signal clk : std_logic;
    signal rst : std_logic;

    signal read_address_valid_inst : std_logic;
    signal read_address_ready_inst : std_logic;
    signal read_address_inst : std_logic_vector(READ_ADDRESS_LENGTH - 1 downto 0);

    signal write_address_valid_inst : std_logic;
    signal write_address_ready_inst : std_logic;
    signal write_address_inst : std_logic_vector(WRITE_ADDRESS_LENGTH - 1 downto 0);

    signal dst_address_valid_inst : std_logic;
    signal dst_address_ready_inst : std_logic;
    signal dst_address_inst : std_logic_vector(WRITE_BACK_ADDRESS_LENGTH - 1 downto 0);
    signal dst_write_en_inst : std_logic;
begin

    process begin
        clk <= '0';
        wait for 1ns;
        clk <= '1';
        wait for 1ns;
    end process;

    process begin
        rst <= '1';
        wait for 4ns;
        rst <= '0';
        wait;
    end process;
    
    process (clk) begin
        if rising_edge(clk) and sym_cntr < natural'high then
            sym_cntr <= sym_cntr + 1;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                write_address_valid_inst <= '1';
                write_address_inst <= std_logic_vector(to_unsigned(2, write_address_inst'length));
            elsif sym_cntr = 6 then
                write_address_valid_inst <= '0';
            elsif sym_cntr = 10 then
                write_address_valid_inst <= '1';
            elsif sym_cntr = 11 then
                write_address_valid_inst <= '0';
            elsif sym_cntr = 12 then
                write_address_valid_inst <= '1';
            elsif sym_cntr = 15 then
                write_address_valid_inst <= '0';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                dst_write_en_inst <= '0';
                dst_address_valid_inst <= '0';
            elsif sym_cntr = 7 then
                dst_address_valid_inst <= '1';
                dst_address_inst <= std_logic_vector(to_unsigned(2, dst_address_inst'length));
            elsif sym_cntr = 8 then
                dst_write_en_inst <= '1';
            elsif sym_cntr = 9 then
                dst_write_en_inst <= '0';
                dst_address_valid_inst <= '0';
            elsif sym_cntr = 10 then
                dst_address_valid_inst <= '1';
                dst_write_en_inst <= '1';
            elsif sym_cntr = 11 then
                dst_address_valid_inst <= '0';
                dst_write_en_inst <= '0';
            elsif sym_cntr = 13 then
                dst_address_valid_inst <= '1';
                dst_write_en_inst <= '1';
            elsif sym_cntr = 14 then
                dst_address_valid_inst <= '0';
                dst_write_en_inst <= '0';
            elsif sym_cntr = 19 then
                dst_address_valid_inst <= '1';
                dst_write_en_inst <= '1';
            elsif sym_cntr = 20 then
                dst_address_valid_inst <= '0';
                dst_write_en_inst <= '0';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                read_address_valid_inst <= '0';
            elsif sym_cntr = 17 then
                read_address_valid_inst <= '1';
                read_address_inst <= std_logic_vector(to_unsigned(2, read_address_inst'length));
            elsif sym_cntr = 22 then
                read_address_valid_inst <= '0';
            end if;
        end if;
    end process;

    tb_scoreboard_module : entity work.scoreboard_module
        generic map (
            NUM_OF_REGISTERS => NUM_OF_REGISTERS,
            WRITE_ADDRESS_LENGTH => WRITE_ADDRESS_LENGTH,
            READ_ADDRESS_LENGTH => READ_ADDRESS_LENGTH,
            WRITE_BACK_ADDRESS_LENGTH => WRITE_BACK_ADDRESS_LENGTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            read_address_valid => read_address_valid_inst,
            read_address_ready => read_address_ready_inst,
            read_address => read_address_inst,
            
            write_address_valid => write_address_valid_inst,
            write_address_ready => write_address_ready_inst,
            write_address => write_address_inst,
            
            dst_address_valid => dst_address_valid_inst,
            dst_address_ready => dst_address_ready_inst,
            dst_address => dst_address_inst,
            dst_write_en => dst_write_en_inst
        );

end Behavioral;
