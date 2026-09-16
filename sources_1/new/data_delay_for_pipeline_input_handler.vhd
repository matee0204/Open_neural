----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/26/2026 04:06:33 PM
-- Design Name: 
-- Module Name: data_delay_for_pipeline_input_handler - Behavioral
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

entity data_delay_for_pipeline_input_handler is
    generic (
        DATA_LENGTH : natural := 8;
        DELAY_LENGTH : natural := 2
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        input_en : in std_logic;
        
        data_in_valid : in std_logic;
        data_in_ready : out std_logic;
        data_in : in std_logic_vector(DATA_LENGTH - 1 downto 0);

        data_out_valid : out std_logic;
        data_out_ready : in std_logic;
        data_out : out std_logic_vector(DATA_LENGTH - 1 downto 0)
    );
end data_delay_for_pipeline_input_handler;

architecture Behavioral of data_delay_for_pipeline_input_handler is
    constant FIRST_DELAY_LENGTH : natural := 1;

    signal data_in_ready_from_first_data_delay : std_logic;
    signal data_out_valid_from_first_data_delay : std_logic;
    signal data_out_from_first_data_delay : std_logic_vector(DATA_LENGTH - 1 downto 0);

    signal data_in_ready_from_second_data_delay : std_logic;
    signal data_out_valid_from_second_data_delay : std_logic;
    signal data_out_from_second_data_delay : std_logic_vector(DATA_LENGTH - 1 downto 0);
begin

    data_in_ready <= data_in_ready_from_first_data_delay;

    first_data_delay : entity work.data_delay
        generic map(
            DATA_LENGTH  => DATA_LENGTH,
            DELAY_LENGTH => FIRST_DELAY_LENGTH
        )
        port map(
            clk            => clk,
            rst            => rst,

            input_en       => '1',

            data_in_valid  => data_in_valid,
            data_in_ready  => data_in_ready_from_first_data_delay,
            data_in        => data_in,

            data_out_valid => data_out_valid_from_first_data_delay,
            data_out_ready => data_in_ready_from_second_data_delay,
            data_out       => data_out_from_first_data_delay
        );

    data_out_valid <= data_out_valid_from_second_data_delay;
    data_out <= data_out_from_second_data_delay;

    second_data_delay : entity work.data_delay
        generic map(
            DATA_LENGTH  => DATA_LENGTH,
            DELAY_LENGTH => DELAY_LENGTH - FIRST_DELAY_LENGTH
        )
        port map(
            clk            => clk,
            rst            => rst,

            input_en       => input_en,

            data_in_valid  => data_out_valid_from_first_data_delay,
            data_in_ready  => data_in_ready_from_second_data_delay,
            data_in        => data_out_from_first_data_delay,
            
            data_out_valid => data_out_valid_from_second_data_delay,
            data_out_ready => data_out_ready,
            data_out       => data_out_from_second_data_delay
        );
    

end Behavioral;
