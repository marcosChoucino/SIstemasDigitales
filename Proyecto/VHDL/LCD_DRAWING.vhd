library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity LCD_DRAWING IS
	port
	(	--entradas
		reset,CLK		: in 	std_logic;
		DEL_SREEN, DRAWFIG	: in std_logic;
		COLOUR_CODE		: in std_logic_vector(2 downto 0);
		DONE_CURSOR,DONECOLOUR	: in std_logic;

		--salidas
		OP_SETCURSOR		: out std_logic;
		XCOL			: out std_logic_vector(7 downto 0);
		YCOL			: out std_logic_vector(8 downto 0);
		OP_DRAWINGCOLOUR		: out std_logic;
		RGB			: out std_logic_vector(15 downto 0);
		NUM_PIX			: out std_logic_vector(16 downto 0)
	);
end LCD_DRAWING;


architecture ARCH_LCD_DRAWING of LCD_DRAWING is
	--aqui faltan un monton de cosas que no se como funcionan 

	--señales registro colores
	signal COLOUR_CODE_OUT : unsigned(2 downto 0);
	signal LD_COLOUR		: std_logic;
	--contador colorines
	signal OUT_DIAG	:  	unsigned(7 downto 0);
	signal CL_DIAG :	std_logic;
	signal LD_DIAG : 	std_logic;
	signal INC_DIAG : 	std_logic;


	--contador numpix

	signal BORRAR_DIAGONAL: std_logic;

begin
	-- voy a copiar los componentes de lcd control que creo que vamos a necesitar 
--------------------------------------------
--REGISTRO COLORES
--------------------------------------------
	--registro que seleccionara los colores 
	process(CLK,reset)
	begin
	if (reset='1') then COLOUR_CODE_OUT <=(others=>'0');
   	elsif (CLK'event and CLK='1') then 
	     	if (LD_COLOUR='1') then COLOUR_CODE_OUT <= unsigned(COLOUR_CODE);
         end if;
	end if;		  
	end process;
	
--------------------------------------------
--REGISTRO CONTADOR DIAGONAL
--------------------------------------------
	process(CLK,reset)
	begin
		if (reset='1') then OUT_DIAG<=(others=>'0');
   		elsif (CLK'event and CLK='1') then 
	   		if (CL_DIAG ='1') then OUT_DIAG<=(others=>'0');
           	elsif (INC_DIAG='1') then OUT_DIAG <= OUT_DIAG + 1;
            elsif (LD_DIAG ='1') then OUT_DIAG <= x"F0";
            end if;
		end if;		  
	end process;

--------------------------------------------
--MULTIFLEXOR DE LOS COLORES :p
--------------------------------------------

-- RGB 8:1 Multiplexer
	RGB <= X"F81F" when COLOUR_CODE_OUT=0 else    -- ROJO 
	 		X"001F" when COLOUR_CODE_OUT=1 else   -- AZUL
           			X"07E0" when COLOUR_CODE_OUT=2 else   -- VERDE
			X"FFE0" when COLOUR_CODE_OUT=3 else	-- AMARILLO
           	 		X"F81F" when COLOUR_CODE_OUT=4 else -- ROSA
            		X"07FF" when COLOUR_CODE_OUT=5 else    -- CYAN
            		X"FFFF" when COLOUR_CODE_OUT=6 else   --BLANCO
            		X"0000";		-- NEGRO



--------------------------------------------
--MULTIFLEXOR NUMPIX
--------------------------------------------

NUM_PIX <= X"0001" when BORRAR_DIAGONAL = 0 else x"12C00";
end ARCH_LCD_DRAWING;


	