-------------------------------------------------------
-- Design Name : CipherCore
-- File Name   : CipherCore.vhd
-- Function    : Operators to perform encryption step 
-- Coder       : Norawit Nangsue
-------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity State is
    generic (
        DATA_WIDTH :integer := 8;
        ADDR_WIDTH :integer := 4;
        TOTAL_STATE:integer := 1
    );
    port (
        clk        :in   std_logic;                                 -- Clock Input
        address    :out  std_logic_vector (ADDR_WIDTH-1 downto 0);  -- Address Input
        plainByte  :in   std_logic_vector (DATA_WIDTH-1 downto 0);  -- Input Data
        CipherByte :out  std_logic_vector (DATA_WIDTH-1 downto 0);  -- Output Data
        StateWE    :out  std_logic;                                 -- Write Enable/Read Enable
        StateOE    :out  std_logic;                                 -- Output Enable
        CipherState:in   std_logic_vector (TOTAL_STATE-1 downto 0)
    );
end entity;
architecture rtl of State is
    ----------------Internal variables----------------
    
begin
    -- Write Operation : When we = 1, cs = 1
    -- Read Operation : When we = 0, oe = 1, cs = 1

    -- State 0 : SubByte
    -- State 1 : ShiftRow
    -- State 2 : MixColumn
    -- State 3 : AddRoundKey
    
    
    SUB_BYTE:
    process (clk) begin
        if (rising_edge(clk)) then
            if (CipherState = "00") then
                mem(conv_integer(address)) <= dataIn;
            end if;
        end if;
    end process;

    -- Memory Read Block
    
    SHIFT_ROW:
    process (clk) begin
        if (rising_edge(clk)) then
            if (we = '0' and oe = '1') then
                 dataOut <= mem(conv_integer(address));
            end if;
        end if;
    end process;

    MIX_COLUMN:
    process (clk) begin
        if (rising_edge(clk)) then
            if (we = '0' and oe = '1') then
                 dataOut <= mem(conv_integer(address));
            end if;
        end if;
    end process;

    ADD_ROUND_KEY:
    process (clk) begin
        if (rising_edge(clk)) then
            if (we = '0' and oe = '1') then
                 dataOut <= mem(conv_integer(address));
            end if;
        end if;
    end process;

end architecture;