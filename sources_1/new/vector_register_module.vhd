----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/14/2026 03:38:24 PM
-- Design Name: 
-- Module Name: vector_register_module - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vector_register_module is
    generic (
        DATA_WIDTH : natural := 8;
        DEPTH : natural := 128;
        VECTOR_LENGTH : natural := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        register_read_address_valid : in std_logic;
        register_read_address_ready : out std_logic;
        register_read_address : in std_logic_vector(clog2(DEPTH) - 1 downto 0);
        
        register_read_data_valid : out std_logic;
        register_read_data_ready : in std_logic;
        register_read_data : out data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        register_write_address_valid : in std_logic;
        register_write_address_ready : out std_logic;
        register_write_address : in std_logic_vector(clog2(DEPTH) - 1 downto 0);
        
        register_write_data_valid : in std_logic;
        register_write_data_ready : out std_logic;
        register_write_data : in data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0)
    );
end vector_register_module;

architecture Behavioral of vector_register_module is
    signal register_write_en_from_controller : std_logic;
begin

    vector_register_controller_inst : entity work.vector_register_controller
        port map(
            clk                          => clk,
            rst                          => rst,
            register_read_address_valid  => register_read_address_valid,
            register_read_address_ready  => register_read_address_ready,
            register_read_data_valid     => register_read_data_valid,
            register_read_data_ready     => register_read_data_ready,
            register_write_address_valid => register_write_address_valid,
            register_write_address_ready => register_write_address_ready,
            register_write_data_valid    => register_write_data_valid,
            register_write_data_ready    => register_write_data_ready,
            register_write_en            => register_write_en_from_controller
        );
    

    vector_register_inst : entity work.vector_register(Read_first)
        generic map(
            DATA_WIDTH    => DATA_WIDTH,
            DEPTH         => DEPTH,
            VECTOR_LENGTH => VECTOR_LENGTH
        )
        port map(
            clk_A      => clk,
            en_A       => '1',
            wr_en_A    => register_write_en_from_controller,
            address_A  => register_write_address,
            data_in_A  => register_write_data,

            clk_B      => clk,
            en_B       => '1',
            wr_en_B    => '0',
            address_B  => register_read_address,
            data_in_B  => (others => (others => '0')),
            data_out_B => register_read_data
        );

end Behavioral;
