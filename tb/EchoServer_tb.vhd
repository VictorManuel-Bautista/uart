library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EchoServer_tb is
end EchoServer_tb;

architecture behavior of EchoServer_tb is

-- Constantes para el testbench
constant FCLKMHZ:   integer := 27;
constant DATABITS:  integer := 8;
constant PARITYBIT: integer := 1;
constant STOPBIT:   integer := 0;
constant BAUDRATE:  integer := 115200;

-- Período del reloj
constant clk_period: time := 37.037 ns; -- 1 / 27 MHz

-- Señales internas
signal nrst: std_logic := '1';
signal clk: std_logic := '0';
signal rx: std_logic := '1';
signal tx: std_logic;
signal LEDR, LEDG, LEDB: std_logic;

function parity(A: std_logic_vector) return std_logic; 
function parity(A: std_logic_vector) return std_logic is
    variable sum : unsigned(0 downto 0) := "0";
begin 
	for i in A'range loop
	    if A(i) = '1' then
            sum := sum + 1;
        end if;
	end loop;
	return sum(0);
end function;

procedure sendDATA(constant DATA: in std_logic_vector; signal rx: out std_logic) is
begin
    -- Start bit
    rx <= '0'; 
    wait for clk_period * (FCLKMHZ * 1000000 / BAUDRATE);

    -- Send data. LSB first
    for i in DATA'range loop
        rx <= DATA(DATABITS-1-i);
        wait for clk_period * (FCLKMHZ * 1000000 / BAUDRATE);
    end loop;

    -- Parity bit
    if PARITYBIT = 1 then
        rx <= parity(DATA);
        wait for clk_period * (FCLKMHZ * 1000000 / BAUDRATE);
    end if;
    
    -- Stop bit
    if STOPBIT = 1 then
        rx <= '1';
        wait for clk_period * (FCLKMHZ * 1000000 / BAUDRATE);
    end if;
end procedure;

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
uut: entity work.EchoServer
    generic map(
        FCLKMHZ => FCLKMHZ,
        DATABITS => DATABITS,
        STOPBIT => STOPBIT,
        PARITYBIT => PARITYBIT,
        BAUDRATE => BAUDRATE
    )
    port map (
        clk => clk,
        nrst => nrst,
        rx => rx,
        tx => tx,
        LEDR => LEDR,
        LEDG => LEDG,
        LEDB => LEDB
    );

-- Generación de estímulos
stim_process: process
begin
    -- Esperar algunos ciclos de reloj
    nrst <= '0';
    wait for 10 * clk_period;
    nrst <= '1';
    sendDATA(std_logic_vector(to_unsigned(211, DATABITS)), rx);
    wait for 1ms;
    sendDATA(std_logic_vector(to_unsigned(49, DATABITS)), rx);
    -- Termina la simulación
    wait;
end process;

end behavior;
