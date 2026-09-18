----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/09/2026 04:40:19 PM
-- Design Name: 
-- Module Name: vector_bias_module_test - Behavioral
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
use work.utilities.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vector_bias_module_test is
end vector_bias_module_test;

architecture Behavioral of vector_bias_module_test is
    constant BIAS_REGISTER_DEPTH : natural := 128;

    constant VECTOR_LENGTH : natural := 8;
    constant BIAS_DATA_WIDTH : natural := 8;
    constant INPUT_DATA_WIDTH : natural := 32;
    constant OUTPUT_DATA_WIDTH : natural := 32;

    signal clk                               : std_logic;
    signal rst                               : std_logic;

    signal sym_cntr : natural := 0;

    signal bias_reg_read_address_valid_inst  : std_logic;
    signal bias_reg_read_address_ready_inst  : std_logic; -- @suppress "Signal bias_reg_read_address_ready_inst is never read"
    signal bias_reg_read_address_inst        : std_logic_vector(clog2(BIAS_REGISTER_DEPTH) - 1 downto 0);

    signal bias_reg_write_address_valid_inst : std_logic;
    signal bias_reg_write_address_ready_inst : std_logic; -- @suppress "Signal bias_reg_write_address_ready_inst is never read"
    signal bias_reg_write_address_inst       : std_logic_vector(clog2(BIAS_REGISTER_DEPTH) - 1 downto 0);

    signal bias_reg_data_in_valid_inst       : std_logic;
    signal bias_reg_data_in_ready_inst       : std_logic; -- @suppress "Signal bias_reg_data_in_ready_inst is never read"
    signal bias_reg_data_in_inst             : data_vector(0 to VECTOR_LENGTH - 1)(BIAS_DATA_WIDTH - 1 downto 0);

    signal bias_reg_address_valid_inst       : std_logic;
    signal bias_reg_address_ready_inst       : std_logic; -- @suppress "Signal bias_reg_address_ready_inst is never read"
    signal bias_reg_address_inst             : std_logic_vector(clog2(BIAS_REGISTER_DEPTH) - 1 downto 0);

    signal bias_reg_data_out_valid_inst      : std_logic; -- @suppress "Signal bias_reg_data_out_valid_inst is never read"
    signal bias_reg_data_out_ready_inst      : std_logic;
    signal bias_reg_data_out_inst            : data_vector(0 to VECTOR_LENGTH - 1)(BIAS_DATA_WIDTH - 1 downto 0); -- @suppress "Signal bias_reg_data_out_inst is never read"

    signal data_in_valid_inst                : std_logic;
    signal data_in_ready_inst                : std_logic; -- @suppress "Signal data_in_ready_inst is never read"
    signal data_in_inst                      : data_vector_signed(0 to VECTOR_LENGTH - 1)(INPUT_DATA_WIDTH - 1 downto 0);

    signal data_out_valid_inst               : std_logic; -- @suppress "Signal data_out_valid_inst is never read"
    signal data_out_ready_inst               : std_logic;
    signal data_out_inst                     : data_vector_signed(0 to VECTOR_LENGTH - 1)(OUTPUT_DATA_WIDTH - 1 downto 0); -- @suppress "Signal data_out_inst is never read"
begin

    process begin
        clk <= '0';
        wait for 1 ns;
        clk <= '1';
        wait for 1 ns;
    end process;
    
    process begin
        rst <= '1';
        wait for 10 ns;
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
                data_out_ready_inst <= '1';
                bias_reg_data_out_ready_inst <= '1';
            elsif sym_cntr = 14 then
                data_out_ready_inst <= '0';
            elsif sym_cntr = 15 then
                data_out_ready_inst <= '1';
                bias_reg_data_out_ready_inst <= '0';
            elsif sym_cntr = 16 then
                bias_reg_data_out_ready_inst <= '1';
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 4 then
                bias_reg_read_address_valid_inst <= '0';
                bias_reg_write_address_valid_inst <= '0';
                bias_reg_data_in_valid_inst <= '0';
                bias_reg_address_valid_inst <= '0';
                data_in_valid_inst <= '0';
            elsif sym_cntr = 5 then
                bias_reg_write_address_valid_inst <= '1';
                bias_reg_data_in_valid_inst <= '1';
            elsif sym_cntr = 6 then
                bias_reg_write_address_valid_inst <= '0';
                bias_reg_data_in_valid_inst <= '0';
                data_in_valid_inst <= '1';
            elsif sym_cntr = 7 then
                data_in_valid_inst <= '0';
            elsif sym_cntr = 10 then
                bias_reg_read_address_valid_inst <= '1';
            elsif sym_cntr = 12 then
                bias_reg_read_address_valid_inst <= '0';
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 4 then
                bias_reg_read_address_inst <= (others => '0');
                bias_reg_write_address_inst <= (others => '0');
                bias_reg_data_in_inst <= (others => (others => '0'));
                bias_reg_address_inst <= (others => '0');
                data_in_inst <= (others => (others => '0'));
            elsif sym_cntr = 5 then
                bias_reg_read_address_inst <= std_logic_vector(to_unsigned(1, clog2(BIAS_REGISTER_DEPTH)));
                bias_reg_data_in_inst <= (others => std_logic_vector(to_unsigned(1, BIAS_DATA_WIDTH)));
            elsif sym_cntr = 6 then
                data_in_inst <= (others => to_signed(2, INPUT_DATA_WIDTH));
            elsif sym_cntr = 11 then
                bias_reg_read_address_inst <= std_logic_vector(to_unsigned(0, clog2(BIAS_REGISTER_DEPTH)));
            elsif sym_cntr = 14 then
                bias_reg_read_address_inst <= std_logic_vector(to_unsigned(1, clog2(BIAS_REGISTER_DEPTH)));
                bias_reg_address_inst <= std_logic_vector(to_unsigned(1, clog2(BIAS_REGISTER_DEPTH)));
                bias_reg_data_in_inst <= (others => std_logic_vector(to_unsigned(2, BIAS_DATA_WIDTH)));
            end if;
        end if;
    end process;

    tb_vector_bias_module : entity work.vector_bias_module
        generic map(
            BIAS_REGISTER_DEPTH => BIAS_REGISTER_DEPTH,
            VECTOR_LENGTH       => VECTOR_LENGTH,
            BIAS_DATA_WIDTH     => BIAS_DATA_WIDTH,
            INPUT_DATA_WIDTH    => INPUT_DATA_WIDTH,
            OUTPUT_DATA_WIDTH   => OUTPUT_DATA_WIDTH
        )
        port map(
            clk                          => clk,
            rst                          => rst,

            bias_reg_read_address_valid  => bias_reg_read_address_valid_inst,
            bias_reg_read_address_ready  => bias_reg_read_address_ready_inst,
            bias_reg_read_address        => bias_reg_read_address_inst,

            bias_reg_write_address_valid => bias_reg_write_address_valid_inst,
            bias_reg_write_address_ready => bias_reg_write_address_ready_inst,
            bias_reg_write_address       => bias_reg_write_address_inst,

            bias_reg_data_in_valid       => bias_reg_data_in_valid_inst,
            bias_reg_data_in_ready       => bias_reg_data_in_ready_inst,
            bias_reg_data_in             => bias_reg_data_in_inst,

            bias_reg_address_valid       => bias_reg_address_valid_inst,
            bias_reg_address_ready       => bias_reg_address_ready_inst,
            bias_reg_address             => bias_reg_address_inst,

            bias_reg_data_out_valid      => bias_reg_data_out_valid_inst,
            bias_reg_data_out_ready      => bias_reg_data_out_ready_inst,
            bias_reg_data_out            => bias_reg_data_out_inst,

            data_in_valid                => data_in_valid_inst,
            data_in_ready                => data_in_ready_inst,
            data_in                      => data_in_inst,

            data_out_valid               => data_out_valid_inst,
            data_out_ready               => data_out_ready_inst,
            data_out                     => data_out_inst
        );
    

end Behavioral;
