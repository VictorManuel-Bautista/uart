library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uartTX_tb is
end uartTX_tb;

architecture behavior of uartTX_tb is

-- Constantes para el testbench
constant FCLKMHZ:   integer := 27;
constant DATABITS:  integer := 8;
constant STOPBIT:   integer := 0;
constant PARITYBIT: integer := 0;
constant BAUDRATE:  integer := 115200;

-- Período del reloj
constant clk_period: time := 37.037 ns; -- 1 / 27 MHz

-- Señales internas
signal rst: std_logic := '0';
signal clk: std_logic := '0';

signal tx: std_logic;
signal start: std_logic:= '0';
signal dataSent : std_logic_vector(DATABITS-1 downto 0);


begin

-- Generación del reloj
clk_process: process
begin
    while true loop
        clk <= '1';
        wait for clk_period / 2;
        clk <= '0';
        wait for clk_period / 2;
    end loop;
end process;

-- Instancia de la entidad uartRX
uut: entity work.uartTX
    generic map(
        FCLKMHZ => FCLKMHZ,
        DATABITS => DATABITS,
        STOPBIT => STOPBIT,
        PARITYBIT => PARITYBIT,
        BAUDRATE => BAUDRATE
    )
    port map (
        clk => clk,
        rst => rst,
        tx => tx,
        start => start,
        dataSent => dataSent
    );

-- Generación de estímulos
stim_process: process
begin
    -- Esperar algunos ciclos de reloj
    rst <= '1';
    start <= '0';
    dataSent <= std_logic_vector(to_unsigned(49, DATABITS));
    wait for 10 * clk_period;
    rst <= '0';
    wait for 10*clk_period;
    wait until rising_edge(clk);
    start <= '1';
    wait until rising_edge(clk);
    start <= '0';
    
    wait for 1ms;
    dataSent <= std_logic_vector(to_unsigned(211, DATABITS));
    wait for 10*clk_period;
    wait until rising_edge(clk);
    start <= '1';
    wait until rising_edge(clk);
    start <= '0';
    
    wait;
end process;

end behavior;
