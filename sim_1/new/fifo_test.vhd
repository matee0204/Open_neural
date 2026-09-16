----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/11/2026 10:11:11 PM
-- Design Name: 
-- Module Name: fifo_test - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fifo_test is
end fifo_test;

architecture Behavioral of fifo_test is
    constant DATA_WIDTH : positive := 8;
    constant FIFO_DEPTH : positive := 4;
    constant CLK_PERIOD : time := 2 ns;
    
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    
    signal fifo_data_in_valid : std_logic := '0';
    signal fifo_data_in_ready : std_logic;
    signal fifo_data_in : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    
    signal fifo_data_out_valid : std_logic;
    signal fifo_data_out_ready : std_logic := '0';
    signal fifo_data_out : std_logic_vector(DATA_WIDTH - 1 downto 0);

begin

    process begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    fifo_inst : entity work.fifo
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            FIFO_DEPTH => FIFO_DEPTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            data_in_valid => fifo_data_in_valid,
            data_in_ready => fifo_data_in_ready,
            data_in => fifo_data_in,
            
            data_out_valid => fifo_data_out_valid,
            data_out_ready => fifo_data_out_ready,
            data_out => fifo_data_out
        );

    process
        procedure wait_clk is
        begin
            wait until rising_edge(clk);
            wait for 1 ps;
        end procedure;
        
        procedure drive_word(value : natural) is
        begin
            fifo_data_in <= std_logic_vector(to_unsigned(value, DATA_WIDTH));
            fifo_data_in_valid <= '1';
            wait for 1 ps;
            assert fifo_data_in_ready = '1'
                report "FIFO did not accept input word"
                severity failure;
            wait_clk;
            fifo_data_in_valid <= '0';
        end procedure;
        
        procedure expect_output(value : natural) is
        begin
            assert fifo_data_out_valid = '1'
                report "Expected valid output"
                severity failure;
            assert fifo_data_out = std_logic_vector(to_unsigned(value, DATA_WIDTH))
                report "Unexpected FIFO output word"
                severity failure;
        end procedure;
    begin
        rst <= '1';
        fifo_data_in_valid <= '0';
        fifo_data_out_ready <= '0';
        wait for 5 * CLK_PERIOD;
        wait_clk;
        rst <= '0';
        wait_clk;
        
        assert fifo_data_out_valid = '0'
            report "FIFO output valid is active after reset"
            severity failure;
        assert fifo_data_in_ready = '1'
            report "FIFO input ready is inactive after reset"
            severity failure;
        
        drive_word(11);
        
        assert fifo_data_out_valid = '0'
            report "Non-FWFT FIFO output valid is active before a read request"
            severity failure;
        
        fifo_data_out_ready <= '1';
        wait_clk;
        expect_output(11);
        
        fifo_data_in <= std_logic_vector(to_unsigned(99, DATA_WIDTH));
        fifo_data_in_valid <= '1';
        fifo_data_out_ready <= '0';
        wait_clk;
        expect_output(11);
        
        fifo_data_in <= std_logic_vector(to_unsigned(100, DATA_WIDTH));
        wait_clk;
        expect_output(11);
        
        fifo_data_in <= std_logic_vector(to_unsigned(101, DATA_WIDTH));
        wait_clk;
        expect_output(11);
        
        assert fifo_data_in_ready = '0'
            report "FIFO input ready is active when the FIFO is full and output is stalled"
            severity failure;
        
        fifo_data_in <= std_logic_vector(to_unsigned(102, DATA_WIDTH));
        wait_clk;
        expect_output(11);
        
        fifo_data_out_ready <= '1';
        wait for 1 ps;
        assert fifo_data_in_ready = '1'
            report "FIFO input ready is inactive during simultaneous read and write while full"
            severity failure;
        wait_clk;
        expect_output(99);
        
        fifo_data_in_valid <= '0';
        wait_clk;
        expect_output(100);
        wait_clk;
        expect_output(101);
        wait_clk;
        expect_output(102);
        wait_clk;
        
        assert fifo_data_out_valid = '0'
            report "FIFO output valid is active after all words were read"
            severity failure;
        
        fifo_data_out_ready <= '1';
        drive_word(55);
        
        assert fifo_data_out_valid = '0'
            report "Non-FWFT FIFO output valid is active in the same cycle as an empty FIFO write"
            severity failure;
        
        wait_clk;
        expect_output(55);
        wait_clk;
        
        assert fifo_data_out_valid = '0'
            report "FIFO did not become empty after the final read"
            severity failure;
        
        report "fifo_test completed successfully"
            severity note;
        wait;
    end process;

end Behavioral;
