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
    rx:  in std_logic;
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

constant FRAMEBITS : integer := 1 + DATABITS + PARITYBIT + STOPBIT;
constant FRAMECYCLES : integer := FCLKMHZ * 1000000 * FRAMEBITS / BAUDRATE;
constant HALFSYMBOLCYCLES : integer := FCLKMHZ * 1000000 / (BAUDRATE * 2);

signal eHalfBit : std_logic;
signal eCFrame, eCFramer : std_logic;
signal cBaudRate : unsigned(log2(FRAMECYCLES)-1 downto 0);
signal cHalfBit : unsigned(log2(HALFSYMBOLCYCLES)-1 downto 0);
signal shiftReg : std_logic_vector(FRAMEBITS - 1 downto 0);

begin

-- '1' during the frame
eCFramer <= eCFrame when rising_edge(clk);
eCFrame <= '1' when cBaudRate=to_unsigned(0,log2(FRAMECYCLES)) and rx='0' else
           '0' when cBaudRate=to_unsigned(FRAMECYCLES-2,log2(FRAMECYCLES)) else
            eCFramer;

-- Counter for all the frame 
process(clk)
begin
    if(rising_edge(clk)) then
        if eCFramer='1' then 
            if cBaudRate=to_unsigned(FRAMECYCLES-1,log2(FRAMECYCLES)) then
                cBaudRate <= (others=>'0');
            else
                cBaudRate <= cBaudRate + 1;
            end if;
            if cHalfBit=to_unsigned(HALFSYMBOLCYCLES-1,log2(HALFSYMBOLCYCLES)) then
                cHalfBit <= (others=>'0');
            else
                cHalfBit <= cHalfBit + 1;
            end if;
        end if;
    end if;
end process;

-- '1' if half bit reached.
eHalfBit <= '1' when eCFramer='1' and cHalfBit=to_unsigned(HALFSYMBOLCYCLES-2,log2(HALFSYMBOLCYCLES)) else '0';

-- Shift Register
process(clk)
begin
    if(rising_edge(clk)) then
        if eHalfBit='1' then
            for b in FRAMEBITS-2 downto 0 loop
                shiftReg(b) <= shiftReg(b+1);
            end loop;
            shiftReg(FRAMEBITS-1) <= rx;
        end if;
    end if;
end process;


end arch;
