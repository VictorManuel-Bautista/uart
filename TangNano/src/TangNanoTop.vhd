library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TangNanoTop is
port(
    clk : in std_logic;
    nrst: in std_logic;
    rx: in std_logic;
    R: out std_logic;
    G: out std_logic;
    B: out std_logic
);
end TangNanoTop;

architecture arch of TangNanoTop is
    
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
signal eRX : std_logic;
signal cRGB : unsigned (2 downto 0);
signal dataOutUART : std_logic_vector(7 downto 0);

begin

rst <= not nrst;

UART : uartRX port map(clk => clk, rst => rst, rx => rx, dataOut => dataOutUART);

eRX <= '1' when dataOutUART = std_logic_vector(to_unsigned(49, 8)) else '0';

R <= rx;
G <= '1';
B <= '1';

end arch;
