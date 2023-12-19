
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity LCD_intermedio IS
	port
	(	--entradas
		reset,CLK		: in std_logic;
		HANDSAKE,Handsake_draw	: in std_logic;
		ENTRADA		: in std_logic_vector(7 downto 0);

		--salidas
		RECIVIDO		: out std_logic;
		COLOUR			: out std_logic_vector(15 downto 0)
	);
end LCD_intermedio;


architecture ARCH_LCD_intermedio of LCD_intermedio is

	type state is (E0,Eblank1,E1,Eblank2,E2,E3);
	signal EP,ES: state;

	--señales registro
	signal Colour_fin : unsigned(7 downto 0);
	signal LD_2		: std_logic;
	signal CL_2			: std_logic;
	--señales registro
	signal Colour_int : unsigned(7 downto 0);
	signal LD_1		: std_logic;
	signal CL_1			: std_logic;
	


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
	process (EP,HANDSAKE,Handsake_draw)
	begin
  		case EP is
			when E0 => ES <= Eblank1;       
			when Eblank1 => 	if(HANDSAKE='1')then ES <= E1;
						else ES <= Eblank1; --handsake primer
						end if;
			when E1 => ES <= Eblank2; 	         
			when Eblank2 => 	if(HANDSAKE='1')then ES <= E2;
					else ES <= E3; --handsake segundo
					end if;
			when E2 => ES <= E3;                                                                            
			when E3 =>	if(Handsake_draw='1')then ES <= E0;
					else ES <= E3; --handsake_draw
					end if;
  		end case;
	end process;
	
	-- Control signals generation logic
	LD_1 <= '1' when (EP=E1 or EP=E2) else '0';
	LD_2 <= '1' when (EP=E2) else '0';
	CL_1 <= '1' when (EP=E0) else '0';
	CL_2 <= '1' when (EP=E0) else '0';
	RECIVIDO <= '1' when (EP=E3) else '0';
	

-------------------------------------------------------------------------------------------
-- PROCESS UNIT
-------------------------------------------------------------------------------------------
	
--------------------------------------------
--REGISTRO 1
--------------------------------------------
	--registro 1
	process(CLK,reset)
	begin
	if (reset='1') then Colour_int <=(others=>'0');
   	elsif rising_edge(CLK) then 
	     	if (LD_1='1') then Colour_int <= unsigned(ENTRADA);
		elsif (CL_1='1') then Colour_int <=(others=>'0');
         end if;
	end if;		  
	end process;
--------------------------------------------
--REGISTRO 2
--------------------------------------------
	--registro 2 
	process(CLK,reset)
	begin
	if (reset='1') then Colour_fin <=(others=>'0');
   	elsif rising_edge(CLK) then 
	     	if (LD_2='1') then Colour_fin <= Colour_int;
		elsif (CL_2='1') then Colour_fin <=(others=>'0');
         end if;
	end if;		  
	end process;

COLOUR <= std_logic_vector(Colour_int & Colour_fin);
	

end ARCH_LCD_intermedio;						


	