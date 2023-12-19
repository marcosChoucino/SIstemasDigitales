-----------------------------------------------------
--  Phase 1 Project template
--
-------------------------------------------------------
--
-- CLOCK_50 is the system clock.
-- KEY0 is the active-low system reset.
-- LEDR9 is the LT24_Init_Done signal
-- 
---------------------------------------------------------------
-- Version: V1.0  
---       Basic Vhdl layout with the definitions of the 
--        LT24Setup, LCD_CTRL, and LCD_DRAWING components, 
--        and an instance of the LT24Setup component.
--
---------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DE1SOC_LCDLT24_v1 is
 port(
    -- CLOCK ----------------
    CLOCK_50: in  std_logic;
    -- KEY ----------------
    KEY     : in  std_logic_vector(3 downto 0);
    -- SW ----------------
    SW      : in  std_logic_vector(9 downto 0);
    -- LEDR ----------------
    LEDR    : out std_logic_vector(9 downto 0);
    -- LT24_LCD ----------------
    LT24_LCD_ON     : out std_logic;
    LT24_RESET_N    : out std_logic;
    LT24_CS_N       : out std_logic;
    LT24_RD_N       : out std_logic;
    LT24_RS         : out std_logic;
    LT24_WR_N       : out std_logic;
    LT24_D          : out   std_logic_vector(15 downto 0);

    -- GPIO ----------------
    -- GPIO_0 : inout std_logic_vector(35 downto 0);
    -- UART----------------
     UART_RX : in std_logic;

    -- SEG7 ----------------
    HEX0  : out    std_logic_vector(6 downto 0);
    HEX1  : out    std_logic_vector(6 downto 0);
    HEX2  : out    std_logic_vector(6 downto 0);
    HEX3  : out    std_logic_vector(6 downto 0)
    --HEX4  : out    std_logic_vector(6 downto 0);
    --HEX5  : out    std_logic_vector(6 downto 0)

 );
end;

architecture ARCH_1 of DE1SOC_LCDLT24_v1 is 
    
    component LT24Setup 
    port (
        -- CLOCK and Reset_l ----------------
        clk            : in      std_logic;
        reset_l        : in      std_logic;

        LT24_LCD_ON      : out std_logic;
        LT24_RESET_N     : out std_logic;
        LT24_CS_N        : out std_logic;
        LT24_RS          : out std_logic;
        LT24_WR_N        : out std_logic;
        LT24_RD_N        : out std_logic;
        LT24_D           : out std_logic_vector(15 downto 0);

        LT24_CS_N_Int        : in std_logic;
        LT24_RS_Int          : in std_logic;
        LT24_WR_N_Int        : in std_logic;
        LT24_RD_N_Int        : in std_logic;
        LT24_D_Int           : in std_logic_vector(15 downto 0);
      
        LT24_Init_Done       : out std_logic
    );
    end component;
  

    component LCD_DRAWING is
    port (
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
    end component;

    component UART_16
    port
    (	--entradas
       reset,CLK		: in std_logic;
       RX, RECIBIDO: in std_logic;
    
 
       --salidas
       MANDANDO		: out std_logic;
       DATOS			: out std_logic_vector(15 downto 0)

    );
   end component;
    component LCD_CTRL
    port (
            reset,CLK        : in     std_logic;
            LCD_INIT_DONE    : in std_logic;
            OP_SETCURSOR     : in    std_logic;
            XCOL             : in std_logic_vector(7 downto 0);
            YROW             : in std_logic_vector(8 downto 0);
            OP_DRAWCOLOUR    : in    std_logic;
            RGB              : in std_logic_vector(15 downto 0);
            NUMPIX           : in std_logic_vector(16 downto 0);
				
            DONE_CURSOR, DONE_COLOUR   : out std_logic;
            
				LCD_CS_N, LCD_RS, LCD_WR_N : out std_logic;
            LCD_DATA                   : out std_logic_vector(15 downto 0)
    );
    end component;


    component  hex_7seg
    port (
        hex    : in    std_logic_vector(3 downto 0);
        dig    : out    std_logic_vector(6 downto 0)
    );
    end component;

  
    signal clk, reset :  std_logic;
    signal reset_l    :  std_logic;

    signal DONE_CURSOR, DONE_COLOUR      : std_logic;
    signal OP_SETCURSOR, OP_DRAWCOLOUR   :  std_logic;
    signal COL      :  std_logic_vector(7 downto 0);
    signal ROW      :  std_logic_vector(8 downto 0);
    signal RGB      :  std_logic_vector(15 downto 0);
    signal NUMPIX   : std_logic_vector (16 downto 0);
    
    signal  LT24_Init_Done    : std_logic;
    signal  LT24_CS_N_Int     :  std_logic;
    signal  LT24_RS_Int       :  std_logic;
    signal  LT24_WR_N_Int     :  std_logic;
    signal  LT24_RD_N_Int     :  std_logic;
    signal  LT24_D_Int        :  std_logic_vector(15 downto 0);
  
   constant  RED_COLOR    : std_logic_vector(15 downto 0)  := "11111" & "000000" & "00000";
   constant  GREEN_COLOR  : std_logic_vector(15 downto 0)  := "00000" & "111111" & "00000";
   constant  BLUE_COLOR   : std_logic_vector(15 downto 0)  := "00000" & "000000" & "11111";
   constant  WHITE_COLOR  : std_logic_vector(15 downto 0)  := "11111" & "111111" & "11111";
	
	
	--para la uart
	signal HandsakeFromDRAWINGtoUART :  std_logic;
	signal HandsakeFromUARTtoDRAWING :  std_logic;
	signal  datosUart       			:  std_logic_vector(15 downto 0);
	signal resetUart 						:  std_logic;
  
  
  constant  NUMPIXELS        			: std_logic_vector(16 downto 0)  := "0" & x"A000";
  
begin 
   clk      <= CLOCK_50;
   reset    <= not(KEY(0));
   reset_l  <= KEY(0);
   resetUart <= not(KEY(1));
   LT24_RD_N_Int  <= '1';
    
-- LT24Setup component instantiation -----------    
   O1_SETUP:LT24Setup 
   port map(
      clk          => clk,
      reset_l      => reset_l,

      LT24_LCD_ON      => LT24_LCD_ON,
      LT24_RESET_N     => LT24_RESET_N,
      LT24_CS_N        => LT24_CS_N,
      LT24_RS          => LT24_RS,
      LT24_WR_N        => LT24_WR_N,
      LT24_RD_N        => LT24_RD_N,
      LT24_D           => LT24_D,

      LT24_CS_N_Int       => LT24_CS_N_Int,
      LT24_RS_Int         => LT24_RS_Int,
      LT24_WR_N_Int       => LT24_WR_N_Int,
      LT24_RD_N_Int       => LT24_RD_N_Int,
      LT24_D_Int          => LT24_D_Int,
      
      LT24_Init_Done      => LT24_Init_Done
   );
   


   LEDR(0)  <= not(KEY(0));--reset
   LEDR(1)  <= not(KEY(1));--uart
   LEDR(2)  <= not(KEY(2));--delscreen
	LEDR(3)  <= not(KEY(3));--delscreen
	LEDR(4)  <= DONE_CURSOR; 
	LEDR(5)  <= DONE_CURSOR;   
  -- LED 6 PARA LOS SWICH QUE NO SE USAN
  LEDR(6)  <= SW(3) OR SW(4) or SW(5) or SW(6) or SW(7) or SW(8) or SW(9);
   LEDR(7)  <=HandsakeFromDRAWINGtoUART;
	LEDR(8)  <= HandsakeFromUARTtoDRAWING;
   LEDR(9)  <= LT24_Init_Done;
   ---------------------------------------------------------

   
 -- LCD_CTRL component instantiation -----------    
  O2_LCDCONT: LCD_CTRL
   port map (
      CLK     => clk,
      reset   => reset,
      LCD_INIT_DONE  => LT24_Init_Done,    
      
      OP_SETCURSOR   => OP_SETCURSOR ,
      XCOL   => COL,            -- "00111111",
      YROW   => ROW,            -- "001111111",
      
      OP_DRAWCOLOUR  => OP_DRAWCOLOUR,
      RGB            => RGB,    
      NUMPIX         => NUMPIX,       --- "0" & x"A000",
      
      DONE_CURSOR    => DONE_CURSOR,
      DONE_COLOUR    => DONE_COLOUR,
      
      LCD_CS_N  => LT24_CS_N_Int,
      LCD_RS    => LT24_RS_Int,
      LCD_WR_N  => LT24_WR_N_Int,
      LCD_DATA  => LT24_D_Int
   );

    
	 
	  -- uart component instantiation -----------    
  myUART: UART_16
   port map (
      CLK     => clk,
      reset   => resetUart,
		--entradas
		RX => UART_RX,
		RECIBIDO => HandsakeFromDRAWINGtoUART,

		--salidas
		MANDANDO		=> HandsakeFromUARTtoDRAWING,
		DATOS		=> 	datosUart

   );
    
 -- LCD_DRAWING component instantiation -----------    
   O3_LCDDRAW: LCD_DRAWING
   port map (
      reset => reset,
      CLK   => clk,
        
      DEL_SCREEN   => not(KEY(2)),
      DRAW_FIG     => not(KEY(3)),
		UART			=>  not(KEY(1)),
      COLOUR_CODE  => SW(2 downto 0),
      
      DONE_CURSOR  => DONE_CURSOR,
      DONE_COLOUR  => DONE_COLOUR,
              
      OP_SETCURSOR => OP_SETCURSOR,
      XCOL => COL,
      YROW => ROW,
        
      OP_DRAWCOLOUR => OP_DRAWCOLOUR,
      RGB           => RGB,
      NUMPIX       => NUMPIX,
		
		--para la uart
		EntradaUart => datosUart, -- ¿falla? probar esto:   datosUart (7 downto 0) & datosUart(15 downto 8)
		Handsake => HandsakeFromUARTtoDRAWING,
		RECIVIDO  => HandsakeFromDRAWINGtoUART
   );

 -- hex_7seg component instantiation -----------    
	-- Colour Code
	
   O8_DUT_HEX0_7_SEG: hex_7seg
   port map (
 
      -- IN       
      hex     => datosUart(3 downto 0), 
      -- OUT
      dig     => HEX0
   );

	-- Column bits 3...0
   O8_DUT_HEX1_7_SEG: hex_7seg
   port map (
 
      -- IN       
      hex     =>datosUart(7 downto 4), 
      -- OUT
      dig     => HEX1
   );

	-- Column bits  7...4
   O8_DUT_HEX2_7_SEG: hex_7seg
   port map (
 
      -- IN       
      hex     => datosUart(11 downto 8), 
      -- OUT
      dig     => HEX2
   );

	-- Row bits  3...0
   O8_DUT_HEX3_7_SEG: hex_7seg
   port map (
 
      -- IN       
      hex     => datosUart(15 downto 12), 
      -- OUT
      dig     => HEX3
   );





  
END ARCH_1;


----------------------------------------------------------------------------
-----------------------¿COMO USAR LA PLACA?
----------------------------------------------------------------------------




--BOTON 0 -> reset
--BOTON 1 -> UART
--BOTON 2 -> delscreen
--BOTON 3 -> drawfig

--SWICHES 
-- 0 al 2 es color
--el resto sin untilizar

