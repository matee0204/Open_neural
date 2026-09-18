----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/09/2026 02:08:03 PM
-- Design Name: 
-- Module Name: vector_bias_controller - Behavioral
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

entity vector_bias_controller is
    generic (
        BIAS_REGISTER_DEPTH : natural := 128
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        pipeline_en_out : out std_logic;

        bias_reg_read_address_valid : in std_logic;
        bias_reg_read_address_ready : out std_logic;
        bias_reg_read_address : in std_logic_vector(clog2(BIAS_REGISTER_DEPTH) - 1 downto 0);

        bias_reg_write_address_valid : in std_logic;
        bias_reg_write_address_ready : out std_logic;
        bias_reg_write_address : in std_logic_vector(clog2(BIAS_REGISTER_DEPTH) - 1 downto 0);

        bias_reg_read_write_address_out_valid : out std_logic;
        bias_reg_read_write_address_out_ready : in std_logic;
        bias_reg_read_write_address_out : out std_logic_vector(clog2(BIAS_REGISTER_DEPTH) - 1 downto 0);
        bias_reg_write_en : out std_logic;

        bias_reg_data_in_valid : in std_logic; -- @suppress "Unused port: bias_reg_data_in_valid is not used in work.vector_bias_controller(Behavioral)"
        bias_reg_data_in_ready : out std_logic;

        bias_reg_data_out_valid : out std_logic;
        bias_reg_data_out_ready : in std_logic;

        bias_reg_address_valid : in std_logic;
        bias_reg_address_ready : out std_logic;

        data_in_valid : in std_logic;
        data_in_ready : out std_logic;

        data_out_valid : out std_logic;
        data_out_ready : in std_logic
    );
end vector_bias_controller;

architecture Behavioral of vector_bias_controller is
    constant BIAS_PIPELINE_LENGTH : natural := 1;
    constant INPUT_DELAY_LENGTH : natural := 1;
    signal pipeline_en : std_logic;
    signal bias_reg_read_address_valid_d : std_logic;
    signal bias_read_write_address_valid_mux : std_logic;
    signal bias_read_write_address_mux : std_logic_vector(clog2(BIAS_REGISTER_DEPTH) - 1 downto 0);
    signal data_valid_d : std_logic_vector(BIAS_PIPELINE_LENGTH + INPUT_DELAY_LENGTH - 1 downto 0);
    signal bias_reg_write_ready : std_logic;
    signal bias_reg_read_ready : std_logic;
    signal is_there_control_without_data : std_logic;
begin

    pipeline_en <= data_out_ready;
    pipeline_en_out <= pipeline_en;
    is_there_control_without_data <= bias_reg_address_valid and not data_in_valid;
    bias_reg_read_address_ready <= bias_reg_read_ready and not rst;
    bias_reg_write_address_ready <= bias_reg_write_ready and not rst;
    bias_reg_data_in_ready <= bias_reg_write_ready and not rst;
    bias_reg_address_ready <= data_out_ready and not is_there_control_without_data and not rst;
    data_in_ready <= data_out_ready and not rst;
                                   
    data_out_valid <= data_valid_d(data_valid_d'high);
    bias_reg_data_out_valid <= bias_reg_read_address_valid_d;

    process (clk, rst) begin
        if rst = '1' then
            data_valid_d <= (others => '0');
            bias_reg_read_address_valid_d <= '0';
        elsif rising_edge(clk) then
                bias_reg_read_address_valid_d <= bias_reg_read_address_valid;
            if pipeline_en = '1' then
                data_valid_d <= data_valid_d(data_valid_d'high - 1 downto 0) & data_in_valid;
            else
                data_valid_d <= data_valid_d;
            end if;
        end if;
    end process;

    bias_reg_read_write_address_out_valid <= bias_read_write_address_valid_mux;
    bias_reg_read_write_address_out <= bias_read_write_address_mux;

    process (bias_reg_read_address_valid, bias_reg_write_address_valid, bias_reg_read_address, bias_reg_write_address) begin
        if bias_reg_write_address_valid = '1' then
            bias_reg_write_en <= '1';
            bias_reg_write_ready <= '1';
            bias_reg_read_ready <= '0';
            bias_read_write_address_valid_mux <= bias_reg_write_address_valid;
            bias_read_write_address_mux <= bias_reg_write_address;
        elsif bias_reg_read_address_valid = '1' then
            bias_reg_write_en <= '0';
            bias_reg_write_ready <= '0';
            bias_reg_read_ready <= '1';
            bias_read_write_address_valid_mux <= bias_reg_read_address_valid;
            bias_read_write_address_mux <= bias_reg_read_address;
        else
            bias_reg_write_en <= '0';
            bias_reg_write_ready <= '1';
            bias_reg_read_ready <= '1';
            bias_read_write_address_valid_mux <= '0';
            bias_read_write_address_mux <= (others => '0');
        end if;
    end process;

end Behavioral;
