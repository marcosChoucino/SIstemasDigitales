-- Plantilla para creaci�n de testbench
--    xxx debe sustituires por el nombre del m�dulo a testear
---
library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LCD_CTRL_TESTBENCH  is 
end; 
 
architecture a of LCD_CTRL_TESTBENCH is
  component LCD_CTRL
	port
	(
	reset,CLK		: in 	std_logic;
	LCD_INIT_DONE		: in std_logic;
	OP_SETCURSOR		: in	std_logic;
	XCOL			: in std_logic_vector(7 downto 0);
	YROW			: in std_logic_vector(8 downto 0);
	OP_DRAWCOLOUR		: in	std_logic;
	RGB			: in std_logic_vector(15 downto 0);
	NUMPIX			: in std_logic_vector(16 downto 0);
	DONE_CURSOR,DONE_COLOUR	: out std_logic;
	LCD_CS_N,LCD_RS,LCD_WR_N	: out std_logic;
	LCD_DATA		: out std_logic_vector(15 downto 0)
	); 
  end component ; 


	--type state is (E0,E1,E2,E3,E4,E5,E6,E7,E8,E9,E10,E11,E12,E13,E14);
	--signal EP : state := E0;
	--signal EP: state;


	signal tb_reset				: std_logic := '1';-- logica negativa, ojo piojo
	signal tb_CLK				: std_logic := '0';
	signal tb_LCD_INIT_DONE			: std_logic  := '0';
	signal tb_OP_SETCURSOR			: std_logic  := '0';
	signal tb_XCOL				: std_logic_vector(7 downto 0):=(others=>'0');
	signal tb_YROW				: std_logic_vector(8 downto 0):=(others=>'0');
	signal tb_OP_DRAWCOLOUR			: std_logic  := '0';
	signal tb_RGB				: std_logic_vector(15 downto 0):=(others=>'0');
	signal tb_NUMPIX			: std_logic_vector(16 downto 0):=(others=>'0');
	signal tb_DONE_CURSOR,tb_DONE_COLOUR	:  std_logic ;
	signal tb_LCD_CS_N 			:  std_logic ;
	signal tb_LCD_RS			:  std_logic ;
	signal tb_LCD_WR_N			:  std_logic;
	signal tb_LCD_DATA			:  std_logic_vector(15 downto 0);

begin
	DUT: LCD_CTRL
	port map ( 
-- mapeando cositas muy guays
-- mi codigo es:

	reset		=> tb_RESET,
	CLK		=> tb_CLK,
	LCD_INIT_DONE	=> tb_LCD_INIT_DONE,
	OP_SETCURSOR	=> tb_OP_SETCURSOR,
	XCOL		=> tb_XCOL,
	YROW		=> tb_YROW,
	OP_DRAWCOLOUR	=> tb_OP_DRAWCOLOUR,
	RGB		=> tb_RGB,
	NUMPIX		=> tb_NUMPIX,
	DONE_CURSOR	=> tb_DONE_CURSOR,
	DONE_COLOUR	=> tb_DONE_COLOUR,
	LCD_CS_N	=> tb_LCD_CS_N,
	LCD_RS		=> tb_LCD_RS,
	LCD_WR_N	=> tb_LCD_WR_N,
	LCD_DATA	=> tb_LCD_DATA
 );
tb_CLK <= not tb_CLK after 20 ns;
process
    begin
		
		--resetea por si acaso
	wait for 50 ns;
	tb_LCD_INIT_DONE <= '1';--siempre activado 
	tb_RESET <= '0';-- logica negativa, ojo piojo
    wait for 50 ns;      
    tb_RESET <= '1';
	wait for 50 ns;      
    tb_RESET <= '0';
	wait for 50 ns;  

	--provar cosas op_setcursor

--	tb_XCOL	<= "01101010";
--	tb_YROW <= "010111010";
--	wait for 50 ns;
--	tb_LCD_INIT_DONE <= '1';
--	tb_OP_SETCURSOR	 <= '1';
--	wait for 50 ns;
--	tb_LCD_INIT_DONE <= '0';
--	tb_OP_SETCURSOR	 <= '0';

	--probar cosas op_draw_color
	--datos
	tb_NUMPIX <= "00000000000000011";
	tb_RGB <= "0110101001010110";
	wait for 50 ns;
	tb_OP_DRAWCOLOUR	 <= '1';
	tb_RGB <= "0110101001010110";
	wait for 50 ns;
	tb_OP_DRAWCOLOUR	 <= '0';



	wait;
    end process;

end;


