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
		DATOS			: out std_logic_vector(15 downto 0);
		--estos es para el testbench, borrar despues
		LD_DIFF2 : out std_logic;
		PASO2 : out std_logic_vector(4 downto 0);
		DIFF3 : out std_logic_vector(9 downto 0);
		A_CARGAR2 : out std_logic_vector(9 downto 0)
		
		
	);
end UART_16;


architecture ARCH_UART16 of UART_16 is

	type state is (E1,E2,E3,E4,E5,E6,E7);
	signal EP,ES: state;
	--senales internas
	--Cont_paso
	signal LD_PASO		: std_logic; 
	signal DEC_PASO		: std_logic;
	signal OUT_PASO				: unsigned(4 downto 0);
	--REG_DESPL
	signal RESET_DESPL		: std_logic;
	signal ANADIR			: std_logic;
	signal DESPLAZAR		: std_logic;

	--CONT_DIFF
	signal LD_DIFF		: std_logic;
	signal ACT_DIFF		: std_logic;
	signal OUT_DIFF			: unsigned(9 downto 0);
	signal TC_DIFF			: std_logic;
	--multiflexor 
	signal YMEDIO			: std_logic; --se activara cuando quieras cargar un ciclo y medio en vez de un ciclo
	signal A_CARGAR 		: unsigned(9 downto 0);	

	--para cosas
	signal DATOS2			: unsigned(15 downto 0);


	

	--HANSAKE
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
			when E1 => if(RX='0')then ES <=E2;
				else ES <=E1; 
				end if;
			--TOCA MIRAR PASO PARA VER QUE HACER A CONTINUACION      			
			when E2 =>if(OUT_PASO="00001")then ES <=E7;
						elsif (OUT_PASO = "10100" or OUT_PASO = "01011"or OUT_PASO = "01010") then ES <=E3;-- si 20,11 o 10
						elsif (RX = '1') then ES <=E4;
						else ES <=E5;
						end if;
			when E3 => ES <=E6; 
			when E4 => ES <=E6; 
			when E5 => ES <=E6;
			when E6 => if(TC_DIFF='1')then ES <=E2; else ES <=E6; end if;
			when E7 => if(RECIBIDO='1')then ES <=E1; else ES <=E7; end if;
  		end case;
	end process;
	

	--SENALES LOGICAS, TERMINADOcasi leer abajo
	--E1
	RESET_DESPL  <= '1' when (EP=E1) else '0';
	LD_PASO  <= '1' when (EP=E1) else '0';	
	
	YMEDIO<= '1' when (EP=E1 and RX = '0') else '0';
	--LD_DIFF <=  ESTO ESTA EN EL E6 bien hecho, tiene q estar todo en el mismo


	--E2

	--E4 +E5
	DESPLAZAR <= '1' when (EP=E5 or EP=E4) else '0';
	ANADIR <= '1' when (EP=E4) else '0';
	--E6	

	LD_DIFF <= '1' when ((EP=E6 and TC_DIFF = '1') or (EP=E1 and RX = '0')) else '0';-- borrado temporalmente OJO ES ESENCIAL
	DEC_PASO <= '1' when (EP=E6 and TC_DIFF = '1') else '0';


	ACT_DIFF<= '1' when (EP=E6 and  TC_DIFF = '0') else '0';

	--E7
	MANDANDO <= '1' when (EP=E7) else '0';

--TRADUCCIONES 
DATOS <=std_logic_vector(DATOS2);
--OUT_DIFF <=std_logic_vector(OUT_DIFF2);



-------------------------------------------------------------------------------------------
-- PROCESS UNIT
-------------------------------------------------------------------------------------------
	
--------------------------------------------
--REGISTRO DESPLAZAMIENTO
--------------------------------------------


--NOTAS REGISTRO DESPLAZAMIENTO dato(6 downto 0 ) + AVANZAR
	--registro que desplaza los datos 
	process(CLK,RESET_DESPL,reset)--TODO ENTERO
	begin
	if (RESET_DESPL='1'or reset='1') then DATOS2 <=(others=>'0');
   	elsif rising_edge(CLK) then 
	     	if (DESPLAZAR='1') then DATOS2 <=  DATOS2(14 downto 0 ) & ANADIR;
         end if;
	end if;		  
	end process;
	DATOS<=std_logic_vector(DATOS2);
	
--------------------------------------------
--REGISTRO CONTADOR_PASO
--------------------------------------------
	process(CLK,reset)
	begin
		if (reset='1') then OUT_PASO<= "00000";
   	elsif rising_edge(CLK) then 
           	if (DEC_PASO='1') then OUT_PASO <= OUT_PASO - 1;
	            elsif (LD_PASO ='1') then OUT_PASO <= "10100";
            end if;
		end if;		  
	end process;
	PASO2 <=std_logic_vector(OUT_PASO);
--------------------------------------------
--REGISTRO CONTADOR_DIFF NO CREO QUE FUNCIONE BIEN PERO NO SE PORQUE
--------------------------------------------
	process(CLK,reset)
	begin
		if (reset='1') then OUT_DIFF<= "0000000000" ; TC_DIFF<='1'; --ESTE NUMERO HAY QUE CAMBIARLO
   	elsif rising_edge(CLK) then 
           	if (ACT_DIFF='1') then OUT_DIFF <= OUT_DIFF - 1;
        	elsif (LD_DIFF ='1') then OUT_DIFF <= A_CARGAR;
		else OUT_DIFF<=OUT_DIFF	;
            end if;
			if(OUT_DIFF="0000000000") then TC_DIFF<='1';
			else TC_DIFF<='0';
			end if;
		end if;		  
	end process;

	--borrare despues
	DIFF3<=std_logic_vector(OUT_DIFF);
	LD_DIFF2 <=LD_DIFF;	


	--------------------------------------------
--MULTIFLEXOR DE X BITS DE ENTRADA Y DOS POSIBLES VALORES
--------------------------------------------



		A_CARGAR <= "1010001000" when (YMEDIO='1') else "0110110010";  	--(434/2 +434)-3
					--434-3

--borrameeee
A_CARGAR2 <= std_logic_vector(A_CARGAR);



	
end ARCH_UART16;
