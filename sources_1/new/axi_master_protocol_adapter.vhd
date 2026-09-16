library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity axi_master_protocol_adapter is
    generic (
        AXI_ADDR_WIDTH : positive := 32;
        AXI_DATA_WIDTH : positive := 32
    );
    port (
        clk    : in  std_logic;
        aresetn : in  std_logic;

        wr_addr_valid : in  std_logic;
        wr_addr_ready : out std_logic;
        wr_addr_data  : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);


        wr_data_valid : in  std_logic;
        wr_data_ready : out std_logic;
        wr_data  : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);

        rd_addr_valid : in  std_logic;
        rd_addr_ready : out std_logic;
        rd_addr_data  : in  std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);


        rd_data_valid : out std_logic;
        rd_data_ready : in  std_logic;
        rd_data  : out std_logic_vector(AXI_DATA_WIDTH-1 downto 0);


        -----------------------------------------------------------------------
        -- AXI4-LITE MASTER
        -----------------------------------------------------------------------

        -- Write address channel
        m_axi_awaddr  : out std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        m_axi_awvalid : out std_logic;
        m_axi_awready : in  std_logic;

        -- Write data channel
        m_axi_wdata  : out std_logic_vector(
            AXI_DATA_WIDTH-1 downto 0
        );
        m_axi_wstrb  : out std_logic_vector(
            (AXI_DATA_WIDTH/8)-1 downto 0
        );
        m_axi_wvalid : out std_logic;
        m_axi_wready : in  std_logic;

        -- Write response channel
        m_axi_bresp  : in  std_logic_vector(1 downto 0);
        m_axi_bvalid : in  std_logic;
        m_axi_bready : out std_logic;

        -- Read address channel
        m_axi_araddr  : out std_logic_vector(AXI_ADDR_WIDTH-1 downto 0);
        m_axi_arvalid : out std_logic;
        m_axi_arready : in  std_logic;

        -- Read data channel
        m_axi_rdata  : in  std_logic_vector(AXI_DATA_WIDTH-1 downto 0);
        m_axi_rresp  : in  std_logic_vector(1 downto 0);
        m_axi_rvalid : in  std_logic;
        m_axi_rready : out std_logic
    );
end entity axi_master_protocol_adapter;


architecture rtl of axi_master_protocol_adapter is


    ---------------------------------------------------------------------------
    -- Vivado interface attributes
    ---------------------------------------------------------------------------

    attribute X_INTERFACE_INFO      : string;
    attribute X_INTERFACE_PARAMETER : string;
    attribute X_INTERFACE_MODE      : string;


    ---------------------------------------------------------------------------
    -- Clock
    ---------------------------------------------------------------------------

    attribute X_INTERFACE_INFO of clk : signal is "xilinx.com:signal:clock:1.0 aclk CLK";
    attribute X_INTERFACE_PARAMETER of clk : signal is "ASSOCIATED_BUSIF M_AXI, ASSOCIATED_RESET aresetn";


    ---------------------------------------------------------------------------
    -- Reset
    ---------------------------------------------------------------------------

    attribute X_INTERFACE_INFO of aresetn : signal is "xilinx.com:signal:reset:1.0 aresetn RST";
    attribute X_INTERFACE_PARAMETER of aresetn : signal is "POLARITY ACTIVE_LOW";


    ---------------------------------------------------------------------------
    -- AXI interface
    ---------------------------------------------------------------------------

    attribute X_INTERFACE_INFO of m_axi_awaddr : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWADDR";
    attribute X_INTERFACE_INFO of m_axi_awvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWVALID";
    attribute X_INTERFACE_INFO of m_axi_awready : signal is "xilinx.com:interface:aximm:1.0 M_AXI AWREADY";
    attribute X_INTERFACE_INFO of m_axi_wdata : signal is "xilinx.com:interface:aximm:1.0 M_AXI WDATA";
    attribute X_INTERFACE_INFO of m_axi_wstrb : signal is "xilinx.com:interface:aximm:1.0 M_AXI WSTRB";
    attribute X_INTERFACE_INFO of m_axi_wvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI WVALID";
    attribute X_INTERFACE_INFO of m_axi_wready : signal is "xilinx.com:interface:aximm:1.0 M_AXI WREADY";
    attribute X_INTERFACE_INFO of m_axi_bresp : signal is "xilinx.com:interface:aximm:1.0 M_AXI BRESP";
    attribute X_INTERFACE_INFO of m_axi_bvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI BVALID";
    attribute X_INTERFACE_INFO of m_axi_bready : signal is "xilinx.com:interface:aximm:1.0 M_AXI BREADY";
    attribute X_INTERFACE_INFO of m_axi_araddr : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARADDR";
    attribute X_INTERFACE_INFO of m_axi_arvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARVALID";
    attribute X_INTERFACE_INFO of m_axi_arready : signal is "xilinx.com:interface:aximm:1.0 M_AXI ARREADY";
    attribute X_INTERFACE_INFO of m_axi_rdata : signal is "xilinx.com:interface:aximm:1.0 M_AXI RDATA";
    attribute X_INTERFACE_INFO of m_axi_rresp : signal is "xilinx.com:interface:aximm:1.0 M_AXI RRESP";
    attribute X_INTERFACE_INFO of m_axi_rvalid : signal is "xilinx.com:interface:aximm:1.0 M_AXI RVALID";
    attribute X_INTERFACE_INFO of m_axi_rready : signal is "xilinx.com:interface:aximm:1.0 M_AXI RREADY";
    attribute X_INTERFACE_PARAMETER of m_axi_awaddr : signal is "XIL_INTERFACENAME M_AXI, PROTOCOL AXI4LITE, FREQ_HZ 100000000";
    attribute X_INTERFACE_MODE of m_axi_awaddr : signal is "master";

    ---------------------------------------------------------------------------
    -- Internal CUSTOM WRITE READY signals
    --
    -- Fontos:
    -- Ezeket használja a processz is, nem az OUT portokat.
    ---------------------------------------------------------------------------

    signal wr_addr_ready_i    : std_logic;
    signal wr_payload_ready_i : std_logic;


    ---------------------------------------------------------------------------
    -- WRITE registers
    ---------------------------------------------------------------------------

    signal wr_addr_reg : std_logic_vector(AXI_ADDR_WIDTH-1 downto 0) := (others => '0');

    signal wr_data_reg : std_logic_vector(AXI_DATA_WIDTH-1 downto 0) := (others => '0');


    ---------------------------------------------------------------------------
    -- WRITE buffer flags
    ---------------------------------------------------------------------------

    signal wr_addr_stored : std_logic := '0';
    signal wr_data_stored : std_logic := '0';


    ---------------------------------------------------------------------------
    -- AXI WRITE handshake flags
    ---------------------------------------------------------------------------

    signal aw_done : std_logic := '0';
    signal w_done  : std_logic := '0';


    ---------------------------------------------------------------------------
    -- WRITE state machine
    ---------------------------------------------------------------------------

    type wr_state_t is (
        WR_COLLECT,
        WR_AXI_TRANSFER,
        WR_RESPONSE
    );

    signal wr_state : wr_state_t := WR_COLLECT;


    ---------------------------------------------------------------------------
    -- Internal CUSTOM READ READY signal
    ---------------------------------------------------------------------------

    signal rd_addr_ready_i : std_logic;


    ---------------------------------------------------------------------------
    -- READ registers
    ---------------------------------------------------------------------------

    signal rd_addr_reg :
        std_logic_vector(AXI_ADDR_WIDTH-1 downto 0)
        := (others => '0');

    signal rd_data_reg :
        std_logic_vector(AXI_DATA_WIDTH-1 downto 0)
        := (others => '0');


    ---------------------------------------------------------------------------
    -- READ payload VALID register
    ---------------------------------------------------------------------------

    signal rd_payload_valid_reg : std_logic := '0';


    ---------------------------------------------------------------------------
    -- READ state machine
    ---------------------------------------------------------------------------

    type rd_state_t is (
        RD_COLLECT_ADDR,
        RD_AXI_ADDR,
        RD_AXI_DATA,
        RD_WAIT_USER_READY,
        RD_USER_TRANSFER
    );

    signal rd_state : rd_state_t := RD_COLLECT_ADDR;


begin


    ---------------------------------------------------------------------------
    -- Generic parameter checks
    ---------------------------------------------------------------------------

    assert AXI_DATA_WIDTH mod 8 = 0
        report "G_AXI_DATA_WIDTH must be divisible by 8"
        severity failure;


    ---------------------------------------------------------------------------
    -- ========================================================================
    -- CUSTOM WRITE INTERFACE
    -- ========================================================================
    ---------------------------------------------------------------------------

    wr_addr_ready_i <= '1'
        when (wr_state = WR_COLLECT)
         and (wr_addr_stored = '0')
        else '0';


    wr_payload_ready_i <= '1'
        when (wr_state = WR_COLLECT)
         and (wr_data_stored = '0')
        else '0';


    ---------------------------------------------------------------------------
    -- Drive output ports from internal signals.
    --
    -- A processz ezeket az internal jeleket olvassa.
    ---------------------------------------------------------------------------

    wr_addr_ready    <= wr_addr_ready_i;
    wr_data_ready <= wr_payload_ready_i;


    ---------------------------------------------------------------------------
    -- ========================================================================
    -- AXI WRITE OUTPUTS
    -- ========================================================================
    ---------------------------------------------------------------------------

    m_axi_awaddr <= wr_addr_reg;

    m_axi_wdata <= wr_data_reg;


    ---------------------------------------------------------------------------
    -- Minden byte érvényes.
    ---------------------------------------------------------------------------

    m_axi_wstrb <= (others => '1');


    ---------------------------------------------------------------------------
    -- AWVALID
    --
    -- Addig 1, amíg az AW handshake meg nem történik.
    ---------------------------------------------------------------------------

    m_axi_awvalid <= '1'
        when (wr_state = WR_AXI_TRANSFER)
         and (aw_done = '0')
        else '0';


    ---------------------------------------------------------------------------
    -- WVALID
    --
    -- Addig 1, amíg a W handshake meg nem történik.
    ---------------------------------------------------------------------------

    m_axi_wvalid <= '1'
        when (wr_state = WR_AXI_TRANSFER)
         and (w_done = '0')
        else '0';


    ---------------------------------------------------------------------------
    -- BREADY
    ---------------------------------------------------------------------------

    m_axi_bready <= '1'
        when wr_state = WR_RESPONSE
        else '0';


    ---------------------------------------------------------------------------
    -- ========================================================================
    -- WRITE STATE MACHINE
    -- ========================================================================
    ---------------------------------------------------------------------------

    write_proc : process(clk)

        variable addr_available : boolean;
        variable data_available : boolean;

        variable aw_finished : boolean;
        variable w_finished  : boolean;

    begin

        if rising_edge(clk) then

            if aresetn = '0' then

                wr_state <= WR_COLLECT;

                wr_addr_reg <= (others => '0');
                wr_data_reg <= (others => '0');

                wr_addr_stored <= '0';
                wr_data_stored <= '0';

                aw_done <= '0';
                w_done  <= '0';

            else

                case wr_state is


                    -----------------------------------------------------------------
                    -- COLLECT
                    --
                    -- Address és data egymástól függetlenül érkezhet.
                    -----------------------------------------------------------------

                    when WR_COLLECT =>

                        addr_available := (wr_addr_stored = '1');
                        data_available := (wr_data_stored = '1');


                        -------------------------------------------------------------
                        -- Address handshake
                        -------------------------------------------------------------

                        if (wr_addr_valid = '1')
                           and (wr_addr_ready_i = '1') then

                            wr_addr_reg <= wr_addr_data;

                            wr_addr_stored <= '1';

                            addr_available := true;

                        end if;


                        -------------------------------------------------------------
                        -- Payload handshake
                        -------------------------------------------------------------

                        if (wr_data_valid = '1')
                           and (wr_payload_ready_i = '1') then

                            wr_data_reg <= wr_data;

                            wr_data_stored <= '1';

                            data_available := true;

                        end if;


                        -------------------------------------------------------------
                        -- Mindkettő megérkezett.
                        -------------------------------------------------------------

                        if addr_available and data_available then

                            aw_done <= '0';
                            w_done  <= '0';

                            wr_state <= WR_AXI_TRANSFER;

                        end if;


                    -----------------------------------------------------------------
                    -- AXI WRITE TRANSFER
                    -----------------------------------------------------------------

                    when WR_AXI_TRANSFER =>

                        aw_finished := (aw_done = '1');
                        w_finished  := (w_done = '1');


                        -------------------------------------------------------------
                        -- AW handshake
                        -------------------------------------------------------------

                        if (aw_done = '0')
                           and (m_axi_awready = '1') then

                            aw_done <= '1';

                            aw_finished := true;

                        end if;


                        -------------------------------------------------------------
                        -- W handshake
                        -------------------------------------------------------------

                        if (w_done = '0')
                           and (m_axi_wready = '1') then

                            w_done <= '1';

                            w_finished := true;

                        end if;


                        -------------------------------------------------------------
                        -- Mindkét AXI csatorna elkészült.
                        -------------------------------------------------------------

                        if aw_finished and w_finished then

                            wr_state <= WR_RESPONSE;

                        end if;


                    -----------------------------------------------------------------
                    -- AXI WRITE RESPONSE
                    -----------------------------------------------------------------

                    when WR_RESPONSE =>

                        if m_axi_bvalid = '1' then

                            ---------------------------------------------------------
                            -- A custom protokollnak nincs response/error csatornája.
                            --
                            -- BRESP-et ezért itt elfogyasztjuk.
                            ---------------------------------------------------------

                            wr_addr_stored <= '0';
                            wr_data_stored <= '0';

                            aw_done <= '0';
                            w_done  <= '0';

                            wr_state <= WR_COLLECT;

                        end if;

                end case;

            end if;

        end if;

    end process;


    ---------------------------------------------------------------------------
    -- ========================================================================
    -- CUSTOM READ ADDRESS INTERFACE
    -- ========================================================================
    ---------------------------------------------------------------------------

    rd_addr_ready_i <= '1'
        when rd_state = RD_COLLECT_ADDR
        else '0';


    rd_addr_ready <= rd_addr_ready_i;


    ---------------------------------------------------------------------------
    -- ========================================================================
    -- AXI READ OUTPUTS
    -- ========================================================================
    ---------------------------------------------------------------------------

    m_axi_araddr <= rd_addr_reg;


    ---------------------------------------------------------------------------
    -- ARVALID
    ---------------------------------------------------------------------------

    m_axi_arvalid <= '1'
        when rd_state = RD_AXI_ADDR
        else '0';


    ---------------------------------------------------------------------------
    -- RREADY
    ---------------------------------------------------------------------------

    m_axi_rready <= '1'
        when rd_state = RD_AXI_DATA
        else '0';


    ---------------------------------------------------------------------------
    -- ========================================================================
    -- CUSTOM READ PAYLOAD OUTPUT
    -- ========================================================================
    ---------------------------------------------------------------------------

    rd_data  <= rd_data_reg;
    rd_data_valid <= rd_payload_valid_reg;


    ---------------------------------------------------------------------------
    -- ========================================================================
    -- READ STATE MACHINE
    -- ========================================================================
    ---------------------------------------------------------------------------

    read_proc : process(clk)
    begin

        if rising_edge(clk) then

            if aresetn = '0' then

                rd_state <= RD_COLLECT_ADDR;

                rd_addr_reg <= (others => '0');
                rd_data_reg <= (others => '0');

                rd_payload_valid_reg <= '0';

            else

                case rd_state is


                    -----------------------------------------------------------------
                    -- COLLECT READ ADDRESS
                    -----------------------------------------------------------------

                    when RD_COLLECT_ADDR =>

                        if (rd_addr_valid = '1')
                           and (rd_addr_ready_i = '1') then

                            rd_addr_reg <= rd_addr_data;

                            rd_state <= RD_AXI_ADDR;

                        end if;


                    -----------------------------------------------------------------
                    -- AXI READ ADDRESS
                    -----------------------------------------------------------------

                    when RD_AXI_ADDR =>

                        if m_axi_arready = '1' then

                            rd_state <= RD_AXI_DATA;

                        end if;


                    -----------------------------------------------------------------
                    -- AXI READ DATA
                    -----------------------------------------------------------------

                    when RD_AXI_DATA =>

                        if m_axi_rvalid = '1' then

                            rd_data_reg <= m_axi_rdata;

                            rd_state <= RD_WAIT_USER_READY;

                        end if;


                    -----------------------------------------------------------------
                    -- AXI data megérkezett, de a custom READY még 0.
                    --
                    -- FONTOS:
                    --
                    -- rd_payload_valid_reg továbbra is 0.
                    --
                    -- Csak READY=1 mellett engedjük 1-re.
                    -----------------------------------------------------------------

                    when RD_WAIT_USER_READY =>

                        if rd_data_ready = '1' then

                            rd_payload_valid_reg <= '1';

                            rd_state <= RD_USER_TRANSFER;

                        end if;


                    -----------------------------------------------------------------
                    -- Custom payload VALID=1.
                    --
                    -- Ha READY=0:
                    --
                    --     VALID marad 1
                    --     DATA stabil marad
                    --
                    -- Ha READY=1:
                    --
                    --     handshake
                    --     VALID -> 0
                    -----------------------------------------------------------------

                    when RD_USER_TRANSFER =>

                        if rd_data_ready = '1' then

                            rd_payload_valid_reg <= '0';

                            rd_state <= RD_COLLECT_ADDR;

                        end if;

                end case;

            end if;

        end if;

    end process;


end architecture rtl;
