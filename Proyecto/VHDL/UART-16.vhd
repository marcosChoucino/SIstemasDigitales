library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity UART_16 IS
	port
	(	--entradas
		reset,CLK		: in std_logic;
		RX, RECIBIDO: in std_logic;
	

		--salidas
		MANDANDO		: out std_logic;
		DATOS			: out std_logic_vector(15 downto 0)

		
	);
end UART_16;


architecture ARCH_UART16 of UART_16 is

	type state is (E1,E2,E4,E5,E6,E7,Eesperar
);
	signal EP,ES: state;
	--senales internas
	--Cont_paso
	signal LD_PASO			: std_logic; 
	signal DEC_PASO		: std_logic;
	signal OUT_PASO		: unsigned(4 downto 0);
	--REG_DESPL
	signal ANADIR			: std_logic;
	signal DESPLAZAR		: std_logic;

	--CONT_DIFF
	signal LD_DIFF			: std_logic;
	signal ACT_DIFF		: std_logic;
	signal OUT_DIFF		: unsigned(9 downto 0);
	signal TC_DIFF			: std_logic;
	--multiflexor 
	signal YMEDIO			: std_logic; --se activara cuando quieras cargar un ciclo y medio en vez de un ciclo
	signal A_CARGAR 		: unsigned(9 downto 0);	

	--para cosas
	signal DATOS2			: unsigned(15 downto 0);

begin

--notaaas: velocidad de la uart : inversa de 115200, el tiempo va por ciclos
--
-------------------------------------------------------------------------------------------
	-- CONTROL UNIT
-------------------------------------------------------------------------------------------
	-- Current state Register (State Machine)
	process (CLK, reset)
	begin
		if reset = '1' then EP <= E1;
	  	elsif rising_edge(CLK) then EP <= ES ;
		end if;
	end process;

	-- Next state generation logic
	process (EP,RX,RECIBIDO,TC_DIFF,OUT_PASO)--OJO, EN ESTE PARENTESIS FALTAN COSAS FIJISIMO
	begin
  		case EP is
                                  		
	       	   			
			--ESPERAR HASTA RECIBIR PRIMER RX
			when E1 =>  ES <=E2;
			--TOCA MIRAR PASO PARA VER QUE HACER A CONTINUACION      			
			when E2 =>if(OUT_PASO="00000")then ES <=E7;
						elsif  (OUT_PASO = "10010" or OUT_PASO = "01001") then ES<=Eesperar;--pasos 18  y 9 nos ponemos a esperar a rx
						elsif (RX = '1')then ES <=E4;
						else ES <= E5;
						end if;
			when Eesperar=> if (RX = '0') then ES <=E6;
							else ES <=Eesperar;
							end if;
			when E4 => ES <=E6; 
			when E5 => ES <=E6;
			when E6 => if(TC_DIFF='1')then ES <=E2; else ES <=E6; end if;
			when E7 => if(RECIBIDO='1')then ES <=E1; else ES <=E7; end if;
			
			--when Evacio  => ES <=E6;

			
  		end case;
	end process;
	

	--SENALES LOGICAS, TERMINADOcasi leer abajo
	--E1

	LD_PASO  <= '1' when (EP=E1) else '0';	

		
	


	--LD_DIFF <=  ESTO ESTA EN EL E6 bien hecho, tiene q estar todo en el mismo


	--E2

	--E4 +E5
	DESPLAZAR <= '1' when (EP=E5 or EP=E4) else '0';
	ANADIR <= '1' when (EP=E4) else '0';
	--E6	
	DEC_PASO <= '1' when (EP=E6 and TC_DIFF = '1') else '0';
	ACT_DIFF	<= '1' when (EP=E6 and  TC_DIFF = '0') else '0';
	--E6 + Eesperar
	LD_DIFF <= '1' when ((EP=E6 and TC_DIFF = '1') or  (EP = Eesperar) ) else '0';
	YMEDIO<= '1' when ( (EP=Eesperar)) else '0';
	--E7
	MANDANDO <= '1' when (EP=E7) else '0';


-------------------------------------------------------------------------------------------
-- PROCESS UNIT
-------------------------------------------------------------------------------------------
	
--------------------------------------------
--REGISTRO DESPLAZAMIENTO
--------------------------------------------
		process(CLK,reset)
	begin
	if (reset='1') then DATOS2 <=(others=>'0');
   	elsif CLK'event AND CLK='1' then 
	     	if (DESPLAZAR='1') then DATOS2 <=  ANADIR & DATOS2(15 downto 1 ) ;
         end if;
	end if;		  
	end process;
	
	
	DATOS<=std_logic_vector(DATOS2);
	--si no fuese LBF SERIA : DATOS2(14 downto 0 ) & ANADIR
--------------------------------------------
--REGISTRO CONTADOR_PASO
--------------------------------------------
	process(CLK,reset)
	begin
		if (reset='1') then OUT_PASO<= "10010";
   	elsif CLK'event AND CLK='1' then 
           	if(LD_PASO ='1') then OUT_PASO <= "10010";
	        elsif  (DEC_PASO='1')  then OUT_PASO <= OUT_PASO - 1 ;
            end if;
		end if;		  
	end process;
	--------------------------------------------
--REGISTRO CONTADOR_DIFF 
--------------------------------------------

	process(CLK,reset)
	begin
		if (reset='1') then OUT_DIFF<= "0000000000" ;
   	elsif rising_edge(CLK) then 
           	if (ACT_DIFF='1') then OUT_DIFF <= OUT_DIFF - 1;
        	elsif (LD_DIFF ='1') then OUT_DIFF <= A_CARGAR;
		else OUT_DIFF<=OUT_DIFF	;
            end if;
		end if;
	end process;
		TC_DIFF <= '1' when (OUT_DIFF = "0000000000") else '0';
	--------------------------------------------
--MULTIFLEXOR DE X BITS DE ENTRADA Y DOS POSIBLES VALORES
-----------------------------------------------

		A_CARGAR <= "1010001001" when (YMEDIO='1') else "0110101111";  	--(434/2 +434)-3
					--434-3
	
end ARCH_UART16;
