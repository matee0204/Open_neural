----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/23/2026 06:31:44 PM
-- Design Name: 
-- Module Name: address_mapper - Behavioral
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

entity address_mapper is
    generic (
        ADDRESS_WIDTH : natural := 32;
        NUMBER_OF_REGISTER_BLOCKS : natural := 3;
        ORIG_BASE_ADDR : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS * ADDRESS_WIDTH - 1 downto 0) := (others => '0');
        ORIG_ADDR_MASK : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS * ADDRESS_WIDTH - 1 downto 0) := (others => '0');
        MOD_ADDR_OFFSET : std_logic_vector(NUMBER_OF_REGISTER_BLOCKS * ADDRESS_WIDTH - 1 downto 0) := (others => '0')
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        address_in_valid : in std_logic;
        address_in_ready : out std_logic;
        address_in : in std_logic_vector(ADDRESS_WIDTH - 1 downto 0);

        address_out_valid : out std_logic;
        address_out_ready : in std_logic;
        address_out : out std_logic_vector(ADDRESS_WIDTH - 1 downto 0)
    );
end address_mapper;

architecture Behavioral of address_mapper is
    signal address_valid_d : std_logic;
    signal mapped_address : std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
    signal pipeline_en : std_logic;
    signal address_valid : std_logic;
begin

    pipeline_en <= address_out_ready;
    address_in_ready <= pipeline_en and not rst;

    address_out_valid <= address_valid_d;

    process (clk, rst) begin
        if rst = '1' then
            address_valid_d <= '0';
        else
            if rising_edge(clk) then
                if pipeline_en = '1' then
                    address_valid_d <= address_in_valid and address_valid;
                end if;
            end if;
        end if;
    end process;

    address_out <= mapped_address;

    process (clk)
        variable reg_block_index : natural range 0 to NUMBER_OF_REGISTER_BLOCKS - 1;
        variable offset : std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
        variable mask : std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
        variable masked_address : std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
    begin
        if rising_edge(clk) then
            if pipeline_en = '1' then
                reg_block_index := target_slave(NUMBER_OF_REGISTER_BLOCKS, ADDRESS_WIDTH, ORIG_BASE_ADDR, ORIG_ADDR_MASK, address_in);
                offset := slv_slice(NUMBER_OF_REGISTER_BLOCKS, ADDRESS_WIDTH, MOD_ADDR_OFFSET, reg_block_index, ADDRESS_WIDTH);
                mask := slv_slice(NUMBER_OF_REGISTER_BLOCKS, ADDRESS_WIDTH, ORIG_ADDR_MASK, reg_block_index, ADDRESS_WIDTH);
                masked_address := address_in and mask;
                
                mapped_address <= std_logic_vector(unsigned(masked_address) + unsigned(offset));
            end if;
        end if;
    end process;

    process (address_in)
        variable valid : boolean;
    begin
        valid := is_address_valid(NUMBER_OF_REGISTER_BLOCKS, ADDRESS_WIDTH, ORIG_BASE_ADDR, ORIG_ADDR_MASK, address_in);
        
        if valid then
            address_valid <= '1';
        else
            address_valid <= '0';
        end if;
    end process;

end Behavioral;
