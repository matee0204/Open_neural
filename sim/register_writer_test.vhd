----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/19/2026 06:33:36 PM
-- Design Name: 
-- Module Name: register_writer_test - Behavioral
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

entity register_writer_test is
end register_writer_test;

architecture Behavioral of register_writer_test is
    constant REG_ADDRESS_LENGTH : natural := 16;
    constant VECTOR_LENGTH : natural := 8;
    constant DATA_WIDTH : natural := 8;
        
    signal sym_cntr : natural := 0;
    
    signal clk : std_logic;
    signal rst : std_logic;
    
    signal load_reg_address_valid_inst : std_logic;
    signal load_reg_address_ready_inst : std_logic;
    signal load_reg_address_inst : std_logic_vector(REG_ADDRESS_LENGTH - 1 downto 0);
        
    signal load_reg_data_valid_inst : std_logic;
    signal load_reg_data_ready_inst : std_logic;
    signal load_reg_data_inst : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);

    signal mov_reg_address_valid_inst : std_logic;
    signal mov_reg_address_ready_inst : std_logic;
    signal mov_reg_address_inst : std_logic_vector(REG_ADDRESS_LENGTH - 1 downto 0);
        
    signal mov_reg_data_valid_inst : std_logic;
    signal mov_reg_data_ready_inst : std_logic;
    signal mov_reg_data_inst : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);

    signal bias_quant_reg_address_valid_inst : std_logic;
    signal bias_quant_reg_address_ready_inst : std_logic;
    signal bias_quant_reg_address_inst : std_logic_vector(REG_ADDRESS_LENGTH - 1 downto 0);
        
    signal bias_quant_reg_data_valid_inst : std_logic;
    signal bias_quant_reg_data_ready_inst : std_logic;
    signal bias_quant_reg_data_inst : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);

    signal reg_address_valid_inst : std_logic;
    signal reg_address_ready_inst : std_logic;
    signal reg_address_inst : std_logic_vector(REG_ADDRESS_LENGTH - 1 downto 0);
    
    signal reg_data_valid_inst : std_logic;
    signal reg_data_ready_inst : std_logic;
    signal reg_data_inst : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);

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
            if sym_cntr = 4 then
                load_reg_address_valid_inst <= '0';
                load_reg_data_valid_inst <= '0';
                mov_reg_address_valid_inst <= '0';
                mov_reg_data_valid_inst <= '0';
                bias_quant_reg_address_valid_inst <= '0';
                bias_quant_reg_data_valid_inst <= '0';
            elsif sym_cntr = 5 then
                load_reg_address_valid_inst <= '1';
                load_reg_data_valid_inst <= '1';
                mov_reg_address_valid_inst <= '0';
                mov_reg_data_valid_inst <= '0';
                bias_quant_reg_address_valid_inst <= '1';
                bias_quant_reg_data_valid_inst <= '1';
            elsif sym_cntr = 9 then
                load_reg_address_valid_inst <= '0';
                load_reg_data_valid_inst <= '0';
                mov_reg_address_valid_inst <= '1';
                mov_reg_data_valid_inst <= '1';
                bias_quant_reg_address_valid_inst <= '1';
                bias_quant_reg_data_valid_inst <= '1';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 4 then
                reg_address_ready_inst <= '0';
                reg_data_ready_inst <= '0';
            elsif sym_cntr = 5 then
                reg_address_ready_inst <= '1';
                reg_data_ready_inst <= '1';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                load_reg_address_inst <= std_logic_vector(to_unsigned(1, load_reg_address_inst'length));
                mov_reg_address_inst <= std_logic_vector(to_unsigned(2, mov_reg_address_inst'length));
                bias_quant_reg_address_inst <= std_logic_vector(to_unsigned(3, bias_quant_reg_address_inst'length));
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                load_reg_data_inst <= (others => std_logic_vector(to_unsigned(1, DATA_WIDTH)));
                mov_reg_data_inst <= (others => std_logic_vector(to_unsigned(2, DATA_WIDTH)));
                bias_quant_reg_data_inst <= (others => std_logic_vector(to_unsigned(3, DATA_WIDTH)));
            end if;
        end if;
    end process;

    tb_register_writer : entity work.register_writer
        generic map (
            REG_ADDRESS_LENGTH => REG_ADDRESS_LENGTH,
            VECTOR_LENGTH => VECTOR_LENGTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
        
            load_reg_address_valid => load_reg_address_valid_inst,
            load_reg_address_ready => load_reg_address_ready_inst,
            load_reg_address => load_reg_address_inst,
        
            load_reg_data_valid => load_reg_data_valid_inst,
            load_reg_data_ready => load_reg_data_ready_inst,
            load_reg_data => load_reg_data_inst,
            
            mov_reg_address_valid => mov_reg_address_valid_inst,
            mov_reg_address_ready => mov_reg_address_ready_inst,
            mov_reg_address => mov_reg_address_inst,
        
            mov_reg_data_valid => mov_reg_data_valid_inst,
            mov_reg_data_ready => mov_reg_data_ready_inst,
            mov_reg_data => mov_reg_data_inst,
            
            bias_quant_reg_address_valid => bias_quant_reg_address_valid_inst,
            bias_quant_reg_address_ready => bias_quant_reg_address_ready_inst,
            bias_quant_reg_address => bias_quant_reg_address_inst,
        
            bias_quant_reg_data_valid => bias_quant_reg_data_valid_inst,
            bias_quant_reg_data_ready => bias_quant_reg_data_ready_inst,
            bias_quant_reg_data => bias_quant_reg_data_inst,
            
            reg_address_valid => reg_address_valid_inst,
            reg_address_ready => reg_address_ready_inst,
            reg_address => reg_address_inst,
        
            reg_data_valid => reg_data_valid_inst,
            reg_data_ready => reg_data_ready_inst,
            reg_data => reg_data_inst
        );

end Behavioral;
