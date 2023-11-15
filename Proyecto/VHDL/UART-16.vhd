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
		SALIDA			: out std_logic_vector(15 downto 0)
		
	);
end UART16;


architecture ARCH_UART16 of UART16 is

	type state is (E0,E1,E2,E3,E4,E5,E6,E7,E8);
	signal EP,ES: state;
	--senales internas
	--Cont_paso
	signal LD_CONT_PASO		: std_logic;
	signal DEC_CONT_PASO		: std_logic;
	signal OUT_PASO				: unsigned(4 downto 0);
	--REG_DESPL
	signal RESET_DESPL		: std_logic;
	signal ANADIR			: std_logic;
	signal DESPLAZAR		: std_logic;
	signal DATOS			: unsigned(15 downto 0);
	--CONT_DIFF
	signal LD_DIFF		: std_logic;
	signal DEC_DIFF		: std_logic;
	signal OUT_DIFF			: unsigned(15 downto 0);
	signal TC_DIFF			: std_logic;
	--multiflexor 
	signal MITAD			: std_logic;
	signal A_CARGAR 		: unsigned(8 downto 0);	

	

	--HANSAKE
begin

--notaaas: velocidad de la uart : inversa de 115200, el tiempo va por ciclos
--
-------------------------------------------------------------------------------------------
	-- CONTROL UNIT
-------------------------------------------------------------------------------------------
	-- FALTA ENTERO
	-- Current state Register (State Machine)
	process (CLK, reset)
	begin
		if reset = '1' then EP <= E0;
	  	elsif rising_edge(CLK) then EP <= ES ;
		end if;
	end process;

	-- Next state generation logic
	process (EP,RX,RECIBIDO,TC_DIFF)--OJO, EN ESTE PARENTESIS FALTAN COSAS FIJISIMO
	begin
  		case EP is
			when E0 => 	 ES <= E1;                                   		
	       	   			
			--ESPERAR HASTA RECIBIR PRIMER RX
			when E1 => if(RX='0')then ES <=E2;
				else ES <=E1; 
				end if;
			--TOCA MIRAR PASO PARA VER QUE HACER A CONTINUACION      			
			when E2 =>if(OUT_PASO="00000")then ES <=E7;
						elsif (OUT_PASO = "10100") then ES <=E8;
						elsif (OUT_PASO = "01010"or OUT_PASO = "01001") then ES <=E3;
						else
							if (RX = '1') then ES <=E5;
							else ES <=E4;
							end if ;
						end if;
			when E3 => ES <=E6; 
			when E4 => ES <=E6; 
			when E5 => ES <=E6;
			when E6 => if(TC_DIFF='1')then ES <=E2; end if;
			when E7 => if(RECIBIDO='1')then ES <=E0; end if;
			when E8	 => ES <=E6;
  		end case;
	end process;
	

	--SENALES LOGICAS, TERMINADOcasi leer abajo
	RESET_DESPL  <= '1' when (EP=E0) else '0';
	LD_CONT_PASO  <= '1' when (EP=E0) else '0';
	LD_DIFF	<= '1' when (EP=E2 or EP=E8) else '0';
	DEC_CONT_PASO	<= '1' when (EP=E5) else '0';


	DESPLAZAR <= '1' when (EP=E5 or EP=E4) else '0';
	ANADIR <= '1' when (EP=E4) else '0';
	MITAD <= '1' when (EP=E8) else '0';
	MANDANDO <= '1' when (EP=E7) else '0';

--############################################3
	-- OJO PIOJO
	DEC_DIFF <= '1' when (EP=E6 and TC_DIFF = '0') else '0';-- tengo que comprovar si esto esta bien porque no estoy seguro
--###########################################


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
	if (reset='1') then DATOS <=(others=>'0');
   	elsif rising_edge(CLK) then 
	     	if (DESPLAZAR='1') then DATOS <=  DATOS(15 downto 1 ) & ANADIR;
         end if;
	end if;		  
	end process;
	
--------------------------------------------
--REGISTRO CONTADOR_PASO
--------------------------------------------
	process(CLK,reset)
	begin
		if (reset='1') then OUT_PASO<= "00000";
   	elsif rising_edge(CLK) then 
           	if (DEC_CONT_PASO='1') then OUT_PASO <= OUT_PASO - 1;
	            elsif (LD_CONT_PASO ='1') then OUT_PASO <= "10100";
            end if;
		end if;		  
	end process;

--------------------------------------------
--REGISTRO CONTADOR_DIFF NO ESTA HECHO TENGO QUE CALCULAR LOS TIEMPOS + PREGUNTAR A GONZALO LA IDEA PARA DES SINCRONIZAR
--------------------------------------------
	process(CLK,reset)
	begin
		if (reset='1') then OUT_DIFF<= "000000000" ; TC_DIFF<='0'; --ESTE NUMERO HAY QUE CAMBIARLO
   	elsif rising_edge(CLK) then 
           	if (DEC_DIFF='1') then OUT_DIFF <= OUT_DIFF - 1;
            elsif (LD_DIFF ='1') then OUT_DIFF <= A_CARGAR;
            end if;
				if(OUT_DIFF="000000000") then TC_DIFF<='1';--ESTE NUMERO HAY QUE CAMBIARLO
				else TC_DIFF<='0';
				end if;
		end if;		  
	end process;


	--------------------------------------------
--MULTIFLEXOR DE X BITS DE ENTRADA Y DOS POSIBLES VALORES
--------------------------------------------



		A_CARGAR <= "11010110" when (MITAD='1') 	--(434/2)-1
					else "110101111"; --434-3





	
end ARCH_UART16;
