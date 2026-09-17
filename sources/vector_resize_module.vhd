----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/22/2026 02:02:54 PM
-- Design Name: 
-- Module Name: vector_resize_module - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vector_resize_module is
    generic (
        INPUT_WIDTH : natural := 32;
        ADDRESS_WIDTH : natural := 32;
        OUTPUT_WIDTH : natural := 8;
        VECTOR_LENGTH : natural := 8;
        RESIZE_MODE_LENGTH : natural := 3
    );
    port (
        clk : in std_logic;
        
        rst : in std_logic;
        
        resize_mode_valid : in std_logic;
        resize_mode_ready : out std_logic;
        resize_mode : in std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);
        
        data_in_valid : in std_logic;
        data_in_ready : out std_logic;
        data_in : in data_vector(0 to VECTOR_LENGTH - 1)(INPUT_WIDTH - 1 downto 0);

        write_address_in_valid : in std_logic;
        write_address_in_ready : out std_logic;
        write_address_in : in std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
        
        data_out_valid: out std_logic;
        data_out_ready : in std_logic;
        data_out : out data_vector(0 to VECTOR_LENGTH - 1)(OUTPUT_WIDTH - 1 downto 0);

        write_address_out_valid : out std_logic;
        write_address_out_ready : in std_logic;
        write_address_out : out std_logic_vector(ADDRESS_WIDTH - 1 downto 0)
    );
end vector_resize_module;

architecture Behavioral of vector_resize_module is
    constant VECTOR_RESIZE_DELAY : natural := 2;
    signal saturation_en : std_logic;
begin

    vector_resize_inst : entity work.vector_resize
        generic map (
            INPUT_WIDTH => INPUT_WIDTH,
            OUTPUT_WIDTH => OUTPUT_WIDTH,
            VECTOR_LENGTH => VECTOR_LENGTH,
            RESIZE_MODE_LENGTH => RESIZE_MODE_LENGTH
        )
        port map (
            clk => clk,
            
            en => saturation_en,
            resize_mode => resize_mode,
            
            data_in => data_in,
            
            data_out => data_out
        );
        
    vector_stauration_controller_inst : entity work.vector_resize_controller
        generic map (
            VECTOR_RESIZE_DELAY => VECTOR_RESIZE_DELAY
        )
        port map (
            clk => clk,
            
            rst => rst,
            
            saturation_en => saturation_en,
            
            data_in_valid => data_in_valid,
            data_in_ready => data_in_ready,
            resize_mode_valid => resize_mode_valid,
            resize_mode_ready => resize_mode_ready,
            write_address_in_valid => write_address_in_valid,
            write_address_in_ready => write_address_in_ready,
            
            data_out_valid => data_out_valid,
            data_out_ready => data_out_ready,
            write_address_out_valid => write_address_out_valid,
            write_address_out_ready => write_address_out_ready
        );

    vector_resize_write_address_controller_inst : entity work.vector_resize_write_address_controller
        generic map (
            ADDRESS_WIDTH => ADDRESS_WIDTH,
            VECTOR_RESIZE_DELAY => VECTOR_RESIZE_DELAY
        )
        port map (
            clk => clk,
            en => saturation_en,
            write_address_in => write_address_in,
            write_address_out => write_address_out
        );

end Behavioral;
