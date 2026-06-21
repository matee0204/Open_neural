----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/28/2026 05:32:29 PM
-- Design Name: 
-- Module Name: pipeline_mac - Behavioral
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

entity pipeline_mac is
    generic (
        SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH : natural := 8;
        ACCUMULATOR_ADDRESS_LENGTH : natural := 8;
        ACCUMULATOR_MODE_LENGTH : natural := 3;
        VECTOR_LENGTH : natural := 8;
        DATA_WIDTH : natural := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        en : in std_logic;
        
        pipeline_en_out : out std_logic;
        
        reg_data_in_valid : in std_logic;
        reg_data_in_ready : out std_logic;
        reg_data_in : in data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        reg_data_out_valid : out std_logic;
        reg_data_out_ready : in std_logic;
        reg_data_out : out data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        sys_array_bank_address_in_valid : in std_logic;
        sys_array_bank_address_in_ready : out std_logic;
        sys_array_bank_address_in : in std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);
        
        sys_array_bank_address_out_valid : out std_logic;
        sys_array_bank_address_out_ready : in std_logic;
        sys_array_bank_address_out : out std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);
        
        accu_address_in_valid : in std_logic;
        accu_address_in_ready : out std_logic;
        accu_address_in : in std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        
        accu_address_out_valid : out std_logic;
        accu_address_out_ready : in std_logic;
        accu_address_out : out std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        
        accu_mode_in_valid : in std_logic;
        accu_mode_in_ready : out std_logic;
        accu_mode_in : in std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
        
        accu_mode_out_valid : out std_logic;
        accu_mode_out_ready : in std_logic;
        accu_mode_out : out std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0)
    );
end pipeline_mac;

architecture Behavioral of pipeline_mac is
    constant ACCU_DELAY_LENGTH : natural := 19; -- 1 data_delay, 1 weight bank address delay, 1 input delay, 8 sys array delay, 8 output delay
    constant SYS_ARRAY_DATA_DELAY : natural := 2;
    type data_delay_type is array(0 to SYS_ARRAY_DATA_DELAY - 1) of data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
    
    signal pipeline_en : std_logic;
    signal wait_for_data : std_logic;
    signal sys_array_address_valid_d : std_logic; -- 1 data_delay, 1 input delay, -1 sys array address preload
    signal sys_array_bank_address_d : std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);
    signal accu_address_d : data_vector(0 to ACCU_DELAY_LENGTH - 2)(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0); -- -1 delay: accu address preload
    signal accu_address_valid_d : std_logic_vector(ACCU_DELAY_LENGTH - 2 downto 0);
    signal accu_mode_d : data_vector(0 to ACCU_DELAY_LENGTH - 2)(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
    signal accu_mode_valid_d : std_logic_vector(ACCU_DELAY_LENGTH - 2 downto 0);
    signal reg_data_d : data_delay_type;
    signal reg_data_valid_d : std_logic_vector(SYS_ARRAY_DATA_DELAY - 1 downto 0);
begin

    pipeline_en <= sys_array_bank_address_out_ready and reg_data_out_ready and accu_address_out_ready and accu_mode_out_ready;
    wait_for_data <= accu_mode_in_valid and accu_address_in_valid and not reg_data_in_valid;
    sys_array_bank_address_in_ready <= sys_array_bank_address_out_ready and not wait_for_data;
    reg_data_in_ready <= reg_data_out_ready;
    accu_address_in_ready <= accu_address_out_ready and not wait_for_data;
    accu_mode_in_ready <= accu_mode_out_ready and not wait_for_data;
    pipeline_en_out <= pipeline_en;
    
    sys_array_bank_address_out <= sys_array_bank_address_d;
    accu_address_out <= accu_address_d(accu_address_d'high);
    accu_mode_out <= accu_mode_d(accu_mode_d'high);
    reg_data_out <= reg_data_d(reg_data_d'high);

    process (clk) begin
        if rising_edge(clk) then
            if pipeline_en = '1' then
                sys_array_bank_address_d <= sys_array_bank_address_in;
                accu_address_d(0) <= accu_address_in;
                for i in 1 to accu_address_d'high loop
                    accu_address_d(i) <= accu_address_d(i - 1);
                end loop;
                accu_mode_d(0) <= accu_mode_in;
                for i in 1 to accu_mode_d'high loop
                    accu_mode_d(i) <= accu_mode_d(i - 1);
                end loop;
                reg_data_d(0) <= reg_data_in;
                for i in 1 to reg_data_d'high loop
                    reg_data_d(i) <= reg_data_d(i - 1);
                end loop;
            else
                sys_array_bank_address_d <= sys_array_bank_address_d;
                accu_address_d <= accu_address_d;
                accu_mode_d <= accu_mode_d;
                reg_data_d <= reg_data_d;
            end if;
        end if;
    end process;
    
    sys_array_bank_address_out_valid <= sys_array_address_valid_d;
    accu_address_out_valid <= accu_address_valid_d(accu_address_valid_d'high);
    accu_mode_out_valid <= accu_mode_valid_d(accu_mode_valid_d'high);
    reg_data_out_valid <= reg_data_valid_d(reg_data_valid_d'high);
    
    process (clk, rst) begin
        if rst = '1' then
            sys_array_address_valid_d <= '0';
            accu_address_valid_d <= (others => '0');
            accu_mode_valid_d <= (others => '0');
            reg_data_valid_d <= (others => '0');
        else
            if rising_edge(clk) then
                if pipeline_en = '1' then
                    sys_array_address_valid_d <= sys_array_bank_address_in_valid and en;
                    accu_address_valid_d <= accu_address_valid_d(accu_address_valid_d'high - 1 downto 0) & (accu_address_in_valid and en);
                    accu_mode_valid_d <= accu_mode_valid_d(accu_mode_valid_d'high - 1 downto 0) & (accu_mode_in_valid and en);
                    reg_data_valid_d <= reg_data_valid_d(reg_data_valid_d'high - 1 downto 0) & (reg_data_in_valid and en);
                else
                    sys_array_address_valid_d <= sys_array_address_valid_d;
                    accu_address_valid_d <= accu_address_valid_d;
                    accu_mode_valid_d <= accu_mode_valid_d;
                    reg_data_valid_d <= reg_data_valid_d;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
