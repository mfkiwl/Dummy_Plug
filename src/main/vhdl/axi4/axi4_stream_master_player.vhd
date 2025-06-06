-----------------------------------------------------------------------------------
--!     @file    axi4_stream_master player.vhd
--!     @brief   AXI4-Stream Master Dummy Plug Player.
--!     @version 1.9.3
--!     @date    2024/5/6
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
--! @brief   AXI4_STREAM_MASTER_PLAYER :
-----------------------------------------------------------------------------------
entity  AXI4_STREAM_MASTER_PLAYER is
    -------------------------------------------------------------------------------
    -- ジェネリック変数.
    -------------------------------------------------------------------------------
    generic (
        SCENARIO_FILE   : --! @brief シナリオファイルの名前.
                          STRING;
        NAME            : --! @brief 固有名詞.
                          STRING;
        OUTPUT_DELAY    : --! @brief 出力信号遅延時間
                          time;
        SYNC_PLUG_NUM   : --! @brief シンクロ用信号のプラグ番号.
                          SYNC_PLUG_NUM_TYPE := 1;
        SYNC_DEBUG      : --! @brief SYNC 機構のデバッグ出力を有効にするかどうかを指定する
                          boolean := FALSE;
        WIDTH           : --! @brief AXI4 IS WIDTH :
                          AXI4_STREAM_SIGNAL_WIDTH_TYPE;
        SYNC_WIDTH      : --! @brief シンクロ用信号の本数.
                          integer :=  1;
        GPI_WIDTH       : --! @brief GPI(General Purpose Input)信号のビット幅.
                          integer := 8;
        GPO_WIDTH       : --! @brief GPO(General Purpose Output)信号のビット幅.
                          integer := 8;
        FINISH_ABORT    : --! @brief FINISH コマンド実行時にシミュレーションを
                          --!        アボートするかどうかを指定するフラグ.
                          boolean := true
    );
    -------------------------------------------------------------------------------
    -- 入出力ポートの定義.
    -------------------------------------------------------------------------------
    port(
        ---------------------------------------------------------------------------
        -- グローバルシグナル.
        ---------------------------------------------------------------------------
        ACLK            : in    std_logic;
        ARESETn         : in    std_logic;
        ---------------------------------------------------------------------------
        -- AXI4-Streamシグナル.
        ---------------------------------------------------------------------------
        TDATA           : inout std_logic_vector(WIDTH.DATA  -1 downto 0);
        TSTRB           : inout std_logic_vector(WIDTH.DATA/8-1 downto 0);
        TKEEP           : inout std_logic_vector(WIDTH.DATA/8-1 downto 0);
        TUSER           : inout std_logic_vector(WIDTH.USER  -1 downto 0);
        TDEST           : inout std_logic_vector(WIDTH.DEST  -1 downto 0);
        TID             : inout std_logic_vector(WIDTH.ID    -1 downto 0);
        TLAST           : inout std_logic;
        TVALID          : inout std_logic;
        TREADY          : in    std_logic;
        ---------------------------------------------------------------------------
        -- シンクロ用信号.
        ---------------------------------------------------------------------------
        SYNC            : inout SYNC_SIG_VECTOR (SYNC_WIDTH   -1 downto 0);
        --------------------------------------------------------------------------
        -- General Purpose Input 信号
        --------------------------------------------------------------------------
        GPI             : in    std_logic_vector(GPI_WIDTH-1 downto 0) := (others => '0');
        --------------------------------------------------------------------------
        -- General Purpose Output 信号
        --------------------------------------------------------------------------
        GPO             : out   std_logic_vector(GPO_WIDTH-1 downto 0);
        --------------------------------------------------------------------------
        -- レポートステータス出力.
        --------------------------------------------------------------------------
        REPORT_STATUS   : out   REPORT_STATUS_TYPE;
        --------------------------------------------------------------------------
        -- シミュレーション終了通知信号.
        --------------------------------------------------------------------------
        FINISH          : out   std_logic
    );
end AXI4_STREAM_MASTER_PLAYER;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
library DUMMY_PLUG;
use     DUMMY_PLUG.AXI4_TYPES.all;
use     DUMMY_PLUG.AXI4_CORE.all;
use     DUMMY_PLUG.SYNC.all;
use     DUMMY_PLUG.UTIL.all;
-----------------------------------------------------------------------------------
--! @brief   AXI4-Stream Master Dummy Plug Player.
-----------------------------------------------------------------------------------
architecture MODEL of AXI4_STREAM_MASTER_PLAYER is
    -------------------------------------------------------------------------------
    --! SYNC 制御信号
    -------------------------------------------------------------------------------
    signal    sync_rst          : std_logic := '0';
    signal    sync_clr          : std_logic := '0';
    signal    sync_req          : SYNC_REQ_VECTOR(SYNC'range);
    signal    sync_ack          : SYNC_ACK_VECTOR(SYNC'range);
begin
    T: AXI4_STREAM_PLAYER
        ---------------------------------------------------------------------------
        -- ジェネリック変数.
        ---------------------------------------------------------------------------
        generic map(
            SCENARIO_FILE   => SCENARIO_FILE   ,
            NAME            => NAME            , 
            FULL_NAME       => NAME            ,
            MASTER          => TRUE            ,
            SLAVE           => FALSE           ,
            OUTPUT_DELAY    => OUTPUT_DELAY    ,
            WIDTH           => WIDTH           ,
            SYNC_WIDTH      => SYNC_WIDTH      ,
            GPI_WIDTH       => GPI_WIDTH       ,
            GPO_WIDTH       => GPO_WIDTH       ,
            FINISH_ABORT    => FINISH_ABORT
        )
        ---------------------------------------------------------------------------
        -- 入出力ポートの定義.
        ---------------------------------------------------------------------------
        port map(
            -----------------------------------------------------------------------
            -- グローバルシグナル.
            -----------------------------------------------------------------------
            ACLK            => ACLK            , -- In :
            ARESETn         => ARESETn         , -- In :
            -----------------------------------------------------------------------
            -- AXI4-Streamシグナル.
            -----------------------------------------------------------------------
            TDATA_I         => TDATA           , -- In :
            TDATA_O         => TDATA           , -- Out:
            TSTRB_I         => TSTRB           , -- In :
            TSTRB_O         => TSTRB           , -- Out:
            TKEEP_I         => TKEEP           , -- In :
            TKEEP_O         => TKEEP           , -- Out:
            TUSER_I         => TUSER           , -- In :
            TUSER_O         => TUSER           , -- Out:
            TDEST_I         => TDEST           , -- In :
            TDEST_O         => TDEST           , -- Out:
            TID_I           => TID             , -- In :
            TID_O           => TID             , -- Out:
            TLAST_I         => TLAST           , -- In :
            TLAST_O         => TLAST           , -- Out:
            TVALID_I        => TVALID          , -- In :
            TVALID_O        => TVALID          , -- Out:
            TREADY_I        => TREADY          , -- In :
            TREADY_O        => open            , -- Out:
            -----------------------------------------------------------------------
            -- シンクロ用信号.
            -----------------------------------------------------------------------
            SYNC_REQ        => sync_req        , -- Out:
            SYNC_ACK        => sync_ack        , -- In :
            -----------------------------------------------------------------------
            -- General Purpose Input 信号
            -----------------------------------------------------------------------
            GPI             => GPI             , -- In :
            -----------------------------------------------------------------------
            -- General Purpose Output 信号
            -----------------------------------------------------------------------
            GPO             => GPO             , -- Out:
            -----------------------------------------------------------------------
            -- レポートステータス出力.
            -----------------------------------------------------------------------
            REPORT_STATUS   => REPORT_STATUS   , -- Out:
            -----------------------------------------------------------------------
            -- シミュレーション終了通知信号.
            -----------------------------------------------------------------------
            FINISH          => FINISH            -- Out:
        );
    -------------------------------------------------------------------------------
    -- 同期回路
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
                DEBUG    => sync_debug          ,  -- In :
                SYNC     => SYNC(i)             ,  -- I/O:
                REQ      => sync_req(i)         ,  -- In :
                ACK      => sync_ack(i)            -- Out:
            );
    end generate;
    sync_rst <= '0' when (ARESETn = '1') else '1';
    sync_clr <= '0';
end MODEL;
-----------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------
