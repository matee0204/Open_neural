----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/04/2026 09:37:57 PM
-- Design Name: 
-- Module Name: vector_accumulator_test - Behavioral
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
use work.common_constants.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vector_accumulator_test is
end vector_accumulator_test;

architecture Behavioral of vector_accumulator_test is
    constant INPUT_DATA_WIDTH : natural := 24;
    constant ACCUMULATOR_DATA_WIDTH : natural := 32;
    constant ACCUMULATOR_DEPTH : natural := 4;
    constant VECTOR_LENGTH : natural := 4;
    constant ACCUMULATOR_MODE_LENGTH : integer := 3;
    
        
    signal sym_cntr : natural := 0;
    
    signal clk : std_logic;
    signal rst : std_logic;
    signal mode_inst : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
    
    signal data_in_valid_inst : std_logic;
    signal data_in_inst : data_vector_signed(VECTOR_LENGTH - 1 downto 0)(INPUT_DATA_WIDTH - 1 downto 0);
    
    signal address_valid_inst : std_logic;
    signal address_ready_inst : std_logic;
    signal read_address_inst : std_logic_vector(clog2(ACCUMULATOR_DEPTH) - 1 downto 0);
    
    signal write_address_inst : std_logic_vector(clog2(ACCUMULATOR_DEPTH) - 1 downto 0);
    
    signal result_out_valid_inst : std_logic;
    signal result_out_ready_inst : std_logic;
    signal result_out_inst : data_vector_signed(VECTOR_LENGTH - 1 downto 0)(ACCUMULATOR_DATA_WIDTH - 1 downto 0);
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
                write_address_inst <= std_logic_vector(to_unsigned(1, write_address_inst'length));
            elsif sym_cntr = 13 then
                write_address_inst <= std_logic_vector(to_unsigned(0, write_address_inst'length));
            elsif sym_cntr = 17 then
                write_address_inst <= std_logic_vector(to_unsigned(1, write_address_inst'length));
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 10 then
                address_valid_inst <= '1';
                read_address_inst <= std_logic_vector(to_unsigned(1, read_address_inst'length));
            elsif sym_cntr = 11 then
                address_valid_inst <= '0';
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 6 then
                data_in_valid_inst <= '1';
                data_in_inst <= (to_signed(-1, INPUT_DATA_WIDTH),
                                 to_signed(0, INPUT_DATA_WIDTH),
                                 to_signed(10, INPUT_DATA_WIDTH),
                                 to_signed(5, INPUT_DATA_WIDTH));
            elsif sym_cntr = 7 then
                data_in_valid_inst <= '0';
            elsif sym_cntr = 8 then
                data_in_valid_inst <= '1';
            elsif sym_cntr = 10 then
                data_in_valid_inst <= '0';
            elsif sym_cntr = 12 then
                data_in_valid_inst <= '1';
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                mode_inst <= std_logic_vector(to_unsigned(ACCUMULATOR_MODE_OVERRIDE, ACCUMULATOR_MODE_LENGTH));
            elsif sym_cntr = 6 then
                mode_inst <= std_logic_vector(to_unsigned(ACCUMULATOR_MODE_ACCUMULATE, ACCUMULATOR_MODE_LENGTH));
            elsif sym_cntr = 13 then
                mode_inst <= std_logic_vector(to_unsigned(ACCUMULATOR_MODE_OVERRIDE, ACCUMULATOR_MODE_LENGTH));
            elsif sym_cntr = 14 then
                mode_inst <= std_logic_vector(to_unsigned(ACCUMULATOR_MODE_ACCUMULATE, ACCUMULATOR_MODE_LENGTH));
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 3 then
                result_out_ready_inst <= '1';
            end if;
        end if;
    end process;


    tb_vector_accumulator : entity work.vector_accumulator
    generic map (
        INPUT_DATA_WIDTH => INPUT_DATA_WIDTH,
        ACCUMULATOR_DATA_WIDTH => ACCUMULATOR_DATA_WIDTH,
        ACCUMULATOR_DEPTH => ACCUMULATOR_DEPTH,
        VECTOR_LENGTH => VECTOR_LENGTH,
        ACCUMULATOR_MODE_LENGTH => ACCUMULATOR_MODE_LENGTH
    )
    port map
    (
        clk => clk,
        rst => rst,
        
        mode => mode_inst,
        
        data_in => data_in_inst,
        data_in_valid => data_in_valid_inst,
        
        accumulator_write_address => write_address_inst,
        
        accumulator_read_address_valid => address_valid_inst,
        accumulator_read_address_ready => address_ready_inst,
        accumulator_read_address => read_address_inst,
        
        data_out_valid => result_out_valid_inst,
        data_out_ready => result_out_ready_inst,
        data_out => result_out_inst
    );


end Behavioral;
