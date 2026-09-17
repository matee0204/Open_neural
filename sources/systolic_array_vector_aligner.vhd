----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/08/2026 10:04:45 PM
-- Design Name: 
-- Module Name: systolic_array_vector_aligner - Behavioral
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

entity systolic_array_vector_aligner is
    generic (
        DATA_WIDTH : natural := 8;
        VECTOR_LENGTH : natural := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        data_in_valid : in std_logic;
        data_in_ready : out std_logic;
        data_in : in data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        data_out_valid : out std_logic;
        data_out_ready : in std_logic;
        data_out : out data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0)
    );
end systolic_array_vector_aligner;

architecture input of systolic_array_vector_aligner is
    signal shift_en : std_logic;
    signal data_valids : std_logic_vector(VECTOR_LENGTH - 1 downto 0);
begin

    delay_gen : for i in 0 to VECTOR_LENGTH - 1 generate
        delay_block : entity work.Delay
            generic map (
                WIDTH => DATA_WIDTH,
                DELAY => i + 1
            )
            port map (
                clk => clk,
                
                en => shift_en,
                
                data_in => data_in(i),
                
                data_out => data_out(i)
            );
    end generate;

    process (clk, rst) begin
        if rst = '1' then
            data_valids <= (others => '0');
        elsif rising_edge(clk) then
            if shift_en = '1' then
                data_valids <= data_valids(data_valids'high - 1 downto data_valids'low) & data_in_valid;
            else
                data_valids <= data_valids;
            end if;
        end if;
    end process;

    data_in_ready <= data_out_ready;
    data_out_valid <= data_valids(data_valids'high);
    shift_en <= data_out_ready;

end input;

architecture output of systolic_array_vector_aligner is
    signal shift_en : std_logic;
    signal data_valids : std_logic_vector(VECTOR_LENGTH - 1 downto 0);
begin

    delay_gen : for i in 0 to VECTOR_LENGTH - 1 generate
        delay_block : entity work.Delay
            generic map (
                WIDTH => DATA_WIDTH,
                DELAY => VECTOR_LENGTH - i
            )
            port map (
                clk => clk,
                
                en => shift_en,
                
                data_in => data_in(i),
                
                data_out => data_out(i)
            );
    end generate;

    process (clk, rst) begin
        if rst = '1' then
            data_valids <= (others => '0');
        elsif rising_edge(clk) then
            if shift_en = '1' then
                if and data_valids then
                    data_valids <= (others => '0');
                    data_valids(0) <= data_in_valid;
                else
                    data_valids <= data_valids(data_valids'high - 1 downto data_valids'low) & data_in_valid;
                end if;
            else
                data_valids <= data_valids;
            end if;
        end if;
    end process;

    data_in_ready <= data_out_ready;
    data_out_valid <= and data_valids;
    shift_en <= data_out_ready;

end output;
