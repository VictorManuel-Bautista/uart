library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uartRX_tb is
end uartRX_tb;

architecture behavior of uartRX_tb is

-- Constantes para el testbench
constant FCLKMHZ:   integer := 27;
constant DATABITS:  integer := 8;
constant STOPBIT:   integer := 1;
constant PARITYBIT: integer := 1;
constant BAUDRATE:  integer := 115200;

-- Período del reloj
constant clk_period: time := 37.037 ns; -- 1 / 27 MHz

-- Señales internas
signal rst: std_logic := '0';
signal clk: std_logic := '0';
signal rx: std_logic := '1';
signal R: std_logic;
signal G: std_logic;
signal B: std_logic;
constant dataRX: std_logic_vector(0 to DATABITS-1) := std_logic_vector(to_unsigned(49, DATABITS));

begin

-- Generación del reloj
clk_process: process
begin
    while true loop
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end loop;
end process;

-- Instancia de la entidad uartRX
uut: entity work.TangNanoTop
    port map (
        clk => clk,
        nrst => rst,
        rx => rx,
        R => R,
        G => G,
        B => B
    );

-- Generación de estímulos
stim_process: process
begin
    -- Esperar algunos ciclos de reloj
    rst <= '0';
    wait for 10 * clk_period;
    rst <= '1';
    
    -- Enviar un byte (por ejemplo, 0x55) a través de rx
    rx <= '0'; -- Start bit
    wait for clk_period * (FCLKMHZ * 1000000 / BAUDRATE);

    -- Enviar cada bit del byte
    for i in 0 to DATABITS-1 loop
        rx <= dataRX(DATABITS-1-i); -- Cambia esto para enviar los bits correctos
        wait for clk_period * (FCLKMHZ * 1000000 / BAUDRATE);
    end loop;

    -- Enviar stop bit(s)
    rx <= '1';
    wait for clk_period * (FCLKMHZ * 1000000 / BAUDRATE);

    -- Termina la simulación
    wait;
end process;

end behavior;
