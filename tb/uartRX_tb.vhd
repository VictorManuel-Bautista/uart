library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uartRX_tb is
end uartRX_tb;

architecture behavior of uartRX_tb is

-- Constantes para el testbench
constant FCLKMHZ:   integer := 27;
constant DATABITS:  integer := 8;
constant STOPBIT:   integer := 0;
constant PARITYBIT: integer := 0;
constant BAUDRATE:  integer := 115200;

-- Período del reloj
constant clk_period: time := 37.037 ns; -- 1 / 27 MHz

-- Señales internas
signal clk: std_logic := '0';
signal rx: std_logic := '1';
signal dataOut: std_logic_vector(DATABITS-1 downto 0);

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
uut: entity work.uartRX
    generic map (
        FCLKMHZ => FCLKMHZ,
        DATABITS => DATABITS,
        STOPBIT => STOPBIT,
        PARITYBIT => PARITYBIT,
        BAUDRATE => BAUDRATE
    )
    port map (
        clk => clk,
        rx => rx,
        dataOut => dataOut
    );

-- Generación de estímulos
stim_process: process
begin
    -- Esperar algunos ciclos de reloj
    wait for 10 * clk_period;

    -- Enviar un byte (por ejemplo, 0x55) a través de rx
    rx <= '0'; -- Start bit
    wait for clk_period * (FCLKMHZ * 1000000 / BAUDRATE);

    -- Enviar cada bit del byte
    for i in 0 to DATABITS-1 loop
        rx <= '0'; -- Cambia esto para enviar los bits correctos
        wait for clk_period * (FCLKMHZ * 1000000 / BAUDRATE);
    end loop;

    -- Enviar stop bit(s)
    rx <= '1';
    wait for clk_period * (FCLKMHZ * 1000000 / BAUDRATE);

    -- Termina la simulación
    wait;
end process;

end behavior;
