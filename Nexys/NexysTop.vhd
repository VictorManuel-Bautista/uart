library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity NexysTop is
generic(
    FCLKMHZ:   integer := 27;
    DATABITS:  integer := 8;
    STOPBIT:   integer := 1;
    PARITYBIT: integer := 0;
    BAUDRATE:  integer := 9600
);
port(
    clk : in std_logic;
    nrst: in std_logic;
    rx: in std_logic;
    LED: out std_logic
);
end NexysTop;

architecture arch of NexysTop is
    
component uartRX is
generic(
    FCLKMHZ:   integer := 27;
    DATABITS:  integer := 8;
    STOPBIT:   integer := 1;
    PARITYBIT: integer := 0;
    BAUDRATE:  integer := 9600
);
port(
    clk: in std_logic;
    rst: in std_logic;
    rx:  in std_logic;
    dataOut: out std_logic_vector(DATABITS-1 downto 0)
);
end component;

signal rst : std_logic;
signal cRGB : unsigned (2 downto 0);
signal dataOutUART : std_logic_vector(7 downto 0);
constant KEY : integer := 49; -- key ASCII '1' in decimal

begin

rst <= not nrst;
UART : uartRX 
generic map(FCLKMHZ, DATABITS, STOPBIT, PARITYBIT, BAUDRATE)
port map(clk => clk, rst => rst, rx => rx, dataOut => dataOutUART);
LED <= '1' when dataOutUART = std_logic_vector(to_unsigned(KEY, 8)) else '0';


end arch;
