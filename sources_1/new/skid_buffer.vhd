----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/13/2026 09:00:09 PM
-- Design Name: 
-- Module Name: skid_buffer - Behavioral
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

entity skid_buffer is
    generic (
        DATA_WIDTH : natural := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        data_in_valid : in std_logic;
        data_in_ready : out std_logic;
        data_in : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        
        data_out_valid : out std_logic;
        data_out_ready : in std_logic;
        data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    );
end skid_buffer;

architecture Behavioral of skid_buffer is
    signal skid_reg : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal ready_reg : std_logic;
    signal valid_reg : std_logic;
    signal skid_bypass_sel : std_logic;
    signal data_out_ready_negedge : std_logic;
begin

    process (clk, rst) begin
        if rst = '1' then
            valid_reg <= '0';
        elsif rising_edge(clk) then
            if data_out_ready_negedge = '1' then
                valid_reg <= data_in_valid;
            else
                valid_reg <= valid_reg;
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if data_out_ready_negedge = '1' then
                skid_reg <= data_in;
            else
                skid_reg <= skid_reg;
            end if;
        end if;
    end process;
    
    process (data_in, skid_reg, skid_bypass_sel) begin
        case skid_bypass_sel is
            when '1' => data_out <= skid_reg;
            when others => data_out <= data_in;
        end case;
    end process;
    
    process (valid_reg, data_in_valid, skid_bypass_sel) begin
        case skid_bypass_sel is
            when '1' => data_out_valid <= valid_reg;
            when others => data_out_valid <= data_in_valid;
        end case;
    end process;
    
    process (clk, rst) begin
        if rst = '1' then
            ready_reg <= '0';
        elsif rising_edge(clk) then
            ready_reg <= data_out_ready;
        end if;
    end process;

    data_out_ready_negedge <= not data_out_ready and ready_reg;
    skid_bypass_sel <= not ready_reg;
    data_in_ready <= ready_reg;

end Behavioral;
