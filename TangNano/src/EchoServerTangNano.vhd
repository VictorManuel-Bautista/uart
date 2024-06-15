library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity EchoServer is
generic(
    FCLKMHZ:   integer := 27;
    DATABITS:  integer := 8;
    STOPBIT:   integer := 1;
    PARITYBIT: integer := 0;
    BAUDRATE:  integer := 115200
);
port(
    clk : in std_logic;
    nrst: in std_logic;
    rx: in std_logic;
    tx: out std_logic;
    LEDR: out std_logic;
    LEDG: out std_logic;
    LEDB: out std_logic
);
end EchoServer;

architecture arch of EchoServer is
    
component uartRX is
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
    rx:  in std_logic;
    finish: out std_logic;
    dataOut: out std_logic_vector(DATABITS-1 downto 0)
);
end component;

component uartTX is
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
end component;

signal rst : std_logic;
signal dataUART : std_logic_vector(7 downto 0);
signal finishRx : std_logic;
constant KEY : integer := 49; -- key ASCII '1' in decimal

begin

rst <= not nrst;

-- RX Statements
UART_RX_BLOCK : uartRX
generic map(FCLKMHZ, DATABITS, STOPBIT, PARITYBIT, BAUDRATE)
port map(clk => clk, rst => rst, rx => rx, finish => finishRx, dataOut => dataUART);

-- TX Statements
UART_TX_BLOCK : uartTX 
generic map(FCLKMHZ, DATABITS, STOPBIT, PARITYBIT, BAUDRATE)
port map(clk => clk, rst => rst, tx => tx, start => finishRx, dataSent => dataUART);

-- LED brigth if received data=='1' ASCII
LEDR <= '0' when dataUART = std_logic_vector(to_unsigned(KEY, 8)) else '1';
LEDG <= '1';
LEDB <= '1';

end arch;
