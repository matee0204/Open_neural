----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/12/2026 01:36:44 PM
-- Design Name: 
-- Module Name: scoreboard_module - Behavioral
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

entity scoreboard_module is
    generic (
        NUM_OF_REGISTERS : natural := 128;
        ADDRESS_LENGTH : natural := 16
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        pipeline_ready : in std_logic;
        
        read_address1_valid : in std_logic;
        read_address1_ready : out std_logic;
        read_address1 : in std_logic_vector(ADDRESS_LENGTH - 1 downto 0);
        
        read_address2_valid : in std_logic;
        read_address2_ready : out std_logic;
        read_address2 : in std_logic_vector(ADDRESS_LENGTH - 1 downto 0);
        
        read_address3_valid : in std_logic;
        read_address3_ready : out std_logic;
        read_address3 : in std_logic_vector(ADDRESS_LENGTH - 1 downto 0);
        
        write_address_valid : in std_logic;
        write_address_ready : out std_logic;
        write_address : in std_logic_vector(ADDRESS_LENGTH - 1 downto 0);
        
        dst_address_valid : in std_logic;
        dst_address_ready : out std_logic;
        dst_address : in std_logic_vector(ADDRESS_LENGTH - 1 downto 0);
        dst_write_ready : in std_logic
    );
end scoreboard_module;

architecture Behavioral of scoreboard_module is
    signal scoreboard : std_logic_vector(NUM_OF_REGISTERS - 1 downto 0);
    signal scoreboard_read1_out : std_logic;
    signal scoreboard_read2_out : std_logic;
    signal scoreboard_read3_out : std_logic;
    signal scoreboard_write_out : std_logic;
begin

    process (clk, rst) begin
        if rst = '1' then
            scoreboard <= (others => '0');
        else
            if rising_edge(clk) then
                if dst_address_valid = '1' and dst_write_ready = '1' then
                    scoreboard(to_integer(unsigned(dst_address))) <= '0';
                end if;
                if write_address_valid = '1' and scoreboard_write_out = '0' and pipeline_ready = '1' then
                    scoreboard(to_integer(unsigned(write_address))) <= '1';
                end if;
            end if;
        end if;
    end process;
    
    read_address1_ready <= not scoreboard_read1_out and not rst;
    read_address2_ready <= not scoreboard_read2_out and not rst;
    read_address3_ready <= not scoreboard_read3_out and not rst;
    write_address_ready <= not scoreboard_write_out and not rst;
    dst_address_ready <= not rst;
    
    process (scoreboard, read_address1, read_address2, read_address3, write_address, read_address1_valid, read_address2_valid, read_address3_valid, write_address_valid) begin
        scoreboard_read1_out <= scoreboard(to_integer(unsigned(read_address1))) and read_address1_valid;
        scoreboard_read2_out <= scoreboard(to_integer(unsigned(read_address2))) and read_address2_valid;
        scoreboard_read3_out <= scoreboard(to_integer(unsigned(read_address3))) and read_address3_valid;
        scoreboard_write_out <= scoreboard(to_integer(unsigned(write_address))) and write_address_valid;
    end process;

end Behavioral;
