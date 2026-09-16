----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 08/30/2026
-- Design Name:
-- Module Name: axi_slave_protocol_adapter - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--  AXI4-Lite slave to ready/valid address-payload protocol adapter.
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

entity axi_slave_protocol_adapter is
    generic (
        AXI_DATA_WIDTH : natural := 32;
        AXI_ADDR_WIDTH : natural := 32
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        s_axi_awaddr  : in std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0);
        s_axi_awvalid : in std_logic;
        s_axi_awready : out std_logic;

        s_axi_wdata  : in std_logic_vector(AXI_DATA_WIDTH - 1 downto 0);
        s_axi_wstrb  : in std_logic_vector((AXI_DATA_WIDTH / 8) - 1 downto 0);
        s_axi_wvalid : in std_logic;
        s_axi_wready : out std_logic;

        s_axi_bresp  : out std_logic_vector(1 downto 0);
        s_axi_bvalid : out std_logic;
        s_axi_bready : in std_logic;

        s_axi_araddr  : in std_logic_vector(AXI_ADDR_WIDTH - 1 downto 0);
        s_axi_arvalid : in std_logic;
        s_axi_arready : out std_logic;

        s_axi_rdata  : out std_logic_vector(AXI_DATA_WIDTH - 1 downto 0);
        s_axi_rresp  : out std_logic_vector(1 downto 0);
        s_axi_rvalid : out std_logic;
        s_axi_rready : in std_logic;

        write_address_valid : out std_logic;
        write_address_ready : in std_logic;
        write_address_data  : out std_logic_vector(AXI_DATA_WIDTH - 1 downto 0);

        write_data_valid : out std_logic;
        write_data_ready : in std_logic;
        write_data_data  : out std_logic_vector(AXI_DATA_WIDTH - 1 downto 0);

        read_address_valid : out std_logic;
        read_address_ready : in std_logic;
        read_address_data  : out std_logic_vector(AXI_DATA_WIDTH - 1 downto 0);

        read_data_valid : in std_logic;
        read_data_ready : out std_logic;
        read_data_data  : in std_logic_vector(AXI_DATA_WIDTH - 1 downto 0)
    );
end axi_slave_protocol_adapter;

architecture Behavioral of axi_slave_protocol_adapter is
    attribute X_INTERFACE_INFO : string;
    attribute X_INTERFACE_PARAMETER : string;
    attribute X_INTERFACE_MODE : string;

    attribute X_INTERFACE_INFO of clk : signal is "xilinx.com:signal:clock:1.0 clk CLK";
    attribute X_INTERFACE_PARAMETER of clk : signal is "ASSOCIATED_BUSIF S_AXI, ASSOCIATED_RESET rst";

    attribute X_INTERFACE_INFO of rst : signal is "xilinx.com:signal:reset:1.0 rst RST";
    attribute X_INTERFACE_PARAMETER of rst : signal is "POLARITY ACTIVE_HIGH";

    attribute X_INTERFACE_INFO of s_axi_awaddr : signal is "xilinx.com:interface:aximm:1.0 S_AXI AWADDR";
    attribute X_INTERFACE_INFO of s_axi_awvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI AWVALID";
    attribute X_INTERFACE_INFO of s_axi_awready : signal is "xilinx.com:interface:aximm:1.0 S_AXI AWREADY";
    attribute X_INTERFACE_INFO of s_axi_wdata : signal is "xilinx.com:interface:aximm:1.0 S_AXI WDATA";
    attribute X_INTERFACE_INFO of s_axi_wstrb : signal is "xilinx.com:interface:aximm:1.0 S_AXI WSTRB";
    attribute X_INTERFACE_INFO of s_axi_wvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI WVALID";
    attribute X_INTERFACE_INFO of s_axi_wready : signal is "xilinx.com:interface:aximm:1.0 S_AXI WREADY";
    attribute X_INTERFACE_INFO of s_axi_bresp : signal is "xilinx.com:interface:aximm:1.0 S_AXI BRESP";
    attribute X_INTERFACE_INFO of s_axi_bvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI BVALID";
    attribute X_INTERFACE_INFO of s_axi_bready : signal is "xilinx.com:interface:aximm:1.0 S_AXI BREADY";
    attribute X_INTERFACE_INFO of s_axi_araddr : signal is "xilinx.com:interface:aximm:1.0 S_AXI ARADDR";
    attribute X_INTERFACE_INFO of s_axi_arvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI ARVALID";
    attribute X_INTERFACE_INFO of s_axi_arready : signal is "xilinx.com:interface:aximm:1.0 S_AXI ARREADY";
    attribute X_INTERFACE_INFO of s_axi_rdata : signal is "xilinx.com:interface:aximm:1.0 S_AXI RDATA";
    attribute X_INTERFACE_INFO of s_axi_rresp : signal is "xilinx.com:interface:aximm:1.0 S_AXI RRESP";
    attribute X_INTERFACE_INFO of s_axi_rvalid : signal is "xilinx.com:interface:aximm:1.0 S_AXI RVALID";
    attribute X_INTERFACE_INFO of s_axi_rready : signal is "xilinx.com:interface:aximm:1.0 S_AXI RREADY";
    attribute X_INTERFACE_PARAMETER of s_axi_awaddr : signal is "XIL_INTERFACENAME S_AXI, PROTOCOL AXI4LITE, ADDR_WIDTH 32, DATA_WIDTH 32, FREQ_HZ 100000000";
    attribute X_INTERFACE_MODE of s_axi_awaddr : signal is "slave";

    constant AXI_RESP_OKAY : std_logic_vector(1 downto 0) := "00";

    signal write_address_valid_reg : std_logic;
    signal write_address_data_reg  : std_logic_vector(AXI_DATA_WIDTH - 1 downto 0);
    signal write_payload_valid_reg : std_logic;
    signal write_payload_data_reg  : std_logic_vector(AXI_DATA_WIDTH - 1 downto 0);
    signal read_address_valid_reg  : std_logic;
    signal read_address_data_reg   : std_logic_vector(AXI_DATA_WIDTH - 1 downto 0);

    signal write_address_accepted : std_logic;
    signal write_payload_accepted : std_logic;
    signal write_response_valid   : std_logic;

    signal read_request_pending : std_logic;
    signal read_response_valid : std_logic;
    signal read_response_data  : std_logic_vector(AXI_DATA_WIDTH - 1 downto 0);

    signal s_axi_awready_int : std_logic;
    signal s_axi_wready_int  : std_logic;
    signal s_axi_arready_int : std_logic;
    signal read_payload_ready_int : std_logic;
begin

    s_axi_awready_int <= write_address_ready and
                         not write_address_valid_reg and
                         not write_address_accepted and
                         not write_response_valid;
    s_axi_wready_int <= write_data_ready and
                        not write_payload_valid_reg and
                        not write_payload_accepted and
                        not write_response_valid;
    s_axi_arready_int <= read_address_ready and
                         not read_address_valid_reg and
                         not read_request_pending and
                         not read_response_valid;
    read_payload_ready_int <= read_request_pending and not read_response_valid;

    s_axi_awready <= s_axi_awready_int;
    s_axi_wready <= s_axi_wready_int;
    s_axi_arready <= s_axi_arready_int;

    write_address_valid <= write_address_valid_reg;
    write_address_data <= write_address_data_reg;
    write_data_valid <= write_payload_valid_reg;
    write_data_data <= write_payload_data_reg;
    read_address_valid <= read_address_valid_reg;
    read_address_data <= read_address_data_reg;
    read_data_ready <= read_payload_ready_int;

    s_axi_bvalid <= write_response_valid;
    s_axi_bresp <= AXI_RESP_OKAY;

    s_axi_rvalid <= read_response_valid;
    s_axi_rresp <= AXI_RESP_OKAY;
    s_axi_rdata <= read_response_data;

    process (clk, rst) begin
        if rst = '1' then
            write_address_valid_reg <= '0';
        elsif rising_edge(clk) then
            if write_address_ready = '1' then
                write_address_valid_reg <= s_axi_awvalid and s_axi_awready_int;
            else
                write_address_valid_reg <= write_address_valid_reg;
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if s_axi_awready_int = '1' and s_axi_awvalid = '1' then
                write_address_data_reg <= std_logic_vector(resize(unsigned(s_axi_awaddr), AXI_DATA_WIDTH));
            else
                write_address_data_reg <= write_address_data_reg;
            end if;
        end if;
    end process;

    process (clk, rst) begin
        if rst = '1' then
            write_payload_valid_reg <= '0';
        elsif rising_edge(clk) then
            if write_data_ready = '1' then
                write_payload_valid_reg <= s_axi_wvalid and s_axi_wready_int;
            else
                write_payload_valid_reg <= write_payload_valid_reg;
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if s_axi_wready_int = '1' and s_axi_wvalid = '1' then
                write_payload_data_reg <= s_axi_wdata;
            else
                write_payload_data_reg <= write_payload_data_reg;
            end if;
        end if;
    end process;

    process (clk, rst) begin
        if rst = '1' then
            read_address_valid_reg <= '0';
        elsif rising_edge(clk) then
            if read_address_ready = '1' then
                read_address_valid_reg <= s_axi_arvalid and s_axi_arready_int;
            else
                read_address_valid_reg <= read_address_valid_reg;
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if s_axi_arready_int = '1' and s_axi_arvalid = '1' then
                read_address_data_reg <= std_logic_vector(resize(unsigned(s_axi_araddr), AXI_DATA_WIDTH));
            else
                read_address_data_reg <= read_address_data_reg;
            end if;
        end if;
    end process;

    process (clk, rst) begin
        if rst = '1' then
            write_address_accepted <= '0';
            write_payload_accepted <= '0';
            write_response_valid <= '0';
        elsif rising_edge(clk) then
            if write_response_valid = '1' then
                if s_axi_bready = '1' then
                    write_response_valid <= '0';
                    write_address_accepted <= '0';
                    write_payload_accepted <= '0';
                end if;
            else
                if write_address_valid_reg = '1' and write_address_ready = '1' then
                    write_address_accepted <= '1';
                end if;

                if write_payload_valid_reg = '1' and write_data_ready = '1' then
                    write_payload_accepted <= '1';
                end if;

                if ((write_address_accepted = '1') or
                    (write_address_valid_reg = '1' and write_address_ready = '1')) and
                   ((write_payload_accepted = '1') or
                    (write_payload_valid_reg = '1' and write_data_ready = '1')) then
                    write_response_valid <= '1';
                end if;
            end if;
        end if;
    end process;

    process (clk, rst) begin
        if rst = '1' then
            read_request_pending <= '0';
        elsif rising_edge(clk) then
            if read_payload_ready_int = '1' and read_data_valid = '1' then
                read_request_pending <= '0';
            elsif read_address_valid_reg = '1' and read_address_ready = '1' then
                read_request_pending <= '1';
            else
                read_request_pending <= read_request_pending;
            end if;
        end if;
    end process;

    process (clk, rst) begin
        if rst = '1' then
            read_response_valid <= '0';
        elsif rising_edge(clk) then
            if read_response_valid = '1' then
                if s_axi_rready = '1' then
                    read_response_valid <= '0';
                end if;
            elsif read_payload_ready_int = '1' then
                read_response_valid <= read_data_valid;
            else
                read_response_valid <= read_response_valid;
            end if;
        end if;
    end process;

    process (clk) begin
        if rising_edge(clk) then
            if read_payload_ready_int = '1' and read_data_valid = '1' then
                read_response_data <= read_data_data;
            else
                read_response_data <= read_response_data;
            end if;
        end if;
    end process;

end Behavioral;
