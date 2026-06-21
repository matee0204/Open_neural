----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/19/2026 02:09:29 PM
-- Design Name: 
-- Module Name: register_writer - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_writer is
    generic (
        REG_ADDRESS_LENGTH : natural := 16;
        
        VECTOR_LENGTH : natural := 8;
        DATA_WIDTH : natural := 8
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        load_reg_address_valid : in std_logic;
        load_reg_address_ready : out std_logic;
        load_reg_address : in std_logic_vector(REG_ADDRESS_LENGTH - 1 downto 0);
        
        load_reg_data_valid : in std_logic;
        load_reg_data_ready : out std_logic;
        load_reg_data : in data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        mov_reg_address_valid : in std_logic;
        mov_reg_address_ready : out std_logic;
        mov_reg_address : in std_logic_vector(REG_ADDRESS_LENGTH - 1 downto 0);
        
        mov_reg_data_valid : in std_logic;
        mov_reg_data_ready : out std_logic;
        mov_reg_data : in data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        bias_quant_reg_address_valid : in std_logic;
        bias_quant_reg_address_ready : out std_logic;
        bias_quant_reg_address : in std_logic_vector(REG_ADDRESS_LENGTH - 1 downto 0);
        
        bias_quant_reg_data_valid : in std_logic;
        bias_quant_reg_data_ready : out std_logic;
        bias_quant_reg_data : in data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
        
        reg_address_valid : out std_logic;
        reg_address_ready : in std_logic;
        reg_address : out std_logic_vector(REG_ADDRESS_LENGTH - 1 downto 0);
        
        reg_data_valid : out std_logic;
        reg_data_ready : in std_logic;
        reg_data : out data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0)
    );
end register_writer;

architecture Behavioral of register_writer is
    constant NUM_OF_INPUT_ADDRESSES : natural := 3;
    constant LOAD_SELECTED : std_logic_vector(NUM_OF_INPUT_ADDRESSES - 1 downto 0) := std_logic_vector(to_unsigned(1, NUM_OF_INPUT_ADDRESSES));
    constant MOV_SELECTED : std_logic_vector(NUM_OF_INPUT_ADDRESSES - 1 downto 0) := std_logic_vector(to_unsigned(2, NUM_OF_INPUT_ADDRESSES));
    constant BIAS_QUANT_SELECTED : std_logic_vector(NUM_OF_INPUT_ADDRESSES - 1 downto 0) := std_logic_vector(to_unsigned(4, NUM_OF_INPUT_ADDRESSES));
    signal pipeline_en : std_logic;
    signal amount_of_shift : std_logic_vector(clog2(NUM_OF_INPUT_ADDRESSES) - 1 downto 0);
    signal valid_signals : std_logic_vector(NUM_OF_INPUT_ADDRESSES - 1 downto 0);
    signal shifted_valid_signals : std_logic_vector(NUM_OF_INPUT_ADDRESSES - 1 downto 0);
    signal priority_encoder_out : std_logic_vector(clog2(NUM_OF_INPUT_ADDRESSES) - 1 downto 0);
    signal has_one : std_logic;
    signal restored_valid_signals : std_logic_vector(NUM_OF_INPUT_ADDRESSES - 1 downto 0);
    signal grant_mask : std_logic_vector(NUM_OF_INPUT_ADDRESSES - 1 downto 0);
    signal selected_address : std_logic_vector(REG_ADDRESS_LENGTH - 1 downto 0);
    signal selected_data : data_vector(0 to VECTOR_LENGTH - 1)(DATA_WIDTH - 1 downto 0);
    signal selected_address_valid : std_logic;
    signal selected_data_valid : std_logic;
begin
    pipeline_en <= reg_address_ready and reg_data_ready;
    valid_signals <= bias_quant_reg_address_valid & mov_reg_address_valid & load_reg_address_valid;
    
    load_reg_address_ready <= restored_valid_signals(0) and pipeline_en and not rst;
    mov_reg_address_ready <= restored_valid_signals(1) and pipeline_en and not rst;
    bias_quant_reg_address_ready <= restored_valid_signals(2) and pipeline_en and not rst;
    
    load_reg_data_ready <= restored_valid_signals(0) and pipeline_en and not rst;
    mov_reg_data_ready <= restored_valid_signals(1) and pipeline_en and not rst;
    bias_quant_reg_data_ready <= restored_valid_signals(2) and pipeline_en and not rst;

    process (valid_signals, amount_of_shift) begin
        shifted_valid_signals <= std_logic_vector(rotate_right(unsigned(valid_signals), to_integer(unsigned(amount_of_shift))));
    end process;
    
    priority_encoder_inst : entity work.priority_encoder
        generic map (
            WIDTH => NUM_OF_INPUT_ADDRESSES
        )
        port map (
            data_in => shifted_valid_signals,
            
            data_out => priority_encoder_out,
            has_one => has_one
        );

    process (clk, rst) begin
        if (rst) then
            amount_of_shift <= (others => '0');
        else
            if rising_edge(clk) then
                amount_of_shift <= std_logic_vector(to_unsigned((to_integer(unsigned(amount_of_shift)) + to_integer(unsigned(priority_encoder_out))) mod NUM_OF_INPUT_ADDRESSES, amount_of_shift'length));
            end if;
        end if;
    end process;
        
    process (priority_encoder_out, has_one) begin
        if has_one = '1' then
            grant_mask <= (others => '0');
            grant_mask(to_integer(unsigned(priority_encoder_out))) <= '1';
        else
            grant_mask <= (others => '1');
        end if;
    end process;
        
    process (grant_mask, amount_of_shift) begin
        restored_valid_signals <= std_logic_vector(rotate_left(unsigned(grant_mask), to_integer(unsigned(amount_of_shift))));
    end process;
    
    reg_address <= selected_address;
    reg_data <= selected_data;
    
    process (clk) begin
        if rising_edge(clk) then
            if pipeline_en = '1' then
                case restored_valid_signals is
                    when LOAD_SELECTED =>
                        selected_address <= load_reg_address;
                        selected_data <= load_reg_data;
                    when MOV_SELECTED =>
                        selected_address <= mov_reg_address;
                        selected_data <= mov_reg_data;
                    when BIAS_QUANT_SELECTED =>
                        selected_address <= bias_quant_reg_address;
                        selected_data <= bias_quant_reg_data;
                    when others =>
                        selected_address <= (others => '0');
                        selected_data <= (others => (others => '0'));
                end case;
            else
                selected_address <= selected_address;
                selected_data <= selected_data;
            end if;
        end if;
    end process;
    
    reg_data_valid <= selected_data_valid;
    reg_address_valid <= selected_address_valid;
    
    process (clk, rst) begin
        if rst = '1' then
            selected_data_valid <= '0';
            selected_address_valid <= '0';
        else
            if rising_edge(clk) then
                if pipeline_en = '1' then
                    selected_data_valid <= load_reg_data_valid or mov_reg_data_valid or bias_quant_reg_data_valid;
                    selected_address_valid <= load_reg_address_valid or mov_reg_address_valid or bias_quant_reg_address_valid;
                else
                    selected_data_valid <= selected_data_valid;
                    selected_address_valid <= selected_address_valid;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
