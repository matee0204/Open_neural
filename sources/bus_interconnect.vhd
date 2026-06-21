----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/13/2026 11:23:52 PM
-- Design Name: 
-- Module Name: bus_interconnect - Behavioral
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

entity bus_interconnect is
    generic (
        ADDRESS_WIDTH : natural := 32;
        DATA_WIDTH : natural := 8;
        NUMBER_OF_SLAVES : natural := 3;
        DEFAULT_SLAVE   : natural  := 0;
        SLAVE_BASE_ADDR : std_logic_vector(NUMBER_OF_SLAVES * ADDRESS_WIDTH - 1 downto 0) := (others => '0');
        SLAVE_ADDR_MASK : std_logic_vector(NUMBER_OF_SLAVES * ADDRESS_WIDTH - 1 downto 0) := (others => '0')
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        address_read_valid : in  std_logic;
        address_read_ready : out std_logic;
        address_read       : in  std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
        data_read_valid    : out std_logic;
        data_read_ready    : in  std_logic;
        data_read          : out std_logic_vector(DATA_WIDTH - 1 downto 0);

        address_write_valid : in  std_logic;
        address_write_ready : out std_logic;
        address_write       : in  std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
        data_write_valid    : in  std_logic;
        data_write_ready    : out std_logic;
        data_write          : in  std_logic_vector(DATA_WIDTH - 1 downto 0);

        s_address_read_valid : out std_logic_vector(NUMBER_OF_SLAVES - 1 downto 0);
        s_address_read_ready : in  std_logic_vector(NUMBER_OF_SLAVES - 1 downto 0);
        s_address_read       : out std_logic_vector(NUMBER_OF_SLAVES * ADDRESS_WIDTH - 1 downto 0);
        s_data_read_valid    : in  std_logic_vector(NUMBER_OF_SLAVES - 1 downto 0);
        s_data_read_ready    : out std_logic_vector(NUMBER_OF_SLAVES - 1 downto 0);
        s_data_read          : in  std_logic_vector(NUMBER_OF_SLAVES * DATA_WIDTH - 1 downto 0);

        s_address_write_valid : out std_logic_vector(NUMBER_OF_SLAVES - 1 downto 0);
        s_address_write_ready : in  std_logic_vector(NUMBER_OF_SLAVES - 1 downto 0);
        s_address_write       : out std_logic_vector(NUMBER_OF_SLAVES * ADDRESS_WIDTH - 1 downto 0);
        s_data_write_valid    : out std_logic_vector(NUMBER_OF_SLAVES - 1 downto 0);
        s_data_write_ready    : in  std_logic_vector(NUMBER_OF_SLAVES - 1 downto 0);
        s_data_write          : out std_logic_vector(NUMBER_OF_SLAVES * DATA_WIDTH - 1 downto 0);

        address_writeback_valid : out std_logic;
        address_writeback_ready : in std_logic;
        address_writeback : out std_logic_vector(ADDRESS_WIDTH - 1 downto 0)
    );
end bus_interconnect;

architecture Behavioral of bus_interconnect is

    signal pipeline_write_en : std_logic;
    signal pipeline_read_en : std_logic;

    function slv_slice (
        v     : std_logic_vector;
        index : natural;
        width : positive
    ) return std_logic_vector is
        variable r : std_logic_vector(width - 1 downto 0);
        variable l : natural range 0 to NUMBER_OF_SLAVES * ADDRESS_WIDTH - 1;
    begin
        l := index * width;
        r := v(l + width - 1 downto l);
        return r;
    end function;

    function address_hits_window(
        addr : std_logic_vector;
        base : std_logic_vector;
        mask : std_logic_vector
    ) return boolean is
    begin
        return (addr and not mask) = (base and not mask);
    end function;

    function target_slave(addr : std_logic_vector(ADDRESS_WIDTH - 1 downto 0)) return natural is
        variable base : std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
        variable mask : std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
    begin
        for s in 0 to NUMBER_OF_SLAVES - 1 loop
            base := slv_slice(SLAVE_BASE_ADDR, s, ADDRESS_WIDTH);
            mask := slv_slice(SLAVE_ADDR_MASK, s, ADDRESS_WIDTH);
            if address_hits_window(addr, base, mask) then
                return s;
            end if;
        end loop;

        if DEFAULT_SLAVE < NUMBER_OF_SLAVES then
            return DEFAULT_SLAVE;
        end if;

        return 0;
    end function;

begin

    process (clk, rst)
        variable read_sel  : natural range 0 to NUMBER_OF_SLAVES - 1;
        variable write_sel : natural range 0 to NUMBER_OF_SLAVES - 1;
    begin
        if (rst) then
            s_address_write_valid <= (others => '0');
            s_address_read_valid <= (others => '0');
            s_data_write_valid <= (others => '0');
            data_read_valid <= '0';
            address_writeback_valid <= '0';
        else
            if rising_edge(clk) then
                read_sel  := target_slave(address_read);
                write_sel := target_slave(address_write);

                s_address_read_valid <= (others => '0');
                if pipeline_read_en = '1' then
                    s_address_read_valid(read_sel) <= address_read_valid;
                    data_read_valid <= '0';
                    for s in 0 to NUMBER_OF_SLAVES - 1 loop
                        if s_data_read_valid(s) = '1' then
                            data_read_valid <= '1';
                        end if;
                    end loop;
                end if;

                s_address_write_valid <= (others => '0');
                s_data_write_valid <= (others => '0');
                if pipeline_write_en = '1' then
                    s_address_write_valid(write_sel) <= address_write_valid and data_write_valid;
                    s_data_write_valid(write_sel) <= address_write_valid and data_write_valid;
                    address_writeback_valid <= address_write_valid and data_write_valid;
                end if;
            end if;
        end if;
    end process;

    process (clk)
        variable read_sel  : natural range 0 to NUMBER_OF_SLAVES - 1;
        variable write_sel : natural range 0 to NUMBER_OF_SLAVES - 1;
    begin
        if rising_edge(clk) then
            read_sel  := target_slave(address_read);
            write_sel := target_slave(address_write);

            s_address_read((read_sel + 1) * ADDRESS_WIDTH - 1 downto read_sel * ADDRESS_WIDTH) <= address_read;

            data_read <= (others => '0');
            for s in 0 to NUMBER_OF_SLAVES - 1 loop
                if s_data_read_valid(s) = '1' then
                    data_read <= s_data_read((s + 1) * DATA_WIDTH - 1 downto s * DATA_WIDTH);
                end if;
            end loop;

            s_address_write((write_sel + 1) * ADDRESS_WIDTH - 1 downto write_sel * ADDRESS_WIDTH) <= address_write;
            s_data_write((write_sel + 1) * DATA_WIDTH - 1 downto write_sel * DATA_WIDTH) <= data_write;
            address_writeback <= address_write;
        end if;
    end process;

    process (s_address_read_ready, s_address_write_ready, address_writeback_ready, rst, address_read, address_write, data_read_ready, s_data_read_valid, s_data_write_ready)
        variable read_sel  : natural range 0 to NUMBER_OF_SLAVES - 1;
        variable write_sel : natural range 0 to NUMBER_OF_SLAVES - 1;
    begin
        read_sel  := target_slave(address_read);
        write_sel := target_slave(address_write);

        pipeline_write_en <= s_address_write_ready(write_sel) and s_data_write_ready(write_sel) and address_writeback_ready;
        pipeline_read_en <= s_address_read_ready(read_sel) and data_read_ready;
        
        address_read_ready <= s_address_read_ready(read_sel) and not rst;
        address_write_ready <= s_address_write_ready(write_sel) and not rst;
        data_write_ready <= s_data_write_ready(write_sel) and not rst;
        for s in 0 to NUMBER_OF_SLAVES - 1 loop
            if s_data_read_valid(s) = '1' then
                s_data_read_ready(s) <= data_read_ready;
            else
                s_data_read_ready(s) <= '1';
            end if;
        end loop;
    end process;

end Behavioral;
