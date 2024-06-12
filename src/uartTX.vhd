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
signal eCFrame, eCFramer : std_logic;
signal eNewSymbol : std_logic;
signal cSymbolCycles : unsigned(log2(SYMBOLCYCLES)-1 downto 0);
signal cFrameSymbols : unsigned(log2(FRAMEBITS)-1 downto 0);
signal shiftReg : std_logic_vector(FRAMEBITS - 1 downto 0);
signal loadSignal : std_logic_vector(FRAMEBITS -1 downto 0);

begin

-- eCFramer='1' during the entire frame and register it.
-- Enable for the counters.
eCFramer <= '0' when rst='1' else eCFrame when rising_edge(clk);
eCFrame <= '1' when cSymbolCycles=to_unsigned(0,log2(SYMBOLCYCLES)) and cFrameSymbols=to_unsigned(0,log2(FRAMEBITS)) and start='1' else
           '0' when cFrameSymbols=to_unsigned(FRAMEBITS,log2(FRAMEBITS)) else
            eCFramer;

-- Counter of cycles per symbol.
-- Counter of the frame symbols.
-- Only working for the frame duration.
process(rst, clk)
begin
    if rst='1' then
        cSymbolCycles <= (others =>'0');
        cFrameSymbols <= (others =>'0');
    elsif(rising_edge(clk)) then
        if eCFramer='1' then 
            if cSymbolCycles=to_unsigned(SYMBOLCYCLES,log2(SYMBOLCYCLES)) then
                cSymbolCycles <= (others=>'0');
            else
                cSymbolCycles <= cSymbolCycles + 1;
            end if;
        end if;
        if eNewSymbol='1' then 
            if cFrameSymbols=to_unsigned(FRAMEBITS,log2(FRAMEBITS)) then
                cFrameSymbols <= (others=>'0');
            else
                cFrameSymbols <= cFrameSymbols + 1;
            end if;
        end if;
    end if;
end process;

-- eNewSymbol='1' (pulse) at the start of the new symbol. 
eNewSymbol <= '1' when eCFramer='1' and cSymbolCycles=to_unsigned((SYMBOLCYCLES), log2(SYMBOLCYCLES)) else '0';

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
process(start, clk)
begin
    if start='1' then
        shiftReg <= loadSignal;
    elsif(rising_edge(clk)) then
        if start='1' or eNewSymbol='1' then
            for b in FRAMEBITS-2 downto 0 loop
                shiftReg(b) <= shiftReg(b+1);
            end loop;
        end if;
    end if;
end process;

-- Output data.
tx <= shiftReg(0) when eCFramer='1' else '1';

end arch;
