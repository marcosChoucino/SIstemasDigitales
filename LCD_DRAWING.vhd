library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity LCD_DRAWING IS
	port
	(	--entradas
		reset,CLK		: in 	std_logic;
		DEL_SREEN, DRAWFIG	: in std_logic;
		COLOR_CODE		: in std_logic_vector(2 downto 0);
		DONE_CURSOR,DONECOLOR	: in std_logic;

		--salidas
		OP_SETCURSOR		: out std_logic;
		XCOL			: out std_logic_vector(7 downto 0);
		YCOL			: out std_logic_vector(8 downto 0);
		OP_DRAWINGCOLOR		: out std_logic;
		RGB			: out std_logic_vector(15 downto 0);
		NUM_PIX			: out std_logic_vector(16 downto 0);




	);
end LCD_DRAWING;


architecture ARCH_LCD_DRAWING of LCD_DRAWING is
	--aqui faltan un monton de cosas que no se como funcionan 

	signal COLOR_CODE :  std_logic_vector(2 downto 0);
	signal COLOR_CODE_OUT : std_logic_vector(2 downto 0);
	signal LD_COLOR		: std_logic;

begin
	-- voy a copiar los componentes de lcd control que creo que vamos a necesitar 



	--registro que seleccionara los colores 
	process(CLK,reset)
	begin
	if (reset='1') then COLOR_CODE_OUT <=(others=>'0');
   	elsif (CLK'event and CLK='1') then 
	     	if (LD_COLOR='1') then COLOR_CODE_OUT <= COLOR_CODE;
         end if;
	end if;		  
	end process;
	


	