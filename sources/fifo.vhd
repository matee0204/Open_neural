----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/11/2026 06:29:45 PM
-- Design Name: 
-- Module Name: fifo - Behavioral
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

entity fifo is
    generic (
        DATA_WIDTH : positive := 8;
        FIFO_DEPTH : positive := 16
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
end fifo;

architecture Behavioral of fifo is
    type FIFO_t is array (0 to FIFO_DEPTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal FIFO_arr : FIFO_t;
    signal read_pointer : natural range 0 to FIFO_DEPTH - 1 := 0;
    signal write_pointer : natural range 0 to FIFO_DEPTH - 1 := 0;
    signal data_count : natural range 0 to FIFO_DEPTH := 0;
    
    signal data_in_ready_int : std_logic;
    signal data_out_valid_reg : std_logic := '0';
    signal data_out_reg : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
    
    function next_pointer(pointer : natural) return natural is
    begin
        if pointer = FIFO_DEPTH - 1 then
            return 0;
        else
            return pointer + 1;
        end if;
    end function;

begin

    data_in_ready_int <= '1' when data_count < FIFO_DEPTH or
                                  (data_out_valid_reg = '1' and data_out_ready = '1') else '0';
    
    data_in_ready <= data_in_ready_int;
    data_out_valid <= data_out_valid_reg;
    data_out <= data_out_reg;

    process (clk, rst)
        variable push_input : boolean;
        variable consume_output : boolean;
    begin
        if rst = '1' then
            read_pointer <= 0;
            write_pointer <= 0;
            data_count <= 0;
            data_out_valid_reg <= '0';
            data_out_reg <= (others => '0');
        elsif rising_edge(clk) then
            push_input := (data_in_valid = '1') and (data_in_ready_int = '1');
            consume_output := (data_out_valid_reg = '1') and (data_out_ready = '1');

            if push_input then
                FIFO_arr(write_pointer) <= data_in;
                write_pointer <= next_pointer(write_pointer);
            end if;

            if consume_output then
                read_pointer <= next_pointer(read_pointer);
                
                if data_count > 1 then
                    data_out_reg <= FIFO_arr(next_pointer(read_pointer));
                    data_out_valid_reg <= '1';
                else
                    data_out_valid_reg <= '0';
                end if;
            elsif data_out_valid_reg = '0' and data_out_ready = '1' and data_count > 0 then
                data_out_reg <= FIFO_arr(read_pointer);
                data_out_valid_reg <= '1';
            end if;

            if push_input and not consume_output then
                data_count <= data_count + 1;
            elsif not push_input and consume_output then
                data_count <= data_count - 1;
            else
                data_count <= data_count;
            end if;
        end if;
    end process;

end Behavioral;
