
-- Plantilla para creaci?n de testbench
--    xxx debe sustituires por el nombre del m?dulo a testear
---
library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART16TB  is 
end; 
 
architecture a of UART16TB is
  component UART16
	port
	(	--entradas
    reset,CLK		: in std_logic;
    RX, RECIBIDO: in std_logic;


    --salidas
    MANDANDO		: out std_logic;
    DATOS			: out std_logic_vector(15 downto 0);


	--salidas a borrar despues
	DESPLAZAR : out std_logic;
	TC_DIFF2 : out std_logic;
	DIFF3 : out std_logic_vector(9 downto 0);
	A_CARGAR2 : out std_logic_vector(9 downto 0);
	LD_DIFF2 : out std_logic;
	PASO2 : out std_logic_vector(4 downto 0)

	); 
  end component ; 


	--entrada
	signal tb_reset				: std_logic := '0';
	signal tb_CLK				: std_logic := '0';
	signal tb_RX		 	: std_logic := '1';
	signal tb_RECIBIDO : std_logic := '0';
	--salida
	signal tb_MANDANDO : std_logic;
	signal tb_DATOS			: std_logic_vector(15 downto 0);

	

	--Borrare despues
	signal tb_PASO2		: std_logic_vector(4 downto 0);
	signal tb_DESPLAZAR		: std_logic;
	
	signal tb_DIFF3		: std_logic_vector(9 downto 0);
	signal tb_LD_DIFF2	 : std_logic;
	signal tb_TC_DIFF2	: std_logic;

	signal tb_ACARGAR2		: std_logic_vector(9 downto 0);



	--signal tb_DIFF			: std_logic;




begin
	DUT: UART16
	port map ( 
-- mapeando 
-- mi codigo es:

RECIBIDO	=> tb_RECIBIDO,
reset			=> tb_RESET,
CLK			=> tb_CLK,
RX		 	=> tb_RX,

MANDANDO => tb_MANDANDO,

DATOS			=> tb_DATOS,
DIFF3=> tb_DIFF3,

--BORRARE DESPUES
A_CARGAR2 => tb_ACARGAR2,
PASO2 => tb_PASO2,
DESPLAZAR => tb_DESPLAZAR,

TC_DIFF2 => tb_TC_DIFF2,

LD_DIFF2 => tb_LD_DIFF2


	);
--peque�a explicacion de lo que voy ha hacer:
-- la uart manda 115200 bits cada 1 segundo, 
--tras hacer la inversa me queda q manda un bit cada
--86805 nanosegundos
--

--tb_CLK <= not tb_CLK after 20 ns;
tb_CLK <= not tb_CLK after 10 ns;

process
    begin
		--se empieza reseteando
	tb_RX<= '1';

	wait for 10 ns; 
	tb_reset<= '1';
	wait for 10 ns; 	
	tb_reset<= '0';	
	wait for 210 ns; 
	--empiezo a hacer cosas	
	tb_RX<= '0';
	wait for 8680 ns; 

	tb_RX<= '1';--primer dato es un 1	
	wait for 8680 ns; 

	tb_RX<= '0';--segundo un 0
	wait for 8680 ns; 

	tb_RX<= '1';
	wait for 8680 ns; 

	tb_RX<= '0';
	wait for 8680 ns; 

	tb_RX<= '1';
	wait for 8680 ns; 

	tb_RX<= '0';
	wait for 8680 ns; 

	tb_RX<= '1';
	wait for 8680 ns; 

	tb_RX<= '0';
	wait for 8680 ns; 

	tb_RX<= '1';	
	--wait for 500 ns; 
	wait;
    end process;

end;
