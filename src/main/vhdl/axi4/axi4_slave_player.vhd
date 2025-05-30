-----------------------------------------------------------------------------------
--!     @file    axi4_slave_player.vhd
--!     @brief   AXI4 Slave Dummy Plug Player.
--!     @version 1.9.3
--!     @date    2025/5/6
--!     @author  Ichiro Kawazome <ichiro_k@ca2.so-net.ne.jp>
-----------------------------------------------------------------------------------
--
--      Copyright (C) 2012-2025 Ichiro Kawazome
--      All rights reserved.
--
--      Redistribution and use in source and binary forms, with or without
--      modification, are permitted provided that the following conditions
--      are met:
--
--        1. Redistributions of source code must retain the above copyright
--           notice, this list of conditions and the following disclaimer.
--
--        2. Redistributions in binary form must reproduce the above copyright
--           notice, this list of conditions and the following disclaimer in
--           the documentation and/or other materials provided with the
--           distribution.
--
--      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--      "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--      LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
--      A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT
--      OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
--      SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
--      LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
--      DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
--      THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
--      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
--      OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.CORE.REPORT_STATUS_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_PLUG_NUM_TYPE;
use     DUMMY_PLUG.SYNC.SYNC_SIG_VECTOR;
-----------------------------------------------------------------------------------
--! @brief   AXI4 Slave Dummy Plug Player.
-----------------------------------------------------------------------------------
entity  AXI4_SLAVE_PLAYER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        NAME            : --! @brief 固有名詞.
                          STRING;
        READ_ENABLE     : --! @brief リードトランザクションの可/不可を指定する.
                          boolean   := TRUE;
        WRITE_ENABLE    : --! @brief ライトトランザクションの可/不可を指定する.
                          boolean   := TRUE;
        OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                          time    := 0 ns;
        WIDTH           : --! @brief AXI4 チャネルの可変長信号のビット幅.
                          AXI4_SIGNAL_WIDTH_TYPE;
        SYNC_PLUG_NUM   : --! @brief シンクロ用信号のプラグ番号.
                          SYNC_PLUG_NUM_TYPE := 1;
        SYNC_WIDTH      : --! @brief シンクロ用信号の本数.
                          integer :=  1;
        SYNC_DEBUG      : --! @brief SYNC 機構のデバッグ出力を有効にするかどうかを指定する
                          boolean := FALSE;
        DEFAULT_SYNC_IO : --! @brief リードトランザクション/ライトトランザクション
                          --         ウェイト時に完了を待ってから次のコマンドを実行
                          --         するか否かを指定する.
                          boolean := true;
        GPI_WIDTH       : --! @brief GPI(General Purpose Input)信号のビット幅.
                          integer := 8;
        GPO_WIDTH       : --! @brief GPO(General Purpose Output)信号のビット幅.
                          integer := 8;
        DEBUG_MAIN      : --! @brief MAIN CHANNEL のデバッグレベル
                          integer := 0;
        DEBUG_CHANNEL_AR: --! @brief AR CHANNEL のデバッグレベル
                          integer := 0;
        DEBUG_CHANNEL_R : --! @brief R CHANNEL のデバッグレベル
                          integer := 0;
        DEBUG_CHANNEL_AW: --! @brief AW CHANNEL のデバッグレベル
                          integer := 0;
        DEBUG_CHANNEL_W : --! @brief W CHANNEL のデバッグレベル
                          integer := 0;
        DEBUG_CHANNEL_B : --! @brief B CHANNEL のデバッグレベル
                          integer := 0;
        FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                          --!        アボートするかどうかを指定するフラグ.
                          boolean := true
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        --------------------------------------------------------------------------
        -- グローバルシグナル.
        --------------------------------------------------------------------------
        ACLK            : in    std_logic;
        ARESETn         : in    std_logic;
        --------------------------------------------------------------------------
        -- リードアドレスチャネルシグナル.
        --------------------------------------------------------------------------
        ARADDR          : in    std_logic_vector(WIDTH.ARADDR -1 downto 0);
        ARLEN           : in    std_logic_vector(WIDTH.ALEN   -1 downto 0);
        ARSIZE          : in    AXI4_ASIZE_TYPE;
        ARBURST         : in    AXI4_ABURST_TYPE;
        ARLOCK          : in    std_logic_vector(WIDTH.ALOCK  -1 downto 0);
        ARCACHE         : in    AXI4_ACACHE_TYPE;
        ARPROT          : in    AXI4_APROT_TYPE;
        ARQOS           : in    AXI4_AQOS_TYPE;
        ARREGION        : in    AXI4_AREGION_TYPE;
        ARUSER          : in    std_logic_vector(WIDTH.ARUSER -1 downto 0);
        ARID            : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        ARVALID         : in    std_logic;
        ARREADY         : inout std_logic;
        --------------------------------------------------------------------------
        -- リードデータチャネルシグナル.
        --------------------------------------------------------------------------
        RLAST           : inout std_logic;
        RDATA           : inout std_logic_vector(WIDTH.RDATA  -1 downto 0);
        RRESP           : inout AXI4_RESP_TYPE;
        RUSER           : inout std_logic_vector(WIDTH.RUSER  -1 downto 0);
        RID             : inout std_logic_vector(WIDTH.ID     -1 downto 0);
        RVALID          : inout std_logic;
        RREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- ライトアドレスチャネルシグナル.
        --------------------------------------------------------------------------
        AWADDR          : in    std_logic_vector(WIDTH.AWADDR -1 downto 0);
        AWLEN           : in    std_logic_vector(WIDTH.ALEN   -1 downto 0);
        AWSIZE          : in    AXI4_ASIZE_TYPE;
        AWBURST         : in    AXI4_ABURST_TYPE;
        AWLOCK          : in    std_logic_vector(WIDTH.ALOCK  -1 downto 0);
        AWCACHE         : in    AXI4_ACACHE_TYPE;
        AWPROT          : in    AXI4_APROT_TYPE;
        AWQOS           : in    AXI4_AQOS_TYPE;
        AWREGION        : in    AXI4_AREGION_TYPE;
        AWUSER          : in    std_logic_vector(WIDTH.AWUSER -1 downto 0);
        AWID            : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        AWVALID         : in    std_logic;
        AWREADY         : inout std_logic;
        --------------------------------------------------------------------------
        -- ライトデータチャネルシグナル.
        --------------------------------------------------------------------------
        WLAST           : in    std_logic;
        WDATA           : in    std_logic_vector(WIDTH.WDATA  -1 downto 0);
        WSTRB           : in    std_logic_vector(WIDTH.WDATA/8-1 downto 0);
        WUSER           : in    std_logic_vector(WIDTH.WUSER  -1 downto 0);
        WID             : in    std_logic_vector(WIDTH.ID     -1 downto 0);
        WVALID          : in    std_logic;
        WREADY          : inout std_logic;
        --------------------------------------------------------------------------
        -- ライト応答チャネルシグナル.
        --------------------------------------------------------------------------
        BRESP           : inout AXI4_RESP_TYPE;
        BUSER           : inout std_logic_vector(WIDTH.BUSER  -1 downto 0);
        BID             : inout std_logic_vector(WIDTH.ID     -1 downto 0);
        BVALID          : inout std_logic;
        BREADY          : in    std_logic;
        --------------------------------------------------------------------------
        -- シンクロ用信号
        --------------------------------------------------------------------------
        SYNC            : inout SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
        --------------------------------------------------------------------------
        -- General Purpose Input 信号
        --------------------------------------------------------------------------
        GPI             : in    std_logic_vector(GPI_WIDTH    -1 downto 0) := (others => '0');
        --------------------------------------------------------------------------
        -- General Purpose Output 信号
        --------------------------------------------------------------------------
        GPO             : out   std_logic_vector(GPO_WIDTH    -1 downto 0);
        --------------------------------------------------------------------------
        -- レポートステータス出力.
        --------------------------------------------------------------------------
        REPORT_STATUS   : out   REPORT_STATUS_TYPE;
        --------------------------------------------------------------------------
        -- シミュレーション終了通知信号.
        --------------------------------------------------------------------------
        FINISH          : out   std_logic
    );
end AXI4_SLAVE_PLAYER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_CORE.all;
use     DUMMY_PLUG.CORE.all;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.UTIL.all;
-----------------------------------------------------------------------------------
--! @brief   AXI4 Slave Dummy Plug Player.
-----------------------------------------------------------------------------------
architecture MODEL of AXI4_SLAVE_PLAYER is
    -------------------------------------------------------------------------------
    --! SYNC 制御信号
    -------------------------------------------------------------------------------
    signal    sync_rst          : std_logic := '0';
    signal    sync_clr          : std_logic := '0';
    signal    sync_req          : SYNC_REQ_VECTOR(SYNC'range);
    signal    sync_ack          : SYNC_ACK_VECTOR(SYNC'range);
    -------------------------------------------------------------------------------
    --! ローカル同期制御信号
    -------------------------------------------------------------------------------
    constant  SYNC_LOCAL_WAIT   : integer := 2;
    signal    sync_local_signal : SYNC_SIG_TYPE;
    signal    sync_local_debug  : boolean := FALSE;
    signal    sync_local_m_req  : SYNC_REQ_VECTOR(0 downto 0) := (others => 0);
    signal    sync_local_m_ack  : SYNC_ACK_VECTOR(0 downto 0);
    signal    sync_local_ar_req : SYNC_REQ_VECTOR(0 downto 0) := (others => 0);
    signal    sync_local_ar_ack : SYNC_ACK_VECTOR(0 downto 0);
    signal    sync_local_r_req  : SYNC_REQ_VECTOR(0 downto 0) := (others => 0);
    signal    sync_local_r_ack  : SYNC_ACK_VECTOR(0 downto 0);
    signal    sync_local_aw_req : SYNC_REQ_VECTOR(0 downto 0) := (others => 0);
    signal    sync_local_aw_ack : SYNC_ACK_VECTOR(0 downto 0);
    signal    sync_local_w_req  : SYNC_REQ_VECTOR(0 downto 0) := (others => 0);
    signal    sync_local_w_ack  : SYNC_ACK_VECTOR(0 downto 0);
    signal    sync_local_b_req  : SYNC_REQ_VECTOR(0 downto 0) := (others => 0);
    signal    sync_local_b_ack  : SYNC_ACK_VECTOR(0 downto 0);
    signal    sync_dummy_req    : SYNC_REQ_VECTOR(0 downto 0) := (others => 0);
    signal    sync_dummy_ack    : SYNC_ACK_VECTOR(0 downto 0) := (others => '0');
    signal    sync_read_signal  : SYNC_SIG_TYPE;
    signal    sync_read_a_req   : SYNC_REQ_VECTOR(0 downto 0) := (others => 0);
    signal    sync_read_a_ack   : SYNC_ACK_VECTOR(0 downto 0);
    signal    sync_read_d_req   : SYNC_REQ_VECTOR(0 downto 0) := (others => 0);
    signal    sync_read_d_ack   : SYNC_ACK_VECTOR(0 downto 0);
    signal    sync_write_signal : SYNC_SIG_TYPE;
    signal    sync_write_a_req  : SYNC_REQ_VECTOR(0 downto 0) := (others => 0);
    signal    sync_write_a_ack  : SYNC_ACK_VECTOR(0 downto 0);
    signal    sync_write_d_req  : SYNC_REQ_VECTOR(0 downto 0) := (others => 0);
    signal    sync_write_d_ack  : SYNC_ACK_VECTOR(0 downto 0);
    signal    sync_write_b_req  : SYNC_REQ_VECTOR(0 downto 0) := (others => 0);
    signal    sync_write_b_ack  : SYNC_ACK_VECTOR(0 downto 0);
    -------------------------------------------------------------------------------
    --! トランザクション用信号.
    -------------------------------------------------------------------------------
    signal    tran_read         : AXI4_TRANSACTION_SIGNAL_TYPE;
    signal    tran_write        : AXI4_TRANSACTION_SIGNAL_TYPE;
    constant  tran_dummy        : AXI4_TRANSACTION_SIGNAL_TYPE := AXI4_TRANSACTION_SIGNAL_NULL;
    -------------------------------------------------------------------------------
    --! 各チャネルの状態出力.
    -------------------------------------------------------------------------------
    signal    reports           : REPORT_STATUS_VECTOR(1 to 6) := (1 to 6 => REPORT_STATUS_NULL);
begin
    -------------------------------------------------------------------------------
    -- メイン用のプレイヤー
    -------------------------------------------------------------------------------
    M: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE       => SCENARIO_FILE    ,
            NAME                => NAME             ,
            FULL_NAME           => NAME             ,
            CHANNEL             => AXI4_CHANNEL_M   ,
            MASTER              => FALSE            ,
            SLAVE               => FALSE            ,
            READ_ENABLE         => READ_ENABLE      ,
            WRITE_ENABLE        => WRITE_ENABLE     ,
            OUTPUT_DELAY        => OUTPUT_DELAY     ,
            DEBUG_LEVEL         => DEBUG_MAIN       ,
            WIDTH               => WIDTH            ,
            SYNC_WIDTH          => SYNC_WIDTH       ,
            SYNC_LOCAL_WAIT     => SYNC_LOCAL_WAIT  ,
            DEFAULT_SYNC_IO     => DEFAULT_SYNC_IO  ,
            GPI_WIDTH           => GPI_WIDTH        ,
            GPO_WIDTH           => GPO_WIDTH        ,
            FINISH_ABORT        => FINISH_ABORT
        )
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK                => ACLK             , -- In :
            ARESETn             => ARESETn          , -- In :
            -----------------------------------------------------------------------
            -- リードアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            ARADDR_I            => ARADDR           , -- In :
            ARADDR_O            => open             , -- Out:
            ARLEN_I             => ARLEN            , -- In :
            ARLEN_O             => open             , -- Out:
            ARSIZE_I            => ARSIZE           , -- In :
            ARSIZE_O            => open             , -- Out:
            ARBURST_I           => ARBURST          , -- In :
            ARBURST_O           => open             , -- Out:
            ARLOCK_I            => ARLOCK           , -- In :
            ARLOCK_O            => open             , -- Out:
            ARCACHE_I           => ARCACHE          , -- In :
            ARCACHE_O           => open             , -- Out:
            ARPROT_I            => ARPROT           , -- In :
            ARPROT_O            => open             , -- Out:
            ARQOS_I             => ARQOS            , -- In :
            ARQOS_O             => open             , -- Out:
            ARREGION_I          => ARREGION         , -- In :
            ARREGION_O          => open             , -- Out:
            ARUSER_I            => ARUSER           , -- In :
            ARUSER_O            => open             , -- Out:
            ARID_I              => ARID             , -- In :
            ARID_O              => open             , -- Out:
            ARVALID_I           => ARVALID          , -- In :
            ARVALID_O           => open             , -- Out:
            ARREADY_I           => ARREADY          , -- In :
            ARREADY_O           => open             , -- Out:
            -----------------------------------------------------------------------
            -- リードデータチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I            => RVALID           , -- In :
            RVALID_O            => open             , -- Out:
            RLAST_I             => RLAST            , -- In :
            RLAST_O             => open             , -- Out:
            RDATA_I             => RDATA            , -- In :
            RDATA_O             => open             , -- Out:
            RRESP_I             => RRESP            , -- In :
            RRESP_O             => open             , -- Out:
            RUSER_I             => RUSER            , -- In :
            RUSER_O             => open             , -- Out:
            RID_I               => RID              , -- In :
            RID_O               => open             , -- Out:
            RREADY_I            => RREADY           , -- In :
            RREADY_O            => open             , -- Out:
            -----------------------------------------------------------------------
            -- ライトアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            AWADDR_I            => AWADDR           , -- In :
            AWADDR_O            => open             , -- Out:
            AWLEN_I             => AWLEN            , -- In :
            AWLEN_O             => open             , -- Out:
            AWSIZE_I            => AWSIZE           , -- In :
            AWSIZE_O            => open             , -- Out:
            AWBURST_I           => AWBURST          , -- In :
            AWBURST_O           => open             , -- Out:
            AWLOCK_I            => AWLOCK           , -- In :
            AWLOCK_O            => open             , -- Out:
            AWCACHE_I           => AWCACHE          , -- In :
            AWCACHE_O           => open             , -- Out:
            AWPROT_I            => AWPROT           , -- In :
            AWPROT_O            => open             , -- Out:
            AWQOS_I             => AWQOS            , -- In :
            AWQOS_O             => open             , -- Out:
            AWREGION_I          => AWREGION         , -- In :
            AWREGION_O          => open             , -- Out:
            AWUSER_I            => AWUSER           , -- In :
            AWUSER_O            => open             , -- Out:
            AWID_I              => AWID             , -- In :
            AWID_O              => open             , -- Out:
            AWVALID_I           => AWVALID          , -- In :
            AWVALID_O           => open             , -- Out:
            AWREADY_I           => AWREADY          , -- In :
            AWREADY_O           => open             , -- Out:
            -----------------------------------------------------------------------
            -- ライトデータチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I            => WVALID           , -- In :
            WVALID_O            => open             , -- Out:
            WLAST_I             => WLAST            , -- In :
            WLAST_O             => open             , -- Out:
            WDATA_I             => WDATA            , -- In :
            WDATA_O             => open             , -- Out:
            WSTRB_I             => WSTRB            , -- In :
            WSTRB_O             => open             , -- Out:
            WUSER_I             => WUSER            , -- In :
            WUSER_O             => open             , -- Out:
            WID_I               => WID              , -- In :
            WID_O               => open             , -- Out:
            WREADY_I            => WREADY           , -- In :
            WREADY_O            => open             , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I            => BVALID           , -- In :
            BVALID_O            => open             , -- Out:
            BRESP_I             => BRESP            , -- In :
            BRESP_O             => open             , -- Out:
            BUSER_I             => BUSER            , -- In :
            BUSER_O             => open             , -- Out:
            BID_I               => BID              , -- In :
            BID_O               => open             , -- Out:
            BREADY_I            => BREADY           , -- In :
            BREADY_O            => open             , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ            => sync_req         , -- Out:
            SYNC_ACK            => sync_ack         , -- In :
            SYNC_LOCAL_REQ      => sync_local_m_req , -- Out:
            SYNC_LOCAL_ACK      => sync_local_m_ack , -- In :
            SYNC_TRANS_REQ      => sync_dummy_req   , -- Out:
            SYNC_TRANS_ACK      => sync_dummy_ack   , -- In :
            -----------------------------------------------------------------------
            -- トランザクション用信号.
            -----------------------------------------------------------------------
            TRAN_I              => tran_dummy       , -- In :
            TRAN_O              => open             , -- Out:
            ----------------------------------------------------------------------
            -- GPIO
            ----------------------------------------------------------------------
            GPI                 => GPI              , -- In :
            GPO                 => GPO              , -- Out:
            -----------------------------------------------------------------------
            -- 各種状態出力.
            -----------------------------------------------------------------------
            REPORT_STATUS       => reports(1)       , -- Out:
            FINISH              => FINISH             -- Out:
        );
    -------------------------------------------------------------------------------
    -- リードアドレスチャネルプレイヤー
    -------------------------------------------------------------------------------
    AR: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE       => SCENARIO_FILE    ,
            NAME                => NAME             ,
            FULL_NAME           => NAME & ".AR"     ,
            CHANNEL             => AXI4_CHANNEL_AR  ,
            MASTER              => FALSE            ,
            SLAVE               => TRUE             ,
            READ_ENABLE         => READ_ENABLE      ,
            WRITE_ENABLE        => WRITE_ENABLE     ,
            OUTPUT_DELAY        => OUTPUT_DELAY     ,
            DEBUG_LEVEL         => DEBUG_CHANNEL_AR ,
            WIDTH               => WIDTH            ,
            SYNC_WIDTH          => SYNC_WIDTH       ,
            SYNC_LOCAL_WAIT     => SYNC_LOCAL_WAIT  ,
            DEFAULT_SYNC_IO     => DEFAULT_SYNC_IO  ,
            GPI_WIDTH           => GPI_WIDTH        ,
            GPO_WIDTH           => GPO_WIDTH        ,
            FINISH_ABORT        => FINISH_ABORT
        )
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK                => ACLK             , -- In :
            ARESETn             => ARESETn          , -- In :
            -----------------------------------------------------------------------
            -- リードアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            ARADDR_I            => ARADDR           , -- In :
            ARADDR_O            => open             , -- Out:
            ARLEN_I             => ARLEN            , -- In :
            ARLEN_O             => open             , -- Out:
            ARSIZE_I            => ARSIZE           , -- In :
            ARSIZE_O            => open             , -- Out:
            ARBURST_I           => ARBURST          , -- In :
            ARBURST_O           => open             , -- Out:
            ARLOCK_I            => ARLOCK           , -- In :
            ARLOCK_O            => open             , -- Out:
            ARCACHE_I           => ARCACHE          , -- In :
            ARCACHE_O           => open             , -- Out:
            ARPROT_I            => ARPROT           , -- In :
            ARPROT_O            => open             , -- Out:
            ARQOS_I             => ARQOS            , -- In :
            ARQOS_O             => open             , -- Out:
            ARREGION_I          => ARREGION         , -- In :
            ARREGION_O          => open             , -- Out:
            ARUSER_I            => ARUSER           , -- In :
            ARUSER_O            => open             , -- Out:
            ARID_I              => ARID             , -- In :
            ARID_O              => open             , -- Out:
            ARVALID_I           => ARVALID          , -- In :
            ARVALID_O           => open             , -- Out:
            ARREADY_I           => ARREADY          , -- In :
            ARREADY_O           => ARREADY          , -- Out:
            -----------------------------------------------------------------------
            -- リードデータチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I            => RVALID           , -- In :
            RVALID_O            => open             , -- Out:
            RLAST_I             => RLAST            , -- In :
            RLAST_O             => open             , -- Out:
            RDATA_I             => RDATA            , -- In :
            RDATA_O             => open             , -- Out:
            RRESP_I             => RRESP            , -- In :
            RRESP_O             => open             , -- Out:
            RUSER_I             => RUSER            , -- In :
            RUSER_O             => open             , -- Out:
            RID_I               => RID              , -- In :
            RID_O               => open             , -- Out:
            RREADY_I            => RREADY           , -- In :
            RREADY_O            => open             , -- Out:
            -----------------------------------------------------------------------
            -- ライトアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            AWADDR_I            => AWADDR           , -- In :
            AWADDR_O            => open             , -- Out:
            AWLEN_I             => AWLEN            , -- In :
            AWLEN_O             => open             , -- Out:
            AWSIZE_I            => AWSIZE           , -- In :
            AWSIZE_O            => open             , -- Out:
            AWBURST_I           => AWBURST          , -- In :
            AWBURST_O           => open             , -- Out:
            AWLOCK_I            => AWLOCK           , -- In :
            AWLOCK_O            => open             , -- Out:
            AWCACHE_I           => AWCACHE          , -- In :
            AWCACHE_O           => open             , -- Out:
            AWPROT_I            => AWPROT           , -- In :
            AWPROT_O            => open             , -- Out:
            AWQOS_I             => AWQOS            , -- In :
            AWQOS_O             => open             , -- Out:
            AWREGION_I          => AWREGION         , -- In :
            AWREGION_O          => open             , -- Out:
            AWUSER_I            => AWUSER           , -- In :
            AWUSER_O            => open             , -- Out:
            AWID_I              => AWID             , -- In :
            AWID_O              => open             , -- Out:
            AWVALID_I           => AWVALID          , -- In :
            AWVALID_O           => open             , -- Out:
            AWREADY_I           => AWREADY          , -- In :
            AWREADY_O           => open             , -- Out:
            -----------------------------------------------------------------------
            -- ライトデータチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I            => WVALID           , -- In :
            WVALID_O            => open             , -- Out:
            WLAST_I             => WLAST            , -- In :
            WLAST_O             => open             , -- Out:
            WDATA_I             => WDATA            , -- In :
            WDATA_O             => open             , -- Out:
            WSTRB_I             => WSTRB            , -- In :
            WSTRB_O             => open             , -- Out:
            WUSER_I             => WUSER            , -- In :
            WUSER_O             => open             , -- Out:
            WID_I               => WID              , -- In :
            WID_O               => open             , -- Out:
            WREADY_I            => WREADY           , -- In :
            WREADY_O            => open             , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I            => BVALID           , -- In :
            BVALID_O            => open             , -- Out:
            BRESP_I             => BRESP            , -- In :
            BRESP_O             => open             , -- Out:
            BUSER_I             => BUSER            , -- In :
            BUSER_O             => open             , -- Out:
            BID_I               => BID              , -- In :
            BID_O               => open             , -- Out:
            BREADY_I            => BREADY           , -- In :
            BREADY_O            => open             , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ            => open             , -- Out:
            SYNC_ACK            => sync_ack         , -- In :
            SYNC_LOCAL_REQ      => sync_local_ar_req, -- Out:
            SYNC_LOCAL_ACK      => sync_local_ar_ack, -- In :
            SYNC_TRANS_REQ      => sync_read_a_req  , -- Out:
            SYNC_TRANS_ACK      => sync_read_a_ack  , -- In :
            -----------------------------------------------------------------------
            -- トランザクション用信号.
            -----------------------------------------------------------------------
            TRAN_I              => tran_read        , -- In :
            TRAN_O              => tran_read        , -- Out:
            ----------------------------------------------------------------------
            -- GPIO
            ----------------------------------------------------------------------
            GPI                 => GPI              , -- In :
            GPO                 => open             , -- Out:
            -----------------------------------------------------------------------
            -- 各種状態出力.
            -----------------------------------------------------------------------
            REPORT_STATUS       => reports(2)       , -- Out:
            FINISH              => open               -- Out:
        );
    -------------------------------------------------------------------------------
    -- リードデータチャネルプレイヤー
    -------------------------------------------------------------------------------
    R: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE       => SCENARIO_FILE    ,
            NAME                => NAME             ,
            FULL_NAME           => NAME & ".R"      ,
            CHANNEL             => AXI4_CHANNEL_R   ,
            MASTER              => FALSE            ,
            SLAVE               => TRUE             ,
            READ_ENABLE         => READ_ENABLE      ,
            WRITE_ENABLE        => WRITE_ENABLE     ,
            OUTPUT_DELAY        => OUTPUT_DELAY     ,
            DEBUG_LEVEL         => DEBUG_CHANNEL_R  ,
            WIDTH               => WIDTH            ,
            SYNC_WIDTH          => SYNC_WIDTH       ,
            SYNC_LOCAL_WAIT     => SYNC_LOCAL_WAIT  ,
            DEFAULT_SYNC_IO     => DEFAULT_SYNC_IO  ,
            GPI_WIDTH           => GPI_WIDTH        ,
            GPO_WIDTH           => GPO_WIDTH        ,
            FINISH_ABORT        => FINISH_ABORT
        )
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK                => ACLK             , -- In :
            ARESETn             => ARESETn          , -- In :
            -----------------------------------------------------------------------
            -- リードアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            ARADDR_I            => ARADDR           , -- In :
            ARADDR_O            => open             , -- Out:
            ARLEN_I             => ARLEN            , -- In :
            ARLEN_O             => open             , -- Out:
            ARSIZE_I            => ARSIZE           , -- In :
            ARSIZE_O            => open             , -- Out:
            ARBURST_I           => ARBURST          , -- In :
            ARBURST_O           => open             , -- Out:
            ARLOCK_I            => ARLOCK           , -- In :
            ARLOCK_O            => open             , -- Out:
            ARCACHE_I           => ARCACHE          , -- In :
            ARCACHE_O           => open             , -- Out:
            ARPROT_I            => ARPROT           , -- In :
            ARPROT_O            => open             , -- Out:
            ARQOS_I             => ARQOS            , -- In :
            ARQOS_O             => open             , -- Out:
            ARREGION_I          => ARREGION         , -- In :
            ARREGION_O          => open             , -- Out:
            ARUSER_I            => ARUSER           , -- In :
            ARUSER_O            => open             , -- Out:
            ARID_I              => ARID             , -- In :
            ARID_O              => open             , -- Out:
            ARVALID_I           => ARVALID          , -- In :
            ARVALID_O           => open             , -- Out:
            ARREADY_I           => ARREADY          , -- In :
            ARREADY_O           => open             , -- Out:
            -----------------------------------------------------------------------
            -- リードデータチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I            => RVALID           , -- In :
            RVALID_O            => RVALID           , -- Out:
            RLAST_I             => RLAST            , -- In :
            RLAST_O             => RLAST            , -- Out:
            RDATA_I             => RDATA            , -- In :
            RDATA_O             => RDATA            , -- Out:
            RRESP_I             => RRESP            , -- In :
            RRESP_O             => RRESP            , -- Out:
            RUSER_I             => RUSER            , -- In :
            RUSER_O             => RUSER            , -- Out:
            RID_I               => RID              , -- In :
            RID_O               => RID              , -- Out:
            RREADY_I            => RREADY           , -- In :
            RREADY_O            => open             , -- Out:
            -----------------------------------------------------------------------
            -- ライトアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            AWADDR_I            => AWADDR           , -- In :
            AWADDR_O            => open             , -- Out:
            AWLEN_I             => AWLEN            , -- In :
            AWLEN_O             => open             , -- Out:
            AWSIZE_I            => AWSIZE           , -- In :
            AWSIZE_O            => open             , -- Out:
            AWBURST_I           => AWBURST          , -- In :
            AWBURST_O           => open             , -- Out:
            AWLOCK_I            => AWLOCK           , -- In :
            AWLOCK_O            => open             , -- Out:
            AWCACHE_I           => AWCACHE          , -- In :
            AWCACHE_O           => open             , -- Out:
            AWPROT_I            => AWPROT           , -- In :
            AWPROT_O            => open             , -- Out:
            AWQOS_I             => AWQOS            , -- In :
            AWQOS_O             => open             , -- Out:
            AWREGION_I          => AWREGION         , -- In :
            AWREGION_O          => open             , -- Out:
            AWUSER_I            => AWUSER           , -- In :
            AWUSER_O            => open             , -- Out:
            AWID_I              => AWID             , -- In :
            AWID_O              => open             , -- Out:
            AWVALID_I           => AWVALID          , -- In :
            AWVALID_O           => open             , -- Out:
            AWREADY_I           => AWREADY          , -- In :
            AWREADY_O           => open             , -- Out:
            -----------------------------------------------------------------------
            -- ライトデータチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I            => WVALID           , -- In :
            WVALID_O            => open             , -- Out:
            WLAST_I             => WLAST            , -- In :
            WLAST_O             => open             , -- Out:
            WDATA_I             => WDATA            , -- In :
            WDATA_O             => open             , -- Out:
            WSTRB_I             => WSTRB            , -- In :
            WSTRB_O             => open             , -- Out:
            WUSER_I             => WUSER            , -- In :
            WUSER_O             => open             , -- Out:
            WID_I               => WID              , -- In :
            WID_O               => open             , -- Out:
            WREADY_I            => WREADY           , -- In :
            WREADY_O            => open             , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I            => BVALID           , -- In :
            BVALID_O            => open             , -- Out:
            BRESP_I             => BRESP            , -- In :
            BRESP_O             => open             , -- Out:
            BUSER_I             => BUSER            , -- In :
            BUSER_O             => open             , -- Out:
            BID_I               => BID              , -- In :
            BID_O               => open             , -- Out:
            BREADY_I            => BREADY           , -- In :
            BREADY_O            => open             , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ            => open             , -- Out:
            SYNC_ACK            => sync_ack         , -- In :
            SYNC_LOCAL_REQ      => sync_local_r_req , -- Out:
            SYNC_LOCAL_ACK      => sync_local_r_ack , -- In :
            SYNC_TRANS_REQ      => sync_read_d_req  , -- Out:
            SYNC_TRANS_ACK      => sync_read_d_ack  , -- In :
            -----------------------------------------------------------------------
            -- トランザクション用信号.
            -----------------------------------------------------------------------
            TRAN_I              => tran_read        , -- In :
            TRAN_O              => open             , -- Out:
            ----------------------------------------------------------------------
            -- GPIO
            ----------------------------------------------------------------------
            GPI                 => GPI              , -- In :
            GPO                 => open             , -- Out:
            -----------------------------------------------------------------------
            -- 各種状態出力.
            -----------------------------------------------------------------------
            REPORT_STATUS       => reports(3)       , -- Out:
            FINISH              => open               -- Out:
        );
    -------------------------------------------------------------------------------
    -- ライトアドレスチャネルプレイヤー
    -------------------------------------------------------------------------------
    AW: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE       => SCENARIO_FILE    ,
            NAME                => NAME             ,
            FULL_NAME           => NAME & ".AW"     ,
            CHANNEL             => AXI4_CHANNEL_AW  ,
            MASTER              => FALSE            ,
            SLAVE               => TRUE             ,
            READ_ENABLE         => READ_ENABLE      ,
            WRITE_ENABLE        => WRITE_ENABLE     ,
            OUTPUT_DELAY        => OUTPUT_DELAY     ,
            DEBUG_LEVEL         => DEBUG_CHANNEL_AW ,
            WIDTH               => WIDTH            ,
            SYNC_WIDTH          => SYNC_WIDTH       ,
            SYNC_LOCAL_WAIT     => SYNC_LOCAL_WAIT  ,
            DEFAULT_SYNC_IO     => DEFAULT_SYNC_IO  ,
            GPI_WIDTH           => GPI_WIDTH        ,
            GPO_WIDTH           => GPO_WIDTH        ,
            FINISH_ABORT        => FINISH_ABORT
        )
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK                => ACLK             , -- In :
            ARESETn             => ARESETn          , -- In :
            -----------------------------------------------------------------------
            -- リードアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            ARADDR_I            => ARADDR           , -- In :
            ARADDR_O            => open             , -- Out:
            ARLEN_I             => ARLEN            , -- In :
            ARLEN_O             => open             , -- Out:
            ARSIZE_I            => ARSIZE           , -- In :
            ARSIZE_O            => open             , -- Out:
            ARBURST_I           => ARBURST          , -- In :
            ARBURST_O           => open             , -- Out:
            ARLOCK_I            => ARLOCK           , -- In :
            ARLOCK_O            => open             , -- Out:
            ARCACHE_I           => ARCACHE          , -- In :
            ARCACHE_O           => open             , -- Out:
            ARPROT_I            => ARPROT           , -- In :
            ARPROT_O            => open             , -- Out:
            ARQOS_I             => ARQOS            , -- In :
            ARQOS_O             => open             , -- Out:
            ARREGION_I          => ARREGION         , -- In :
            ARREGION_O          => open             , -- Out:
            ARUSER_I            => ARUSER           , -- In :
            ARUSER_O            => open             , -- Out:
            ARID_I              => ARID             , -- In :
            ARID_O              => open             , -- Out:
            ARVALID_I           => ARVALID          , -- In :
            ARVALID_O           => open             , -- Out:
            ARREADY_I           => ARREADY          , -- In :
            ARREADY_O           => open             , -- Out:
            -----------------------------------------------------------------------
            -- リードデータチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I            => RVALID           , -- In :
            RVALID_O            => open             , -- Out:
            RLAST_I             => RLAST            , -- In :
            RLAST_O             => open             , -- Out:
            RDATA_I             => RDATA            , -- In :
            RDATA_O             => open             , -- Out:
            RRESP_I             => RRESP            , -- In :
            RRESP_O             => open             , -- Out:
            RUSER_I             => RUSER            , -- In :
            RUSER_O             => open             , -- Out:
            RID_I               => RID              , -- In :
            RID_O               => open             , -- Out:
            RREADY_I            => RREADY           , -- In :
            RREADY_O            => open             , -- Out:
            -----------------------------------------------------------------------
            -- ライトアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            AWADDR_I            => AWADDR           , -- In :
            AWADDR_O            => open             , -- Out:
            AWLEN_I             => AWLEN            , -- In :
            AWLEN_O             => open             , -- Out:
            AWSIZE_I            => AWSIZE           , -- In :
            AWSIZE_O            => open             , -- Out:
            AWBURST_I           => AWBURST          , -- In :
            AWBURST_O           => open             , -- Out:
            AWLOCK_I            => AWLOCK           , -- In :
            AWLOCK_O            => open             , -- Out:
            AWCACHE_I           => AWCACHE          , -- In :
            AWCACHE_O           => open             , -- Out:
            AWPROT_I            => AWPROT           , -- In :
            AWPROT_O            => open             , -- Out:
            AWQOS_I             => AWQOS            , -- In :
            AWQOS_O             => open             , -- Out:
            AWREGION_I          => AWREGION         , -- In :
            AWREGION_O          => open             , -- Out:
            AWUSER_I            => AWUSER           , -- In :
            AWUSER_O            => open             , -- Out:
            AWID_I              => AWID             , -- In :
            AWID_O              => open             , -- Out:
            AWVALID_I           => AWVALID          , -- In :
            AWVALID_O           => open             , -- Out:
            AWREADY_I           => AWREADY          , -- In :
            AWREADY_O           => AWREADY          , -- Out:
            -----------------------------------------------------------------------
            -- ライトデータチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I            => WVALID           , -- In :
            WVALID_O            => open             , -- Out:
            WLAST_I             => WLAST            , -- In :
            WLAST_O             => open             , -- Out:
            WDATA_I             => WDATA            , -- In :
            WDATA_O             => open             , -- Out:
            WSTRB_I             => WSTRB            , -- In :
            WSTRB_O             => open             , -- Out:
            WUSER_I             => WUSER            , -- In :
            WUSER_O             => open             , -- Out:
            WID_I               => WID              , -- In :
            WID_O               => open             , -- Out:
            WREADY_I            => WREADY           , -- In :
            WREADY_O            => open             , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I            => BVALID           , -- In :
            BVALID_O            => open             , -- Out:
            BRESP_I             => BRESP            , -- In :
            BRESP_O             => open             , -- Out:
            BUSER_I             => BUSER            , -- In :
            BUSER_O             => open             , -- Out:
            BID_I               => BID              , -- In :
            BID_O               => open             , -- Out:
            BREADY_I            => BREADY           , -- In :
            BREADY_O            => open             , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ            => open             , -- Out:
            SYNC_ACK            => sync_ack         , -- In :
            SYNC_LOCAL_REQ      => sync_local_aw_req, -- Out:
            SYNC_LOCAL_ACK      => sync_local_aw_ack, -- In :
            SYNC_TRANS_REQ      => sync_write_a_req , -- Out:
            SYNC_TRANS_ACK      => sync_write_a_ack , -- In :
            -----------------------------------------------------------------------
            -- トランザクション用信号.
            -----------------------------------------------------------------------
            TRAN_I              => tran_write       , -- In :
            TRAN_O              => tran_write       , -- Out:
            ----------------------------------------------------------------------
            -- GPIO
            ----------------------------------------------------------------------
            GPI                 => GPI              , -- In :
            GPO                 => open             , -- Out:
            -----------------------------------------------------------------------
            -- 各種状態出力.
            -----------------------------------------------------------------------
            REPORT_STATUS       => reports(4)       , -- Out:
            FINISH              => open               -- Out:
        );
    -------------------------------------------------------------------------------
    -- ライトデータチャネルプレイヤー
    -------------------------------------------------------------------------------
    W: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE       => SCENARIO_FILE    ,
            NAME                => NAME             ,
            FULL_NAME           => NAME & ".W"      ,
            CHANNEL             => AXI4_CHANNEL_W   ,
            MASTER              => FALSE            ,
            SLAVE               => TRUE             ,
            READ_ENABLE         => READ_ENABLE      ,
            WRITE_ENABLE        => WRITE_ENABLE     ,
            OUTPUT_DELAY        => OUTPUT_DELAY     ,
            DEBUG_LEVEL         => DEBUG_CHANNEL_W  ,
            WIDTH               => WIDTH            ,
            SYNC_WIDTH          => SYNC_WIDTH       ,
            SYNC_LOCAL_WAIT     => SYNC_LOCAL_WAIT  ,
            DEFAULT_SYNC_IO     => DEFAULT_SYNC_IO  ,
            GPI_WIDTH           => GPI_WIDTH        ,
            GPO_WIDTH           => GPO_WIDTH        ,
            FINISH_ABORT        => FINISH_ABORT
        )
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK                => ACLK             , -- In :
            ARESETn             => ARESETn          , -- In :
            -----------------------------------------------------------------------
            -- リードアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            ARADDR_I            => ARADDR           , -- In :
            ARADDR_O            => open             , -- Out:
            ARLEN_I             => ARLEN            , -- In :
            ARLEN_O             => open             , -- Out:
            ARSIZE_I            => ARSIZE           , -- In :
            ARSIZE_O            => open             , -- Out:
            ARBURST_I           => ARBURST          , -- In :
            ARBURST_O           => open             , -- Out:
            ARLOCK_I            => ARLOCK           , -- In :
            ARLOCK_O            => open             , -- Out:
            ARCACHE_I           => ARCACHE          , -- In :
            ARCACHE_O           => open             , -- Out:
            ARPROT_I            => ARPROT           , -- In :
            ARPROT_O            => open             , -- Out:
            ARQOS_I             => ARQOS            , -- In :
            ARQOS_O             => open             , -- Out:
            ARREGION_I          => ARREGION         , -- In :
            ARREGION_O          => open             , -- Out:
            ARUSER_I            => ARUSER           , -- In :
            ARUSER_O            => open             , -- Out:
            ARID_I              => ARID             , -- In :
            ARID_O              => open             , -- Out:
            ARVALID_I           => ARVALID          , -- In :
            ARVALID_O           => open             , -- Out:
            ARREADY_I           => ARREADY          , -- In :
            ARREADY_O           => open             , -- Out:
            -----------------------------------------------------------------------
            -- リードデータチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I            => RVALID           , -- In :
            RVALID_O            => open             , -- Out:
            RLAST_I             => RLAST            , -- In :
            RLAST_O             => open             , -- Out:
            RDATA_I             => RDATA            , -- In :
            RDATA_O             => open             , -- Out:
            RRESP_I             => RRESP            , -- In :
            RRESP_O             => open             , -- Out:
            RUSER_I             => RUSER            , -- In :
            RUSER_O             => open             , -- Out:
            RID_I               => RID              , -- In :
            RID_O               => open             , -- Out:
            RREADY_I            => RREADY           , -- In :
            RREADY_O            => open             , -- Out:
            -----------------------------------------------------------------------
            -- ライトアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            AWADDR_I            => AWADDR           , -- In :
            AWADDR_O            => open             , -- Out:
            AWLEN_I             => AWLEN            , -- In :
            AWLEN_O             => open             , -- Out:
            AWSIZE_I            => AWSIZE           , -- In :
            AWSIZE_O            => open             , -- Out:
            AWBURST_I           => AWBURST          , -- In :
            AWBURST_O           => open             , -- Out:
            AWLOCK_I            => AWLOCK           , -- In :
            AWLOCK_O            => open             , -- Out:
            AWCACHE_I           => AWCACHE          , -- In :
            AWCACHE_O           => open             , -- Out:
            AWPROT_I            => AWPROT           , -- In :
            AWPROT_O            => open             , -- Out:
            AWQOS_I             => AWQOS            , -- In :
            AWQOS_O             => open             , -- Out:
            AWREGION_I          => AWREGION         , -- In :
            AWREGION_O          => open             , -- Out:
            AWUSER_I            => AWUSER           , -- In :
            AWUSER_O            => open             , -- Out:
            AWID_I              => AWID             , -- In :
            AWID_O              => open             , -- Out:
            AWVALID_I           => AWVALID          , -- In :
            AWVALID_O           => open             , -- Out:
            AWREADY_I           => AWREADY          , -- In :
            AWREADY_O           => open             , -- Out:
            -----------------------------------------------------------------------
            -- ライトデータチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I            => WVALID           , -- In :
            WVALID_O            => open             , -- Out:
            WLAST_I             => WLAST            , -- In :
            WLAST_O             => open             , -- Out:
            WDATA_I             => WDATA            , -- In :
            WDATA_O             => open             , -- Out:
            WSTRB_I             => WSTRB            , -- In :
            WSTRB_O             => open             , -- Out:
            WUSER_I             => WUSER            , -- In :
            WUSER_O             => open             , -- Out:
            WID_I               => WID              , -- In :
            WID_O               => open             , -- Out:
            WREADY_I            => WREADY           , -- In :
            WREADY_O            => WREADY           , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I            => BVALID           , -- In :
            BVALID_O            => open             , -- Out:
            BRESP_I             => BRESP            , -- In :
            BRESP_O             => open             , -- Out:
            BUSER_I             => BUSER            , -- In :
            BUSER_O             => open             , -- Out:
            BID_I               => BID              , -- In :
            BID_O               => open             , -- Out:
            BREADY_I            => BREADY           , -- In :
            BREADY_O            => open             , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ            => open             , -- Out:
            SYNC_ACK            => sync_ack         , -- In :
            SYNC_LOCAL_REQ      => sync_local_w_req , -- Out:
            SYNC_LOCAL_ACK      => sync_local_w_ack , -- In :
            SYNC_TRANS_REQ      => sync_write_d_req , -- Out:
            SYNC_TRANS_ACK      => sync_write_d_ack , -- In :
            -----------------------------------------------------------------------
            -- トランザクション用信号.
            -----------------------------------------------------------------------
            TRAN_I              => tran_write       , -- In :
            TRAN_O              => open             , -- Out:
            ----------------------------------------------------------------------
            -- GPIO
            ----------------------------------------------------------------------
            GPI                 => GPI              , -- In :
            GPO                 => open             , -- Out:
            -----------------------------------------------------------------------
            -- 各種状態出力.
            -----------------------------------------------------------------------
            REPORT_STATUS       => reports(5)       , -- Out:
            FINISH              => open               -- Out:
        );
    -------------------------------------------------------------------------------
    -- ライト応答チャネルプレイヤー
    -------------------------------------------------------------------------------
    B: AXI4_CHANNEL_PLAYER 
        generic map (
            SCENARIO_FILE       => SCENARIO_FILE    ,
            NAME                => NAME             ,
            FULL_NAME           => NAME & ".B"      ,
            CHANNEL             => AXI4_CHANNEL_B   ,
            MASTER              => FALSE            ,
            SLAVE               => TRUE             ,
            READ_ENABLE         => READ_ENABLE      ,
            WRITE_ENABLE        => WRITE_ENABLE     ,
            OUTPUT_DELAY        => OUTPUT_DELAY     ,
            DEBUG_LEVEL         => DEBUG_CHANNEL_B  ,
            WIDTH               => WIDTH            ,
            SYNC_WIDTH          => SYNC_WIDTH       ,
            SYNC_LOCAL_WAIT     => SYNC_LOCAL_WAIT  ,
            DEFAULT_SYNC_IO     => DEFAULT_SYNC_IO  ,
            GPI_WIDTH           => GPI_WIDTH        ,
            GPO_WIDTH           => GPO_WIDTH        ,
            FINISH_ABORT        => FINISH_ABORT
        )
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK                => ACLK             , -- In :
            ARESETn             => ARESETn          , -- In :
            -----------------------------------------------------------------------
            -- リードアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            ARADDR_I            => ARADDR           , -- In :
            ARADDR_O            => open             , -- Out:
            ARLEN_I             => ARLEN            , -- In :
            ARLEN_O             => open             , -- Out:
            ARSIZE_I            => ARSIZE           , -- In :
            ARSIZE_O            => open             , -- Out:
            ARBURST_I           => ARBURST          , -- In :
            ARBURST_O           => open             , -- Out:
            ARLOCK_I            => ARLOCK           , -- In :
            ARLOCK_O            => open             , -- Out:
            ARCACHE_I           => ARCACHE          , -- In :
            ARCACHE_O           => open             , -- Out:
            ARPROT_I            => ARPROT           , -- In :
            ARPROT_O            => open             , -- Out:
            ARQOS_I             => ARQOS            , -- In :
            ARQOS_O             => open             , -- Out:
            ARREGION_I          => ARREGION         , -- In :
            ARREGION_O          => open             , -- Out:
            ARUSER_I            => ARUSER           , -- In :
            ARUSER_O            => open             , -- Out:
            ARID_I              => ARID             , -- In :
            ARID_O              => open             , -- Out:
            ARVALID_I           => ARVALID          , -- In :
            ARVALID_O           => open             , -- Out:
            ARREADY_I           => ARREADY          , -- In :
            ARREADY_O           => open             , -- Out:
            -----------------------------------------------------------------------
            -- リードデータチャネルシグナル.
            -----------------------------------------------------------------------
            RVALID_I            => RVALID           , -- In :
            RVALID_O            => open             , -- Out:
            RLAST_I             => RLAST            , -- In :
            RLAST_O             => open             , -- Out:
            RDATA_I             => RDATA            , -- In :
            RDATA_O             => open             , -- Out:
            RRESP_I             => RRESP            , -- In :
            RRESP_O             => open             , -- Out:
            RUSER_I             => RUSER            , -- In :
            RUSER_O             => open             , -- Out:
            RID_I               => RID              , -- In :
            RID_O               => open             , -- Out:
            RREADY_I            => RREADY           , -- In :
            RREADY_O            => open             , -- Out:
            -----------------------------------------------------------------------
            -- ライトアドレスチャネルシグナル.
            -----------------------------------------------------------------------
            AWADDR_I            => AWADDR           , -- In :
            AWADDR_O            => open             , -- Out:
            AWLEN_I             => AWLEN            , -- In :
            AWLEN_O             => open             , -- Out:
            AWSIZE_I            => AWSIZE           , -- In :
            AWSIZE_O            => open             , -- Out:
            AWBURST_I           => AWBURST          , -- In :
            AWBURST_O           => open             , -- Out:
            AWLOCK_I            => AWLOCK           , -- In :
            AWLOCK_O            => open             , -- Out:
            AWCACHE_I           => AWCACHE          , -- In :
            AWCACHE_O           => open             , -- Out:
            AWPROT_I            => AWPROT           , -- In :
            AWPROT_O            => open             , -- Out:
            AWQOS_I             => AWQOS            , -- In :
            AWQOS_O             => open             , -- Out:
            AWREGION_I          => AWREGION         , -- In :
            AWREGION_O          => open             , -- Out:
            AWUSER_I            => AWUSER           , -- In :
            AWUSER_O            => open             , -- Out:
            AWID_I              => AWID             , -- In :
            AWID_O              => open             , -- Out:
            AWVALID_I           => AWVALID          , -- In :
            AWVALID_O           => open             , -- Out:
            AWREADY_I           => AWREADY          , -- In :
            AWREADY_O           => open             , -- Out:
            -----------------------------------------------------------------------
            -- ライトデータチャネルシグナル.
            -----------------------------------------------------------------------
            WVALID_I            => WVALID           , -- In :
            WVALID_O            => open             , -- Out:
            WLAST_I             => WLAST            , -- In :
            WLAST_O             => open             , -- Out:
            WDATA_I             => WDATA            , -- In :
            WDATA_O             => open             , -- Out:
            WSTRB_I             => WSTRB            , -- In :
            WSTRB_O             => open             , -- Out:
            WUSER_I             => WUSER            , -- In :
            WUSER_O             => open             , -- Out:
            WID_I               => WID              , -- In :
            WID_O               => open             , -- Out:
            WREADY_I            => WREADY           , -- In :
            WREADY_O            => open             , -- Out:
            -----------------------------------------------------------------------
            -- ライト応答チャネルシグナル.
            -----------------------------------------------------------------------
            BVALID_I            => BVALID           , -- In :
            BVALID_O            => BVALID           , -- Out:
            BRESP_I             => BRESP            , -- In :
            BRESP_O             => BRESP            , -- Out:
            BUSER_I             => BUSER            , -- In :
            BUSER_O             => BUSER            , -- Out:
            BID_I               => BID              , -- In :
            BID_O               => BID              , -- Out:
            BREADY_I            => BREADY           , -- In :
            BREADY_O            => open             , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号
            -----------------------------------------------------------------------
            SYNC_REQ            => open             , -- Out:
            SYNC_ACK            => sync_ack         , -- In :
            SYNC_LOCAL_REQ      => sync_local_b_req , -- Out:
            SYNC_LOCAL_ACK      => sync_local_b_ack , -- In :
            SYNC_TRANS_REQ      => sync_write_b_req , -- Out:
            SYNC_TRANS_ACK      => sync_write_b_ack , -- In :
            -----------------------------------------------------------------------
            -- トランザクション用信号.
            -----------------------------------------------------------------------
            TRAN_I              => tran_write       , -- In :
            TRAN_O              => open             , -- Out:
            ----------------------------------------------------------------------
            -- GPIO
            ----------------------------------------------------------------------
            GPI                 => GPI              , -- In :
            GPO                 => open             , -- Out:
            -----------------------------------------------------------------------
            -- 各種状態出力.
            -----------------------------------------------------------------------
            REPORT_STATUS       => reports(6)       , -- Out:
            FINISH              => open               -- Out:
        );
    -------------------------------------------------------------------------------
    -- レポートの集計.
    -------------------------------------------------------------------------------
    REPORT_STATUS <= MARGE_REPORT_STATUS(reports);
    -------------------------------------------------------------------------------
    -- このコア用の同期回路
    -------------------------------------------------------------------------------
    SYNC_DRIVER: for i in SYNC'range generate
        constant UNIT_NAME : string := NAME & ":SYNC(" & INTEGER_TO_STRING(i) & ")";
    begin 
        UNIT: SYNC_SIG_DRIVER
            generic map (
                NAME     => UNIT_NAME           ,
                PLUG_NUM => SYNC_PLUG_NUM
            )
            port map (
                CLK      => ACLK                ,  -- In :
                RST      => sync_rst            ,  -- In :
                CLR      => sync_clr            ,  -- In :
                DEBUG    => SYNC_DEBUG          ,  -- In :
                SYNC     => SYNC(i)             ,  -- I/O:
                REQ      => sync_req(i)         ,  -- In :
                ACK      => sync_ack(i)            -- Out:
            );
    end generate;
    sync_rst <= '0' when (ARESETn = '1') else '1';
    sync_clr <= '0';
    -------------------------------------------------------------------------------
    -- このコア内部のローカルな同期回路
    -------------------------------------------------------------------------------
    SYNC_LOCAL : SYNC_LOCAL_HUB 
        generic map (
            NAME     => NAME & ":SYNC_LOCAL"    ,
            PLUG_SIZE=> 6
        )
        port map (
            CLK      => ACLK                    ,  -- In :
            RST      => sync_rst                ,  -- In :
            CLR      => sync_clr                ,  -- In :
            DEBUG    => sync_local_debug        ,  -- In :
            SYNC     => sync_local_signal       ,  -- I/O:
            REQ(1)   => sync_local_m_req (0)    ,  -- In :
            REQ(2)   => sync_local_ar_req(0)    ,  -- In :
            REQ(3)   => sync_local_r_req (0)    ,  -- In :
            REQ(4)   => sync_local_aw_req(0)    ,  -- In :
            REQ(5)   => sync_local_w_req (0)    ,  -- In :
            REQ(6)   => sync_local_b_req (0)    ,  -- In :
            ACK(1)   => sync_local_m_ack (0)    ,  -- Out:
            ACK(2)   => sync_local_ar_ack(0)    ,  -- Out:
            ACK(3)   => sync_local_r_ack (0)    ,  -- Out:
            ACK(4)   => sync_local_aw_ack(0)    ,  -- Out:
            ACK(5)   => sync_local_w_ack (0)    ,  -- Out:
            ACK(6)   => sync_local_b_ack (0)       -- Out:
        );
    -- U_SYNC_PRINT : SYNC_PRINT generic map (NAME => NAME) port map (SYNC => sync_local_signal);
    -------------------------------------------------------------------------------
    -- このコア内部のローカルな同期回路
    -------------------------------------------------------------------------------
    SYNC_TRANSACTION_WRITE : SYNC_LOCAL_HUB
        generic map (
            NAME     => NAME & ":SYNC_TRANSACTION_WRITE",
            PLUG_SIZE=> 3
        )
        port map (
            CLK      => ACLK                    ,  -- In :
            RST      => sync_rst                ,  -- In :
            CLR      => sync_clr                ,  -- In :
            DEBUG    => sync_local_debug        ,  -- In :
            SYNC     => sync_write_signal       ,  -- I/O:
            REQ(1)   => sync_write_a_req(0)     ,  -- In :
            REQ(2)   => sync_write_d_req(0)     ,  -- In :
            REQ(3)   => sync_write_b_req(0)     ,  -- In :
            ACK(1)   => sync_write_a_ack(0)     ,  -- Out:
            ACK(2)   => sync_write_d_ack(0)     ,  -- Out:
            ACK(3)   => sync_write_b_ack(0)        -- Out:
        );
    -------------------------------------------------------------------------------
    -- このコア内部のローカルな同期回路
    -------------------------------------------------------------------------------
    SYNC_TRANSACTION_READ : SYNC_LOCAL_HUB
        generic map (
            NAME     => NAME & ":SYNC_TRANSACTION_READ",
            PLUG_SIZE=> 2
        )
        port map (
            CLK      => ACLK                    ,  -- In :
            RST      => sync_rst                ,  -- In :
            CLR      => sync_clr                ,  -- In :
            DEBUG    => sync_local_debug        ,  -- In :
            SYNC     => sync_read_signal        ,  -- I/O:
            REQ(1)   => sync_read_a_req(0)      ,  -- In :
            REQ(2)   => sync_read_d_req(0)      ,  -- In :
            ACK(1)   => sync_read_a_ack(0)      ,  -- Out:
            ACK(2)   => sync_read_d_ack(0)         -- Out:
        );
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
