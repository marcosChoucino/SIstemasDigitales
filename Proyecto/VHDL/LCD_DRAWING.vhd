library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity LCD_DRAWING IS
	port
	(	--entradas
		reset,CLK		: in 	std_logic;
		DEL_SCREEN, DRAWFIG	: in std_logic;
		COLOUR_CODE		: in std_logic_vector(2 downto 0);
		DONE_CURSOR,DONE_COLOUR	: in std_logic;

		--salidas
		OP_SETCURSOR		: out std_logic;
		XCOL			: out std_logic_vector(7 downto 0);
		YROW			: out std_logic_vector(8 downto 0);
		OP_DRAWINGCOLOUR		: out std_logic;
		RGB			: out std_logic_vector(15 downto 0);
		NUM_PIX			: out std_logic_vector(16 downto 0)
	);
end LCD_DRAWING;


architecture ARCH_LCD_DRAWING of LCD_DRAWING is

	type state is (E0,E1,E2,E3,E4,E5,E6,E7);
	signal EP,ES: state;

	--señales registro colores
	signal COLOUR_CODE_OUT : unsigned(2 downto 0);
	signal LD_COLOUR		: std_logic;
	--contador colorines
	signal TC_DIAG	:  	std_logic;
	signal OUT_DIAG :	unsigned(7 downto 0);
	signal LD_DIAG : 	std_logic;
	signal INC_DIAG : 	std_logic;
	--contador YROW
	signal YROW2	:  	unsigned(8 downto 0);
	signal LD_Y : 	std_logic;
	signal INC_Y : 	std_logic;
	--contador XCOL
	signal XCOL2	:  	unsigned(7 downto 0);
	signal LD_X : 	std_logic;
	signal INC_X : 	std_logic;
	--contador numpix

	signal BORRAR_DIAGONAL: std_logic;

begin
-------------------------------------------------------------------------------------------
	-- CONTROL UNIT
-------------------------------------------------------------------------------------------
	--
	-- Current state Register (State Machine)
	process (CLK, reset)
	begin
		if reset = '1' then EP <= E0;
	  	elsif (CLK'EVENT) and (CLK ='1') then EP <= ES ;
		end if;
	end process;

	-- Next state generation logic
	process (EP,DEL_SCREEN,DRAWFIG,DONE_CURSOR,DONE_COLOUR)
	begin
  		case EP is
			when E0 => 	if (DEL_SCREEN='0' and DRAWFIG='0') then ES <= E0;          	-- |
	           			elsif (DEL_SCREEN='1') then ES <= E1;         			-- |Initial state
                   			elsif (DRAWFIG='1') then ES <= E4; 				-- |
		   			else ES <= E0;                                   		-- |
	       	   			end if;
			--DEL_SCREEN
			when E1 => ES <= E2;       
			when E2 => 	if(DONE_CURSOR='1')then ES <= E3;
					else ES <= E2; --handsake done_cursor_delScreen
					end if;
					         
			when E3 => 	if(DONE_COLOUR='1')then ES <= E0;
					else ES <= E3; --handsake done_colour_delScreen 
					end if;
                  	--DRAWFIG
			when E4 => ES <= E5;                                                    
			when E5 => ES <= E6;                         
			when E6 =>	if(DONE_CURSOR='1')then ES <= E7;
					else ES <= E6; --handsake done_cursor_drawfig
					end if;
			when E7 => 	if(DONE_CURSOR='1' and TC_DIAG='0')then ES <= E0;
					elsif(DONE_CURSOR='1' and TC_DIAG='0')then ES <= E5; --handsake done_colour_drawfig
					else ES <= E7;  
					end if;                                
  		end case;
	end process;
	
	-- Control signals generation logic
	LD_X <= '1' when (EP=E1 or EP=E5) else '0';
	LD_Y <= '1' when (EP=E1 or EP=E5) else '0';
	LD_COLOUR <= '1' when (EP=E1 or EP=E5) else '0';
	LD_DIAG <= '1' when (EP=E4) else '0';
	OP_SETCURSOR <= '1' when(EP=E3 or EP=E7) else '0';
	OP_SETCURSOR <= '1' when(EP=E2 or EP=E6) else '0';	
	BORRAR_DIAGONAL <= '1' when (EP=E3) else '0';
	INC_DIAG <= '1' when (EP=E5) else '0';

-------------------------------------------------------------------------------------------
-- PROCESS UNIT
-------------------------------------------------------------------------------------------
	
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
		if (reset='1') then TC_DIAG<='0'; OUT_DIAG<= x"F0";
   		elsif (CLK'event and CLK='1') then 
           		if (INC_DIAG='1') then OUT_DIAG <= OUT_DIAG - 1;
            		elsif (LD_DIAG ='1') then OUT_DIAG <= x"F0";
            		end if;
		end if;		  
	end process;

--------------------------------------------
--REGISTRO CONTADOR YROW
--------------------------------------------
	process(CLK,reset)
	begin
		if (reset='1') then YROW2<=(others=>'0');
   		elsif (CLK'event and CLK='1') then 
	   		if (INC_Y='1') then YROW2 <= YROW2 + 1;
            		elsif (LD_Y ='1') then YROW2 <= x"0";
            		end if;
		end if;		  
	end process;
	YROW <=std_logic_vector(YROW2);
--------------------------------------------
--REGISTRO CONTADOR XCOL
--------------------------------------------
	process(CLK,reset)
	begin
		if (reset='1') then XCOL2<=(others=>'0');
   		elsif (CLK'event and CLK='1') then 
	   		if (INC_X='1') then XCOL2 <= XCOL2 + 1;
            		elsif (LD_X ='1') then XCOL2 <= x"0";
            		end if;
		end if;		  
	end process;
	XCOL <= std_logic_vector(XCOL2);
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

NUM_PIX <= X"0001" when BORRAR_DIAGONAL = '0' else x"12C00";
end ARCH_LCD_DRAWING;


	