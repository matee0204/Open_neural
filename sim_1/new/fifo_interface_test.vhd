----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/15/2026 02:03:43 PM
-- Design Name: 
-- Module Name: fifo_interface_test - Behavioral
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

entity fifo_interface_test is
end fifo_interface_test;

architecture Behavioral of fifo_interface_test is
    constant DATA_WIDTH : natural := 8;

    signal clk : std_logic;
    signal rst : std_logic;
        
    signal sym_cntr : natural := 0;

    signal data_in_valid_inst : std_logic;
    signal data_in_ready_inst : std_logic;
    signal data_in_inst : std_logic_vector(DATA_WIDTH - 1 downto 0);

    signal data_step_en_inst : std_logic;

    signal data_out_valid_inst : std_logic;
    signal data_out_ready_inst : std_logic;
    signal data_out_inst : std_logic_vector(DATA_WIDTH - 1 downto 0);
begin

    process begin
        clk <= '0';
        wait for 1 ns;
        clk <= '1';
        wait for 1 ns;
    end process;
    
    process begin
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
        wait;
    end process;
    
    process (clk) begin
        if rising_edge(clk) and sym_cntr < natural'high then
            sym_cntr <= sym_cntr + 1;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 3 then
                data_out_ready_inst <= '1';
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 3 then
                data_step_en_inst <= '0';
            end if;
        end if;
    end process; 

    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 3 then
                data_in_valid_inst <= '0';
            elsif sym_cntr = 5 then
                data_in_valid_inst <= '1';
            elsif sym_cntr = 6 then
                data_in_valid_inst <= '0';
            end if;
        end if;
    end process; 

    tb_fifo_interface : entity work.fifo_interface
        generic map (
            DATA_WIDTH => DATA_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,

            data_in_valid => data_in_valid_inst,
            data_in_ready => data_in_ready_inst,
            data_in => data_in_inst,

            data_step_en => data_step_en_inst,

            data_out_valid => data_out_valid_inst,
            data_out_ready => data_out_ready_inst,
            data_out => data_out_inst
        );

end Behavioral;
