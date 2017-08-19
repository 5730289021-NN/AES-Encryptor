-------------------------------------------------------
-- Design Name : State
-- File Name : State.vhd
-- Function : Synchronous read write RAM to collect the State
-- Coder : Deepak Kumar Tala (Verilog)
-- Translator : Alexander H Pham (VHDL)
-- Modifier : Norawit Nangsue
-------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity State is
	port (
		CLK : in std_logic; -- Clock
		RST : in std_logic; -- Reset
		ADDRESS : in std_logic_vector (3 downto 0); -- Address
		DOUT : out std_logic_vector (7 downto 0); -- Data Out
		WE : in std_logic; -- Write Enable from Address
		LOAD : in std_logic; -- User Load
		UIN : in std_logic_vector(7 downto 0); -- User Input
		CIN : in std_logic_vector(7 downto 0); -- Cipher Input
		CT : out std_logic_vector(7 downto 0); -- Cipher Text
		FIN : in std_logic
	);
end entity;

architecture Behavioural of State is
	----------------Internal variables----------------
	type RAM is array (integer range <>)of std_logic_vector (7 downto 0);
	signal mem : RAM (0 to 15);
	signal addressCounter : unsigned(3 downto 0);
	signal RegZ : std_logic;
begin
	process (CLK, RST)
	begin
		if (RST = '1') then
			CT <= X"00";
			addressCounter <= "0000";
			RegZ <= '0';
		elsif (rising_edge(clk)) then
			if (LOAD = '1') then
				addressCounter <= addressCounter + 1;
				mem(to_integer(unsigned(addressCounter))) <= UIN;
			elsif (WE = '1') then
				mem(to_integer(unsigned(address) - 1)) <= CIN;
			elsif (FIN = '1' or RegZ = '1') then
				addressCounter <= addressCounter + 1;
				CT <= mem(to_integer(unsigned(addressCounter)));
				if (RegZ = '0') then
					RegZ <= '1';
				elsif (addressCounter = "1111") then
					RegZ <= '0';
				end if;
			end if;
		end if;
	end process;
	DOUT <= mem(to_integer(unsigned(address)));
end Behavioural;