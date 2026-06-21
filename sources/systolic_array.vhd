----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/08/2026 05:47:22 PM
-- Design Name: 
-- Module Name: systolic_array - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity systolic_array is
    generic (
        SYS_ARRAY_SIZE : natural := 8;
        INPUT_DATA_WIDTH : natural := 8;
        OUTPUT_DATA_WIDTH : natural := 32;
        WEIGHT_REGISTER_DEPTH : natural := 2
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        weight_col_read_address_valid : in std_logic;
        weight_col_read_address_ready : out std_logic;
        weight_col_read_address : in std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH * SYS_ARRAY_SIZE) - 1 downto 0);

        weight_out_valid : out std_logic;
        weight_out_ready : in std_logic;
        weight_out : out data_vector(0 to SYS_ARRAY_SIZE - 1)(INPUT_DATA_WIDTH - 1 downto 0);

        weight_col_write_address_valid : in std_logic;
        weight_col_write_address_ready : out std_logic;
        weight_col_write_address : in std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH * SYS_ARRAY_SIZE) - 1 downto 0);

        weight_in_valid : in std_logic;
        weight_in_ready : out std_logic;
        weight_in : in data_vector(0 to SYS_ARRAY_SIZE - 1)(INPUT_DATA_WIDTH - 1 downto 0);
        
        selected_weight_bank_valid : in std_logic;
        selected_weight_bank_ready : out std_logic;
        selected_weight_bank : in std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH) - 1 downto 0);
        
        data_in_valid : in std_logic;
        data_in_ready : out std_logic;
        data_in : in data_vector(0 to SYS_ARRAY_SIZE - 1)(INPUT_DATA_WIDTH - 1 downto 0);
        
        result_out_valid : out std_logic;
        result_out_ready : in std_logic;
        result_out : out data_vector(0 to SYS_ARRAY_SIZE - 1)(OUTPUT_DATA_WIDTH - 1 downto 0)
    );
end systolic_array;

architecture Behavioral of systolic_array is
    signal systolic_array_enable : std_logic;
    signal weight_col_address_valid_out_from_controller : std_logic; -- @suppress "Signal weight_col_address_valid_out_from_controller is never read"
    signal weight_col_address_out_from_controller : std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH * SYS_ARRAY_SIZE) - 1 downto 0);
    signal selected_weight_address_from_controller : std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH) - 1 downto 0);
    signal weight_write_en_out_from_controller : std_logic;
begin

    systolic_array_controller_inst : entity work.systolic_array_controller
        generic map(
            SYS_ARRAY_SIZE       => SYS_ARRAY_SIZE,
            WEIGHT_REGISTER_DEPTH => WEIGHT_REGISTER_DEPTH
        )
        port map(
            clk                            => clk,
            rst                            => rst,

            pipeline_en                    => systolic_array_enable,

            weight_col_read_address_valid  => weight_col_read_address_valid,
            weight_col_read_address_ready  => weight_col_read_address_ready,
            weight_col_read_address        => weight_col_read_address,

            weight_col_write_address_valid => weight_col_write_address_valid,
            weight_col_write_address_ready => weight_col_write_address_ready,
            weight_col_write_address       => weight_col_write_address,

            weight_col_address_valid_out   => weight_col_address_valid_out_from_controller,
            weight_col_address_ready_in    => '1',
            weight_col_address_out         => weight_col_address_out_from_controller,
            weight_write_en_out            => weight_write_en_out_from_controller,

            weight_in_valid                => weight_in_valid,
            weight_in_ready                => weight_in_ready,
        
            weight_out_valid               => weight_out_valid,
            weight_out_ready               => weight_out_ready,

            selected_weight_bank_valid     => selected_weight_bank_valid,
            selected_weight_bank_ready     => selected_weight_bank_ready,
            selected_weight_bank           => selected_weight_bank,

            selected_weight_bank_out       => selected_weight_address_from_controller,
            
            data_in_valid                  => data_in_valid,
            data_in_ready                  => data_in_ready,

            result_out_valid               => result_out_valid,
            result_out_ready               => result_out_ready
        );
    

    systolic_array_block_inst : entity work.systolic_array_block
        generic map (
            SYS_ARRAY_SIZE => SYS_ARRAY_SIZE,
            INPUT_DATA_WIDTH => INPUT_DATA_WIDTH,
            OUTPUT_DATA_WIDTH => OUTPUT_DATA_WIDTH,
            WEIGHT_REGISTER_DEPTH => WEIGHT_REGISTER_DEPTH
        )
        port map (
            clk => clk,
            en => systolic_array_enable,
        
            weight_write_en => weight_write_en_out_from_controller,
            weight_in => weight_in,
            weight_out => weight_out,
            weight_col_address => weight_col_address_out_from_controller,
            
            selected_weight_bank => selected_weight_address_from_controller,
            
            data_in => data_in,
            
            result_out => result_out
        );

end Behavioral;
