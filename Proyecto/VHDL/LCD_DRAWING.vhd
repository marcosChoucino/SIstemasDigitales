library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity LCD_DRAWING IS
	port
	(	--entradas
		reset,CLK		: in std_logic;
		DEL_SCREEN, DRAW_FIG, UART	: in std_logic;
		COLOUR_CODE		: in std_logic_vector(2 downto 0);
		DONE_CURSOR,DONE_COLOUR	: in std_logic;
		Handsake 		: in std_logic;
		EntradaUart		: in std_logic_vector(15 downto 0);

		--salidas
		OP_SETCURSOR		: out std_logic;
		XCOL			: out std_logic_vector(7 downto 0);
		YROW			: out std_logic_vector(8 downto 0);
		OP_DRAWCOLOUR		: out std_logic;
		RGB			: out std_logic_vector(15 downto 0);
		NUMPIX			: out std_logic_vector(16 downto 0);
		RECIVIDO		: out std_logic
	);
end LCD_DRAWING;


architecture ARCH_LCD_DRAWING of LCD_DRAWING is

	type state is (E0,E1,E2,E3,E4,E5,E6,E7,E8,E9,Eespera,E10,E11,E12,E13,E14);
	signal EP,ES: state;


	signal RGB0: std_logic_vector(15 downto 0);
	signal RGB1: std_logic_vector(15 downto 0);
	signal LD_UART: std_logic;	
	signal UartM: std_logic;
	--contador OUT_Y
	signal TC_OUT_Y	:  	std_logic;
	signal OUT_Y :	unsigned(8 downto 0);
	signal LD_OUT_Y : 	std_logic;
	signal INC_OUT_Y : 	std_logic;
	--se�ales registro colores
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
	  	elsif rising_edge(CLK) then EP <= ES ;
		end if;
	end process;

	-- Next state generation logic
	process (EP,DEL_SCREEN,DRAW_FIG,UART,DONE_CURSOR,DONE_COLOUR,TC_DIAG,Handsake,TC_OUT_Y)
	begin
  		case EP is
			when E0 => 	if (DEL_SCREEN='1') then ES <= E1;          	-- |
	           			elsif (DRAW_FIG='1') then ES <= E4;         			-- |Initial state
                   		elsif (UART='1') then ES <= E9; 				-- |				-- |
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
                  	--DRAW_FIG
			when E4 => ES <= E5;                                                    
			when E5 => ES <= E6;                         
			when E6 =>	if(DONE_CURSOR='1')then ES <= E7;
					else ES <= E6; --handsake done_cursor_DRAW_FIG
					end if;
			when E7 => 	if(DONE_COLOUR='1' and TC_DIAG='1')then ES <= E0;
					elsif(DONE_COLOUR='1' and TC_DIAG='0')then ES <= E8; --handsake done_colour_DRAW_FIG
					else ES <= E7;  
					end if;     
			when E8 => ES <= E5;
			--UART
			when E9 => ES <= Eespera;
			when Eespera=>  if(Handsake='1')then ES <= E10;
					else ES <= Eespera; --handsake done_cursor_drawfig
					end if;  
			when E10 => ES <=E11;
			when E11=>  if(DONE_CURSOR='1')then ES <= E12;
					else ES <= E11; --handsake done_cursor_drawfig
					end if; 
			
			
			when E12=>  if(DONE_COLOUR='0')then ES <= E12;--handsake done_cursor_drawfig
				    elsif(TC_DIAG='0')then ES <= E13;
				    elsif(TC_OUT_Y='0')then ES <= E14;
					else ES <= E0; 
					end if;
					
			when E13=> ES <=Eespera;
			when E14=> ES <=Eespera;
        
  		end case;
	end process;
	
	-- Control signals generation logic
	LD_X <= '1' when (EP=E1 or EP=E4 or EP=E9 or EP=E14) else '0';
	LD_Y <= '1' when (EP=E1 or EP=E4 or EP=E9) else '0';
	LD_COLOUR <= '1' when (EP=E1 or EP=E4) else '0';
	LD_DIAG <= '1' when (EP=E4 or EP=E9 or EP=E14 ) else '0';
	OP_DRAWCOLOUR <= '1' when(EP=E3 or EP=E7 or EP=E12) else '0';
	OP_SETCURSOR <= '1' when(EP=E2 or EP=E6 or EP=E11) else '0';	
	BORRAR_DIAGONAL <= '1' when (EP=E3) else '0'; -- tal vez mejor en E1 o en los dos
	INC_DIAG <= '1' when (EP=E5 or EP=E10) else '0';
	INC_Y<= '1' when (EP=E8 or EP=E14) else '0';
	INC_X<= '1' when (EP=E8 or EP=E13) else '0';
	LD_UART<= '1' when (EP=E10) else '0';
	LD_OUT_Y<= '1' when (EP=E9) else '0';
	INC_OUT_Y<= '1' when (EP=E14) else '0';
	RECIVIDO<= '1' when EP=E10 else '0';-- añadido estado 11 tambien por si acaso
	UartM<= '1' when (EP=E12) else '0';

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
   	elsif rising_edge(CLK) then 
	     	if (LD_COLOUR='1') then COLOUR_CODE_OUT <= unsigned(COLOUR_CODE);
         end if;
	end if;		  
	end process;
	
--------------------------------------------
--REGISTRO CONTADOR DIAGONAL
--------------------------------------------
	process(CLK,reset)
	begin
		if (reset='1') then OUT_DIAG<= "11110000"; TC_DIAG<='0'; 
   	elsif rising_edge(CLK) then 
           	if (INC_DIAG='1') then OUT_DIAG <= OUT_DIAG - 1;
            elsif (LD_DIAG ='1') then OUT_DIAG <= "11110000";
            end if;
				if(OUT_DIAG="00000000") then TC_DIAG<='1';
				else TC_DIAG<='0';
				end if;
		end if;		  
	end process;

--------------------------------------------
--REGISTRO CONTADOR FIN DE PROGRAMA
--------------------------------------------
	process(CLK,reset)
	begin
		if (reset='1') then OUT_Y<= "101000000"; TC_OUT_Y<='0'; 
   	elsif rising_edge(CLK) then 
           	if (INC_OUT_Y='1') then OUT_Y <= OUT_Y - 1;
            elsif (LD_OUT_Y ='1') then OUT_Y <= "101000000";
            end if;
				if(OUT_Y="000000000") then TC_OUT_Y<='1';
				else TC_OUT_Y<='0';
				end if;
		end if;		  
	end process;
--------------------------------------------
--REGISTRO CONTADOR YROW
--------------------------------------------
	process(CLK,reset)
	begin
		if (reset='1') then YROW2<=(others=>'0');
   		elsif rising_edge(CLK) then 
	   		if (INC_Y='1') then YROW2 <= YROW2 + 1;
            		elsif (LD_Y ='1') then YROW2 <= "000000000";
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
   		elsif rising_edge(CLK) then 
	   		if (INC_X='1') then XCOL2 <= XCOL2 + 1;
            		elsif (LD_X ='1') then XCOL2 <= "00000000";
            		end if;
		end if;		  
	end process;
	XCOL <= std_logic_vector(XCOL2);
--------------------------------------------
--MULTIFLEXOR DE LOS COLORES :p
--------------------------------------------
 
-- RGB 8:1 Multiplexer
	RGB0 <= 	"1111100000011111" when COLOUR_CODE_OUT="0000" else    -- ROJO 
	 		"0000000000011111" when COLOUR_CODE_OUT="0001" else   -- AZUL
           		"0000011111100000" when COLOUR_CODE_OUT="0010" else   -- VERDE
			"1111111111100000" when COLOUR_CODE_OUT="0011" else	-- AMARILLO
           	 	"1111100000011111" when COLOUR_CODE_OUT="0100" else -- ROSA
            		"0000011111111111" when COLOUR_CODE_OUT="0101" else    -- CYAN
            		"1111111111111111" when COLOUR_CODE_OUT="0110" else   --BLANCO
            		"0000000000000000";		-- NEGRO


--------------------------------------------
--REGISTRO COLORES UART
--------------------------------------------
	--registro que seleccionara los colores 
	process(CLK,reset)
	begin
	if (reset='1') then RGB1 <=(others=>'0');
   	elsif rising_edge(CLK) then 
		if (LD_UART='1') then RGB1 <= EntradaUart;
         end if;
	end if;		  
	end process;
--------------------------------------------
--MULTIFLEXOR COLOUR
--------------------------------------------

RGB <= RGB0 when UartM = '0' else RGB1;
--------------------------------------------
--MULTIFLEXOR NUMPIX
--------------------------------------------

NUMPIX <= "00000000000000001" when BORRAR_DIAGONAL = '0' else "10010110000000000";
end ARCH_LCD_DRAWING;						


	
