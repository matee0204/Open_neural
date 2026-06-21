----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/14/2026 10:17:02 AM
-- Design Name: 
-- Module Name: bus_interconnect_test - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bus_interconnect_test is
end bus_interconnect_test;

architecture Behavioral of bus_interconnect_test is
    constant ADDRESS_WIDTH : natural := 8;
    constant DATA_WIDTH : natural := 8;
    constant NUMBER_OF_SLAVES : natural := 3;
    constant DEFAULT_SLAVE   : natural  := 0;
    constant SLAVE_BASE_ADDR : std_logic_vector(NUMBER_OF_SLAVES * ADDRESS_WIDTH - 1 downto 0) := x"804000";
    constant SLAVE_ADDR_MASK : std_logic_vector(NUMBER_OF_SLAVES * ADDRESS_WIDTH - 1 downto 0) := x"7F3F3F";

    signal clk : std_logic;
    signal rst : std_logic;
        
    signal sym_cntr : natural := 0;

    signal address_read_valid_inst  :  std_logic;
    signal address_read_ready_inst  : std_logic;
    signal address_read_inst        : std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
    signal data_read_valid_inst     : std_logic;
    signal data_read_ready_inst     :  std_logic;
    signal data_read_inst           : std_logic_vector(DATA_WIDTH - 1 downto 0);

    signal address_write_valid_inst :  std_logic;
    signal address_write_ready_inst : std_logic;
    signal address_write_inst       :  std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
    signal data_write_valid_inst    :  std_logic;
    signal data_write_ready_inst    : std_logic;
    signal data_write_inst          :  std_logic_vector(DATA_WIDTH - 1 downto 0);

    signal s_address_read_valid_inst : std_logic_vector(NUMBER_OF_SLAVES - 1 downto 0);
    signal s_address_read_ready_inst :  std_logic_vector(NUMBER_OF_SLAVES - 1 downto 0);
    signal s_address_read_inst       : std_logic_vector(NUMBER_OF_SLAVES * ADDRESS_WIDTH - 1 downto 0);
    signal s_data_read_valid_inst    : std_logic_vector(NUMBER_OF_SLAVES - 1 downto 0);
    signal s_data_read_ready_inst    : std_logic_vector(NUMBER_OF_SLAVES - 1 downto 0);
    signal s_data_read_inst          :  std_logic_vector(NUMBER_OF_SLAVES * DATA_WIDTH - 1 downto 0);

    signal s_address_write_valid_inst : std_logic_vector(NUMBER_OF_SLAVES - 1 downto 0);
    signal s_address_write_ready_inst :  std_logic_vector(NUMBER_OF_SLAVES - 1 downto 0);
    signal s_address_write_inst       : std_logic_vector(NUMBER_OF_SLAVES * ADDRESS_WIDTH - 1 downto 0);
    signal s_data_write_valid_inst    : std_logic_vector(NUMBER_OF_SLAVES - 1 downto 0);
    signal s_data_write_ready_inst    :  std_logic_vector(NUMBER_OF_SLAVES - 1 downto 0);
    signal s_data_write_inst          : std_logic_vector(NUMBER_OF_SLAVES * DATA_WIDTH - 1 downto 0);

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
                data_read_ready_inst <= '1';
                s_address_read_ready_inst <= (others => '1');
                s_address_write_ready_inst <= (others => '1');
                s_data_write_ready_inst <= (others => '1');
            elsif sym_cntr = 14 then
                s_address_write_ready_inst <= b"110";
            elsif sym_cntr = 15 then
                s_address_write_ready_inst <= b"111";
                s_data_write_ready_inst <= b"110";
            elsif sym_cntr = 16 then
                s_data_write_ready_inst <= b"111";
            elsif sym_cntr = 20 then
                s_address_read_ready_inst <= b"110";
            elsif sym_cntr = 21 then
                s_address_read_ready_inst <= b"111";
                data_read_ready_inst <= '0';
            elsif sym_cntr = 22 then
                data_read_ready_inst <= '1';
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 4 then
                address_read_valid_inst <= '0';
                address_write_valid_inst <= '0';
                data_write_valid_inst <= '0';
                s_data_read_valid_inst <= (others => '0');
            elsif sym_cntr = 6 then
                address_write_valid_inst <= '1';
                data_write_valid_inst <= '1';
            elsif sym_cntr = 7 then
                address_write_valid_inst <= '0';
                data_write_valid_inst <= '0';
            elsif sym_cntr = 9 then
                address_read_valid_inst <= '1';
            elsif sym_cntr = 10 then
                address_read_valid_inst <= '0';
            elsif sym_cntr = 11 then
                s_data_read_valid_inst <= b"001";
            elsif sym_cntr = 12 then
                s_data_read_valid_inst <= b"000";
            elsif sym_cntr = 14 then
                address_write_valid_inst <= '1';
                data_write_valid_inst <= '1';
            elsif sym_cntr = 16 then
                address_write_valid_inst <= '0';
                data_write_valid_inst <= '0';
            elsif sym_cntr = 20 then
                address_read_valid_inst <= '1';
                s_data_read_valid_inst <= b"001";
            elsif sym_cntr = 22 then
                address_read_valid_inst <= '0';
                s_data_read_valid_inst <= b"000";
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                address_read_inst <= (others => '0');
                address_write_inst <= (others => '0');
                data_write_inst <= (others => '0');
                s_data_read_inst <= (others => '0');
            elsif sym_cntr = 6 then
                address_write_inst <= x"01";
                data_write_inst <= x"02";
            end if;
        end if;
    end process;

    tb_bus_interconnect : entity work.bus_interconnect
        generic map(
            ADDRESS_WIDTH    => ADDRESS_WIDTH,
            DATA_WIDTH       => DATA_WIDTH,
            NUMBER_OF_SLAVES => NUMBER_OF_SLAVES,
            DEFAULT_SLAVE    => DEFAULT_SLAVE,
            SLAVE_BASE_ADDR  => SLAVE_BASE_ADDR,
            SLAVE_ADDR_MASK  => SLAVE_ADDR_MASK
        )
        port map(
            clk                   => clk,
            rst                   => rst,
            address_read_valid    => address_read_valid_inst,
            address_read_ready    => address_read_ready_inst,
            address_read          => address_read_inst,
            data_read_valid       => data_read_valid_inst,
            data_read_ready       => data_read_ready_inst,
            data_read             => data_read_inst,
            address_write_valid   => address_write_valid_inst,
            address_write_ready   => address_write_ready_inst,
            address_write         => address_write_inst,
            data_write_valid      => data_write_valid_inst,
            data_write_ready      => data_write_ready_inst,
            data_write            => data_write_inst,
            s_address_read_valid  => s_address_read_valid_inst,
            s_address_read_ready  => s_address_read_ready_inst,
            s_address_read        => s_address_read_inst,
            s_data_read_valid     => s_data_read_valid_inst,
            s_data_read_ready     => s_data_read_ready_inst,
            s_data_read           => s_data_read_inst,
            s_address_write_valid => s_address_write_valid_inst,
            s_address_write_ready => s_address_write_ready_inst,
            s_address_write       => s_address_write_inst,
            s_data_write_valid    => s_data_write_valid_inst,
            s_data_write_ready    => s_data_write_ready_inst,
            s_data_write          => s_data_write_inst
        );
    

end Behavioral;
