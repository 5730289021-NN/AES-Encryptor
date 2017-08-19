-------------------------------------------------------
-- Design Name : KeyState
-- File Name   : KeyState.vhd
-- Function    : Synchronous read write RAM to collect the KeyState
-- Coder       : Deepak Kumar Tala (Verilog)
-- Translator  : Alexander H Pham (VHDL)
-- Modifier    : Norawit Nangsue
-------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity KeyState is
    port (
        CLK         :in   std_logic;                      -- Clock
        RST         :in   std_logic;                      -- Reset
        ADDRESS     :in   std_logic_vector (3 downto 0);  -- Address
        DOUT        :out  std_logic_vector (7 downto 0);  -- Data Out
        WE          :in   std_logic;                      -- Write Enable from Address
        LOAD        :in   std_logic;                      -- User Load
        UIN         :in   std_logic_vector(7 downto 0);   -- User Input
        CIN         :in   std_logic_vector(7 downto 0)    -- Cipher Input
    );
end entity;

architecture Behavioural of KeyState is
    ----------------Internal variables----------------
    type RAM is array (integer range <>)of std_logic_vector (7 downto 0);
    signal mem : RAM (0 to 15);
    signal addressCounter : unsigned(3 downto 0);
begin
    process (CLK, RST)
    begin
        if (RST = '1') then
            addressCounter <= "0000";
        elsif (rising_edge(CLK)) then
            if (LOAD = '1') then
                addressCounter <= addressCounter + 1;
                mem(to_integer(unsigned(addressCounter))) <= UIN;
            elsif (WE = '1') then
                mem(to_integer(unsigned(address) - 1)) <= CIN;
            end if;
        end if;
    end process;
    DOUT <= mem(to_integer(unsigned(address)));
end Behavioural;