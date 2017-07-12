-------------------------------------------------------
-- Design Name : AsyncState
-- File Name   : AsyncState.vhd
-- Function    : Asynchronous read write RAM to collect the State
-- Coder       : Deepak Kumar Tala (Verilog)
-- Translator  : Alexander H Pham (VHDL)
-- Modifier    : Norawit Nangsue

-- Not Finished
-------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity State is
    generic (
        DATA_WIDTH :integer := 8;
        ADDR_WIDTH :integer := 4
    );
    port (
        clk     :in    std_logic;                                 -- Clock Input
        address :in    std_logic_vector (ADDR_WIDTH-1 downto 0);  -- Address Input
        dataIn  :in    std_logic_vector (DATA_WIDTH-1 downto 0);  -- Input Data
        dataOut :out   std_logic_vector (DATA_WIDTH-1 downto 0);  -- Output Data
        we      :in    std_logic;                                 -- Write Enable/Read Enable
        oe      :in    std_logic                                  -- Output Enable
    );
end entity;
architecture rtl of State is
    ----------------Internal variables----------------
    constant RAM_DEPTH :integer := 2**ADDR_WIDTH;
    type RAM is array (integer range <>)of std_logic_vector (DATA_WIDTH-1 downto 0);
    signal mem : RAM (0 to RAM_DEPTH-1);
begin

    -- Memory Write Block
    -- Write Operation : When we = 1, cs = 1
    MEM_WRITE:
    process (clk) begin
        if (rising_edge(clk)) then
            if (we = '1') then
                mem(conv_integer(address)) <= dataIn;
            end if;
        end if;
    end process;

    -- Memory Read Block
    -- Read Operation : When we = 0, oe = 1, cs = 1
    MEM_READ:
    process (clk) begin
        if (rising_edge(clk)) then
            if (we = '0' and oe = '1') then
                 dataOut <= mem(conv_integer(address));
            end if;
        end if;
    end process;

end architecture;