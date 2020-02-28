
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-----------------------------------------------------
-- 1680 X 1050 Resolution / 60 HZ - FPS
-- Pixel Freq: 147.14 MHz
-----------------------------------------------------
-- H > PW + BP    &  H < total - FP
-- V > PW + BP    &  V < total - FP
-----------------------------------------------------

entity vga_driver is Port (In_RED : in std_logic_vector(3 downto 0);
                           In_GREEN : in std_logic_vector(3 downto 0);
                           In_BLUE : in std_logic_vector(3 downto 0); 
                           ---------------------------------------------
                           In_X    : in std_logic_vector(10 downto 0); 
                           In_Y    : in std_logic_vector(10 downto 0);
                           ---------------------------------------------
                           clk_100Mhz: in std_logic;
                           RED : out std_logic_vector(3 downto 0);
                           GREEN : out std_logic_vector(3 downto 0);
                           BLUE : out std_logic_vector(3 downto 0);
                           HS : out std_logic;
                           VS : out std_logic);
end vga_driver;

architecture Behavioral of vga_driver is

component clk_wiz_0 is port(
   clk_out1 : out std_logic;
  clk_in1 : in std_logic);
  
end component;

-- Pixel clock 25 MHz
signal pixel_freq: std_logic := '0';
signal H_pulse : integer := 2256;
signal V_pulse : integer := 1087;
signal H_counter : integer := 0;
signal V_counter : integer := 0;
signal V_en : std_logic;
--signal HS_sig : std_logic;

begin

--MCMM block for clock division.
Pixel_Freq_Gen :  clk_wiz_0 port map(
   clk_out1 =>  pixel_freq,
  clk_in1 => clk_100Mhz         
 );
 
H_Sync: Process(pixel_freq) begin
    if rising_edge(pixel_freq) then
        if H_counter < H_pulse -1 then
            V_en <= '0';
            H_counter <= H_counter + 1;
        else
            V_en <= '1'; 
            H_counter <= 0;
        end if;       
    end if;
end process;
V_Sync: Process(pixel_freq) begin
    if rising_edge(pixel_freq) then
        if V_en = '1' then
            if V_counter < V_pulse -1 then
                V_counter <= V_counter + 1;
            else
                V_counter <= 0;
            end if;
        end if;
    end if;
end process;

HS <= '0' when H_counter < 183 else '1';
VS <= '0' when V_counter < 3 else '1';

VGA_out : process(pixel_freq) begin
    if (H_counter+ to_integer(unsigned(In_X)) > 471 and H_counter+to_integer(unsigned(In_X)) < 2151 and V_counter+to_integer(unsigned(In_Y)) > 35 and V_counter+to_integer(unsigned(In_Y)) < 1085 ) then
        --if (H_counter = to_integer(unsigned(In_X))) and (V_counter = to_integer(unsigned(In_Y)))  then
            RED <= In_RED;
            GREEN <= In_GREEN;
            BLUE <= In_BLUE;    
        --end if;  
    else
        RED <= "0000"; 
        GREEN <= "0000";
        BLUE <= "0000";      
    end if;
end process;
--RED <= In_RED  when (H_counter > 471 and H_counter < 2151 and V_counter > 35 and V_counter < 1085 ) else "0000";
--GREEN <= In_GREEN when (H_counter > 471 and H_counter < 2151 and V_counter > 35 and V_counter < 1085 ) else "0000";
--BLUE <= In_BLUE when (H_counter > 471 and H_counter < 2151 and V_counter > 35 and V_counter < 1085 ) else "0000";

end Behavioral;
