----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/04/2026 10:59:16 AM
-- Design Name: 
-- Module Name: pipeline_bias_quant - Behavioral
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

entity pipeline_bias_quant is
    generic (
        REGISTER_ADDRESS_LENGTH : natural := 16;
        ACCUMULATOR_ADDRESS_LENGTH : natural := 8;
        BIAS_ADDRESS_LENGTH : natural := 8;
        RESIZE_MODE_LENGTH : natural := 3;
        VECTOR_LENGTH : natural := 8;
        DATA_WIDTH : natural := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        en : in std_logic;
        
        pipeline_en_out : out std_logic;
        
        accu_address_in_valid : in std_logic;
        accu_address_in_ready : out std_logic;
        accu_address_in : in std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        
        accu_address_out_valid : out std_logic;
        accu_address_out_ready : in std_logic;
        accu_address_out : out std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        
        bias_address_in_valid : in std_logic;
        bias_address_in_ready : out std_logic;
        bias_address_in : in std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);
        
        bias_address_out_valid : out std_logic;
        bias_address_out_ready : in std_logic;
        bias_address_out : out std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);
        
        resize_mode_in_valid : in std_logic;
        resize_mode_in_ready : out std_logic;
        resize_mode_in : in std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);
        
        resize_mode_out_valid : out std_logic;
        resize_mode_out_ready : in std_logic;
        resize_mode_out : out std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);
        
        reg_write_address_in_valid : in std_logic;
        reg_write_address_in_ready : out std_logic;
        reg_write_address_in : in std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        reg_write_address_out_valid : out std_logic;
        reg_write_address_out_ready : in std_logic;
        reg_write_address_out : out std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
            
        reg_write_data_in_valid : in std_logic;
        reg_write_data_in_ready : out std_logic;
        reg_write_data_in : in data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        reg_write_data_out_valid : out std_logic;
        reg_write_data_out_ready : in std_logic;
        reg_write_data_out : out data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0)
    );
end pipeline_bias_quant;

architecture Behavioral of pipeline_bias_quant is
    constant RESIZE_MODE_DELAY_LENGTH : natural := 3;
    constant REGISTER_WRITE_DELAY_LENGTH : natural := 6;
    signal pipeline_en : std_logic;
    signal accu_address_d : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
    signal accu_address_valid_d : std_logic;
    signal bias_address_d : std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);
    signal bias_address_valid_d : std_logic;
    signal resize_mode_d : data_vector(0 to RESIZE_MODE_DELAY_LENGTH - 1)(RESIZE_MODE_LENGTH - 1 downto 0);
    signal resize_mode_valid_d : std_logic_vector(RESIZE_MODE_DELAY_LENGTH - 1 downto 0);
    signal reg_write_address_d : data_vector(0 to REGISTER_WRITE_DELAY_LENGTH - 1)(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    signal reg_write_address_valid_d : std_logic_vector(REGISTER_WRITE_DELAY_LENGTH - 1 downto 0);
    signal reg_write_data_valid_d : std_logic;
    signal reg_write_data_d : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
begin

    pipeline_en <= accu_address_out_ready and bias_address_out_ready and resize_mode_out_ready and reg_write_address_out_ready and reg_write_data_out_ready;
    accu_address_in_ready <= accu_address_out_ready;
    bias_address_in_ready <= bias_address_out_ready;
    resize_mode_in_ready <= resize_mode_out_ready;
    reg_write_address_in_ready <= reg_write_address_out_ready and reg_write_data_out_ready;
    reg_write_data_in_ready <= reg_write_data_out_ready and reg_write_address_out_ready;
    pipeline_en_out <= pipeline_en;
    
    accu_address_out <= accu_address_d;
    bias_address_out <= bias_address_d;
    resize_mode_out <= resize_mode_d(RESIZE_MODE_DELAY_LENGTH - 1);
    reg_write_address_out <= reg_write_address_d(REGISTER_WRITE_DELAY_LENGTH - 1);
    reg_write_data_out <= reg_write_data_d;
    
    process (clk) begin
        if rising_edge(clk) then
            if pipeline_en = '1' then
                accu_address_d <= accu_address_in;
                bias_address_d <= bias_address_in;
                resize_mode_d(0) <= resize_mode_in;
                for i in 1 to RESIZE_MODE_DELAY_LENGTH - 1 loop
                    resize_mode_d(i) <= resize_mode_d(i - 1);
                end loop;
                reg_write_address_d(0) <= reg_write_address_in;
                for i in 1 to REGISTER_WRITE_DELAY_LENGTH - 1 loop
                    reg_write_address_d(i) <= reg_write_address_d(i - 1);
                end loop;
                reg_write_data_d <= reg_write_data_in;
            else
                accu_address_d <= accu_address_d;
                bias_address_d <= bias_address_d;
                resize_mode_d <= resize_mode_d;
                reg_write_address_d <= reg_write_address_d;
                reg_write_data_d <= reg_write_data_d;
            end if;
        end if;
    end process;
    
    accu_address_out_valid <= accu_address_valid_d;
    bias_address_out_valid <= bias_address_valid_d;
    resize_mode_out_valid <= resize_mode_valid_d(RESIZE_MODE_DELAY_LENGTH - 1);
    reg_write_address_out_valid <= reg_write_address_valid_d(REGISTER_WRITE_DELAY_LENGTH - 1);
    reg_write_data_out_valid <= reg_write_data_valid_d;
    
    process (clk, rst) begin
        if rst = '1' then
            accu_address_valid_d <= '0';
            bias_address_valid_d <= '0';
            resize_mode_valid_d <= (others => '0');
            reg_write_address_valid_d <= (others => '0');
            reg_write_data_valid_d <= '0';
        else
            if rising_edge(clk) then
                if pipeline_en = '1' then
                    accu_address_valid_d <= accu_address_in_valid and en;
                    bias_address_valid_d <= bias_address_in_valid and en;
                    resize_mode_valid_d <= resize_mode_valid_d(RESIZE_MODE_DELAY_LENGTH - 2 downto 0) & (resize_mode_in_valid and en);
                    reg_write_address_valid_d <= reg_write_address_valid_d(REGISTER_WRITE_DELAY_LENGTH - 2 downto 0) & (reg_write_address_in_valid and en);
                    reg_write_data_valid_d <= reg_write_data_in_valid;
                else
                    accu_address_valid_d <= accu_address_valid_d;
                    bias_address_valid_d <= bias_address_valid_d;
                    resize_mode_valid_d <= resize_mode_valid_d;
                    reg_write_address_valid_d <= reg_write_address_valid_d;
                    reg_write_data_valid_d <= reg_write_data_valid_d;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
