library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity UART16 IS
	port
	(	--entradas
		reset,CLK		: in std_logic;
		RX, RECIBIDO: in std_logic;
	

		--salidas
		MANDANDO		: out std_logic;
		DATOS			: out std_logic_vector(15 downto 0);
		
	);
end UART16;


architecture ARCH_UART16 of UART16 is

	type state is (E0,E1,E2,E3,E4,E5,E6,E7);
	signal EP,ES: state;
	--senales internas
	--Cont_paso
	signal RESET_CONT_PASO		: std_logic;
	signal DEC_CONT_PASO		: std_logic;
	--REG_DESPL
	signal RESET_DESPL		: std_logic;
	signal ANADIR			: std_logic;
	signal DESPLAZAR		: std_logic;
	signal DATOS			: unsigned(15 downto 0);
	--CONT_DIFF
	signal LD_CONT_DIFF		: std_logic;
	signal DEC_CONT DIFF		: std_logic;
	signal NAC			: unsigned(15 downto 0);
	signal DONE_BIT			: std_logic;
	

	--HANSAKE
	signal MANDANDO: std_logic;
	signal RECIBIDO: std_logic;

begin

--notaaas: velocidad de la uart : inversa de 115200, el tiempo va por ciclos
--
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
	process (EP,DEL_SCREEN,DRAW_FIG,DONE_CURSOR,DONE_COLOUR,TC_DIAG)
	begin
  		case EP is
			when E0 => 	if (DEL_SCREEN='0' and DRAW_FIG='0') then ES <= E0;          	-- |
	           			elsif (DEL_SCREEN='1') then ES <= E1;         			-- |Initial state
                   	elsif (DRAW_FIG='1') then ES <= E4; 				-- |
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
  		end case;
	end process;
	

	--SENALES LOGICAS
	RESET_DESPL  <= '1' when (EP=E0) else '0';
	LD_CONT_PASO  <= '1' when (EP=E0) else '0';
	LD_CONT_DIFF	<= '1' when (EP=E0) else '0';
	LD_CONT_DIFF <= '1' when (EP=E2) else '0';

	DESPLAZAR <= '1' when (EP=E5 or EP=E4) else '0';
	ANADIR <= '1' when (EP=E4) else '0';


	-- Control signals generation logic
	LD_X <= '1' when (EP=E1 or EP=E4) else '0';
	LD_Y <= '1' when (EP=E1 or EP=E4) else '0';
	LD_COLOUR <= '1' when (EP=E1 or EP=E4) else '0';
	LD_DIAG <= '1' when (EP=E4) else '0';
	OP_DRAWCOLOUR <= '1' when(EP=E3 or EP=E7) else '0';
	OP_SETCURSOR <= '1' when(EP=E2 or EP=E6) else '0';	
	BORRAR_DIAGONAL <= '1' when (EP=E3) else '0'; -- tal vez mejor en E1 o en los dos
	INC_DIAG <= '1' when (EP=E5) else '0';
	INC_Y<= '1' when (EP=E8) else '0';
	INC_X<= '1' when (EP=E8) else '0';

-------------------------------------------------------------------------------------------
-- PROCESS UNIT
-------------------------------------------------------------------------------------------
	
--------------------------------------------
--REGISTRO DESPLAZAMIENTO
--------------------------------------------


--NOTAS REGISTRO DESPLAZAMIENTO dato(6 downto 0 ) + AVANZAR
	--registro que desplaza los datos 
	process(CLK,reset)--TODO ENTERO
	begin
	if (reset='1') then COLOUR_CODE_OUT <=(others=>'0');
   	elsif rising_edge(CLK) then 
	     	if (LD_COLOUR='1') then COLOUR_CODE_OUT <= unsigned(COLOUR_CODE);
         end if;
	end if;		  
	end process;
	
--------------------------------------------
--REGISTRO CONTADOR_PASO
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
--REGISTRO CONTADOR_DIFF
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






	
