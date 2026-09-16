----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/11/2026 08:00:17 AM
-- Design Name: 
-- Module Name: neural_engine_dummy - Behavioral
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

entity neural_engine_dummy is
    generic (
        DATA_WIDTH : natural := 32;
        LED_WIDTH : natural := 8;
        MEMORY_ADDRESS_WIDTH : natural := 32;
        MEMORY_DATA_WIDTH : natural := 32
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        data_in_valid : in std_logic;
        data_in_ready : out std_logic;
        data_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);

        led_data_out : out std_logic_vector(LED_WIDTH - 1 downto 0);

        write_address_valid : out std_logic;
        write_address_ready : in std_logic;
        write_address : out std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);

        write_data_valid : out std_logic;
        write_data_ready : in std_logic;
        write_data : out std_logic_vector(MEMORY_DATA_WIDTH - 1 downto 0);

        read_address_valid : out std_logic;
        read_address_ready : in std_logic;
        read_address : out std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);

        read_data_valid : in std_logic;
        read_data_ready : out std_logic;
        read_data : in std_logic_vector(MEMORY_DATA_WIDTH - 1 downto 0)

    );
end neural_engine_dummy;

architecture Behavioral of neural_engine_dummy is

    attribute X_INTERFACE_PARAMETER : string;
    attribute X_INTERFACE_PARAMETER of rst : signal is "POLARITY ACTIVE_HIGH";

    constant READ_INDEX : natural := 1;
    constant WRITE_INDEX : natural := 0;
    constant ADDRESS_LENGTH_IN_DATA_IN : natural := 8;
    constant DATA_LENGTH_IN_DATA_IN : natural := 8;

    type demux_t is array(0 to 1) of std_logic_vector(ADDRESS_LENGTH_IN_DATA_IN - 1 downto 0);
    signal address_valid_demux : std_logic_vector(1 downto 0);
    signal address_demux : demux_t;
    signal data_valid_d : std_logic;
    signal data_d : std_logic_vector(DATA_LENGTH_IN_DATA_IN - 1 downto 0);
    signal data_in_ready_mux : std_logic;
    signal read_write : std_logic;
    signal address : std_logic_vector(ADDRESS_LENGTH_IN_DATA_IN - 1 downto 0);
    signal data : std_logic_vector(DATA_LENGTH_IN_DATA_IN - 1 downto 0);
begin

    led_data_out <= data_d(LED_WIDTH / 2 - 1 downto 0) & read_data(LED_WIDTH / 2 - 1 downto 0);

    read_write <= data_in(data_in'high);
    address <= data_in(data_in'high - 1 downto data_in'high - ADDRESS_LENGTH_IN_DATA_IN);
    data <= data_in(data_in'high - ADDRESS_LENGTH_IN_DATA_IN - 1 downto data_in'high - ADDRESS_LENGTH_IN_DATA_IN - DATA_LENGTH_IN_DATA_IN);

    write_data_valid <= data_valid_d;
    write_address_valid <= address_valid_demux(WRITE_INDEX);
    read_address_valid <= address_valid_demux(READ_INDEX);

    process (clk, rst) begin
        if rst = '1' then
            data_valid_d <= '0';
            address_valid_demux <= (others => '0');
        else
            if rising_edge(clk) then
                data_valid_d <= data_in_valid;
                address_valid_demux <= (others => '0');
                case read_write is
                    when to_unsigned(WRITE_INDEX, 1)(0) =>
                        address_valid_demux(WRITE_INDEX) <= data_in_valid;
                    when to_unsigned(READ_INDEX, 1)(0) =>
                        address_valid_demux(READ_INDEX) <= data_in_valid;
                    when others =>
                        address_valid_demux <= (others => '0');
                end case;
            end if;
        end if;
    end process;

    write_data <= (write_data'high downto DATA_LENGTH_IN_DATA_IN => '0') &  data_d;
    write_address <= (write_address'high downto ADDRESS_LENGTH_IN_DATA_IN => '0') & address_demux(WRITE_INDEX);
    read_address <= (read_address'high downto ADDRESS_LENGTH_IN_DATA_IN => '0') & address_demux(READ_INDEX);

    process (clk) begin
        if rising_edge(clk) then
            data_d <= data;
            address_demux <= (others => (others => '0'));
            case read_write is
                when to_unsigned(WRITE_INDEX, 1)(0) =>
                    address_demux(WRITE_INDEX) <= address;
                when to_unsigned(READ_INDEX, 1)(0) =>
                    address_demux(READ_INDEX) <= address;
                when others =>
                    address_demux <= (others => (others => '0'));
            end case;
        end if;
    end process;

    data_in_ready <= data_in_ready_mux;
    read_data_ready <= '1';
    
    process (clk) begin
        if rising_edge(clk) then
            case read_write is
                when to_unsigned(WRITE_INDEX, 1)(0) =>
                    data_in_ready_mux <= write_address_ready and write_data_ready;
                when to_unsigned(READ_INDEX, 1)(0) =>
                    data_in_ready_mux <= read_address_ready;
                when others =>
                    data_in_ready_mux <= '1';
            end case;
        end if;
    end process;

end Behavioral;
