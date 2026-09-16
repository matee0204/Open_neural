----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/15/2026 11:48:37 AM
-- Design Name: 
-- Module Name: fifo_interface - Behavioral
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

entity fifo_interface is
    generic (
        DATA_WIDTH : natural := 32
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        data_in_valid : in std_logic;
        data_in_ready : out std_logic;
        data_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);

        data_step_en : in std_logic;

        data_out_valid : out std_logic;
        data_out_ready : in std_logic;
        data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end fifo_interface;

architecture Behavioral of fifo_interface is
    signal data_valid_buffer : std_logic;
    signal data_buffer : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal data_step_ready : std_logic;
begin

    data_step_ready <= data_out_ready and (not data_valid_buffer or data_step_en);
    data_in_ready <= data_step_ready;

    data_out_valid <= data_valid_buffer;

    process (clk, rst) begin
        if rst = '1' then
            data_valid_buffer <= '0';
        else
            if rising_edge(clk) then
                if data_out_ready = '1' then
                    data_valid_buffer <= data_in_valid;
                else
                    data_valid_buffer <= data_valid_buffer;
                end if;
            end if;
        end if;
    end process;

    data_out <= data_buffer;

    process (clk) begin
        if rising_edge(clk) then
            if data_out_ready = '1' then
                data_buffer <= data_in;
            else
                data_buffer <= data_buffer;
            end if;
        end if;
    end process;

end Behavioral;
