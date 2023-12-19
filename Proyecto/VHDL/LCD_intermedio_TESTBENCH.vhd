

-- Plantilla para creaci�n de testbench
--    xxx debe sustituires por el nombre del m�dulo a testear
---
library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LCD_intermedio_TESTBENCH  is 
end; 
 
architecture a of LCD_intermedio_TESTBENCH is
  component LCD_intermedio
	port
	(	--entradas
		reset,CLK		: in std_logic;
		HANDSAKE,Handsake_draw	: in std_logic;
		ENTRADA		: in std_logic_vector(7 downto 0);

		--salidas
		RECIVIDO		: out std_logic;
		COLOUR			: out std_logic_vector(15 downto 0)
	);
  end component ; 


	--type state is (E0,E1,E2,E3,E4,E5,E6,E7);
	--signal EP : state := E0;
	--signal EP: state;


	signal tb_reset				: std_logic := '1';
	signal tb_CLK				: std_logic := '0';
	signal tb_HANDSAKE		 	: std_logic := '0';
	signal tb_Handsake_draw			: std_logic := '0';
	signal tb_RECIVIDO			: std_logic := '0';
	signal tb_COLOUR			: std_logic_vector(15 downto 0):=(others=>'0');
	signal tb_ENTRADA 			: std_logic_vector(7 downto 0):=(others=>'0');
	

begin
	DUT: LCD_intermedio
	port map ( 
-- mapeando 
-- mi codigo es:

	reset			=> tb_RESET,
	CLK			=> tb_CLK,
	HANDSAKE		=> tb_HANDSAKE,
	Handsake_draw		=> tb_Handsake_draw,
	RECIVIDO		=> tb_RECIVIDO,
	COLOUR			=> tb_COLOUR,
	ENTRADA			=> tb_ENTRADA
 );
tb_CLK <= not tb_CLK after 20 ns;
process
    begin
		
		--resetea por si acaso
	wait for 50 ns; 
	tb_RESET <= '0';
    	wait for 50 ns;      
    	tb_RESET <= '1';
	wait for 50 ns;      
    	tb_RESET <= '0';
	wait for 50 ns;  

	--provar DEL_CREEN
	
	tb_ENTRADA <="11100011";
	tb_HANDSAKE <= '1';
	wait for 50 ns;
	tb_ENTRADA <="01100010";
	tb_HANDSAKE <= '1';
	wait for 100 ns;
	tb_Handsake_draw <='1';

	
--
	wait;
    end process;

end;
