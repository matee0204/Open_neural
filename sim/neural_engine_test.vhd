----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/15/2026 02:38:34 PM
-- Design Name: 
-- Module Name: neural_engine_test - Behavioral
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

entity neural_engine_test is
end neural_engine_test;

architecture Behavioral of neural_engine_test is
    constant INSTRUCTION_LENGTH                   : natural := 64;
    constant OPERATION_CODE_WIDTH                 : natural := 7;
    constant MEMORY_ADDRESS_WIDTH                 : natural := 32;
    constant REGISTER_ADDRESS_WIDTH               : natural := 16;
    constant REGISTER_BASE_ADDRESSES              : std_logic_vector := x"020001000000";
    constant REGISTER_ADDRESS_MASKS               : std_logic_vector := x"000F007F007F";
    constant REGISTER_ARRAY_DEPTH                 : natural := 128;
    constant SYSTOLIC_ARRAY_WEIGHT_ADDRESS_WIDTH  : natural := 8;
    constant BIAS_ADDRESS_WIDTH                   : natural := 8;
    constant BIAS_REGISTER_DEPTH                  : natural := 128;
    constant BIAS_OUTPUT_DATA_WIDTH               : natural := 32;
    constant ACCUMULATOR_ADDRESS_WIDTH            : natural := 8;
    constant ACCUMULATOR_DEPTH                    : natural := 128;
    constant ACCUMULATOR_OUTPUT_DATA_WIDTH        : natural := 32;
    constant ACCUMULATOR_MODE_LENGTH              : natural := 3;
    constant RESIZE_MODE_LENGTH                   : natural := 3;
    constant NUM_OF_VECTOR_REGISTERS              : natural := 768;
    constant NUM_OF_ACCUMULATOR_REGISTERS         : natural := 32;
    constant DATA_WIDTH                           : natural := 8;
    constant SYSTOLIC_ARRAY_SIZE                  : natural := 8;
    constant SYSTOLIC_ARRAY_OUTPUT_DATA_WIDTH     : natural := 24;
    constant SYSTOLIC_ARRAY_WEIGHT_REGISTER_DEPTH : natural := 2;

    signal clk : std_logic;
    signal rst : std_logic;
        
    signal sym_cntr : natural := 0;

    signal instruction_valid_inst : std_logic;
    signal instruction_ready_inst : std_logic;
    signal instruction_inst : std_logic_vector(INSTRUCTION_LENGTH - 1 downto 0);

    signal memory_write_address_out_valid_inst : std_logic;
    signal memory_write_address_out_ready_inst : std_logic;
    signal memory_write_address_out_inst : std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);

    signal memory_write_data_out_valid_inst : std_logic;
    signal memory_write_data_out_ready_inst : std_logic;
    signal memory_write_data_out_inst : std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto 0);

    signal memory_read_address_out_valid_inst : std_logic;
    signal memory_read_address_out_ready_inst : std_logic;
    signal memory_read_address_out_inst : std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);

    signal memory_read_data_in_valid_inst : std_logic;
    signal memory_read_data_in_ready_inst : std_logic;
    signal memory_read_data_in_inst : std_logic_vector(DATA_WIDTH * SYSTOLIC_ARRAY_SIZE - 1 downto 0);

begin

    process begin
        clk <= '0';
        wait for 1ns;
        clk <= '1';
        wait for 1ns;
    end process;
    
    process begin
        rst <= '1';
        wait for 10ns;
        rst <= '0';
        wait;
    end process;
    
    process (clk) begin
        if rising_edge(clk) and sym_cntr < natural'high then
            sym_cntr <= sym_cntr + 1;
        end if;
    end process;

    process (clk)
        variable opcode : std_logic_vector(OPERATION_CODE_WIDTH - 1 downto 0);
        variable memory_address : std_logic_vector(MEMORY_ADDRESS_WIDTH - 1 downto 0);
        variable register_address : std_logic_vector(REGISTER_ADDRESS_WIDTH - 1 downto 0);
        variable systolic_array_bank_address : std_logic_vector(SYSTOLIC_ARRAY_WEIGHT_ADDRESS_WIDTH - 1 downto 0);
        variable accumulator_write_address : std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0);
        variable accumulator_read_address : std_logic_vector(ACCUMULATOR_ADDRESS_WIDTH - 1 downto 0);
        variable accumulator_mode : std_logic_vector(ACCUMULATOR_MODE_LENGTH - 1 downto 0);
        variable bias_bank_address : std_logic_vector(BIAS_ADDRESS_WIDTH - 1 downto 0);
        variable resize_mode : std_logic_vector(RESIZE_MODE_LENGTH - 1 downto 0);
    begin
        if rising_edge(clk) then
            if sym_cntr = 5 then
                opcode := b"0000001";
                memory_address := x"00000001";
                register_address := x"0001";
                instruction_inst <= opcode & memory_address & register_address & b"0" & x"00";
            elsif sym_cntr = 6 then
                opcode := b"0000001";
                memory_address := x"00000002";
                register_address := x"0001";
                instruction_inst <= opcode & memory_address & register_address & b"0" & x"00";
             elsif sym_cntr = 7 then
                opcode := b"0000010";
                memory_address := x"00000002";
                register_address := x"0001";
                instruction_inst <= opcode & memory_address & register_address & b"0" & x"00";
                
             elsif sym_cntr = 32 then
                opcode := b"0000001";
                memory_address := x"00000001";
                register_address := x"0201";
                instruction_inst <= opcode & memory_address & register_address & b"0" & x"00";
             elsif sym_cntr = 33 then
                opcode := b"0000001";
                memory_address := x"00000002";
                register_address := x"0203";
                instruction_inst <= opcode & memory_address & register_address & b"0" & x"00";
             elsif sym_cntr = 34 then
                opcode := b"0000001";
                memory_address := x"00000003";
                register_address := x"0205";
                instruction_inst <= opcode & memory_address & register_address & b"0" & x"00";
             elsif sym_cntr = 35 then
                opcode := b"0000001";
                memory_address := x"00000004";
                register_address := x"0207";
                instruction_inst <= opcode & memory_address & register_address & b"0" & x"00";
             elsif sym_cntr = 36 then
                opcode := b"0000001";
                memory_address := x"00000005";
                register_address := x"0209";
                instruction_inst <= opcode & memory_address & register_address & b"0" & x"00";
             elsif sym_cntr = 37 then
                opcode := b"0000001";
                memory_address := x"00000006";
                register_address := x"020B";
                instruction_inst <= opcode & memory_address & register_address & b"0" & x"00";
             elsif sym_cntr = 38 then
                opcode := b"0000001";
                memory_address := x"00000007";
                register_address := x"020D";
                instruction_inst <= opcode & memory_address & register_address & b"0" & x"00";
             elsif sym_cntr = 39 then
                opcode := b"0000001";
                memory_address := x"00000008";
                register_address := x"020F";
                instruction_inst <= opcode & memory_address & register_address & b"0" & x"00";
             elsif sym_cntr = 67 then
                opcode := b"0000100";
                register_address := x"0001";
                accumulator_write_address := x"01";
                systolic_array_bank_address := x"01";
                accumulator_mode := b"001";
                instruction_inst <= opcode & register_address & accumulator_write_address & systolic_array_bank_address & accumulator_mode & b"00" & x"00000";
             elsif sym_cntr = 71 then
                opcode := b"0000100";
                register_address := x"0001";
                accumulator_write_address := x"01";
                systolic_array_bank_address := x"01";
                accumulator_mode := b"000";
                instruction_inst <= opcode & register_address & accumulator_write_address & systolic_array_bank_address & accumulator_mode & b"00" & x"00000";
             elsif sym_cntr = 72 then
                opcode := b"0000001";
                memory_address := x"00000001";
                register_address := x"0101";
                instruction_inst <= opcode & memory_address & register_address & b"0" & x"00";
             elsif sym_cntr = 75 then
                opcode := b"0000101";
                register_address := x"0002";
                accumulator_read_address := x"01";
                bias_bank_address := x"01";
                resize_mode := b"001";
                instruction_inst <= opcode & register_address & accumulator_read_address & bias_bank_address & resize_mode & b"00" & x"00000";
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 4 then
                instruction_valid_inst <= '0';
            elsif sym_cntr = 5 then
                instruction_valid_inst <= '1';
            elsif sym_cntr = 19 then
                instruction_valid_inst <= '0';
            elsif sym_cntr = 32 then
                instruction_valid_inst <= '1';
            elsif sym_cntr = 40 then
                instruction_valid_inst <= '0';
            elsif sym_cntr = 67 then
                instruction_valid_inst <= '1';
            elsif sym_cntr = 76 then
                instruction_valid_inst <= '0';
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 4 then
                memory_write_address_out_ready_inst <= '1';
                memory_write_data_out_ready_inst <= '1';
                memory_read_address_out_ready_inst <= '1';
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 4 then
                memory_read_data_in_valid_inst <= '0';
            elsif sym_cntr = 14 then
                memory_read_data_in_valid_inst <= '1';
            elsif sym_cntr = 15 then
                memory_read_data_in_valid_inst <= '0';
            elsif sym_cntr = 27 then
                memory_read_data_in_valid_inst <= '1';
            elsif sym_cntr = 28 then
                memory_read_data_in_valid_inst <= '0';
                
            elsif sym_cntr = 42 then
                memory_read_data_in_valid_inst <= '1';
            elsif sym_cntr = 43 then
                memory_read_data_in_valid_inst <= '0';
            elsif sym_cntr = 46 then
                memory_read_data_in_valid_inst <= '1';
            elsif sym_cntr = 47 then
                memory_read_data_in_valid_inst <= '0';
            elsif sym_cntr = 52 then
                memory_read_data_in_valid_inst <= '1';
            elsif sym_cntr = 53 then
                memory_read_data_in_valid_inst <= '0';
            elsif sym_cntr = 60 then
                memory_read_data_in_valid_inst <= '1';
            elsif sym_cntr = 61 then
                memory_read_data_in_valid_inst <= '0';
            elsif sym_cntr = 53 then
                memory_read_data_in_valid_inst <= '1';
            elsif sym_cntr = 54 then
                memory_read_data_in_valid_inst <= '0';
            elsif sym_cntr = 57 then
                memory_read_data_in_valid_inst <= '1';
            elsif sym_cntr = 58 then
                memory_read_data_in_valid_inst <= '0';
            elsif sym_cntr = 61 then
                memory_read_data_in_valid_inst <= '1';
            elsif sym_cntr = 62 then
                memory_read_data_in_valid_inst <= '0';
            elsif sym_cntr = 65 then
                memory_read_data_in_valid_inst <= '1';
            elsif sym_cntr = 66 then
                memory_read_data_in_valid_inst <= '0';
            elsif sym_cntr = 70 then
                memory_read_data_in_valid_inst <= '1';
            elsif sym_cntr = 71 then
                memory_read_data_in_valid_inst <= '0';
            elsif sym_cntr = 74 then
                memory_read_data_in_valid_inst <= '1';
            elsif sym_cntr = 75 then
                memory_read_data_in_valid_inst <= '0';
                
            elsif sym_cntr = 84 then
                memory_read_data_in_valid_inst <= '1';
            elsif sym_cntr = 85 then
                memory_read_data_in_valid_inst <= '0';
            end if;
        end if;
    end process;
    
    process (clk) begin
        if rising_edge(clk) then
            if sym_cntr = 4 then
                memory_read_data_in_inst <= (others => '0');
            elsif sym_cntr = 14 then
                memory_read_data_in_inst <= x"0101010101010101";
            elsif sym_cntr = 27 then
                memory_read_data_in_inst <= x"0202020202020202";
            elsif sym_cntr = 46 then
                memory_read_data_in_inst <= x"0303030303030303";
            elsif sym_cntr = 52 then
                memory_read_data_in_inst <= x"0404040404040404";
            elsif sym_cntr = 57 then
                memory_read_data_in_inst <= x"0505050505050505";
            elsif sym_cntr = 60 then
                memory_read_data_in_inst <= x"0606060606060606";
            elsif sym_cntr = 65 then
                memory_read_data_in_inst <= x"0707070707070707";
            elsif sym_cntr = 70 then
                memory_read_data_in_inst <= x"0808080808080808";
            elsif sym_cntr = 74 then
                memory_read_data_in_inst <= x"0909090909090909";
            elsif sym_cntr = 80 then
                memory_read_data_in_inst <= x"0101010101010101";
            end if;
        end if;
    end process;

    tb_neural_engine : entity work.neural_engine_wrapper
        generic map(
            INSTRUCTION_LENGTH                   => INSTRUCTION_LENGTH,
            OPERATION_CODE_WIDTH                 => OPERATION_CODE_WIDTH,
            MEMORY_ADDRESS_WIDTH                 => MEMORY_ADDRESS_WIDTH,
            REGISTER_ADDRESS_WIDTH               => REGISTER_ADDRESS_WIDTH,
            REGISTER_BASE_ADDRESSES              => REGISTER_BASE_ADDRESSES,
            REGISTER_ADDRESS_MASKS               => REGISTER_ADDRESS_MASKS,
            REGISTER_ARRAY_DEPTH                 => REGISTER_ARRAY_DEPTH,
            SYSTOLIC_ARRAY_WEIGHT_ADDRESS_WIDTH  => SYSTOLIC_ARRAY_WEIGHT_ADDRESS_WIDTH,
            BIAS_ADDRESS_WIDTH                   => BIAS_ADDRESS_WIDTH,
            BIAS_REGISTER_DEPTH                  => BIAS_REGISTER_DEPTH,
            BIAS_OUTPUT_DATA_WIDTH               => BIAS_OUTPUT_DATA_WIDTH,
            ACCUMULATOR_ADDRESS_WIDTH            => ACCUMULATOR_ADDRESS_WIDTH,
            ACCUMULATOR_DEPTH                    => ACCUMULATOR_DEPTH,
            ACCUMULATOR_OUTPUT_DATA_WIDTH        => ACCUMULATOR_OUTPUT_DATA_WIDTH,
            ACCUMULATOR_MODE_LENGTH              => ACCUMULATOR_MODE_LENGTH,
            RESIZE_MODE_LENGTH                   => RESIZE_MODE_LENGTH,
            NUM_OF_VECTOR_REGISTERS              => NUM_OF_VECTOR_REGISTERS,
            NUM_OF_ACCUMULATOR_REGISTERS         => NUM_OF_ACCUMULATOR_REGISTERS,
            DATA_WIDTH                           => DATA_WIDTH,
            SYSTOLIC_ARRAY_SIZE                  => SYSTOLIC_ARRAY_SIZE,
            SYSTOLIC_ARRAY_OUTPUT_DATA_WIDTH     => SYSTOLIC_ARRAY_OUTPUT_DATA_WIDTH,
            SYSTOLIC_ARRAY_WEIGHT_REGISTER_DEPTH => SYSTOLIC_ARRAY_WEIGHT_REGISTER_DEPTH
        )
        port map(
            clk                            => clk,
            rst                            => rst,
            instruction_valid              => instruction_valid_inst,
            instruction_ready              => instruction_ready_inst,
            instruction                    => instruction_inst,
            memory_write_address_out_valid => memory_write_address_out_valid_inst,
            memory_write_address_out_ready => memory_write_address_out_ready_inst,
            memory_write_address_out       => memory_write_address_out_inst,
            memory_write_data_out_valid    => memory_write_data_out_valid_inst,
            memory_write_data_out_ready    => memory_write_data_out_ready_inst,
            memory_write_data_out          => memory_write_data_out_inst,
            memory_read_address_out_valid  => memory_read_address_out_valid_inst,
            memory_read_address_out_ready  => memory_read_address_out_ready_inst,
            memory_read_address_out        => memory_read_address_out_inst,
            memory_read_data_in_valid      => memory_read_data_in_valid_inst,
            memory_read_data_in_ready      => memory_read_data_in_ready_inst,
            memory_read_data_in            => memory_read_data_in_inst
        );
    

end Behavioral;
