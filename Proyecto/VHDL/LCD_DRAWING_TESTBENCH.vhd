
-- Plantilla para creaci�n de testbench
--    xxx debe sustituires por el nombre del m�dulo a testear
---
library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LCD_DRAWING_TESTBENCH  is 
end; 
 
architecture a of LCD_DRAWING_TESTBENCH is
  component LCD_DRAWING
	port
	(	--entradas
		reset,CLK		: in 	std_logic;
		DEL_SCREEN, DRAW_FIG, UART	: in std_logic;
		COLOUR_CODE		: in std_logic_vector(2 downto 0);
		DONE_CURSOR,DONE_COLOUR	: in std_logic;
		Handsake 		: in std_logic;
		EntradaUart		: in std_logic_vector(15 downto 0);

		--salidas
		OP_SETCURSOR		: out std_logic;
		XCOL			: out std_logic_vector(7 downto 0);
		YROW			: out std_logic_vector(8 downto 0);
		OP_DRAWCOLOUR			: out std_logic;
		RGB			: out std_logic_vector(15 downto 0);
		NUMPIX			: out std_logic_vector(16 downto 0);
		RECIVIDO		: out std_logic
	); 
  end component ; 


	--type state is (E0,E1,E2,E3,E4,E5,E6,E7);
	--signal EP : state := E0;
	--signal EP: state;


	signal tb_reset				: std_logic := '1';
	signal tb_CLK				: std_logic := '0';
	signal tb_DEL_SCREEN		 	: std_logic := '0';
	signal tb_DRAW_FIG			: std_logic := '0';
	signal tb_UART				: std_logic := '0';
	signal tb_COLOUR_CODE			: std_logic_vector(2 downto 0):=(others=>'0');
	signal tb_DONE_CURSOR 			: std_logic:= '0';
	signal tb_DONE_COLOUR 			: std_logic:= '0';
	signal tb_OP_SETCURSOR 			: std_logic:= '0';
	signal tb_XCOL				: std_logic_vector(7 downto 0):=(others=>'0');
	signal tb_YROW 				: std_logic_vector(8 downto 0):=(others=>'0');
	signal tb_OP_DRAWCOLOUR			: std_logic:= '0';
	signal tb_RGB				: std_logic_vector(15 downto 0):=(others=>'0');
	signal tb_NUMPIX 			: std_logic_vector(16 downto 0):=(others=>'0');
	signal tb_Handsake				: std_logic:= '0';
	signal tb_EntradaUart			: std_logic_vector(15 downto 0):=(others=>'0');
	signal tb_RECIVIDO				: std_logic:= '0';

begin
	DUT: LCD_DRAWING
	port map ( 
-- mapeando 
-- mi codigo es:

	reset			=> tb_RESET,
	CLK			=> tb_CLK,
	DEL_SCREEN 		=> tb_DEL_SCREEN,
	DRAW_FIG			=> tb_DRAW_FIG,
	UART			=> tb_UART,
	COLOUR_CODE		=> tb_COLOUR_CODE,
	DONE_CURSOR		=> tb_DONE_CURSOR,
	DONE_COLOUR		=> tb_DONE_COLOUR,
	OP_SETCURSOR		=> tb_OP_SETCURSOR,
	XCOL			=> tb_XCOL,
	YROW			=> tb_YROW,
	OP_DRAWCOLOUR		=> tb_OP_DRAWCOLOUR,
	RGB			=> tb_RGB,
	NUMPIX			=> tb_NUMPIX,
	Handsake		=> tb_Handsake,
	EntradaUart		=> tb_EntradaUart,
	RECIVIDO		=> tb_RECIVIDO
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

	--tb_DEL_SCREEN 	<='1';
	--wait for 70 ns;
	--tb_COLOUR_CODE 	<="010";
	--tb_DEL_SCREEN	<='0';
	--tb_DONE_CURSOR 	<='1';
	--wait for 70 ns;
	--tb_DONE_CURSOR 	<='0';
	
	--wait for 70 ns;
	--tb_COLOUR_CODE 	<="000";
	--tb_DONE_COLOUR 	<='1';
	--wait for 70 ns;
	--tb_DONE_COLOUR 	<='0';


	--probar DRAW_FIG
	--tb_DRAWFIG 	<='1';
	--wait for 70 ns;
	--tb_COLOUR_CODE 	<="001";
	--tb_DRAWFIG	<='0';
	--tb_DONE_CURSOR 	<='1';
	--wait for 70 ns;
	--tb_DONE_CURSOR 	<='0';
	
	--wait for 70 ns;
	--tb_COLOUR_CODE 	<="000";
	--tb_DONE_COLOUR 	<='1';
	--wait for 70 ns;
	--tb_DONE_COLOUR 	<='0';


	--probar UART

	tb_UART		<='1';
	wait for 70 ns;
	tb_DONE_CURSOR 	<='1';
	wait for 70 ns;
	tb_DONE_CURSOR 	<='0';
	tb_UART		<='0';
	tb_EntradaUart	<="0110110001010110";
	tb_Handsake	<='1';
	wait for  100 ns;
	tb_DONE_COLOUR	<= '1';
	tb_Handsake	<='0';
	wait for 70 ns;
	tb_DONE_COLOUR	<= '0';
	wait for  80 ns; --seria 260400 pero sino no se ve bien en el wave
	tb_DONE_CURSOR 	<='1';
	wait for 70 ns;
	tb_DONE_CURSOR 	<='0';
	tb_EntradaUart	<="1111111111111111";
	tb_Handsake	<='1';
	wait for  100 ns;
	tb_DONE_COLOUR	<= '1';
	tb_Handsake	<='0';
	wait for 70 ns;
	tb_DONE_COLOUR	<= '0';
	wait for  80 ns;
	tb_DONE_CURSOR 	<='1';
	wait for 70 ns;
	tb_DONE_CURSOR 	<='0';
	tb_EntradaUart	<="0110100111010110";
	tb_Handsake	<='1';
	wait for  100 ns;
	tb_DONE_COLOUR	<= '1';
	tb_Handsake	<='0';
	wait for 70 ns;
	tb_DONE_COLOUR	<= '0';

	wait;
    end process;

end;

