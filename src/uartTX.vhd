library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity uartTX is
generic(
    FCLKMHZ:   integer := 27;
    DATABITS:  integer := 8;
    STOPBIT:   integer := 1;
    PARITYBIT: integer := 1;
    BAUDRATE:  integer := 115200
);
port(
    clk: in std_logic;
    rst: in std_logic;
    tx:  out std_logic;
    start: in std_logic;
    dataSent: in std_logic_vector(DATABITS-1 downto 0)
);
end uartTX;

architecture arch of uartTX is

-- Functions
function log2(A: integer) return integer;
function log2(A: integer) return integer is 
variable cc : integer := 0;
begin
    for it in 0 to A-1 loop
        if 2**cc > A then
            return cc;
        else
            cc := cc + 1;
        end if;
    end loop;
    return -1;
end;

-- Constants
constant FRAMEBITS : integer := 1 + DATABITS + PARITYBIT + STOPBIT;
constant FRAMECYCLES : integer := FCLKMHZ * 1000000 * FRAMEBITS / BAUDRATE;
constant SYMBOLCYCLES : integer := FCLKMHZ * 1000000 / BAUDRATE;
constant HALFSYMBOLCYCLES : integer := FCLKMHZ * 1000000 / (BAUDRATE * 2);

-- Signals
signal cSymbolCycles : unsigned(log2(SYMBOLCYCLES)-1 downto 0);
signal cFrameSymbols : unsigned(log2(FRAMEBITS)-1 downto 0);

signal eCFrame, eCFrameNext : std_logic;
signal eNewSymbol : std_logic;

signal shiftReg : std_logic_vector(FRAMEBITS - 1 downto 0);
signal loadSignal : std_logic_vector(FRAMEBITS -1 downto 0);

begin


-- Counter of cycles per symbol.
-- Counter of the frame symbols.
process(rst, start, clk)
begin
    if rst='1' or start='1' then
        cSymbolCycles <= (others =>'0');
        cFrameSymbols <= (others =>'0');
    elsif(rising_edge(clk)) then
        if cSymbolCycles=to_unsigned(SYMBOLCYCLES,log2(SYMBOLCYCLES)) then
            cSymbolCycles <= (others=>'0');
        else
            cSymbolCycles <= cSymbolCycles + 1;
        end if;
        cFrameSymbols <= cFrameSymbols + 1;
    end if;
end process;

-- Enable during the frame
--eCFrame <= '1' when rising_edge(clk) and cSymbolCycles=to_unsigned(0,log2(SYMBOLCYCLES)) else '0';
eCFrameNext <= start when cSymbolCycles=to_unsigned(0,log2(SYMBOLCYCLES)) else eCFrame;
process(rst, clk)
begin
    if rst='1' then
        eCFrame<='0';
    elsif rising_edge(clk) then
        eCFrame <= eCFrameNext;
    end if;
end process;

-- eNewSymbol='1' (pulse) at the start of the new symbol. 
eNewSymbol <= '1' when eCFrame='1' and cSymbolCycles=to_unsigned((SYMBOLCYCLES), log2(SYMBOLCYCLES)) else '0';

-- Signal to be loaded to the registers:
-- Start bit.
loadSignal(DATABITS downto 0) <= dataSent&'0';

-- Parity bits.
PARITY_BLOCK: if PARITYBIT>0 generate
signal xorCalc : std_logic_vector(DATABITS-1 downto 0);
begin
    xorCalc(0) <= dataSent(0);
    PARITY_BLOCK_LOOP: for i in 0 to DATABITS-2 generate
        xorCalc(i+1) <= dataSent(i+1) xor xorCalc(i);
    end generate;
    loadSignal(DATABITS+1) <= xorCalc(DATABITS-1);
end generate;

-- Stop bits.
STOP_BLOCK: for i in 1 to STOPBIT generate
    loadSignal(FRAMEBITS - i) <= '1';
end generate;

-- Shift Register of the symbols sampled.
process(rst, clk, start)
begin
    if rst = '1' or start = '1' then
        shiftReg <= loadSignal;
    elsif(rising_edge(clk)) then
        if eNewSymbol='1' then
            for b in FRAMEBITS-2 downto 0 loop
                shiftReg(b) <= shiftReg(b+1);
            end loop;
        end if;
    end if;
end process;

-- Output data.
tx <= shiftReg(0) when eCFrame='1' else '1';

end arch;
