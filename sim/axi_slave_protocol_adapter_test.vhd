----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 08/30/2026
-- Design Name:
-- Module Name: axi_slave_protocol_adapter_test - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--  Testbench for axi_slave_protocol_adapter.
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

entity axi_slave_protocol_adapter_test is
end axi_slave_protocol_adapter_test;

architecture Behavioral of axi_slave_protocol_adapter_test is
    constant AXI_DATA_WIDTH : natural := 32;
    constant AXI_ADDR_WIDTH : natural := 32;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    signal s_axi_awaddr  : std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal s_axi_awvalid : std_logic := '0';
    signal s_axi_awready : std_logic;

    signal s_axi_wdata  : std_logic_vector(AXI_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal s_axi_wstrb  : std_logic_vector((AXI_DATA_WIDTH / 8) - 1 downto 0) := (others => '1');
    signal s_axi_wvalid : std_logic := '0';
    signal s_axi_wready : std_logic;

    signal s_axi_bresp  : std_logic_vector(1 downto 0);
    signal s_axi_bvalid : std_logic;
    signal s_axi_bready : std_logic := '0';

    signal s_axi_araddr  : std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0) := (others => '0');
    signal s_axi_arvalid : std_logic := '0';
    signal s_axi_arready : std_logic;

    signal s_axi_rdata  : std_logic_vector(AXI_DATA_WIDTH - 1 downto 0);
    signal s_axi_rresp  : std_logic_vector(1 downto 0);
    signal s_axi_rvalid : std_logic;
    signal s_axi_rready : std_logic := '0';

    signal write_address_valid : std_logic;
    signal write_address_ready : std_logic := '0';
    signal write_address_data  : std_logic_vector(AXI_DATA_WIDTH - 1 downto 0);

    signal write_data_valid : std_logic;
    signal write_data_ready : std_logic := '0';
    signal write_data_data  : std_logic_vector(AXI_DATA_WIDTH - 1 downto 0);

    signal read_address_valid : std_logic;
    signal read_address_ready : std_logic := '0';
    signal read_address_data  : std_logic_vector(AXI_DATA_WIDTH - 1 downto 0);

    signal read_data_valid : std_logic := '0';
    signal read_data_ready : std_logic;
    signal read_data_data  : std_logic_vector(AXI_DATA_WIDTH - 1 downto 0) := (others => '0');

    procedure wait_clk(signal clock : in std_logic) is
    begin
        wait until rising_edge(clock);
        wait for 1 ps;
    end procedure;
begin

    process begin
        clk <= '0';
        wait for 1 ns;
        clk <= '1';
        wait for 1 ns;
    end process;

    process begin
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
        wait;
    end process;

    process begin
        wait until rst = '0';
        wait_clk(clk);

        assert write_address_valid = '0'
            report "write_address_valid must be low after reset"
            severity error;
        assert write_data_valid = '0'
            report "write_payload_valid must be low after reset"
            severity error;
        assert read_address_valid = '0'
            report "read_address_valid must be low after reset"
            severity error;
        assert s_axi_bvalid = '0'
            report "s_axi_bvalid must be low after reset"
            severity error;
        assert s_axi_rvalid = '0'
            report "s_axi_rvalid must be low after reset"
            severity error;

        s_axi_awaddr <= x"00000100";
        s_axi_awvalid <= '1';
        s_axi_wdata <= x"DEADBEEF";
        s_axi_wvalid <= '1';
        wait for 1 ps;

        assert s_axi_awready = '0'
            report "AXI write address must not be accepted while write_address_ready is low"
            severity error;
        assert s_axi_wready = '0'
            report "AXI write payload must not be accepted while write_payload_ready is low"
            severity error;

        wait_clk(clk);

        assert write_address_valid = '0'
            report "write_address_valid changed while write_address_ready was low"
            severity error;
        assert write_data_valid = '0'
            report "write_payload_valid changed while write_payload_ready was low"
            severity error;

        write_address_ready <= '1';
        write_data_ready <= '1';
        wait for 1 ps;

        assert s_axi_awready = '1'
            report "AXI write address was not ready when adapter output was ready"
            severity error;
        assert s_axi_wready = '1'
            report "AXI write payload was not ready when adapter output was ready"
            severity error;

        wait_clk(clk);

        assert write_address_valid = '1'
            report "write_address_valid did not rise after AXI AW handshake"
            severity error;
        assert write_address_data = x"00000100"
            report "write_address_data does not match accepted AXI AW address"
            severity error;
        assert write_data_valid = '1'
            report "write_payload_valid did not rise after AXI W handshake"
            severity error;
        assert write_data_data = x"DEADBEEF"
            report "write_payload_data does not match accepted AXI W data"
            severity error;

        write_address_ready <= '0';
        write_data_ready <= '0';
        s_axi_awvalid <= '0';
        s_axi_wvalid <= '0';
        s_axi_awaddr <= x"00000200";
        s_axi_wdata <= x"12345678";

        wait_clk(clk);

        assert write_address_valid = '1'
            report "write_address_valid did not hold high while write_address_ready was low"
            severity error;
        assert write_address_data = x"00000100"
            report "write_address_data changed while valid was high and ready was low"
            severity error;
        assert write_data_valid = '1'
            report "write_payload_valid did not hold high while write_payload_ready was low"
            severity error;
        assert write_data_data = x"DEADBEEF"
            report "write_payload_data changed while valid was high and ready was low"
            severity error;

        write_address_ready <= '1';
        write_data_ready <= '1';
        wait_clk(clk);

        assert write_address_valid = '0'
            report "write_address_valid did not clear after output handshake"
            severity error;
        assert write_data_valid = '0'
            report "write_payload_valid did not clear after output handshake"
            severity error;
        assert s_axi_bvalid = '1'
            report "AXI write response did not become valid after address and payload transfer"
            severity error;
        assert s_axi_bresp = "00"
            report "AXI write response must be OKAY"
            severity error;

        write_address_ready <= '0';
        write_data_ready <= '0';
        wait_clk(clk);

        assert s_axi_bvalid = '1'
            report "AXI write response did not hold while BREADY was low"
            severity error;

        s_axi_bready <= '1';
        wait_clk(clk);
        s_axi_bready <= '0';

        assert s_axi_bvalid = '0'
            report "AXI write response did not clear after B handshake"
            severity error;

        s_axi_araddr <= x"00000300";
        s_axi_arvalid <= '1';
        wait for 1 ps;

        assert s_axi_arready = '0'
            report "AXI read address must not be accepted while read_address_ready is low"
            severity error;

        wait_clk(clk);

        assert read_address_valid = '0'
            report "read_address_valid changed while read_address_ready was low"
            severity error;

        read_address_ready <= '1';
        wait for 1 ps;

        assert s_axi_arready = '1'
            report "AXI read address was not ready when adapter output was ready"
            severity error;

        wait_clk(clk);

        assert read_address_valid = '1'
            report "read_address_valid did not rise after AXI AR handshake"
            severity error;
        assert read_address_data = x"00000300"
            report "read_address_data does not match accepted AXI AR address"
            severity error;

        read_address_ready <= '0';
        s_axi_arvalid <= '0';
        s_axi_araddr <= x"00000400";
        wait_clk(clk);

        assert read_address_valid = '1'
            report "read_address_valid did not hold high while read_address_ready was low"
            severity error;
        assert read_address_data = x"00000300"
            report "read_address_data changed while valid was high and ready was low"
            severity error;

        read_address_ready <= '1';
        wait_clk(clk);

        assert read_address_valid = '0'
            report "read_address_valid did not clear after output handshake"
            severity error;
        assert read_data_ready = '1'
            report "read_payload_ready did not rise after read address transfer"
            severity error;

        read_address_ready <= '0';
        read_data_data <= x"CAFEBABE";
        read_data_valid <= '1';
        wait_clk(clk);
        read_data_valid <= '0';

        assert s_axi_rvalid = '1'
            report "AXI read data response did not become valid after read payload transfer"
            severity error;
        assert s_axi_rdata = x"CAFEBABE"
            report "AXI read data does not match accepted read payload"
            severity error;
        assert s_axi_rresp = "00"
            report "AXI read response must be OKAY"
            severity error;
        assert read_data_ready = '0'
            report "read_payload_ready stayed high without a pending read request"
            severity error;

        read_data_data <= x"FFFFFFFF";
        wait_clk(clk);

        assert s_axi_rvalid = '1'
            report "AXI read response did not hold while RREADY was low"
            severity error;
        assert s_axi_rdata = x"CAFEBABE"
            report "AXI read response data changed while RVALID was high and RREADY was low"
            severity error;

        s_axi_rready <= '1';
        wait_clk(clk);
        s_axi_rready <= '0';

        assert s_axi_rvalid = '0'
            report "AXI read response did not clear after R handshake"
            severity error;

        assert false
            report "axi_slave_protocol_adapter_test completed successfully"
            severity note;
        wait;
    end process;

    tb_axi_slave_protocol_adapter : entity work.axi_slave_protocol_adapter
        generic map (
            AXI_DATA_WIDTH => AXI_DATA_WIDTH,
            AXI_ADDR_WIDTH => AXI_ADDR_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,

            s_axi_awaddr => s_axi_awaddr,
            s_axi_awvalid => s_axi_awvalid,
            s_axi_awready => s_axi_awready,

            s_axi_wdata => s_axi_wdata,
            s_axi_wstrb => s_axi_wstrb,
            s_axi_wvalid => s_axi_wvalid,
            s_axi_wready => s_axi_wready,

            s_axi_bresp => s_axi_bresp,
            s_axi_bvalid => s_axi_bvalid,
            s_axi_bready => s_axi_bready,

            s_axi_araddr => s_axi_araddr,
            s_axi_arvalid => s_axi_arvalid,
            s_axi_arready => s_axi_arready,

            s_axi_rdata => s_axi_rdata,
            s_axi_rresp => s_axi_rresp,
            s_axi_rvalid => s_axi_rvalid,
            s_axi_rready => s_axi_rready,

            write_address_valid => write_address_valid,
            write_address_ready => write_address_ready,
            write_address_data => write_address_data,

            write_data_valid => write_data_valid,
            write_data_ready => write_data_ready,
            write_data_data => write_data_data,

            read_address_valid => read_address_valid,
            read_address_ready => read_address_ready,
            read_address_data => read_address_data,

            read_data_valid => read_data_valid,
            read_data_ready => read_data_ready,
            read_data_data => read_data_data
        );

end Behavioral;
