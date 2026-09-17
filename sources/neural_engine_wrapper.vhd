----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/08/2026 05:47:50 PM
-- Design Name: 
-- Module Name: neural_engine_wrapper - Behavioral
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
use work.common_constants.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity neural_engine_wrapper is
    generic (
        INSTRUCTION_LENGTH                   : natural := 64;
        OPERATION_CODE_WIDTH                 : natural := 7;
        MEMORY_ADDRESS_WIDTH                 : natural := 32;
        REGISTER_ADDRESS_WIDTH               : natural := 16;
        REGISTER_ARRAY_DEPTH                 : natural := 128;
        CONTROL_SIGNAL_FIFO_DEPTH            : natural := 16;
        SYSTOLIC_ARRAY_WEIGHT_ADDRESS_WIDTH  : natural := 8;
        BIAS_ADDRESS_WIDTH                   : natural := 8;
        BIAS_REGISTER_DEPTH                  : natural := 128;
        BIAS_OUTPUT_DATA_WIDTH               : natural := 32;
        ACCUMULATOR_ADDRESS_WIDTH            : natural := 8;
        ACCUMULATOR_DEPTH                    : natural := 128;
        ACCUMULATOR_OUTPUT_DATA_WIDTH        : natural := 32;
        ACCUMULATOR_MODE_LENGTH              : natural := 3;
        RESIZE_MODE_LENGTH                   : natural := 3;
        NUM_OF_ACCUMULATOR_REGISTERS         : natural := 32;
        DATA_WIDTH                           : natural := 8;
        SYSTOLIC_ARRAY_SIZE                  : natural := 8;
        SYSTOLIC_ARRAY_OUTPUT_DATA_WIDTH     : natural := 24;
        SYSTOLIC_ARRAY_WEIGHT_REGISTER_DEPTH : natural := 2
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        instruction_valid : in std_logic;
        instruction_ready : out std_logic;
        instruction : in std_logic_vector(INSTRUCTION_LENGTH - 1 downto 0);

        memory_write_address_out_valid : out std_logic;
        memory_write_address_out_ready : in std_logic;
        memory_write_address_out : out std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);

        memory_write_data_out_valid : out std_logic;
        memory_write_data_out_ready : in std_logic;
        memory_write_data_out : out std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto 0);

        memory_read_address_out_valid : out std_logic;
        memory_read_address_out_ready : in std_logic;
        memory_read_address_out : out std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);

        memory_read_data_in_valid : in std_logic;
        memory_read_data_in_ready : out std_logic;
        memory_read_data_in : in std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto 0)
    );
end neural_engine_wrapper;

architecture Behavioral of neural_engine_wrapper is
    
    attribute X_INTERFACE_PARAMETER : string;
    attribute X_INTERFACE_PARAMETER of rst : signal is "POLARITY ACTIVE_HIGH";

begin

    neural_engine_top_inst : entity work.neural_engine_top
        generic map(
            INSTRUCTION_LENGTH                   => INSTRUCTION_LENGTH,
            OPERATION_CODE_WIDTH                 => OPERATION_CODE_WIDTH,
            MEMORY_ADDRESS_WIDTH                 => MEMORY_ADDRESS_WIDTH,
            REGISTER_ADDRESS_WIDTH               => REGISTER_ADDRESS_WIDTH,
            REGISTER_ARRAY_DEPTH                 => REGISTER_ARRAY_DEPTH,
            CONTROL_SIGNAL_FIFO_DEPTH            => CONTROL_SIGNAL_FIFO_DEPTH,
            SYSTOLIC_ARRAY_WEIGHT_ADDRESS_WIDTH  => SYSTOLIC_ARRAY_WEIGHT_ADDRESS_WIDTH,
            BIAS_ADDRESS_WIDTH                   => BIAS_ADDRESS_WIDTH,
            BIAS_REGISTER_DEPTH                  => BIAS_REGISTER_DEPTH,
            BIAS_OUTPUT_DATA_WIDTH               => BIAS_OUTPUT_DATA_WIDTH,
            ACCUMULATOR_ADDRESS_WIDTH            => ACCUMULATOR_ADDRESS_WIDTH,
            ACCUMULATOR_DEPTH                    => ACCUMULATOR_DEPTH,
            ACCUMULATOR_OUTPUT_DATA_WIDTH        => ACCUMULATOR_OUTPUT_DATA_WIDTH,
            ACCUMULATOR_MODE_LENGTH              => ACCUMULATOR_MODE_LENGTH,
            RESIZE_MODE_LENGTH                   => RESIZE_MODE_LENGTH,
            NUM_OF_ACCUMULATOR_REGISTERS         => NUM_OF_ACCUMULATOR_REGISTERS,
            DATA_WIDTH                           => DATA_WIDTH,
            SYSTOLIC_ARRAY_SIZE                  => SYSTOLIC_ARRAY_SIZE,
            SYSTOLIC_ARRAY_OUTPUT_DATA_WIDTH     => SYSTOLIC_ARRAY_OUTPUT_DATA_WIDTH,
            SYSTOLIC_ARRAY_WEIGHT_REGISTER_DEPTH => SYSTOLIC_ARRAY_WEIGHT_REGISTER_DEPTH
        )
        port map(
            clk                            => clk,
            rst                            => rst,

            instruction_valid              => instruction_valid,
            instruction_ready              => instruction_ready,
            instruction                    => instruction,

            memory_write_address_out_valid => memory_write_address_out_valid,
            memory_write_address_out_ready => memory_write_address_out_ready,
            memory_write_address_out       => memory_write_address_out,

            memory_write_data_out_valid    => memory_write_data_out_valid,
            memory_write_data_out_ready    => memory_write_data_out_ready,
            memory_write_data_out          => memory_write_data_out,

            memory_read_address_out_valid  => memory_read_address_out_valid,
            memory_read_address_out_ready  => memory_read_address_out_ready,
            memory_read_address_out        => memory_read_address_out,
            
            memory_read_data_in_valid      => memory_read_data_in_valid,
            memory_read_data_in_ready      => memory_read_data_in_ready,
            memory_read_data_in            => memory_read_data_in
        );
    
    

end Behavioral;
