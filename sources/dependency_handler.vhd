----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/23/2026 10:21:54 PM
-- Design Name: 
-- Module Name: dependency_handler - Behavioral
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

entity dependency_handler is
    generic (
        NUM_OF_VECTOR_REGISTERS : natural := 128;
        NUM_OF_ACCUMULATOR_REGISTERS : natural := 128;
        
        REGISTER_ADDRESS_LENGTH : natural := 16;
        SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH : natural := 8;
        BIAS_ADDRESS_LENGTH : natural := 8;
        ACCUMULATOR_ADDRESS_LENGTH : natural := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        vector_register_pipeline_ready : in std_logic;
        accumulator_pipeline_ready : in std_logic;
        
        register_read_address_in_valid : in std_logic;
        register_read_address_in_ready : out std_logic;
        register_read_address_in : in std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        register_write_address_in_valid : in std_logic;
        register_write_address_in_ready : out std_logic;
        register_write_address_in : in std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        systolic_array_selected_weight_bank_in_valid : in std_logic;
        systolic_array_selected_weight_bank_in_ready : out std_logic;
        systolic_array_selected_weight_bank_in : in std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_LENGTH - 1 downto 0);
        
        selected_accumulator_bank_write_in_valid : in std_logic;
        selected_accumulator_bank_write_in_ready : out std_logic;
        selected_accumulator_bank_write_in : in std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        
        selected_accumulator_bank_read_in_valid : in std_logic;
        selected_accumulator_bank_read_in_ready : out std_logic;
        selected_accumulator_bank_read_in : in std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        
        selected_bias_bank_in_valid : in std_logic;
        selected_bias_bank_in_ready : out std_logic;
        selected_bias_bank_in : in std_logic_vector(BIAS_ADDRESS_LENGTH - 1 downto 0);
        
        pipeline_start_en : out std_logic;
        
        register_write_back_address_valid : in std_logic;
        register_write_back_address_ready : out std_logic;
        register_write_back_address : in std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        register_write_back_ready : in std_logic;
        
        accumulator_write_back_address_valid : in std_logic;
        accumulator_write_back_address_ready : out std_logic;
        accumulator_write_back_address : in std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        accumulator_write_back_ready : in std_logic
    );
end dependency_handler;

architecture Behavioral of dependency_handler is    
    signal vector_register_scoreboard_read_ready : std_logic;
    signal vector_register_scoreboard_write_ready : std_logic;
    signal bias_scoreboard_read_ready : std_logic;
    signal systolic_array_scoreboard_read_ready : std_logic;
    signal accumulator_scoreboard_read_ready : std_logic;
    signal accumulator_scoreboard_write_ready : std_logic;
begin    
    
    register_read_address_in_ready <= vector_register_scoreboard_read_ready;
    register_write_address_in_ready <= vector_register_scoreboard_write_ready;
    systolic_array_selected_weight_bank_in_ready <= systolic_array_scoreboard_read_ready;
    selected_bias_bank_in_ready <= bias_scoreboard_read_ready;
    selected_accumulator_bank_write_in_ready <= '1'; -- Disabling accumulator write is not needed, because there is only one pipeline that writes it
    selected_accumulator_bank_read_in_ready <= accumulator_scoreboard_read_ready;
    
    pipeline_start_en <= vector_register_scoreboard_read_ready and
                         vector_register_scoreboard_write_ready and
                         bias_scoreboard_read_ready and
                         accumulator_scoreboard_read_ready;

    vector_register_scoreboard_inst : entity work.scoreboard_module
        generic map (
            NUM_OF_REGISTERS => NUM_OF_VECTOR_REGISTERS,
            ADDRESS_LENGTH => REGISTER_ADDRESS_LENGTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            pipeline_ready => vector_register_pipeline_ready and pipeline_start_en,
            
            read_address1_valid => register_read_address_in_valid,
            read_address1_ready => vector_register_scoreboard_read_ready,
            read_address1 => register_read_address_in,
            
            read_address2_valid => systolic_array_selected_weight_bank_in_valid,
            read_address2_ready => systolic_array_scoreboard_read_ready,
            read_address2 => std_logic_vector(resize(unsigned(systolic_array_selected_weight_bank_in), REGISTER_ADDRESS_LENGTH)) and x"0200",
            
            read_address3_valid => selected_bias_bank_in_valid,
            read_address3_ready => bias_scoreboard_read_ready,
            read_address3 => std_logic_vector(resize(unsigned(selected_bias_bank_in), REGISTER_ADDRESS_LENGTH)) and x"0100",
            
            write_address_valid => register_write_address_in_valid,
            write_address_ready => vector_register_scoreboard_write_ready,
            write_address => register_write_address_in,
            
            dst_address_valid => register_write_back_address_valid,
            dst_address_ready => register_write_back_address_ready,
            dst_address => register_write_back_address,
            dst_write_ready => register_write_back_ready
        );

    accumulator_scoreboard_inst : entity work.scoreboard_module
        generic map (
            NUM_OF_REGISTERS => NUM_OF_ACCUMULATOR_REGISTERS,
            ADDRESS_LENGTH => ACCUMULATOR_ADDRESS_LENGTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            pipeline_ready => accumulator_pipeline_ready and pipeline_start_en,
            
            read_address1_valid => selected_accumulator_bank_read_in_valid,
            read_address1_ready => accumulator_scoreboard_read_ready,
            read_address1 => selected_accumulator_bank_read_in,
            
            read_address2_valid => '0',
            read_address2 => (others => '0'),
            
            read_address3_valid => '0',
            read_address3 => (others => '0'),
            
            write_address_valid => selected_accumulator_bank_write_in_valid,
            write_address_ready => accumulator_scoreboard_write_ready,
            write_address => selected_accumulator_bank_write_in,
            
            dst_address_valid => accumulator_write_back_address_valid,
            dst_address_ready => accumulator_write_back_address_ready,
            dst_address => accumulator_write_back_address,
            dst_write_ready => accumulator_write_back_ready
        );

end Behavioral;
