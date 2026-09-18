----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/09/2026 04:06:40 PM
-- Design Name: 
-- Module Name: vector_bias_module - Behavioral
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

entity vector_bias_module is
    generic (
        BIAS_REGISTER_DEPTH : natural := 128;
        
        VECTOR_LENGTH : natural := 8;
        BIAS_DATA_WIDTH : natural := 8;
        INPUT_DATA_WIDTH : natural := 32;
        OUTPUT_DATA_WIDTH : natural := 32
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        bias_reg_read_address_valid : in std_logic;
        bias_reg_read_address_ready : out std_logic;
        bias_reg_read_address : in std_logic_vector(clog2(BIAS_REGISTER_DEPTH) - 1 downto 0);

        bias_reg_write_address_valid : in std_logic;
        bias_reg_write_address_ready : out std_logic;
        bias_reg_write_address : in std_logic_vector(clog2(BIAS_REGISTER_DEPTH) - 1 downto 0);

        bias_reg_data_in_valid : in std_logic;
        bias_reg_data_in_ready : out std_logic;
        bias_reg_data_in : in data_vector(0 to VECTOR_LENGTH - 1)(BIAS_DATA_WIDTH - 1 downto 0);

        bias_reg_data_out_valid : out std_logic;
        bias_reg_data_out_ready : in std_logic;
        bias_reg_data_out : out data_vector(0 to VECTOR_LENGTH - 1)(BIAS_DATA_WIDTH - 1 downto 0);

        bias_reg_address_valid : in std_logic;
        bias_reg_address_ready : out std_logic;
        bias_reg_address : in std_logic_vector(clog2(BIAS_REGISTER_DEPTH) - 1 downto 0);

        data_in_valid : in std_logic;
        data_in_ready : out std_logic;
        data_in : in data_vector_signed(0 to VECTOR_LENGTH - 1)(INPUT_DATA_WIDTH - 1 downto 0);

        data_out_valid : out std_logic;
        data_out_ready : in std_logic;
        data_out : out data_vector_signed(0 to VECTOR_LENGTH - 1)(OUTPUT_DATA_WIDTH - 1 downto 0)
    );
end vector_bias_module;

architecture Behavioral of vector_bias_module is
    signal bias_reg_read_write_address_out_valid_from_controller : std_logic; -- @suppress "Signal bias_reg_read_write_address_out_valid_from_controller is never read"
    signal bias_reg_read_write_address_out_from_controller : std_logic_vector(clog2(BIAS_REGISTER_DEPTH) - 1 downto 0);
    signal bias_reg_write_en_from_controller : std_logic;
    signal pipeline_en_out_from_controller : std_logic;
begin

    vector_bias_controller_inst : entity work.vector_bias_controller
        generic map (
            BIAS_REGISTER_DEPTH => BIAS_REGISTER_DEPTH
        )
        port map (
            clk                                   => clk,
            rst                                   => rst,
            pipeline_en_out                       => pipeline_en_out_from_controller,
            bias_reg_read_address_valid           => bias_reg_read_address_valid,
            bias_reg_read_address_ready           => bias_reg_read_address_ready,
            bias_reg_read_address                 => bias_reg_read_address,

            bias_reg_write_address_valid          => bias_reg_write_address_valid,
            bias_reg_write_address_ready          => bias_reg_write_address_ready,
            bias_reg_write_address                => bias_reg_write_address,

            bias_reg_read_write_address_out_valid => bias_reg_read_write_address_out_valid_from_controller,
            bias_reg_read_write_address_out_ready => '1',
            bias_reg_read_write_address_out       => bias_reg_read_write_address_out_from_controller,
            bias_reg_write_en                     => bias_reg_write_en_from_controller,
            
            bias_reg_data_in_valid                => bias_reg_data_in_valid,
            bias_reg_data_in_ready                => bias_reg_data_in_ready,

            bias_reg_data_out_valid               => bias_reg_data_out_valid,
            bias_reg_data_out_ready               => bias_reg_data_out_ready,

            bias_reg_address_valid                => bias_reg_address_valid,
            bias_reg_address_ready                => bias_reg_address_ready,
            
            data_in_valid                         => data_in_valid,
            data_in_ready                         => data_in_ready,
            data_out_valid                        => data_out_valid,
            data_out_ready                        => data_out_ready
        );
    

    vector_bias_inst : entity work.vector_bias
        generic map(
            BIAS_REGISTER_DEPTH => BIAS_REGISTER_DEPTH,
            VECTOR_LENGTH       => VECTOR_LENGTH,
            BIAS_DATA_WIDTH     => BIAS_DATA_WIDTH,
            INPUT_DATA_WIDTH    => INPUT_DATA_WIDTH,
            OUTPUT_DATA_WIDTH   => OUTPUT_DATA_WIDTH
        )
        port map(
            clk                         => clk,
            en                          => pipeline_en_out_from_controller,

            bias_reg_read_write_address => bias_reg_read_write_address_out_from_controller,
            bias_reg_write_en           => bias_reg_write_en_from_controller,
            bias_reg_data_in            => bias_reg_data_in,
            bias_reg_data_out           => bias_reg_data_out,

            bias_reg_address            => bias_reg_address,
            data_in                     => data_in,
            data_out                    => data_out
        );
    

end Behavioral;
