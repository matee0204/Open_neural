----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/21/2026 07:04:08 PM
-- Design Name: 
-- Module Name: vector_resize - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vector_resize is
    generic (
        INPUT_WIDTH : natural := 32;
        OUTPUT_WIDTH : natural := 8;
        VECTOR_LENGTH : natural := 8;
        RESIZE_MODE_LENGTH : natural := 3
    );
    port (
        clk : in std_logic;
        
        en : in std_logic;
        resize_mode : in std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);
        
        data_in : in data_vector(0 to VECTOR_LENGTH - 1)(INPUT_WIDTH - 1 downto 0);
        
        data_out : out data_vector(0 to VECTOR_LENGTH - 1)(OUTPUT_WIDTH - 1 downto 0)
    );
end vector_resize;

architecture Behavioral of vector_resize is
    constant RESIZE_MODE_SATURATION : natural := 0;
    constant RESIZE_MODE_TRUNCATION : natural := 1; -- @suppress "Unused declaration"
    signal data_out_saturation : data_vector(0 to VECTOR_LENGTH - 1)(OUTPUT_WIDTH - 1 downto 0);
    signal data_out_truncation : data_vector(0 to VECTOR_LENGTH - 1)(OUTPUT_WIDTH - 1 downto 0);
    signal resize_mode_delay : std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);
begin

    saturation_gen : for i in 0 to VECTOR_LENGTH - 1 generate
        saturation_inst : entity work.resize_unit(Saturation)
            generic map (
                INPUT_WIDTH => INPUT_WIDTH,
                OUTPUT_WIDTH => OUTPUT_WIDTH
            )
            port map (
                clk => clk,
                
                en => en,
                
                data_in => data_in(i),
                
                data_out => data_out_saturation(i)
            );
    end generate;

    trucation_gen : for i in 0 to VECTOR_LENGTH - 1 generate
        trucation_inst : entity work.resize_unit(Truncation)
            generic map (
                INPUT_WIDTH => INPUT_WIDTH,
                OUTPUT_WIDTH => OUTPUT_WIDTH
            )
            port map (
                clk => clk,
                
                en => en,
                
                data_in => data_in(i),
                
                data_out => data_out_truncation(i)
            );
    end generate;

    process (clk) begin
        if (rising_edge(clk)) then
            if (en = '1') then
                if (resize_mode_delay = std_logic_vector(to_unsigned(RESIZE_MODE_SATURATION, RESIZE_MODE_LENGTH))) then
                    data_out <= data_out_saturation;
                else
                    data_out <= data_out_truncation;
                end if;
            else
                data_out <= data_out;
            end if;
        end if;
    end process;

    process (clk) begin
        if (rising_edge(clk)) then
            if (en = '1') then
                resize_mode_delay <= resize_mode;
            else
                resize_mode_delay <= resize_mode_delay;
            end if;
        end if;
    end process;

end Behavioral;
