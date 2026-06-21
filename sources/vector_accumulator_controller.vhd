----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2026 08:31:52 PM
-- Design Name: 
-- Module Name: vector_accumulator_controller - Behavioral
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
use work.common_constants.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vector_accumulator_controller is
    generic (
        VECTOR_LENGTH : natural := 8;
        INPUT_DATA_WIDTH : natural := 24;
        ACCUMULATOR_DEPTH : natural := 128;
        ACCUMULATOR_DATA_WIDTH : natural := 32;
        ACCUMULATOR_MODE_LENGTH : natural := 3
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        mode : in std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
        
        data_in : in data_vector_signed(VECTOR_LENGTH - 1 downto 0)(INPUT_DATA_WIDTH - 1 downto 0);
        adder_result_in : in data_vector_signed(VECTOR_LENGTH - 1 downto 0)(ACCUMULATOR_DATA_WIDTH - 1 downto 0);
        data_out : out data_vector(VECTOR_LENGTH - 1 downto 0)(ACCUMULATOR_DATA_WIDTH - 1 downto 0);
        
        accumulator_reg_data : in data_vector_signed(VECTOR_LENGTH - 1 downto 0)(ACCUMULATOR_DATA_WIDTH - 1 downto 0);
        adder_in : out data_vector_signed(VECTOR_LENGTH - 1 downto 0)(ACCUMULATOR_DATA_WIDTH - 1 downto 0);
        
        data_in_valid : in std_logic;
        accumulator_write_address_in : in std_logic_vector(clog2(ACCUMULATOR_DEPTH) - 1 downto 0);
        accumulator_write_enable : out std_logic;
        accumulator_write_address_out : out std_logic_vector(clog2(ACCUMULATOR_DEPTH) - 1 downto 0);
        
        accumulator_read_address_valid : in std_logic;
        data_out_valid : out std_logic;
        
        data_out_ready : in std_logic;
        accumulator_read_address_ready : out std_logic;
        
        read_en : out std_logic
    );
    
end vector_accumulator_controller;

architecture Behavioral of vector_accumulator_controller is
    constant mode_accumulate : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(ACCUMULATOR_MODE_ACCUMULATE, ACCUMULATOR_MODE_LENGTH));
    -- constant mode_override : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0) := std_logic_vector(to_unsigned(ACCUMULATOR_MODE_OVERRIDE, ACCUMULATOR_MODE_LENGTH));
    signal mode_delay : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
    signal accumulator_bypass_reg : data_vector_signed(VECTOR_LENGTH - 1 downto 0)(ACCUMULATOR_DATA_WIDTH - 1 downto 0);
    signal selcted_data : data_vector(VECTOR_LENGTH - 1 downto 0)(ACCUMULATOR_DATA_WIDTH - 1 downto 0);
    signal accumulator_address_d : std_logic_vector(clog2(ACCUMULATOR_DEPTH) - 1 downto 0);
begin
    
    accumulator_write_enable <= data_in_valid;
    accumulator_read_address_ready <= data_out_ready;
    read_en <= data_out_ready;
    data_out <= selcted_data;

    process (clk) begin
        if (rising_edge(clk)) then
            if (accumulator_write_enable = '1') then
                for i in 0 to VECTOR_LENGTH - 1 loop
                    accumulator_bypass_reg(i) <= signed(selcted_data(i));
                end loop;
            else
                accumulator_bypass_reg <= accumulator_bypass_reg;
            end if;
        end if;
    end process;
    
    process (accumulator_address_d, accumulator_write_address_out, mode_delay, accumulator_bypass_reg, accumulator_reg_data) begin
        if ((accumulator_address_d = accumulator_write_address_out) and (mode_delay = mode_accumulate)) then
            adder_in <= accumulator_bypass_reg;
        else
            adder_in <= accumulator_reg_data;
        end if;
    end process;

    process (clk) begin
        if (rising_edge(clk)) then
            accumulator_write_address_out <= accumulator_write_address_in;
            accumulator_address_d <= accumulator_write_address_out;
        end if;
    end process;

    process (clk) begin
        if (rising_edge(clk)) then
            mode_delay <= mode;
        end if;
    end process;
    
    process (mode_delay, data_in, adder_result_in) begin
        if (mode_delay = mode_accumulate) then
            for i in 0 to VECTOR_LENGTH - 1 loop
                selcted_data(i) <= std_logic_vector(adder_result_in(i));
            end loop;
        else
            for i in 0 to VECTOR_LENGTH - 1 loop
                selcted_data(i) <= std_logic_vector(resize(data_in(i), ACCUMULATOR_DATA_WIDTH));
            end loop;
        end if;
    end process;
    
    process (clk, rst) begin
        if (rst) then
            data_out_valid <= '0';
        else
            if (rising_edge(clk)) then
                data_out_valid <= accumulator_read_address_valid;
            end if;
        end if;
    end process;

end Behavioral;
