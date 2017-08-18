----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/16/2017 10:18:37 PM
-- Design Name: 
-- Module Name: Fusion - Behavioral
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

entity Fusion is
    Port ( CLK  : in STD_LOGIC;                               -- Clock
           RST  : in STD_LOGIC;                               -- Reset
           PT   : in STD_LOGIC_VECTOR(7 downto 0);            -- Plain Text
           PTL  : in STD_LOGIC;                               -- Plain Text Load
           KEY  : in STD_LOGIC_VECTOR(7 downto 0);            -- Input Key
           KEYL : in STD_LOGIC;                               -- Input Key Load  
           CT   : out STD_LOGIC_VECTOR(7 downto 0);           -- Cipher Text
           CTYPE: in STD_LOGIC;                               -- Cipher Type (0 : AES-128, 1 : AES-256)
           RUN  : in STD_LOGIC;                               -- Run
           DONE : out STD_LOGIC);                             -- Finished
end Fusion;

architecture Structural of Fusion is

    component State
        port (
            CLK         :in   std_logic;                      -- Clock
            RST         :in   std_logic;                      -- Reset
            ADDRESS     :in   std_logic_vector (3 downto 0);  -- Address
            DOUT        :out  std_logic_vector (7 downto 0);  -- Data Out
            WE          :in   std_logic;                      -- Write Enable
            LOAD        :in   std_logic;                      -- User Load
            UIN         :in   std_logic_vector(7 downto 0);   -- User Input
            CIN         :in   std_logic_vector(7 downto 0);   -- Cipher Input
            CT          :out  std_logic_vector(7 downto 0);   -- Cipher Text
            FIN         :in   std_logic                       -- Finished
        );
    end component;
    
    component KeyState
            port (
                CLK         :in   std_logic;                      -- Clock
                RST         :in   std_logic;                      -- Reset
                ADDRESS     :in   std_logic_vector (4 downto 0);  -- Address
                DOUT        :out  std_logic_vector (7 downto 0);  -- Data Out
                WE          :in   std_logic;                      -- Write Enable
                LOAD        :in   std_logic;                      -- User Load
                UIN         :in   std_logic_vector(7 downto 0);   -- User Input
                CIN         :in   std_logic_vector(7 downto 0);    -- Cipher Input
                CTYPE       :in   std_logic                       -- Cipher Type(0:128, 1:256)
            );
    end component;
        
    component CipherCore
        port (
            CLK         :in   std_logic;                      -- Clock
            RST         :in   std_logic;                      -- Reset       
            RUN         :in   std_logic;                      -- Perform Encrypt after load
            CTYPE       :in   std_logic;                      -- Cipher Type
            SOCI        :in   std_logic_vector (7 downto 0);  -- State Out Cipher In
            SICO        :out  std_logic_vector (7 downto 0);  -- State In Cipher Out
            SA          :out  std_logic_vector (3 downto 0);  -- State Address
            SWE         :out  std_logic;                      -- State Write Enable           
            KOCI        :in   std_logic_vector(7 downto 0);   -- Key Out Cipher In
            KICO        :out  std_logic_vector(7 downto 0);   -- Key In Cipher Out
            KA          :out  std_logic_vector(4 downto 0);   -- Key Address
            KWE         :out  std_logic;                      -- Key Write Enable
            FIN         :out  std_logic                       -- Finished
        );
    end component;
    -- Data State
    signal SA   : std_logic_vector(3 downto 0);
    signal SOCI : std_logic_vector(7 downto 0);
    signal SWE  : std_logic;
    signal SICO : std_logic_vector(7 downto 0);
    -- Key State
    signal KA   : std_logic_vector(4 downto 0);
    signal KOCI : std_logic_vector(7 downto 0);
    signal KWE  : std_logic;
    signal KICO : std_logic_vector(7 downto 0);
    
    --Finished
    signal FIN : std_logic;
    
begin
    DState : State
    port map (CLK         => CLK,
              RST         => RST,
              ADDRESS     => SA,
              DOUT        => SOCI,
              WE          => SWE,
              LOAD        => PTL,
              UIN         => PT,
              CIN         => SICO,
              CT          => CT,
              FIN         => FIN
              );
              
    KState : KeyState
    port map (CLK         => CLK,
              RST         => RST,
              ADDRESS     => KA,
              DOUT        => KOCI,
              WE          => KWE,
              LOAD        => KEYL,
              UIN         => KEY,
              CIN         => KICO,
              CTYPE       => CTYPE
              );
              
    Cipher : CipherCore
    port map (CLK   => CLK,
              RST   => RST,
              RUN   => RUN,
              CTYPE => CTYPE,
              SOCI  => SOCI,
              SICO  => SICO,
              SA    => SA,
              SWE   => SWE,
              KOCI  => KOCI,
              KICO  => KICO,
              KA    => KA,
              KWE   => KWE,
              FIN  => FIN);
    
    DONE <= FIN;


end Structural;
