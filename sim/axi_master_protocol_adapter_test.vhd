library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb_custom_to_axi_master is
end entity;


architecture sim of tb_custom_to_axi_master is

    ---------------------------------------------------------------------------
    -- Parameters
    ---------------------------------------------------------------------------

    constant C_ADDR_WIDTH : positive := 32;
    constant C_DATA_WIDTH : positive := 32;

    constant C_CLK_PERIOD : time := 10 ns;


    ---------------------------------------------------------------------------
    -- Clock / Reset
    ---------------------------------------------------------------------------

    signal aclk    : std_logic := '0';
    signal aresetn : std_logic := '0';


    ---------------------------------------------------------------------------
    -- Custom WRITE address
    ---------------------------------------------------------------------------

    signal wr_addr_valid : std_logic := '0';
    signal wr_addr_ready : std_logic;
    signal wr_addr_data  :
        std_logic_vector(C_ADDR_WIDTH-1 downto 0) := (others => '0');


    ---------------------------------------------------------------------------
    -- Custom WRITE payload
    ---------------------------------------------------------------------------

    signal wr_payload_valid : std_logic := '0';
    signal wr_payload_ready : std_logic;
    signal wr_payload_data  :
        std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');


    ---------------------------------------------------------------------------
    -- Custom READ address
    ---------------------------------------------------------------------------

    signal rd_addr_valid : std_logic := '0';
    signal rd_addr_ready : std_logic;
    signal rd_addr_data  :
        std_logic_vector(C_ADDR_WIDTH-1 downto 0) := (others => '0');


    ---------------------------------------------------------------------------
    -- Custom READ payload
    ---------------------------------------------------------------------------

    signal rd_payload_valid : std_logic;
    signal rd_payload_ready : std_logic := '0';
    signal rd_payload_data  :
        std_logic_vector(C_DATA_WIDTH-1 downto 0);


    ---------------------------------------------------------------------------
    -- AXI WRITE address
    ---------------------------------------------------------------------------

    signal m_axi_awaddr :
        std_logic_vector(C_ADDR_WIDTH-1 downto 0);

    signal m_axi_awvalid : std_logic;
    signal m_axi_awready : std_logic := '0';


    ---------------------------------------------------------------------------
    -- AXI WRITE data
    ---------------------------------------------------------------------------

    signal m_axi_wdata :
        std_logic_vector(C_DATA_WIDTH-1 downto 0);

    signal m_axi_wstrb :
        std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);

    signal m_axi_wvalid : std_logic;
    signal m_axi_wready : std_logic := '0';


    ---------------------------------------------------------------------------
    -- AXI WRITE response
    ---------------------------------------------------------------------------

    signal m_axi_bresp :
        std_logic_vector(1 downto 0) := "00";

    signal m_axi_bvalid : std_logic := '0';
    signal m_axi_bready : std_logic;


    ---------------------------------------------------------------------------
    -- AXI READ address
    ---------------------------------------------------------------------------

    signal m_axi_araddr :
        std_logic_vector(C_ADDR_WIDTH-1 downto 0);

    signal m_axi_arvalid : std_logic;
    signal m_axi_arready : std_logic := '0';


    ---------------------------------------------------------------------------
    -- AXI READ data
    ---------------------------------------------------------------------------

    signal m_axi_rdata :
        std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');

    signal m_axi_rresp :
        std_logic_vector(1 downto 0) := "00";

    signal m_axi_rvalid : std_logic := '0';
    signal m_axi_rready : std_logic;


begin

    ---------------------------------------------------------------------------
    -- DUT
    ---------------------------------------------------------------------------

    dut : entity work.axi_master_protocol_adapter
        generic map (
            AXI_ADDR_WIDTH => C_ADDR_WIDTH,
            AXI_DATA_WIDTH => C_DATA_WIDTH
        )
        port map (
            clk    => aclk,
            aresetn => aresetn,

            wr_addr_valid => wr_addr_valid,
            wr_addr_ready => wr_addr_ready,
            wr_addr_data  => wr_addr_data,

            wr_data_valid => wr_payload_valid,
            wr_data_ready => wr_payload_ready,
            wr_data  => wr_payload_data,

            rd_addr_valid => rd_addr_valid,
            rd_addr_ready => rd_addr_ready,
            rd_addr_data  => rd_addr_data,

            rd_data_valid => rd_payload_valid,
            rd_data_ready => rd_payload_ready,
            rd_data  => rd_payload_data,

            m_axi_awaddr  => m_axi_awaddr,
            m_axi_awvalid => m_axi_awvalid,
            m_axi_awready => m_axi_awready,

            m_axi_wdata  => m_axi_wdata,
            m_axi_wstrb  => m_axi_wstrb,
            m_axi_wvalid => m_axi_wvalid,
            m_axi_wready => m_axi_wready,

            m_axi_bresp  => m_axi_bresp,
            m_axi_bvalid => m_axi_bvalid,
            m_axi_bready => m_axi_bready,

            m_axi_araddr  => m_axi_araddr,
            m_axi_arvalid => m_axi_arvalid,
            m_axi_arready => m_axi_arready,

            m_axi_rdata  => m_axi_rdata,
            m_axi_rresp  => m_axi_rresp,
            m_axi_rvalid => m_axi_rvalid,
            m_axi_rready => m_axi_rready
        );


    ---------------------------------------------------------------------------
    -- Clock
    ---------------------------------------------------------------------------

    clock_proc : process
    begin
        while true loop
            aclk <= '0';
            wait for C_CLK_PERIOD / 2;

            aclk <= '1';
            wait for C_CLK_PERIOD / 2;
        end loop;
    end process;


    ---------------------------------------------------------------------------
    -- Test sequence
    ---------------------------------------------------------------------------

    stimulus_proc : process

        -----------------------------------------------------------------------
        -- WRITE helper
        -----------------------------------------------------------------------

        procedure custom_write (
            constant address : in std_logic_vector(C_ADDR_WIDTH-1 downto 0);
            constant data    : in std_logic_vector(C_DATA_WIDTH-1 downto 0)
        ) is
        begin

            -------------------------------------------------------------------
            -- Address
            -------------------------------------------------------------------

            wr_addr_data  <= address;
            wr_addr_valid <= '1';

            loop
                wait until rising_edge(aclk);

                exit when wr_addr_ready = '1';
            end loop;

            wr_addr_valid <= '0';


            -------------------------------------------------------------------
            -- Payload
            --
            -- Szándékosan másik ciklusban küldjük.
            -------------------------------------------------------------------

            wait until rising_edge(aclk);

            wr_payload_data  <= data;
            wr_payload_valid <= '1';

            loop
                wait until rising_edge(aclk);

                exit when wr_payload_ready = '1';
            end loop;

            wr_payload_valid <= '0';


            -------------------------------------------------------------------
            -- AXI write transaction befejeződésére várunk.
            -------------------------------------------------------------------

            loop
                wait until rising_edge(aclk);

                exit when m_axi_bvalid = '1';
            end loop;

            assert m_axi_bresp = "00"
                report "AXI write response is not OKAY"
                severity error;

        end procedure;


        -----------------------------------------------------------------------
        -- READ helper
        -----------------------------------------------------------------------

        procedure custom_read (
            constant address        : in  std_logic_vector(C_ADDR_WIDTH-1 downto 0);
            constant expected_data : in  std_logic_vector(C_DATA_WIDTH-1 downto 0)
        ) is
        begin

            -------------------------------------------------------------------
            -- Send custom read address
            -------------------------------------------------------------------

            rd_addr_data  <= address;
            rd_addr_valid <= '1';

            loop
                wait until rising_edge(aclk);

                exit when rd_addr_ready = '1';
            end loop;

            rd_addr_valid <= '0';


            -------------------------------------------------------------------
            -- AXI read response megvárása.
            -------------------------------------------------------------------

            loop
                wait until rising_edge(aclk);

                exit when m_axi_rvalid = '1';
            end loop;


            -------------------------------------------------------------------
            -- Fontos:
            --
            -- Itt még READY = 0!
            --
            -- A DUT-nak ezért nem szabad VALID=1-re váltania.
            -------------------------------------------------------------------

            assert rd_payload_valid = '0'
                report "rd_payload_valid became 1 while rd_payload_ready = 0"
                severity error;


            -------------------------------------------------------------------
            -- READY felengedése.
            -------------------------------------------------------------------

            rd_payload_ready <= '1';


            -------------------------------------------------------------------
            -- Most már megjelenhet VALID.
            -------------------------------------------------------------------

            loop
                wait until rising_edge(aclk);

                exit when rd_payload_valid = '1';
            end loop;


            assert rd_payload_data = expected_data
                report "Incorrect read payload"
                severity error;


            -------------------------------------------------------------------
            -- Consume payload
            -------------------------------------------------------------------

            wait until rising_edge(aclk);

            assert rd_payload_valid = '0'
                report "rd_payload_valid did not deassert after handshake"
                severity error;

            rd_payload_ready <= '0';

        end procedure;


    begin

        report "========================================";
        report "Starting custom_to_axi_master testbench";
        report "========================================";


        -----------------------------------------------------------------------
        -- RESET
        -----------------------------------------------------------------------

        aresetn <= '0';

        m_axi_awready <= '0';
        m_axi_wready  <= '0';
        m_axi_arready <= '0';

        m_axi_bvalid <= '0';
        m_axi_rvalid <= '0';

        wait for 5 * C_CLK_PERIOD;

        aresetn <= '1';

        wait for 2 * C_CLK_PERIOD;


        -----------------------------------------------------------------------
        -- TEST 1
        --
        -- WRITE:
        --   cím előbb érkezik
        --   adat később érkezik
        --
        -- AXI oldalon AWREADY és WREADY eltérő időben lesz 1.
        -----------------------------------------------------------------------

        report "TEST 1: independent WRITE address/data channels";


        m_axi_awready <= '0';
        m_axi_wready  <= '0';


        -- Az írási folyamat külön processben történik,
        -- hogy itt tudjuk vezérelni az AXI slave-et.
        --
        -- A legegyszerűbb megoldás: cím handshake.
        wr_addr_data  <= x"00001000";
        wr_addr_valid <= '1';

        wait until rising_edge(aclk);

        assert wr_addr_ready = '1'
            report "WRITE address was not accepted"
            severity error;

        wr_addr_valid <= '0';


        -- Egy ciklusig ne legyen WREADY.
        wait until rising_edge(aclk);

        m_axi_awready <= '1';
        m_axi_wready  <= '0';


        wr_payload_data  <= x"12345678";
        wr_payload_valid <= '1';


        -- WREADY továbbra is 0.
        wait until rising_edge(aclk);

        assert wr_payload_valid = '1'
            report "Testbench internal error: payload VALID unexpectedly changed"
            severity error;


        -- Most elfogadjuk az adatot.
        m_axi_wready <= '1';

        wait until rising_edge(aclk);

        wr_payload_valid <= '0';


        -- AW és W már mindketten megvoltak.
        m_axi_awready <= '0';
        m_axi_wready  <= '0';


        -----------------------------------------------------------------------
        -- AXI write response
        -----------------------------------------------------------------------

        wait until rising_edge(aclk);

        assert m_axi_awvalid = '0'
            report "AWVALID still asserted after handshake"
            severity error;

        assert m_axi_wvalid = '0'
            report "WVALID still asserted after handshake"
            severity error;


        m_axi_bresp  <= "00";
        m_axi_bvalid <= '1';

        wait until rising_edge(aclk);

        assert m_axi_bready = '1'
            report "BREADY was not asserted"
            severity error;

        m_axi_bvalid <= '0';

        wait until rising_edge(aclk);


        report "TEST 1 PASSED";


        -----------------------------------------------------------------------
        -- TEST 2
        --
        -- READ response arrives while custom READY = 0.
        --
        -- Ellenőrizzük, hogy:
        --
        --   VALID = 0
        --   DATA lehet tetszőleges
        --
        -- majd READY = 1 után:
        --
        --   VALID = 1
        --   DATA = helyes adat
        -----------------------------------------------------------------------

        report "TEST 2: READ payload backpressure";


        rd_payload_ready <= '0';

        rd_addr_data  <= x"00002000";
        rd_addr_valid <= '1';


        -----------------------------------------------------------------------
        -- Read address elfogadása
        -----------------------------------------------------------------------

        m_axi_arready <= '1';

        wait until rising_edge(aclk);

        assert rd_addr_ready = '1'
            report "READ address was not accepted"
            severity error;

        rd_addr_valid <= '0';
        m_axi_arready <= '0';


        -----------------------------------------------------------------------
        -- AXI ARVALID-nek el kell tűnnie handshake után.
        -----------------------------------------------------------------------

        wait until rising_edge(aclk);

        assert m_axi_arvalid = '0'
            report "ARVALID still asserted after handshake"
            severity error;


        -----------------------------------------------------------------------
        -- AXI RDATA
        -----------------------------------------------------------------------

        m_axi_rdata  <= x"DEADBEEF";
        m_axi_rresp  <= "00";
        m_axi_rvalid <= '1';


        wait until rising_edge(aclk);

        assert m_axi_rready = '1'
            report "RREADY was not asserted"
            severity error;


        -----------------------------------------------------------------------
        -- AXI slave befejezi a tranzakciót.
        -----------------------------------------------------------------------

        m_axi_rvalid <= '0';


        -----------------------------------------------------------------------
        -- A custom READY még mindig 0.
        --
        -- A DUT-nak VALID=0 értéken kell maradnia.
        -----------------------------------------------------------------------

        wait until rising_edge(aclk);

        assert rd_payload_ready = '0'
            report "Testbench error: RD READY unexpectedly changed"
            severity error;

        assert rd_payload_valid = '0'
            report "rd_payload_valid asserted before READY"
            severity error;


        -----------------------------------------------------------------------
        -- READY -> 1
        -----------------------------------------------------------------------

        rd_payload_ready <= '1';

        wait until rising_edge(aclk);


        assert rd_payload_valid = '1'
            report "rd_payload_valid did not assert after READY"
            severity error;

        assert rd_payload_data = x"DEADBEEF"
            report "Incorrect read data"
            severity error;


        -----------------------------------------------------------------------
        -- DATA és VALID stabilitás ellenőrzése READY=0 mellett
        -----------------------------------------------------------------------

        rd_payload_ready <= '0';

        wait until rising_edge(aclk);

        assert rd_payload_valid = '1'
            report "rd_payload_valid changed while READY=0"
            severity error;

        assert rd_payload_data = x"DEADBEEF"
            report "rd_payload_data changed while VALID=1 and READY=0"
            severity error;


        -----------------------------------------------------------------------
        -- Újra READY=1 -> payload elfogyasztása.
        -----------------------------------------------------------------------

        rd_payload_ready <= '1';

        wait until rising_edge(aclk);

        assert rd_payload_valid = '0'
            report "rd_payload_valid did not deassert after handshake"
            severity error;

        rd_payload_ready <= '0';


        report "TEST 2 PASSED";


        -----------------------------------------------------------------------
        -- TEST 3
        --
        -- Több egymás utáni tranzakció.
        -----------------------------------------------------------------------

        report "TEST 3: consecutive transactions";


        -----------------------------------------------------------------------
        -- WRITE #2
        -----------------------------------------------------------------------

        wr_addr_data  <= x"00003000";
        wr_addr_valid <= '1';

        wait until rising_edge(aclk);

        if wr_addr_ready = '1' then
            wr_addr_valid <= '0';
        end if;


        wr_payload_data  <= x"AABBCCDD";
        wr_payload_valid <= '1';


        wait until rising_edge(aclk);

        if wr_payload_ready = '1' then
            wr_payload_valid <= '0';
        end if;


        -----------------------------------------------------------------------
        -- AXI READY-k
        -----------------------------------------------------------------------

        m_axi_awready <= '1';
        m_axi_wready  <= '1';


        loop
            wait until rising_edge(aclk);

            exit when m_axi_awvalid = '0'
                and m_axi_wvalid = '0';
        end loop;


        m_axi_awready <= '0';
        m_axi_wready  <= '0';


        -----------------------------------------------------------------------
        -- Response
        -----------------------------------------------------------------------

        m_axi_bresp  <= "00";
        m_axi_bvalid <= '1';

        wait until rising_edge(aclk);

        assert m_axi_bready = '1'
            report "BREADY missing for second write"
            severity error;

        m_axi_bvalid <= '0';


        report "TEST 3 PASSED";


        -----------------------------------------------------------------------
        -- END
        -----------------------------------------------------------------------

        wait for 5 * C_CLK_PERIOD;

        report "========================================";
        report "ALL TESTS PASSED";
        report "========================================";

        wait;

    end process;


    ---------------------------------------------------------------------------
    -- Protocol assertions
    --
    -- Ezek a DUT általános protokollhelyességét is figyelik.
    ---------------------------------------------------------------------------

    protocol_checker : process(aclk)

        variable prev_rd_valid : std_logic := '0';
        variable prev_rd_data  :
            std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others => '0');

    begin

        if rising_edge(aclk) then

            if aresetn = '1' then

                -----------------------------------------------------------------
                -- A custom READ VALID nem változhat READY=0 mellett.
                -----------------------------------------------------------------

                if rd_payload_ready = '0' then

                    assert rd_payload_valid = prev_rd_valid
                        report "Protocol violation: rd_payload_valid changed while READY=0"
                        severity error;

                end if;


                -----------------------------------------------------------------
                -- Ha VALID=1 és READY=0, DATA stabil kell legyen.
                -----------------------------------------------------------------

                if prev_rd_valid = '1'
                   and rd_payload_ready = '0' then

                    assert rd_payload_data = prev_rd_data
                        report "Protocol violation: read payload changed while VALID=1 and READY=0"
                        severity error;

                end if;


                -----------------------------------------------------------------
                -- VALID 0 -> 1 csak READY=1 mellett történhet.
                -----------------------------------------------------------------

                if prev_rd_valid = '0'
                   and rd_payload_valid = '1' then

                    assert rd_payload_ready = '1'
                        report "Protocol violation: VALID changed 0->1 while READY=0"
                        severity error;

                end if;


                prev_rd_valid := rd_payload_valid;
                prev_rd_data  := rd_payload_data;

            else

                prev_rd_valid := '0';
                prev_rd_data  := (others => '0');

            end if;

        end if;

    end process;

end architecture;
