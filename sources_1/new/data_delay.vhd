----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/10/2026 08:59:16 PM
-- Design Name: 
-- Module Name: data_delay - Behavioral
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

entity data_delay is
    generic (
        DATA_LENGTH : natural := 8;
        DELAY_LENGTH : natural := 3
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
end data_delay;

architecture Behavioral of data_delay is
    signal pipeline_en : std_logic;
    signal data_valid_delay : std_logic_vector(DELAY_LENGTH - 1 downto 0);
    signal data_delay : data_vector(0 to DELAY_LENGTH - 1)(DATA_LENGTH - 1 downto 0);
begin

    pipeline_en <= data_out_ready;
    data_in_ready <= pipeline_en and input_en;
    data_out_valid <= data_valid_delay(DELAY_LENGTH - 1);

    process (clk, rst) begin
        if rst = '1' then
            data_valid_delay <= (others => '0');
        else
            if rising_edge(clk) then
                if pipeline_en = '1' then
                    data_valid_delay(0) <= data_in_valid and input_en;
                    for i in 1 to DELAY_LENGTH - 1 loop
                        data_valid_delay(i) <= data_valid_delay(i - 1);
                    end loop;
                else
                    data_valid_delay <= data_valid_delay;
                end if;
            end if;
        end if;
    end process;
    
    data_out <= data_delay(DELAY_LENGTH - 1);
    
    process (clk) begin
        if rising_edge(clk) then
            if pipeline_en = '1' then
                if input_en = '1' then
                    data_delay(0) <= data_in;
                else
                    data_delay(0) <= data_delay(0);
                end if;
                for i in 1 to DELAY_LENGTH - 1 loop
                    data_delay(i) <= data_delay(i - 1);
                end loop;
            else
                data_delay <= data_delay;
            end if;
        end if;
    end process;

end Behavioral;
