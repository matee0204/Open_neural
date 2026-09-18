----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 03/31/2026 08:45:04 PM
-- Design Name:
-- Module Name: pipeline_mov - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity memory_write_interface is
    generic (
        WRITE_ADDRESS_LENGTH : natural := 16;
        VECTOR_LENGTH : natural := 8;
        DATA_WIDTH : natural := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        write_address_in_valid : in std_logic;
        write_address_in_ready : out std_logic;
        write_address_in : in std_logic_vector(WRITE_ADDRESS_LENGTH - 1 downto 0);

        read_data_in_valid : in std_logic;
        read_data_in_ready : out std_logic;
        read_data_in : in data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);

        write_address_out_valid : out std_logic;
        write_address_out_ready : in std_logic;
        write_address_out : out std_logic_vector(WRITE_ADDRESS_LENGTH - 1 downto 0);

        write_data_out_valid : out std_logic;
        write_data_out_ready : in std_logic;
        write_data_out : out data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0)
    );
end memory_write_interface;

architecture Behavioral of memory_write_interface is
    signal pipeline_en : std_logic;
    signal wait_for_data : std_logic;
    signal reg_address_d : std_logic_vector(WRITE_ADDRESS_LENGTH - 1 downto 0);
    signal reg_address_valid_d : std_logic;
    signal reg_data_d : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
    signal reg_data_valid_d : std_logic;
begin

    pipeline_en <= write_data_out_ready and write_address_out_ready;
    wait_for_data <= write_address_in_valid and not read_data_in_valid;
    write_address_in_ready <= pipeline_en and not wait_for_data;
    read_data_in_ready <= pipeline_en;

    write_address_out_valid <= reg_address_valid_d;
    write_data_out_valid <= reg_data_valid_d;

    process (clk, rst) begin
        if rst = '1' then
            reg_address_valid_d <= '0';
            reg_data_valid_d <= '0';
        elsif rising_edge(clk) then
            if pipeline_en = '1' then
                reg_address_valid_d <= write_address_in_valid and not wait_for_data;
                reg_data_valid_d <= read_data_in_valid;
            else
                reg_address_valid_d <= reg_address_valid_d;
                reg_data_valid_d <= reg_data_valid_d;
            end if;
        end if;
    end process;

    write_address_out <= reg_address_d;
    write_data_out <= reg_data_d;

    process (clk) begin
        if rising_edge(clk) then
            if pipeline_en = '1' then
                reg_address_d <= write_address_in;
                reg_data_d <= read_data_in;
            else
                reg_address_d <= reg_address_d;
                reg_data_d <= reg_data_d;
            end if;
        end if;
    end process;

end Behavioral;
