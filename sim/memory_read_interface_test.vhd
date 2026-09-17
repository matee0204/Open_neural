----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/25/2026 07:59:22 PM
-- Design Name: 
-- Module Name: pipeline_load_test - Behavioral
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

entity memory_read_interface_test is
end memory_read_interface_test;

architecture Behavioral of memory_read_interface_test is
    constant REGISTER_ADDRESS_LENGTH : natural := 16;
    constant MEMORY_ADDRESS_LENGTH : natural := 32;
    constant VECTOR_LENGTH : natural := 8;
    constant DATA_WIDTH : natural := 8;
    
    signal clk : std_logic;
    signal rst : std_logic;
        
    signal sym_cntr : natural := 0;

    signal read_address_in_valid_inst : std_logic;
    signal read_address_in_ready_inst : std_logic;
    signal read_address_in_inst : std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);

    signal read_address_out_valid_inst : std_logic;
    signal read_address_out_ready_inst : std_logic;
    signal read_address_out_inst : std_logic_vector(MEMORY_ADDRESS_LENGTH - 1 downto 0);

    signal data_in_valid_inst : std_logic;
    signal data_in_ready_inst : std_logic;
    signal data_in_inst : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);

    signal write_address_in_valid_inst : std_logic;
    signal write_address_in_ready_inst : std_logic;
    signal write_address_in_inst : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);

    signal write_address_out_valid_inst : std_logic;
    signal write_address_out_ready_inst : std_logic;
    signal write_address_out_inst : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);

    signal data_out_valid_inst : std_logic;
    signal data_out_ready_inst : std_logic;
    signal data_out_inst : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
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
                read_address_in_valid_inst <= '0';
                data_in_valid_inst <= '0';
                write_address_in_valid_inst <= '0';
            elsif sym_cntr = 5 then
                read_address_in_valid_inst <= '1';
                write_address_in_valid_inst <= '1';
            elsif sym_cntr = 8 then
                data_in_valid_inst <= '1';
            elsif sym_cntr = 9 then
                data_in_valid_inst <= '0';
            elsif sym_cntr = 10 then
                read_address_in_valid_inst <= '0';
                write_address_in_valid_inst <= '0';
            elsif sym_cntr = 12 then
                data_in_valid_inst <= '1';
            elsif sym_cntr = 13 then
                data_in_valid_inst <= '0';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 3 then
                read_address_out_ready_inst <= '0';
                write_address_out_ready_inst <= '0';
                data_out_ready_inst <= '0';
            elsif sym_cntr = 4 then
                read_address_out_ready_inst <= '1';
                write_address_out_ready_inst <= '1';
                data_out_ready_inst <= '1';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                read_address_in_inst <= std_logic_vector(to_unsigned(1, read_address_in_inst'length));
                data_in_inst <= (others => (others => '0'));
                write_address_in_inst <= std_logic_vector(to_unsigned(2, write_address_in_inst'length));
            elsif sym_cntr = 6 then
                read_address_in_inst <= std_logic_vector(to_unsigned(2, read_address_in_inst'length));
                write_address_in_inst <= std_logic_vector(to_unsigned(3, write_address_in_inst'length));
            end if;
        end if;
    end process;


    tb_pipeline_load : entity work.memory_read_interface
        generic map (
            READ_ADDRESS_LENGTH => REGISTER_ADDRESS_LENGTH,
            WRITE_ADDRESS_LENGTH => MEMORY_ADDRESS_LENGTH,
            VECTOR_LENGTH => VECTOR_LENGTH,
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            read_address_in_valid => read_address_in_valid_inst,
            read_address_in_ready => read_address_in_ready_inst,
            read_address_in => read_address_in_inst,
            
            read_address_out_valid => read_address_out_valid_inst,
            read_address_out_ready => read_address_out_ready_inst,
            read_address_out => read_address_out_inst,
            
            data_in_valid => data_in_valid_inst,
            data_in_ready => data_in_ready_inst,
            data_in => data_in_inst,
            
            write_address_in_valid => write_address_in_valid_inst,
            write_address_in_ready => write_address_in_ready_inst,
            write_address_in => write_address_in_inst,
            
            write_address_out_valid => write_address_out_valid_inst,
            write_address_out_ready => write_address_out_ready_inst,
            write_address_out => write_address_out_inst,
            
            data_out_valid => data_out_valid_inst,
            data_out_ready => data_out_ready_inst,
            data_out => data_out_inst
        );

end Behavioral;