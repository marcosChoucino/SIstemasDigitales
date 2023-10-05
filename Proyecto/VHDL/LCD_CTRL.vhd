library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity LCD_CTRL IS
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
end LCD_CTRL;

architecture ARCH_LCD_CTRL of LCD_CTRL is

	type state is (E0,E1,E2,E3,E4,E5,E6,E7,E8,E9,E10,E11,E12,E13,E14);
	signal EP,ES: state;
	
	signal RSDAT,RSCOM: std_logic;
	signal CL_DAT,INC_DAT,LD_2C: std_logic;
	signal LD_CURSOR,LD_DRAW,DECPIX: std_logic;
	signal RXCOL : std_logic_vector(7 downto 0);
	signal RYROW : std_logic_vector(8 downto 0);
	signal RRGB,YMUX8to1 : std_logic_vector(15 downto 0);
	signal QNUMPIX: unsigned (16 downto 0);
	signal QDAT : unsigned (2 downto 0);
	signal ENDPIX: std_logic;
	signal CL_LCD_DATA: std_logic;
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
	process (EP,LCD_INIT_DONE,OP_SETCURSOR,OP_DRAWCOLOUR,QDAT,ENDPIX)
	begin
  		case EP is
			when E0 => 	if (LCD_INIT_DONE='0') then ES <= E0;           -- |
	           			elsif (OP_SETCURSOR='1') then ES <= E1;         -- |Initial state
                   			elsif (OP_DRAWCOLOUR='1') then ES <= E14; -- |
		   			else ES <= E0;                                     -- |
	       	   			end if;
			when E1 => ES <= E2;       
			when E2 => ES <= E3;       -- Clock Cycle 0 - LT24 BUS Send Command    
			when E3 => ES <= E4;       -- Clock Cycle 1 - LT24 BUS                
			when E4 => 	if (QDAT=6) then ES <= E5;	      --|
	           			elsif (QDAT=5) then ES <= E11;   --|                                
		   			   elsif (QDAT=2) then ES <= E12;      --| Clock Cycle 2 - LT24 BUS                                
                   	else ES <= E13;            --|
	           			end if;                           
			when E5 => ES <= E6;                         --| Clock Cycle 3 - LT24 BUS
			when E6 => ES <= E7;     -- Clock Cycle 0 - LT24 BUS Send Command  (DrawColour) 
			when E7 => ES <= E8;     -- Clock Cycle 1 - LT24 BUS                           
			when E8 => ES <= E9;     -- Clock Cycle 2 - LT24 BUS                           
			when E9 => 	if (ENDPIX='0') then ES <= E6; -- |
	                	else ES <= E10;             -- |Clock Cycle 3 - LT24 BUS         
	           			end if;                        -- |
			when E10 => ES<=E0;		 -- DONE_COLOUR
			when E11 => ES<=E0;      -- Clock Cycle 3 - LT24 BUS (DONE_CURSOR)
			when E12 => ES<=E2;      -- Clock Cycle 3 - LT24 BUS 
			when E13 => ES<=E2;      -- Clock Cycle 3 - LT24 BUS 
			when E14 => ES<=E2;       
  		end case;
	end process;
	
	-- Control signals generation logic
	LD_2C <= '1' when (EP=E14) else '0';
	DECPIX <= '1' when (EP=E7) else '0';
	RSDAT <= '1' when (EP=E5 or EP=E13) else '0';
	INC_DAT <= '1' when (EP=E5 or EP=E12 or EP=E13) else '0'; 
	CL_DAT <= '1' when (EP=E1) else '0';
	RSCOM <='1' when (EP=E1 or EP=E14 or EP=E12) else '0';
	LD_CURSOR <= '1' when (EP=E1) else '0';
	LD_DRAW <= '1' when (EP=E14) else '0';
	
	CL_LCD_DATA <= '1' when (EP=E0 or EP=E1 or EP=E14) else '0';

	LCD_CS_N <= '0' when (EP=E2 or EP=E6) else '1'; -- Negative logic 
	LCD_WR_N <= '0' when (EP=E2 or EP=E6) else '1'; -- Negative logic 
	DONE_CURSOR <= '1' when EP=E11 else '0';
	DONE_COLOUR <= '1' when EP=E10 else '0';



	-------------------------------------------------------------------------------------------
	-- PROCESS UNIT
	-------------------------------------------------------------------------------------------
	
	-- RXCOL, RYCOL Registers
	process(CLK,reset)
	begin
	if (reset='1') then RXCOL<=x"00"; RYROW<=(others=>'0');
   	elsif (CLK'event and CLK='1') then 
	     	if (LD_CURSOR='1') then RXCOL<=XCOL; RYROW<=YROW;
         end if;
	end if;		  
	end process;
	
	
	-- RRGB Register
	process(CLK,reset)
	begin
	if (reset='1') then RRGB<=x"0000";
   	elsif (CLK'event and CLK='1') then 
	     	if (LD_DRAW='1') then RRGB<=RGB;
             	end if;
	end if;		  
	end process;

	
	-- QDAT Counter (LT24 Bus Command/Data Sequence)
	process(CLK,reset)
	begin
		if (reset='1') then QDAT<=(others=>'0');
   		elsif (CLK'event and CLK='1') then 
	   		if (CL_DAT='1') then QDAT<=(others=>'0');
           	elsif (INC_DAT='1') then QDAT <= QDAT+1;
            elsif (LD_2C='1') then QDAT <= to_unsigned(6,3);
            end if;
		end if;		  
	end process;

	
	-- YMUX8to1 8:1 Multiplexer
	YMUX8to1 <= x"002A" when QDAT=0 else      -- COLUMN COMMAND
	 		   x"0000" when QDAT=1 else		-- COLUMN DATA 0
            x"00"&RXCOL when QDAT=2 else	-- COLUMN DATA 1
			   x"002B" when QDAT=3 else						-- ROW COMMAND
            x"00"&"0000000"&RYROW(8) when QDAT=4 else -- ROW DATA 0
            x"00"&RYROW(7 downto 0) when QDAT=5 else  -- ROW DATA 1
            x"002C" when QDAT=6 else    -- MEMORY WRITE COMMAND (SEND PIXEL)
            RRGB;							    -- RGB16  PIXEL (DATA MEMORY)
				
				
   -- LCD_DATA 2:1 mux				
	LCD_DATA <= x"0000" when (CL_LCD_DATA='1') else YMUX8to1;		--LCD_DATA line (LT24 Bus)


	-- RNNUMPIX Counter
	process(CLK,reset)
	begin
		if (reset='1') then QNUMPIX <= (others=>'0');
   		elsif (CLK'event and CLK='1') then 
	     		if (LD_DRAW='1') then QNUMPIX <= unsigned(NUMPIX);
            elsif (DECPIX='1') then QNUMPIX <= QNUMPIX-1;
            end if;
		end if;		  
	end process;
	ENDPIX <='1' when QNUMPIX=0 else '0';


	-- RSDAT line (LT24 Bus)
	process(CLK,reset)
	begin
		if (reset='1') then LCD_RS <= '1'; 
   	elsif (CLK'event and CLK='1') then 
	    		if (RSDAT='1') then LCD_RS <= '1';
            elsif (RSCOM='1') then LCD_RS <= '0';
            end if;
		end if;		  
	end process;
	-------------------------------------------------------------------------------------------

end  ARCH_LCD_CTRL;

