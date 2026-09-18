----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2026 08:09:15 PM
-- Design Name: 
-- Module Name: priority_encoder_test - Behavioral
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

entity priority_encoder_test is
end priority_encoder_test;

architecture Behavioral of priority_encoder_test is
    constant WIDTH : natural := 3;
    signal data_in_inst : std_logic_vector(WIDTH - 1 downto 0);
    signal data_out_inst : std_logic_vector(clog2(WIDTH) - 1 downto 0);
    signal has_one_inst : std_logic;
begin

    process begin
        wait for 5ns;
        data_in_inst <= b"000";
        wait for 1ns;
        data_in_inst <= b"001";
        wait for 1ns;
        data_in_inst <= b"010";
        wait for 1ns;
        data_in_inst <= b"011";
        wait for 1ns;
        data_in_inst <= b"100";
        wait for 1ns;
        data_in_inst <= b"101";
        wait for 1ns;
        data_in_inst <= b"110";
        wait for 1ns;
        data_in_inst <= b"111";
        wait;
    end process;

    tb_priority_encoder : entity work.priority_encoder
        generic map (
            WIDTH => WIDTH
        )
        port map (
            data_in => data_in_inst,
            
            data_out => data_out_inst,
            has_one => has_one_inst
        );

end Behavioral;
