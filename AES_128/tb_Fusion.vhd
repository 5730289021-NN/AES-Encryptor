-- Testbench automatically generated online
-- at http://vhdl.lapinoo.net
-- Generation date : 17.7.2017 09:06:40 GMT

library ieee;
use ieee.std_logic_1164.all;

entity tb_Fusion is
end tb_Fusion;

architecture tb of tb_Fusion is

    component Fusion
        port (CLK   : in std_logic;
              RST   : in std_logic;
              PT    : in std_logic_vector (7 downto 0);
              PTL   : in std_logic;
              KEY   : in std_logic_vector (7 downto 0);
              KEYL  : in std_logic;
              CT    : out std_logic_vector (7 downto 0);
              CTYPE : in std_logic;
              RUN   : in std_logic;
              DONE  : out std_logic);
    end component;

    signal CLK   : std_logic;
    signal RST   : std_logic;
    signal PT    : std_logic_vector (7 downto 0);
    signal PTL   : std_logic;
    signal KEY   : std_logic_vector (7 downto 0);
    signal KEYL  : std_logic;
    signal CT    : std_logic_vector (7 downto 0);
    signal CTYPE : std_logic;
    signal RUN   : std_logic;
    signal DONE  : std_logic;

    constant TbPeriod : time := 1000 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : Fusion
    port map (CLK   => CLK,
              RST   => RST,
              PT    => PT,
              PTL   => PTL,
              KEY   => KEY,
              KEYL  => KEYL,
              CT    => CT,
              CTYPE => CTYPE,
              RUN   => RUN,
              DONE  => DONE);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that CLK is really your main clock signal
    CLK <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        PT <= (others => '0');
        PTL <= '0';
        KEY <= (others => '0');
        KEYL <= '0';
        CTYPE <= '0';
        RUN <= '0';

        -- Reset generation
        -- EDIT: Check that RST is really your reset signal
        RST <= '1';
        wait for 1000 ns;
        RST <= '0';
        wait for 1000 ns;

        -- EDIT Add stimuli here
        PTL <= '1';
        KEYL <= '1';
        PT <= X"00";
        KEY <= X"00";
        wait for TbPeriod;
        PT <= X"11";
        KEY <= X"01";
        wait for TbPeriod;
        PT <= X"22";
        KEY <= X"02";
        wait for TbPeriod;
        PT <= X"33";
        KEY <= X"03";
        wait for TbPeriod;
        PT <= X"44";
        KEY <= X"04";
        wait for TbPeriod;
        PT <= X"55";
        KEY <= X"05";
        wait for TbPeriod;
        PT <= X"66";
        KEY <= X"06";
        wait for TbPeriod;
        PT <= X"77";
        KEY <= X"07";
        wait for TbPeriod;
        PT <= X"88";
        KEY <= X"08";
        wait for TbPeriod;
        PT <= X"99";
        KEY <= X"09";
        wait for TbPeriod;
        PT <= X"AA";
        KEY <= X"0A";
        wait for TbPeriod;
        PT <= X"BB";
        KEY <= X"0B";
        wait for TbPeriod;
        PT <= X"CC";
        KEY <= X"0C";
        wait for TbPeriod;
        PT <= X"DD";
        KEY <= X"0D";
        wait for TbPeriod;
        PT <= X"EE";
        KEY <= X"0E";
        wait for TbPeriod;
        PT <= X"FF";
        KEY <= X"0F";
        wait for TbPeriod;
        PT <= X"FE";
        KEY <= X"01";
        PTL <= '0';
        KEYL <= '0';
        wait for TbPeriod;
        RUN <= '1';
        wait for 10 * TbPeriod;
        RUN <= '0';
        
        wait for 1000 * TbPeriod;
        CTYPE <= '1';
        wait for TbPeriod;
        RST <= '1';
        
        wait for TbPeriod;
        RST <= '0';
        wait for TbPeriod;
        
        PTL <= '1';
        KEYL <= '1';
        PT <= X"00";
        KEY <= X"00";
        wait for TbPeriod;
        PT <= X"11";
        KEY <= X"01";
        wait for TbPeriod;
        PT <= X"22";
        KEY <= X"02";
        wait for TbPeriod;
        PT <= X"33";
        KEY <= X"03";
        wait for TbPeriod;
        PT <= X"44";
        KEY <= X"04";
        wait for TbPeriod;
        PT <= X"55";
        KEY <= X"05";
        wait for TbPeriod;
        PT <= X"66";
        KEY <= X"06";
        wait for TbPeriod;
        PT <= X"77";
        KEY <= X"07";
        wait for TbPeriod;
        PT <= X"88";
        KEY <= X"08";
        wait for TbPeriod;
        PT <= X"99";
        KEY <= X"09";
        wait for TbPeriod;
        PT <= X"AA";
        KEY <= X"0A";
        wait for TbPeriod;
        PT <= X"BB";
        KEY <= X"0B";
        wait for TbPeriod;
        PT <= X"CC";
        KEY <= X"0C";
        wait for TbPeriod;
        PT <= X"DD";
        KEY <= X"0D";
        wait for TbPeriod;
        PT <= X"EE";
        KEY <= X"0E";
        wait for TbPeriod;
        PT <= X"FF";
        KEY <= X"0F";
        wait for TbPeriod;
        PTL <= '0';
        KEY <= X"10";
        wait for TbPeriod;
        KEY <= X"11";
        wait for TbPeriod;
        KEY <= X"12";
        wait for TbPeriod;
        KEY <= X"13";
        wait for TbPeriod;
        KEY <= X"14";
        wait for TbPeriod;
        KEY <= X"15";
        wait for TbPeriod;
        KEY <= X"16";
        wait for TbPeriod;
        KEY <= X"17";
        wait for TbPeriod;
        KEY <= X"18";
        wait for TbPeriod;
        KEY <= X"19";
        wait for TbPeriod;
        KEY <= X"1A";
        wait for TbPeriod;
        KEY <= X"1B";
        wait for TbPeriod;
        KEY <= X"1C";
        wait for TbPeriod;
        KEY <= X"1D";
        wait for TbPeriod;
        KEY <= X"1E";
        wait for TbPeriod;
        KEY <= X"1F";
        wait for TbPeriod;                                                                                
        KEYL <= '0';
        wait for TbPeriod;
        RUN <= '1';
        
        wait for 10 * TbPeriod;
        RUN <= '0';
        wait for 1700 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;