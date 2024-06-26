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
signal finish : std_logic;
signal dataOut : std_logic_vector(DATABITS -1 downto 0);

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
    rx <= parity(DATA);
    wait for clk_period * (FCLKMHZ * 1000000 / BAUDRATE);
    
    -- Stop bit
    rx <= '1';
    wait for clk_period * (FCLKMHZ * 1000000 / BAUDRATE);
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
uut: entity work.uartRX
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
        rx => rx,
        finish => finish,
        dataOut => dataOut
    );

-- Generación de estímulos
stim_process: process
begin
    -- Esperar algunos ciclos de reloj
    rst <= '1';
    wait for 10 * clk_period;
    rst <= '0';
    sendDATA(std_logic_vector(to_unsigned(50, DATABITS)), rx);

    -- Termina la simulación
    wait;
end process;

end behavior;
