----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2026 06:06:38 PM
-- Design Name: 
-- Module Name: vector_accumulator - Behavioral
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

entity vector_accumulator is
    generic (
        INPUT_DATA_WIDTH : natural := 24;
        ACCUMULATOR_DATA_WIDTH : natural := 32;
        ACCUMULATOR_DEPTH : natural := 128;
        VECTOR_LENGTH : natural := 8;
        ACCUMULATOR_ADDRESS_WIDTH : natural := 32;
        ACCUMULATOR_MODE_LENGTH : natural := 3
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        mode_valid : in std_logic;
        mode_ready : out std_logic;
        mode : in std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
        
        data_in : in data_vector_signed(0 to VECTOR_LENGTH - 1)(INPUT_DATA_WIDTH - 1 downto 0);
        data_in_ready : out std_logic;
        data_in_valid : in std_logic;
        
        accumulator_write_address_valid : in std_logic;
        accumulator_write_address_ready : out std_logic;
        accumulator_write_address : in std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0);
        
        accumulator_read_address_valid : in std_logic;
        accumulator_read_address_ready : out std_logic;
        accumulator_read_address : in std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0);
        
        data_out_valid : out std_logic;
        data_out_ready : in std_logic;
        data_out : out data_vector_signed(0 to VECTOR_LENGTH - 1)(ACCUMULATOR_DATA_WIDTH - 1 downto 0);

        accumulator_write_back_address_valid : out std_logic;
        accumulator_write_back_address_ready : in std_logic;
        accumulator_write_back_address : out std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0)
    );
end vector_accumulator;

architecture Behavioral of vector_accumulator is
    -- constant INPUT_DATA_DELAY : natural := 1;
    signal accumulator_reg_out : data_vector(0 to VECTOR_LENGTH - 1)(ACCUMULATOR_DATA_WIDTH - 1 downto 0);
    signal adder_in_from_reg : data_vector_signed(0 to VECTOR_LENGTH - 1)(ACCUMULATOR_DATA_WIDTH - 1 downto 0);
    signal adder_in_from_controller : data_vector_signed(0 to VECTOR_LENGTH - 1)(ACCUMULATOR_DATA_WIDTH - 1 downto 0);
    signal accumulator_reg_read_out : data_vector(0 to VECTOR_LENGTH - 1)(ACCUMULATOR_DATA_WIDTH - 1 downto 0);
    signal accumulator_read_out : data_vector_signed(0 to VECTOR_LENGTH - 1)(ACCUMULATOR_DATA_WIDTH - 1 downto 0);
    signal adder_out : data_vector_signed(0 to VECTOR_LENGTH - 1)(ACCUMULATOR_DATA_WIDTH - 1 downto 0);
    signal accumulator_reg_in_signed : data_vector(0 to VECTOR_LENGTH - 1)(ACCUMULATOR_DATA_WIDTH - 1 downto 0);
    signal accumulator_reg_in : data_vector(0 to VECTOR_LENGTH - 1)(ACCUMULATOR_DATA_WIDTH - 1 downto 0);
    signal accumulator_write_enable : std_logic;
    signal accumulator_write_address_d : std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0);
    signal accumulator_read_enable : std_logic;
    signal input_data_delay : data_vector_signed(0 to VECTOR_LENGTH - 1)(INPUT_DATA_WIDTH - 1 downto 0);
begin
    
    accumulator_write_back_address_valid <= accumulator_write_enable;
    accumulator_write_back_address <= accumulator_write_address_d;

    process (accumulator_reg_out, accumulator_reg_in, accumulator_reg_read_out) begin
        for i in 0 to VECTOR_LENGTH - 1 loop
            adder_in_from_reg(i) <= signed(accumulator_reg_out(i));
            accumulator_reg_in_signed(i) <= std_logic_vector(accumulator_reg_in(i));
            accumulator_read_out(i) <= signed(accumulator_reg_read_out(i));
        end loop;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            input_data_delay <= data_in;
        end if;
    end process;

    accumalator_adder_inst : entity work.vector_adder
        generic map (
            INPUT_A_DATA_WIDTH => INPUT_DATA_WIDTH,
            INPUT_B_DATA_WIDTH => ACCUMULATOR_DATA_WIDTH,
            OUTPUT_DATA_WIDTH => ACCUMULATOR_DATA_WIDTH,
            VECTOR_LENGTH => VECTOR_LENGTH
        )
        port map (
            data_in_A => input_data_delay,
            
            data_in_B => adder_in_from_controller,
            
            result_out => adder_out
        );
        
    accumulator_controller_inst : entity work.vector_accumulator_controller
        generic map (
            VECTOR_LENGTH => VECTOR_LENGTH,
            INPUT_DATA_WIDTH => INPUT_DATA_WIDTH,
            ACCUMULATOR_ADDRESS_WIDTH => ACCUMULATOR_ADDRESS_WIDTH,
            ACCUMULATOR_DATA_WIDTH => ACCUMULATOR_DATA_WIDTH,
            ACCUMULATOR_MODE_LENGTH => ACCUMULATOR_MODE_LENGTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            mode_valid => mode_valid,
            mode_ready => mode_ready,
            mode => mode,
            
            data_in => input_data_delay,
            data_in_ready => data_in_ready,
            adder_result_in => adder_out,
            data_out => accumulator_reg_in,
            
            accumulator_reg_data => adder_in_from_reg,
            adder_in => adder_in_from_controller,
            
            data_in_valid => data_in_valid,
            accumulator_write_address_in_valid => accumulator_write_address_valid,
            accumulator_write_address_in_ready => accumulator_write_address_ready,
            accumulator_write_enable => accumulator_write_enable,
            accumulator_write_address_in => accumulator_write_address,
            accumulator_write_address_out => accumulator_write_address_d,

            accumulator_write_back_address_ready => accumulator_write_back_address_ready,
            
            accumulator_read_address_valid => accumulator_read_address_valid,
            data_out_valid => data_out_valid,
            
            data_out_ready => data_out_ready,
            accumulator_read_address_ready => accumulator_read_address_ready,
            
            read_en => accumulator_read_enable
        );
        
    accumulator_register_inst : entity work.vector_register(Write_first)
        generic map (
            DATA_WIDTH => ACCUMULATOR_DATA_WIDTH,
            DEPTH => ACCUMULATOR_DEPTH,
            VECTOR_LENGTH => VECTOR_LENGTH
        )
        port map (
            clk_A => clk,
            en_A => '1',
            
            wr_en_A => '0',
            address_A => accumulator_write_address(clog2(ACCUMULATOR_DEPTH) - 1 downto 0),
            
            data_in_A => (others => (others => '0')),
            data_out_A => accumulator_reg_out,
            
            clk_B => clk,
            en_B => '1',
            
            wr_en_B => accumulator_write_enable,
            address_B => accumulator_write_address_d(clog2(ACCUMULATOR_DEPTH) - 1 downto 0),
            
            data_in_B => accumulator_reg_in_signed
        );
        
    accumulator_shadow_register_inst : entity work.vector_register(Write_first)
        generic map (
            DATA_WIDTH => ACCUMULATOR_DATA_WIDTH,
            DEPTH => ACCUMULATOR_DEPTH,
            VECTOR_LENGTH => VECTOR_LENGTH
        )
        port map (
            clk_A => clk,
            en_A => '1',
            
            wr_en_A => accumulator_write_enable,
            address_A => accumulator_write_address_d(clog2(ACCUMULATOR_DEPTH) - 1 downto 0),
            
            data_in_A => accumulator_reg_in_signed,
            
            clk_B => clk,
            en_B => accumulator_read_enable,
            
            wr_en_B => '0',
            address_B => accumulator_read_address(clog2(ACCUMULATOR_DEPTH) - 1 downto 0),
            
            data_in_B => (others => (others => '0')),
            data_out_B => accumulator_reg_read_out
        );
        
    data_out <= accumulator_read_out;
    
end Behavioral;
