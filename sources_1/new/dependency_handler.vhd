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
        NUM_OF_REGISTERS : natural := 128;
        NUM_OF_ACCUMULATOR_REGISTERS : natural := 128;
        REGISTER_ADDRESS_LENGTH : natural := 16;
        ACCUMULATOR_ADDRESS_LENGTH : natural := 8;
        NUM_OF_VECTOR_REGISTER_BLOCKS : natural := 3;

        VECTOR_REGISTER_BASE_ADDRESS : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0) := (others => '0');
        BIAS_REGISTER_BASE_ADDRESS : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0) := (others => '0');
        SYS_ARRAY_REGISTER_BASE_ADDRESS : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0) := (others => '0');

        VECTOR_REGISTER_ADDRESS_MASK : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0) := (others => '0');
        BIAS_REGISTER_ADDRESS_MASK : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0) := (others => '0');
        SYS_ARRAY_REGISTER_ADDRESS_MASK : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0) := (others => '0');

        VECTOR_REGISTER_MOD_OFFSET : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0) := (others => '0');
        BIAS_REGISTER_MOD_OFFSET : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0) := (others => '0');
        SYS_ARRAY_REGISTER_MOD_OFFSET : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0) := (others => '0')
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        pipeline_start_en : out std_logic;
        
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
        systolic_array_selected_weight_bank_in : in std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        selected_bias_bank_in_valid : in std_logic;
        selected_bias_bank_in_ready : out std_logic;
        selected_bias_bank_in : in std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        register_write_back_address_valid : in std_logic;
        register_write_back_address_ready : out std_logic;
        register_write_back_address : in std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
        
        selected_accumulator_bank_write_in_valid : in std_logic;
        selected_accumulator_bank_write_in_ready : out std_logic;
        selected_accumulator_bank_write_in : in std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        
        selected_accumulator_bank_read_in_valid : in std_logic;
        selected_accumulator_bank_read_in_ready : out std_logic;
        selected_accumulator_bank_read_in : in std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        register_write_back_ready : in std_logic;
        
        accumulator_write_back_address_valid : in std_logic;
        accumulator_write_back_address_ready : out std_logic;
        accumulator_write_back_address : in std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
        accumulator_write_back_ready : in std_logic
    );
end dependency_handler;

architecture Behavioral of dependency_handler is    
    signal vector_register_read_address_ready_from_vector_register_scoreboard : std_logic;
    signal vector_register_write_address_ready_from_vector_register_scoreboard : std_logic;
    signal bias_scoreboard_read_address_ready_from_vector_register_scoreboard : std_logic;
    signal systolic_array_read_address_ready_from_vector_register_scoreboard : std_logic;
    signal write_back_address_ready_from_vector_register_scoreboard : std_logic;
    signal accumulator_read_address_ready_from_accumulator_scoreboard : std_logic;
    signal accumulator_write_address_ready_from_accumulator_scoreboard : std_logic;
    signal write_back_address_ready_from_accumulator_scoreboard : std_logic;

    signal address_in_ready_from_vector_register_input_address_mapper_write : std_logic;
    signal address_out_valid_from_vector_register_input_address_mapper_write : std_logic;
    signal address_out_from_vector_register_input_address_mapper_write : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);

    signal address_in_ready_from_vector_register_input_address_mapper_vector_register_read : std_logic;
    signal address_out_valid_from_vector_register_input_address_mapper_vector_register_read : std_logic;
    signal address_out_from_vector_register_input_address_mapper_vector_register_read : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);

    signal address_in_ready_from_vector_register_input_address_mapper_systolic_array_read : std_logic;
    signal address_out_valid_from_vector_register_input_address_mapper_systolic_array_read : std_logic;
    signal address_out_from_vector_register_input_address_mapper_systolic_array_read : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);

    signal address_in_ready_from_vector_register_input_address_mapper_bias_read : std_logic;
    signal address_out_valid_from_vector_register_input_address_mapper_bias_read : std_logic;
    signal address_out_from_vector_register_input_address_mapper_bias_read : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);

    signal register_write_back_valid_to_vector_register_input_address_mapper_write_back : std_logic;
    signal address_in_ready_from_vector_register_input_address_mapper_write_back : std_logic;
    signal address_out_valid_from_vector_register_input_address_mapper_write_back : std_logic;
    signal address_out_from_vector_register_input_address_mapper_vector_write_back : std_logic_vector(REGISTER_ADDRESS_LENGTH - 1 downto 0);
    
    signal selected_accumulator_bank_read_in_valid_d : std_logic;
    signal selected_accumulator_bank_read_in_d : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
    signal accumulator_write_back_address_valid_d : std_logic;
    signal accumulator_write_back_address_d : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
    signal selected_accumulator_bank_write_in_valid_d : std_logic;
    signal selected_accumulator_bank_write_in_d : std_logic_vector(ACCUMULATOR_ADDRESS_LENGTH - 1 downto 0);
begin    

    register_write_address_in_ready <= address_in_ready_from_vector_register_input_address_mapper_write;

    vector_register_input_address_mapper_write_inst : entity work.address_mapper
        generic map(
            ADDRESS_WIDTH             => REGISTER_ADDRESS_LENGTH,
            NUMBER_OF_REGISTER_BLOCKS => NUM_OF_VECTOR_REGISTER_BLOCKS,
            ORIG_BASE_ADDR            => SYS_ARRAY_REGISTER_BASE_ADDRESS & BIAS_REGISTER_BASE_ADDRESS & VECTOR_REGISTER_BASE_ADDRESS,
            ORIG_ADDR_MASK            => SYS_ARRAY_REGISTER_ADDRESS_MASK & BIAS_REGISTER_ADDRESS_MASK & VECTOR_REGISTER_ADDRESS_MASK,
            MOD_ADDR_OFFSET           => SYS_ARRAY_REGISTER_MOD_OFFSET & BIAS_REGISTER_MOD_OFFSET & VECTOR_REGISTER_MOD_OFFSET
        )
        port map(
            clk               => clk,
            rst               => rst,

            address_in_valid  => register_write_address_in_valid,
            address_in_ready  => address_in_ready_from_vector_register_input_address_mapper_write,
            address_in        => register_write_address_in,

            address_out_valid => address_out_valid_from_vector_register_input_address_mapper_write,
            address_out_ready => vector_register_write_address_ready_from_vector_register_scoreboard,
            address_out       => address_out_from_vector_register_input_address_mapper_write
        );

    register_read_address_in_ready <= address_in_ready_from_vector_register_input_address_mapper_vector_register_read;

    vector_register_input_address_mapper_vector_register_read_inst : entity work.address_mapper
        generic map(
            ADDRESS_WIDTH             => REGISTER_ADDRESS_LENGTH,
            NUMBER_OF_REGISTER_BLOCKS => 1, -- There is only one register block, because this module handles only one address range
            ORIG_BASE_ADDR            => VECTOR_REGISTER_BASE_ADDRESS,
            ORIG_ADDR_MASK            => VECTOR_REGISTER_ADDRESS_MASK,
            MOD_ADDR_OFFSET           => VECTOR_REGISTER_MOD_OFFSET
        )
        port map(
            clk               => clk,
            rst               => rst,

            address_in_valid  => register_read_address_in_valid,
            address_in_ready  => address_in_ready_from_vector_register_input_address_mapper_vector_register_read,
            address_in        => register_read_address_in,

            address_out_valid => address_out_valid_from_vector_register_input_address_mapper_vector_register_read,
            address_out_ready => vector_register_read_address_ready_from_vector_register_scoreboard,
            address_out       => address_out_from_vector_register_input_address_mapper_vector_register_read
        );
    
    systolic_array_selected_weight_bank_in_ready <= address_in_ready_from_vector_register_input_address_mapper_systolic_array_read;

    vector_register_input_address_mapper_systolic_array_read_inst : entity work.address_mapper
        generic map(
            ADDRESS_WIDTH             => REGISTER_ADDRESS_LENGTH,
            NUMBER_OF_REGISTER_BLOCKS => 1, -- There is only one register block, because this module handles only one address range
            ORIG_BASE_ADDR            => BIAS_REGISTER_BASE_ADDRESS,
            ORIG_ADDR_MASK            => BIAS_REGISTER_ADDRESS_MASK,
            MOD_ADDR_OFFSET           => BIAS_REGISTER_MOD_OFFSET
        )
        port map(
            clk               => clk,
            rst               => rst,

            address_in_valid  => systolic_array_selected_weight_bank_in_valid,
            address_in_ready  => address_in_ready_from_vector_register_input_address_mapper_systolic_array_read,
            address_in        => systolic_array_selected_weight_bank_in,

            address_out_valid => address_out_valid_from_vector_register_input_address_mapper_systolic_array_read,
            address_out_ready => systolic_array_read_address_ready_from_vector_register_scoreboard,
            address_out       => address_out_from_vector_register_input_address_mapper_systolic_array_read
        );

    selected_bias_bank_in_ready <= address_in_ready_from_vector_register_input_address_mapper_bias_read;

    vector_register_input_address_mapper_bias_read_inst : entity work.address_mapper
        generic map(
            ADDRESS_WIDTH             => REGISTER_ADDRESS_LENGTH,
            NUMBER_OF_REGISTER_BLOCKS => 1, -- There is only one register block, because this module handles only one address range
            ORIG_BASE_ADDR            => SYS_ARRAY_REGISTER_BASE_ADDRESS,
            ORIG_ADDR_MASK            => SYS_ARRAY_REGISTER_ADDRESS_MASK,
            MOD_ADDR_OFFSET           => SYS_ARRAY_REGISTER_MOD_OFFSET
        )
        port map(
            clk               => clk,
            rst               => rst,

            address_in_valid  => selected_bias_bank_in_valid,
            address_in_ready  => address_in_ready_from_vector_register_input_address_mapper_bias_read,
            address_in        => selected_bias_bank_in,

            address_out_valid => address_out_valid_from_vector_register_input_address_mapper_bias_read,
            address_out_ready => bias_scoreboard_read_address_ready_from_vector_register_scoreboard,
            address_out       => address_out_from_vector_register_input_address_mapper_bias_read
        );

    register_write_back_address_ready <= address_in_ready_from_vector_register_input_address_mapper_write_back;
    register_write_back_valid_to_vector_register_input_address_mapper_write_back <= register_write_back_address_valid and register_write_back_ready;

    vector_register_input_address_mapper_writeback_inst : entity work.address_mapper
        generic map(
            ADDRESS_WIDTH             => REGISTER_ADDRESS_LENGTH,
            NUMBER_OF_REGISTER_BLOCKS => NUM_OF_VECTOR_REGISTER_BLOCKS,
            ORIG_BASE_ADDR            => SYS_ARRAY_REGISTER_BASE_ADDRESS & BIAS_REGISTER_BASE_ADDRESS & VECTOR_REGISTER_BASE_ADDRESS,
            ORIG_ADDR_MASK            => SYS_ARRAY_REGISTER_ADDRESS_MASK & BIAS_REGISTER_ADDRESS_MASK & VECTOR_REGISTER_ADDRESS_MASK,
            MOD_ADDR_OFFSET           => SYS_ARRAY_REGISTER_MOD_OFFSET & BIAS_REGISTER_MOD_OFFSET & VECTOR_REGISTER_MOD_OFFSET
        )
        port map(
            clk               => clk,
            rst               => rst,

            address_in_valid  => register_write_back_valid_to_vector_register_input_address_mapper_write_back,
            address_in_ready  => address_in_ready_from_vector_register_input_address_mapper_write_back,
            address_in        => register_write_back_address,

            address_out_valid => address_out_valid_from_vector_register_input_address_mapper_write_back,
            address_out_ready => write_back_address_ready_from_vector_register_scoreboard,
            address_out       => address_out_from_vector_register_input_address_mapper_vector_write_back
        );
    

    pipeline_start_en <= address_in_ready_from_vector_register_input_address_mapper_vector_register_read and
                         address_in_ready_from_vector_register_input_address_mapper_systolic_array_read and
                         address_in_ready_from_vector_register_input_address_mapper_bias_read and
                         accumulator_read_address_ready_from_accumulator_scoreboard and
                         address_in_ready_from_vector_register_input_address_mapper_write;

    vector_register_scoreboard_inst : entity work.scoreboard_module
        generic map (
            NUM_OF_REGISTERS => NUM_OF_REGISTERS,
            ADDRESS_LENGTH => REGISTER_ADDRESS_LENGTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            pipeline_ready => vector_register_pipeline_ready and pipeline_start_en,
            
            read_address1_valid => address_out_valid_from_vector_register_input_address_mapper_vector_register_read,
            read_address1_ready => vector_register_read_address_ready_from_vector_register_scoreboard,
            read_address1 => address_out_from_vector_register_input_address_mapper_vector_register_read,
            
            read_address2_valid => address_out_valid_from_vector_register_input_address_mapper_systolic_array_read,
            read_address2_ready => systolic_array_read_address_ready_from_vector_register_scoreboard,
            read_address2 => address_out_from_vector_register_input_address_mapper_systolic_array_read,
            
            read_address3_valid => address_out_valid_from_vector_register_input_address_mapper_bias_read,
            read_address3_ready => bias_scoreboard_read_address_ready_from_vector_register_scoreboard,
            read_address3 => address_out_from_vector_register_input_address_mapper_bias_read,
            
            write_address_valid => address_out_valid_from_vector_register_input_address_mapper_write,
            write_address_ready => vector_register_write_address_ready_from_vector_register_scoreboard,
            write_address => address_out_from_vector_register_input_address_mapper_write,
            
            dst_address_valid => address_out_valid_from_vector_register_input_address_mapper_write_back,
            dst_address_ready => write_back_address_ready_from_vector_register_scoreboard,
            dst_address => address_out_from_vector_register_input_address_mapper_vector_write_back
        );

    process (clk, rst) begin
        if rst = '1' then
            selected_accumulator_bank_read_in_valid_d <= '0';
        else
            if rising_edge(clk) then
                if accumulator_read_address_ready_from_accumulator_scoreboard = '1' then
                    selected_accumulator_bank_read_in_valid_d <= selected_accumulator_bank_read_in_valid;
                else
                    selected_accumulator_bank_read_in_valid_d <= selected_accumulator_bank_read_in_valid_d;
                end if;
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if accumulator_read_address_ready_from_accumulator_scoreboard = '1' then
                selected_accumulator_bank_read_in_d <= selected_accumulator_bank_read_in;
            else
                selected_accumulator_bank_read_in_d <= selected_accumulator_bank_read_in_d;
            end if;
        end if;
    end process;

    process (clk, rst) begin
        if rst = '1' then
            accumulator_write_back_address_valid_d <= '0';
        else
            if rising_edge(clk) then
                if write_back_address_ready_from_accumulator_scoreboard = '1' then
                    accumulator_write_back_address_valid_d <= accumulator_write_back_address_valid and accumulator_write_back_ready;
                else
                    accumulator_write_back_address_valid_d <= accumulator_write_back_address_valid_d;
                end if;
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if write_back_address_ready_from_accumulator_scoreboard = '1' then
                accumulator_write_back_address_d <= accumulator_write_back_address;
            else
                accumulator_write_back_address_d <= accumulator_write_back_address_d;
            end if;
        end if;
    end process;

    process (clk, rst) begin
        if rst = '1' then
            selected_accumulator_bank_write_in_valid_d <= '0';
        else
            if rising_edge(clk) then    -- No need to enable write because accumulator_write_address_ready_from_accumulator_scoreboard is not used and selected_accumulator_bank_write_in_ready is always 1
                selected_accumulator_bank_write_in_valid_d <= selected_accumulator_bank_write_in_valid;
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then    -- No need to enable write because accumulator_write_address_ready_from_accumulator_scoreboard is not used and selected_accumulator_bank_write_in_ready is always 1
            selected_accumulator_bank_write_in_d <= selected_accumulator_bank_write_in;
        end if;
    end process;

    accumulator_write_back_address_ready <= write_back_address_ready_from_accumulator_scoreboard;
    selected_accumulator_bank_write_in_ready <= '1'; -- Disabling accumulator write is not needed, because there is only one pipeline that writes it
    selected_accumulator_bank_read_in_ready <= accumulator_read_address_ready_from_accumulator_scoreboard;

    accumulator_scoreboard_inst : entity work.scoreboard_module
        generic map (
            NUM_OF_REGISTERS => NUM_OF_ACCUMULATOR_REGISTERS,
            ADDRESS_LENGTH => ACCUMULATOR_ADDRESS_LENGTH
        )
        port map (
            clk => clk,
            rst => rst,
            
            pipeline_ready => accumulator_pipeline_ready and pipeline_start_en,
            
            read_address1_valid => selected_accumulator_bank_read_in_valid_d,
            read_address1_ready => accumulator_read_address_ready_from_accumulator_scoreboard,
            read_address1 => selected_accumulator_bank_read_in_d,
            
            read_address2_valid => '0',
            read_address2 => (others => '0'),
            
            read_address3_valid => '0',
            read_address3 => (others => '0'),
            
            write_address_valid => selected_accumulator_bank_write_in_valid_d,
            write_address_ready => accumulator_write_address_ready_from_accumulator_scoreboard,
            write_address => selected_accumulator_bank_write_in_d,
            
            dst_address_valid => accumulator_write_back_address_valid_d,
            dst_address_ready => write_back_address_ready_from_accumulator_scoreboard,
            dst_address => accumulator_write_back_address_d
        );

end Behavioral;
