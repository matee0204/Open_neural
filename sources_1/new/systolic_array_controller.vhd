----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/06/2026 09:01:23 PM
-- Design Name: 
-- Module Name: systolic_array_controller - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity systolic_array_controller is
    generic (
        SYS_ARRAY_SIZE : natural := 8;
        WEIGHT_REGISTER_DEPTH : natural := 2;
        DATA_IN_DELAY : natural := 2
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        pipeline_en : out std_logic;

        weight_col_read_address_valid : in std_logic;
        weight_col_read_address_ready : out std_logic;
        weight_col_read_address : in std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH * SYS_ARRAY_SIZE) - 1 downto 0);

        weight_col_write_address_valid : in std_logic;
        weight_col_write_address_ready : out std_logic;
        weight_col_write_address : in std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH * SYS_ARRAY_SIZE) - 1 downto 0);
        
        weight_col_address_valid_out : out std_logic;
        weight_col_address_ready_in : in std_logic;
        weight_col_address_out : out std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH * SYS_ARRAY_SIZE) - 1 downto 0);
        weight_write_en_out : out std_logic;

        weight_in_valid : in std_logic; -- @suppress "Unused port: weight_in_valid is not used in work.systolic_array_controller(Behavioral)"
        weight_in_ready : out std_logic;
        
        weight_out_valid : out std_logic;
        weight_out_ready : in std_logic;

        selected_weight_bank_valid : in std_logic; -- @suppress "Unused port: selected_weight_bank_valid is not used in work.systolic_array_controller(Behavioral)"
        selected_weight_bank_ready : out std_logic;
        selected_weight_bank : in std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH) - 1 downto 0);

        selected_weight_bank_out : out std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH) - 1 downto 0);

        data_in_valid : in std_logic;
        data_in_ready : out std_logic;
        
        result_out_valid : out std_logic;
        result_out_ready : in std_logic
    );
end systolic_array_controller;

architecture Behavioral of systolic_array_controller is
    signal data_valid_d : std_logic_vector(SYS_ARRAY_SIZE + DATA_IN_DELAY - 1 downto 0);
    signal weight_read_address_valid_d : std_logic;
    signal weight_read_write_address_valid_mux : std_logic;
    signal weight_read_write_address_mux : std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH * SYS_ARRAY_SIZE) - 1 downto 0);
    signal operation_in_progress : std_logic;
    signal current_selected_weight_bank : std_logic_vector(clog2(WEIGHT_REGISTER_DEPTH) - 1 downto 0);
    signal are_selected_banks_the_same : std_logic;
    signal is_there_control_without_data : std_logic;
begin

    pipeline_en <= result_out_ready and weight_col_address_ready_in and weight_out_ready;
    data_in_ready <= result_out_ready and not rst;
    weight_in_ready <= weight_col_address_ready_in and not rst;
    is_there_control_without_data <= selected_weight_bank_valid and not data_in_valid;
    selected_weight_bank_ready <= not (operation_in_progress and not are_selected_banks_the_same and selected_weight_bank_valid) and
                                  not is_there_control_without_data and
                                  not rst;
    
    result_out_valid <= data_valid_d(data_valid_d'high);
    weight_out_valid <= weight_read_address_valid_d;
    operation_in_progress <= or data_valid_d;
    are_selected_banks_the_same <= '1' when current_selected_weight_bank = selected_weight_bank else '0';
    selected_weight_bank_out <= current_selected_weight_bank;

    process (clk, rst) begin
        if rst = '1' then
            data_valid_d <= (others => '0');
            weight_read_address_valid_d <= '0';
            current_selected_weight_bank <= (others => '0');
        elsif rising_edge(clk) then
            if pipeline_en = '1' then
                data_valid_d <= data_valid_d(data_valid_d'high - 1 downto 0) & data_in_valid;
                weight_read_address_valid_d <= weight_col_read_address_valid;
                if selected_weight_bank_valid = '1' and operation_in_progress = '0' then
                    current_selected_weight_bank <= selected_weight_bank;
                else
                    current_selected_weight_bank <= current_selected_weight_bank;
                end if;
            else
                data_valid_d <= data_valid_d;
                weight_read_address_valid_d <= weight_read_address_valid_d;
            end if;
        end if;
    end process;

    weight_col_address_valid_out <= weight_read_write_address_valid_mux;
    weight_col_address_out <= weight_read_write_address_mux;

    process (weight_col_read_address_valid, weight_col_write_address_valid, weight_col_read_address, weight_col_write_address) begin
        if weight_col_write_address_valid = '1' then
            weight_write_en_out <= '1';
            weight_col_write_address_ready <= '1';
            weight_col_read_address_ready <= '0';
            weight_read_write_address_valid_mux <= weight_col_write_address_valid;
            weight_read_write_address_mux <= weight_col_write_address;
        elsif weight_col_read_address_valid = '1' then
            weight_write_en_out <= '0';
            weight_col_write_address_ready <= '0';
            weight_col_read_address_ready <= '1';
            weight_read_write_address_valid_mux <= weight_col_read_address_valid;
            weight_read_write_address_mux <= weight_col_read_address;
        else
            weight_write_en_out <= '0';
            weight_col_write_address_ready <= '1';
            weight_col_read_address_ready <= '1';
            weight_read_write_address_valid_mux <= '0';
            weight_read_write_address_mux <= (others => '0');
        end if;
    end process;

end Behavioral;
