----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/02/2026 09:44:21 PM
-- Design Name: 
-- Module Name: register_reader_test - Behavioral
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

entity register_reader_test is
end register_reader_test;

architecture Behavioral of register_reader_test is
    constant REGISTER_ADDRESS_LENGTH : natural := 16;
    constant VECTOR_LENGTH : natural := 8;
    constant DATA_WIDTH : natural := 8;
    
    signal clk : std_logic;
    signal rst : std_logic;
        
    signal sym_cntr : natural := 0;

    signal register_address_in_valid_inst : std_logic;
    signal register_address_in_ready_inst : std_logic;
    signal register_address_in_inst : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    
    signal register_address_out_valid_inst : std_logic;
    signal register_address_out_ready_inst : std_logic;
    signal register_address_out_inst : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);

    signal register_data_in_valid_inst : std_logic;
    signal register_data_in_ready_inst : std_logic;
    signal register_data_in_inst : data_vector(0 to VECTOR_LENGTH)(DATA_WIDTH - 1 downto 0);

    signal register_data_out_valid_inst : std_logic;
    signal register_data_out_ready_inst : std_logic;
    signal register_data_out_inst : data_vector(0 to VECTOR_LENGTH)(DATA_WIDTH - 1 downto 0);
    
begin

    process begin
        clk <= '0';
        wait for 1ns;
        clk <= '1';
        wait for 1ns;
    end process;
    
    process begin
        rst <= '1';
        wait for 10ns;
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
                register_address_out_ready_inst <= '1';
                register_data_out_ready_inst <= '1';
            elsif sym_cntr = 11 then
                register_address_out_ready_inst <= '0';
            elsif sym_cntr = 13 then
                register_address_out_ready_inst <= '1';
            elsif sym_cntr = 14 then
                register_data_out_ready_inst <= '0';
            elsif sym_cntr = 15 then
                register_data_out_ready_inst <= '1';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                register_address_in_valid_inst <= '0';
                register_data_in_valid_inst <= '0';
            elsif sym_cntr = 6 then
                register_address_in_valid_inst <= '1';
            elsif sym_cntr = 7 then
                register_address_in_valid_inst <= '0';
            elsif sym_cntr = 8 then
                register_data_in_valid_inst <= '1';
            elsif sym_cntr = 9 then
                register_data_in_valid_inst <= '0';
            elsif sym_cntr = 11 then
                register_address_in_valid_inst <= '1';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            register_address_in_inst <= std_logic_vector(to_unsigned(sym_cntr, register_address_in_inst'length));
            register_data_in_inst <= (others => (std_logic_vector(to_unsigned(sym_cntr, DATA_WIDTH)),
                                                 std_logic_vector(to_unsigned(sym_cntr, DATA_WIDTH)),
                                                 std_logic_vector(to_unsigned(sym_cntr, DATA_WIDTH)),
                                                 std_logic_vector(to_unsigned(sym_cntr, DATA_WIDTH)),
                                                 std_logic_vector(to_unsigned(sym_cntr, DATA_WIDTH)),
                                                 std_logic_vector(to_unsigned(sym_cntr, DATA_WIDTH)),
                                                 std_logic_vector(to_unsigned(sym_cntr, DATA_WIDTH)),
                                                 std_logic_vector(to_unsigned(sym_cntr, DATA_WIDTH))));
        end if;
    end process;

    

    tb_register_reader : entity work.register_reader
    generic map (
        REGISTER_ADDRESS_LENGTH => REGISTER_ADDRESS_LENGTH,
        VECTOR_LENGTH => VECTOR_LENGTH,
        DATA_WIDTH => DATA_WIDTH
    )
    port map (
        clk => clk,
        rst => rst,
        
        register_address_in_valid => register_address_in_valid_inst,
        register_address_in_ready => register_address_in_ready_inst,
        register_address_in => register_address_in_inst,
        
        register_address_out_valid => register_address_out_valid_inst,
        register_address_out_ready => register_address_out_ready_inst,
        register_address_out => register_address_out_inst,
        
        register_data_in_valid => register_data_in_valid_inst,
        register_data_in_ready => register_data_in_ready_inst,
        register_data_in => register_data_in_inst,
        
        register_data_out_valid => register_data_out_valid_inst,
        register_data_out_ready => register_data_out_ready_inst,
        register_data_out => register_data_out_inst
    );

end Behavioral;
