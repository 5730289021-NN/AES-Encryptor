------------------------------------------------------
-- Design Name : CipherCore
-- File Name : CipherCore.vhd
-- Function : Operators to perform encryption step
-- Coder : Norawit Nangsue
-------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CipherCore is
	port (
		CLK : in std_logic; -- Clock
		RST : in std_logic; -- Reset 
		RUN : in std_logic; -- Perform Encrypt after load
		CTYPE : in std_logic; -- Cipher Type
		SOCI : in std_logic_vector (7 downto 0); -- State Out Cipher In
		SICO : out std_logic_vector (7 downto 0); -- State In Cipher Out
		SA : out std_logic_vector (3 downto 0); -- State Address
		SWE : out std_logic; -- State Write Enable
		KOCI : in std_logic_vector(7 downto 0); -- Key Out Cipher In
		KICO : out std_logic_vector(7 downto 0); -- Key In Cipher Out
		KA : out std_logic_vector(3 downto 0); -- Key Address
		KWE : out std_logic; -- Key Write Enable
		FIN : out std_logic -- Cipher Finished
	);
end entity;
architecture Behavioural of CipherCore is
	----------------Internal variables----------------
	type CIPHER_STATE is (IDLE, SUB_BYTE, SHIFT_ROW, MIX_COLUMN, ADD_ROUND_KEY);
	signal CipherState : CIPHER_STATE;
	--Key State
    type KEY_STATE is (IDLE, READ_LAST, READ_MIDDLE, CHAIN);
    signal KeyState : KEY_STATE;
    --Read or Write State
    type RW_STATE is (READ, WRITE);
    signal rwState : RW_STATE;
	--For Address Lookup
	signal StateAddress : unsigned(3 downto 0) := "0000";
	signal KeyAddress : unsigned(3 downto 0) := "0000";
	signal StateAddressN : std_logic_vector(3 downto 0); -- State Address from Row and Column
	--For Storing Data
	signal RegZ : std_logic;
	signal RegA : std_logic_vector(7 downto 0);
	signal RegB : std_logic_vector(7 downto 0);
	signal RegC : std_logic_vector(7 downto 0);
	signal RegD : std_logic_vector(7 downto 0);
	--For storing data of Row/Column Diffusioning
	signal RegRow : unsigned(1 downto 0);
	signal RegCol : unsigned(1 downto 0);
	--Shift-XORed Signal of each Reg
	signal SigAx : std_logic_vector(7 downto 0);
	signal SigBx : std_logic_vector(7 downto 0);
	signal SigCx : std_logic_vector(7 downto 0);
	signal SigDx : std_logic_vector(7 downto 0);
	signal SigSOCIx : std_logic_vector(7 downto 0);
	--Round Counting
	signal Round : unsigned(3 downto 0);
	--Last Round(depending on ctype)
	signal LRound : unsigned(3 downto 0);
 

	--S-Box
	type SBOX_DATA is array(255 downto 0) of std_logic_vector(7 downto 0);
	constant SBox : SBOX_DATA := 
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
	--RCon
	type RCON_DATA is array(0 to 10) of std_logic_vector(7 downto 0);
	constant Rcon : RCON_DATA := 
	(X"8d", X"01", X"02", X"04", X"08", X"10", X"20", X"40", X"80", X"1b", X"36");
 

begin
	process (CLK, RST)
	begin
		if (RST = '1') then
			CipherState <= IDLE;
			rwState <= READ;
			RegZ <= '0';
			RegA <= X"00";
			RegB <= X"00";
			RegC <= X"00";
			RegD <= X"00";
			RegRow <= "01";
			RegCol <= "00";
			Round <= X"0";
			StateAddress <= "0000";
			KeyAddress <= X"0";
			SICO <= X"00";
			KICO <= X"00";
			SWE <= '0';
			KWE <= '0';
			FIN <= '0';
		elsif (rising_edge(CLK)) then
			case CipherState is
				when IDLE => 
					FIN <= '0';
					if RUN = '1' then
						CipherState <= ADD_ROUND_KEY;
						RegA <= X"00";
					end if;
				when SUB_BYTE => 
					if (StateAddress /= "0000") or (RegZ = '0') then
						RegZ <= '1';
						SWE <= '1';
						StateAddress <= StateAddress + 1;
						SICO <= SBox(to_integer(unsigned(SOCI)));
					elsif (StateAddress = "0000") and (RegZ = '1') then
						RegZ <= '0';
						CipherState <= SHIFT_ROW;
						RegRow <= "01";--?
						SWE <= '0';
					end if;
				when SHIFT_ROW => 
					if (rwState = READ) then
						case RegCol is
							when "00" => RegA <= SOCI;
							when "01" => RegB <= SOCI;
							when "10" => RegC <= SOCI;
							when "11" => 
								case RegRow is
									when "00" => -- No Rotate
										SICO <= RegA;
									when "01" => -- 1 Time
										SICO <= RegB;
										RegB <= RegC;
										RegC <= SOCI;
										RegD <= RegA;
									when "10" => -- 2 Times
										SICO <= RegC;
										RegB <= SOCI;
										RegC <= RegA;
										RegD <= RegB;
									when "11" => -- 3 Times
										SICO <= SOCI;
										RegB <= RegA;
										RegC <= RegB;
										RegD <= RegC;
									when others => 
							end case;
							rwState <= WRITE;
							SWE <= '1'; 
							when others => 
						end case;
					elsif (rwState = WRITE) then
						case RegCol is
							when "00" => SICO <= RegB; --Write B to SICO and
							when "01" => SICO <= RegC;
							when "10" => SICO <= RegD;
							when "11" => 
								rwState <= READ;
								SWE <= '0';
								RegRow <= RegRow + 1;
								if RegRow = "11" then
									if (Round = LRound) then
										CipherState <= ADD_ROUND_KEY;
										KeyState <= READ_LAST;
										KeyAddress <= X"D";
										KWE <= '0';
									else
										CipherState <= MIX_COLUMN;
									end if;
								end if;
							when others => 
						end case;
					end if;
					RegCol <= RegCol + 1;
				when MIX_COLUMN => 
					if (rwState = READ) then
						case RegRow is
							when "00" => RegA <= SOCI;
							when "01" => RegB <= SOCI;
							when "10" => RegC <= SOCI;
							when "11" => 
								SICO <= SigAx xor (SigBx xor RegB) xor RegC xor SOCI;
								RegB <= RegA xor SigBx xor (SigCx xor RegC) xor SOCI;
								RegC <= RegA xor RegB xor SigCx xor (SigSOCIx xor SOCI);
								RegD <= (SigAx xor RegA) xor RegB xor RegC xor SigSOCIx;
								rwState <= WRITE;
								SWE <= '1';
							when others => 
						end case;
					elsif (rwState = WRITE) then
						case RegRow is
							when "00" => SICO <= RegB;
							when "01" => SICO <= RegC;
							when "10" => SICO <= RegD;
							when "11" => 
								rwState <= READ;
								SWE <= '0';
								RegCol <= RegCol + 1;
								if RegCol = "11" then
									CipherState <= ADD_ROUND_KEY;
									KeyState <= READ_LAST;
									KeyAddress <= X"D";
									KWE <= '0';
								end if;
							when others => 
						end case;
					end if;
					RegRow <= RegRow + 1;
				when ADD_ROUND_KEY => 
					if (Round = X"0" or (Round = X"1" and CTYPE = '1')) then -- Can XOR immediately
						if (StateAddress /= "0000") or (RegZ = '0') then
							RegZ <= '1';
							SWE <= '1';
							StateAddress <= StateAddress + 1;
							KeyAddress <= KeyAddress + 1;
							SICO <= SOCI XOR KOCI;
						elsif (StateAddress = "0000") and (RegZ = '1') then
							RegZ <= '0';
							CipherState <= SUB_BYTE;
							Round <= Round + 1;
						end if;
					else
						case KeyState is
							when READ_LAST => --Checked
								case RegRow is
									when "00" => 
										KeyAddress <= X"E"; --Force Address Input
										RegA <= SBox(to_integer(unsigned(KOCI))) xor Rcon(to_integer(unsigned(Round)));
									when "01" => 
										KeyAddress <= X"F";
										RegB <= SBox(to_integer(unsigned(KOCI)));
									when "10" => 
										KeyAddress <= X"C";
										RegC <= SBox(to_integer(unsigned(KOCI)));
									when "11" => 
										RegD <= SBox(to_integer(unsigned(KOCI)));
										KeyState <= CHAIN;
										rwState <= WRITE;
									when others => 
							end case;
							RegRow <= RegRow + 1;
							when CHAIN => 
								SWE <= '1';
								KWE <= '1';
								case RegRow is
									when "00" => 
										RegA <= KOCI xor RegA;
										KICO <= KOCI xor RegA;
										SICO <= SOCI xor KOCI xor RegA;
										if (RegZ = '0') then
											RegZ <= '1';
										elsif (RegZ = '1' and RegCol = "00" and RegRow = "00") then
											RegZ <= '0';
											SWE <= '0';
											KWE <= '0';
											rwState <= READ;
											KeyState <= IDLE;
											if (Round = LRound) then
												FIN <= '1';
												CipherState <= IDLE;
												Round <= X"0";
											else
												CipherState <= SUB_BYTE;
												Round <= Round + 1;
											end if;
										end if;
									when "01" => 
										RegB <= KOCI xor RegB; --XOR with the Previous one
										KICO <= KOCI xor RegB; --Save Key
										SICO <= SOCI xor KOCI xor RegB; --Save State
									when "10" => 
										RegC <= KOCI xor RegC;
										KICO <= KOCI xor RegC;
										SICO <= SOCI xor KOCI xor RegC;
									when "11" => 
										RegD <= KOCI xor RegD;
										KICO <= KOCI xor RegD;
										SICO <= SOCI xor KOCI xor RegD;
										RegCol <= RegCol + 1;
									when others => 
							end case;
							RegRow <= RegRow + 1;
							when others => 
						end case;
 
					end if;
			end case;
		end if; 
	end process;
 
	--Signal For Mix Column
	SigAx <= (RegA(6 downto 0) & '0') when RegA(7) = '0'
	         else (RegA(6 downto 0) & '0') xor X"1b" when RegA(7) = '1';
	SigBx <= (RegB(6 downto 0) & '0') when RegB(7) = '0'
	         else (RegB(6 downto 0) & '0') xor X"1b" when RegB(7) = '1';
	SigCx <= (RegC(6 downto 0) & '0') when RegC(7) = '0'
	         else (RegC(6 downto 0) & '0') xor X"1b" when RegC(7) = '1';
	SigDx <= (RegD(6 downto 0) & '0') when RegD(7) = '0'
	         else (RegD(6 downto 0) & '0') xor X"1b" when RegD(7) = '1';
	SigSOCIx <= (SOCI(6 downto 0) & '0') when SOCI(7) = '0'
	            else (SOCI(6 downto 0) & '0') xor X"1b" when SOCI(7) = '1';

	StateAddressN <= std_logic_vector(RegCol) & std_logic_vector(RegRow);
 
	SA <= std_logic_vector(StateAddress) when CipherState = SUB_BYTE
	      else
	      std_logic_vector(StateAddress) when CipherState = ADD_ROUND_KEY and Round = 0
	      else std_logic_vector(StateAddress) when CipherState = ADD_ROUND_KEY and Round = 1 and CType = '1'
	      else StateAddressN when rwState = READ or KeyState = CHAIN
	      else std_logic_vector(unsigned(StateAddressN) + 1) when rwState = WRITE;
 
	KA(3 downto 0) <= std_logic_vector(KeyAddress) when Round = 0 or (Round = 1 and CType = '1') or KeyState = READ_LAST or KeyState = READ_MIDDLE
	                  else StateAddressN when KeyState = CHAIN
	                  else std_logic_vector(unsigned(StateAddressN) + 1) when rwState = WRITE;

 
	LRound <= "1010";
 
end Behavioural;