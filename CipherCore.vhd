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
    port (
        clk        :in   std_logic;                         -- Clock Input
        rst        :in   std_logic;                                 
        run        :in   std_logic
        address    :out  std_logic_vector (7 downto 0);  -- Address Input
        PlainByte  :in   std_logic_vector (7 downto 0);  -- Input Data
        CipherByte :out  std_logic_vector (7 downto 0);  -- Output Data
        StateWE    :out  std_logic;                                 -- Write Enable/Read Enable
        StateOE    :out  std_logic;                                 -- Output Enable
        
    );
end entity;
architecture rtl of State is
    ----------------Internal variables----------------
    type CIPHER_STATE is (IDLE, SUB_BYTE, SHIFT_ROW, MIX_COLUMN, ADD_ROUND_KEY);
    signal CipherState  : CIPHER_STATE;
    --For Address Lookup
    signal StateAddress : std_logic_vector(3 downto 0) := "0000";
    --For Storing Data
    signal RegA : std_logic_vector(3 downto 0);
    signal RegB : std_logic_vector(3 downto 0);
    signal RegC : std_logic_vector(3 downto 0);
    signal RegD : std_logic_vector(3 downto 0);
    signal RegX : std_logic_vector(15 downto 0);
    --Read or Write State
    type RW_STATE is (READ, WRITE);
    signal rwState : RW_STATE;
    --For storing data of Row/Column Diffusioning
    signal RegRow: std_logic_vector(2 downto 0);
    signal RegCol: std_logic_vector(2 downto 0);

    --S-Box
    type SBOX_DATA is array(0 to 255) of std_logic_vector(7 downto 0);
    constant SBox: SBOX_DATA(0 to 255) :=
    (
    X"16", X"bb", X"54", X"b0", X"0f", X"2d", X"99", X"41", X"68", X"42", X"e6", X"bf", X"0d", X"89", X"a1", X"8c", 
    X"df", X"28", X"55", X"ce", X"e9", X"87", X"1e", X"9b", X"94", X"8e", X"d9", X"69", X"11", X"98", X"f8", X"e1", 
    X"9e", X"1d", X"c1", X"86", X"b9", X"57", X"35", X"61", X"0e", X"f6", X"03", X"48", X"66", X"b5", X"3e", X"70", 
    X"8a", X"8b", X"bd", X"4b", X"1f", X"74", X"dd", X"e8", X"c6", X"b4", X"a6", X"1c", X"2e", X"25", X"78", X"ba", 
    X"08", X"ae", X"7a", X"65", X"ea", X"f4", X"56", X"6c", X"a9", X"4e", X"d5", X"8d", X"6d", X"37", X"c8", X"e7", 
    X"79", X"e4", X"95", X"91", X"62", X"ac", X"d3", X"c2", X"5c", X"24", X"06", X"49", X"0a", X"3a", X"32", X"e0", 
    X"db", X"0b", X"5e", X"de", X"14", X"b8", X"ee", X"46", X"88", X"90", X"2a", X"22", X"dc", X"4f", X"81", X"60", 
    X"73", X"19", X"5d", X"64", X"3d", X"7e", X"a7", X"c4", X"17", X"44", X"97", X"5f", X"ec", X"13", X"0c", X"cd", 
    X"d2", X"f3", X"ff", X"10", X"21", X"da", X"b6", X"bc", X"f5", X"38", X"9d", X"92", X"8f", X"40", X"a3", X"51", 
    X"a8", X"9f", X"3c", X"50", X"7f", X"02", X"f9", X"45", X"85", X"33", X"4d", X"43", X"fb", X"aa", X"ef", X"d0", 
    X"cf", X"58", X"4c", X"4a", X"39", X"be", X"cb", X"6a", X"5b", X"b1", X"fc", X"20", X"ed", X"00", X"d1", X"53", 
    X"84", X"2f", X"e3", X"29", X"b3", X"d6", X"3b", X"52", X"a0", X"5a", X"6e", X"1b", X"1a", X"2c", X"83", X"09", 
    X"75", X"b2", X"27", X"eb", X"e2", X"80", X"12", X"07", X"9a", X"05", X"96", X"18", X"c3", X"23", X"c7", X"04", 
    X"15", X"31", X"d8", X"71", X"f1", X"e5", X"a5", X"34", X"cc", X"f7", X"3f", X"36", X"26", X"93", X"fd", X"b7", 
    X"c0", X"72", X"a4", X"9c", X"af", X"a2", X"d4", X"ad", X"f0", X"47", X"59", X"fa", X"7d", X"c9", X"82", X"ca", 
    X"76", X"ab", X"d7", X"fe", X"2b", X"67", X"01", X"30", X"c5", X"6f", X"6b", X"f2", X"7b", X"77", X"7c", X"63" 
    );

begin
    -- Write Operation : When we = 1, cs = 1
    -- Read Operation : When we = 0, oe = 1, cs = 1
    process (clk, rst)
    begin
        if rst = '1' then
            CipherState <= IDLE;
            rwState <= READ;
            RegA <= "0000";
            RegB <= "0000";
            RegC <= "0000";
            RegD <= "0000";
            StateAddress <= "0000";
            StateOE <= '1';
            StateWE <= '0';
        elsif (rising_edge(clk)) then
            case CipherState is
                when IDLE =>
                    if run = '1' then
                        CipherState <= SUB_BYTE;
                    end if;
                when SUB_BYTE =>
                    StateWE <= '1';
                    CipherByte <= SBox(PlainByte);
                    StateAddress <= StateAddress + '1';
                    if StateAddress = "1111" then
                        CipherState = SHIFT_ROW;
                        StateWE <= '0';
                    end if;
                when SHIFT_ROW =>
                    if rwState = READ then
                        case RegCol is
                            when "00" => RegA <= PlainByte;
                            when "01" => RegB <= PlainByte;
                            when "10" => RegC <= PlainByte;
                            when "11" =>
                                case RegRow is
                                    when "00" => RegX <= RegA & RegB & RegC & PlainByte;
                                    when "01" => RegX <= RegB & RegC & PlainByte & RegA;
                                    when "10" => RegX <= RegC & PlainByte & RegA & RegB;
                                    when "11" => RegX <= PlainByte & RegA & RegB & RegC;
                                end case;
                                rwState <= WRITE;
                                StateAddress <= StateAddress - "0011";
                        end case;
                    elsif rwState = WRITE then
                        StateWE <= '1';
                        case RegCol is
                            when "00" => CipherByte <= RegX(15 downto 12);
                            when "01" => CipherByte <= RegX(11 downto 8);
                            when "10" => CipherByte <= RegX(7 downto 4);
                            when "11" => 
                                CipherByte <= RegX(3 downto 0);
                                rwState <= READ;
                                if RegRow = "11"
                                    CipherState <= MIX_COLUMN;
                                end if;
                        end case;
                    end if;
                    RegCol <= RegCol + '1';
                    StateAddress <= StateAddress + '1';
                when MIX_COLUMN =>
                    

                when ADD_ROUND_KEY =>
                
            end case;
        end if;  
    end process;

end architecture;

--if rwState = READ then
                    --    RegA <= SBox(PlainByte);
                    --    StateWE <= '1';
                    --    rwState <= WRITE
                    --elsif rwState = WRITE then
                    --    CipherByte <= RegA;
                    --    StateAddress <= StateAddress + 1;
                    --    StateWE <= '0';
                    --    rwState <= READ;
                    --    if StateAddress = "1111" then
                    --       CipherState = SHIFT_ROW;
                    --    end if;
                    --end if;