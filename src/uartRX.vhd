library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity uartRX is
generic(
    FCLKMHZ:   integer := 27;
    DATABITS:  integer := 8;
    STOPBIT:   integer := 0;
    PARITYBIT: integer := 0;
    BAUDRATE:  integer := 115200
);
port(
    clk: in std_logic;
    rst: in std_logic;
    rx:  in std_logic;
    finish: out std_logic;
    dataOut: out std_logic_vector(DATABITS-1 downto 0)
);
end uartRX;

architecture arch of uartRX is
    
-- Functions
function log2(A:  integer) return integer;
function log2(A:  integer) return integer is 
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
signal eHalfBit : std_logic;
signal cSymbolCycles : unsigned(log2(SYMBOLCYCLES)-1 downto 0);
signal cFrameSymbols : unsigned(log2(FRAMEBITS)-1 downto 0);
signal shiftReg : std_logic_vector(FRAMEBITS - 1 downto 0);

begin

-- eCFramer='1' during the entire frame and register it.
-- Enable for the counters.
eCFramer <= '0' when rst='1' else eCFrame when rising_edge(clk);
eCFrame <= '1' when cSymbolCycles=to_unsigned(0,log2(SYMBOLCYCLES)) and cFrameSymbols=to_unsigned(0,log2(FRAMEBITS)) and rx='0' else
           '0' when cFrameSymbols=to_unsigned(FRAMEBITS,log2(FRAMEBITS)) else
            eCFramer;

-- Counter of cycles per symbol.
-- Counter of the symbols.
-- Only working for the frame duration.
process(rst, clk)
begin
    if rst='1' then
        cSymbolCycles <= (others =>'0');
        cFrameSymbols <= (others =>'0');
    elsif(rising_edge(clk)) then
        if eCFramer='1' then 
            if cSymbolCycles=to_unsigned(SYMBOLCYCLES-1,log2(SYMBOLCYCLES)) then
                cSymbolCycles <= (others=>'0');
            else
                cSymbolCycles <= cSymbolCycles + 1;
            end if;
        end if;
        if eHalfBit='1' then 
            if cFrameSymbols=to_unsigned(FRAMEBITS,log2(FRAMEBITS)) then
                cFrameSymbols <= (others=>'0');
            else
                cFrameSymbols <= cFrameSymbols + 1;
            end if;
        end if;
    end if;
end process;

-- Sampling in the middle of the received symbol.
-- eHalfBit='1' (pulse) if half bit reached. 
eHalfBit <= '1' when eCFramer='1' and cSymbolCycles=to_unsigned((HALFSYMBOLCYCLES), log2(HALFSYMBOLCYCLES)) else '0';

-- Shift Register of the symbols sampled.
process(rst, clk)
begin
    if rst='1' then
        shiftReg <= (others =>'0');
    elsif(rising_edge(clk)) then
        if eHalfBit='1' then
            for b in FRAMEBITS-2 downto 0 loop
                shiftReg(b) <= shiftReg(b+1);
            end loop;
            shiftReg(FRAMEBITS-1) <= rx;
        end if;
    end if;
end process;

-- Output data.
dataOut <= shiftReg(DATABITS downto 1);
finish <= '1' when cFrameSymbols=to_unsigned(FRAMEBITS,log2(FRAMEBITS)) and eCFramer='1' else '0';

end arch;
