library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
library UNISIM;
use UNISIM.VComponents.all;
--use work.EE478.all;

entity pong is
    Port ( sys_clk : in std_logic;
          TMDS, TMDSB : out std_logic_vector(3 downto 0);
          p1_up : in std_logic;
          p1_dn : in std_logic;
          p2_up : in std_logic;
          p2_dn : in std_logic
          );
end pong;

architecture Behavioral of pong is

-- Video Timing Parameters
--1280x720@60HZ
constant HPIXELS_HDTV720P : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(1280, 11)); --Horizontal Live Pixels
constant VLINES_HDTV720P  : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(720, 11));  --Vertical Live ines
constant HSYNCPW_HDTV720P : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(80, 11));  --HSYNC Pulse Width
constant VSYNCPW_HDTV720P : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(5, 11));    --VSYNC Pulse Width
constant HFNPRCH_HDTV720P : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(72, 11));   --Horizontal Front Porch
constant VFNPRCH_HDTV720P : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(3, 11));    --Vertical Front Porch
constant HBKPRCH_HDTV720P : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(216, 11));  --Horizontal Front Porch
constant VBKPRCH_HDTV720P : std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(22, 11));   --Vertical Front Porch

constant pclk_M : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(36, 8));
constant pclk_D : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(24, 8)); 

constant tc_hsblnk: std_logic_vector(10 downto 0) := (HPIXELS_HDTV720P - 1);
constant tc_hssync: std_logic_vector(10 downto 0) := (HPIXELS_HDTV720P - 1 + HFNPRCH_HDTV720P);
constant tc_hesync: std_logic_vector(10 downto 0) := (HPIXELS_HDTV720P - 1 + HFNPRCH_HDTV720P + HSYNCPW_HDTV720P);
constant tc_heblnk: std_logic_vector(10 downto 0) := (HPIXELS_HDTV720P - 1 + HFNPRCH_HDTV720P + HSYNCPW_HDTV720P + HBKPRCH_HDTV720P);
constant tc_vsblnk: std_logic_vector(10 downto 0) := (VLINES_HDTV720P - 1);
constant tc_vssync: std_logic_vector(10 downto 0) := (VLINES_HDTV720P - 1 + VFNPRCH_HDTV720P);
constant tc_vesync: std_logic_vector(10 downto 0) := (VLINES_HDTV720P - 1 + VFNPRCH_HDTV720P + VSYNCPW_HDTV720P);
constant tc_veblnk: std_logic_vector(10 downto 0) := (VLINES_HDTV720P - 1 + VFNPRCH_HDTV720P + VSYNCPW_HDTV720P + VBKPRCH_HDTV720P);
signal sws_clk: std_logic_vector(3 downto 0); --clk synchronous output
signal sws_clk_sync: std_logic_vector(3 downto 0); --clk synchronous output
signal bgnd_hblnk : std_logic;
signal bgnd_vblnk : std_logic;

signal red_data, green_data, blue_data : std_logic_vector(7 downto 0) := (others => '0');
signal hcount, vcount : std_logic_vector(10 downto 0);
signal hsync, vsync, active : std_logic;
    signal pclk : std_logic;
signal clkfb : std_logic;
signal rgb_data : std_logic_vector(23 downto 0) := (others => '0');
constant v_min : unsigned(10 downto 0) := to_unsigned(260, 11);
constant v_max : unsigned(10 downto 0) := to_unsigned(460, 11);
constant h_min : unsigned(10 downto 0) := to_unsigned(540, 11);
constant h_max : unsigned(10 downto 0) := to_unsigned(740, 11);

-- Paddle coordinates
constant pad_width : unsigned(10 downto 0) := to_unsigned(20, 11);
constant pad_height : unsigned(10 downto 0) := to_unsigned(200, 11);

signal lpad_top : unsigned(10 downto 0) := to_unsigned(200, 11);
constant lpad_left : unsigned(10 downto 0) := to_unsigned(50, 11);

signal rpad_top : unsigned(10 downto 0) := to_unsigned(400, 11);
constant rpad_left : unsigned(10 downto 0) := to_unsigned(1210, 11); -- screen_with - indent_left - pad_width
-- End Paddle coordinates

-- Ball coordinates
signal ball_x : unsigned(10 downto 0) := to_unsigned(640, 11);
signal ball_y : unsigned(10 downto 0) := to_unsigned(360, 11);
signal ball_dx : signed(7 downto 0) := to_signed(1, 8);
signal ball_dy : signed(7 downto 0) := to_signed(1, 8);
signal ball_rad : unsigned(7 downto 0) := to_unsigned(10, 8);
-- End ball coordinates

-- pixel values on and off
constant ONN : std_logic_vector(7 downto 0) := x"FF";
constant OFF : std_logic_vector(7 downto 0) := x"00";

constant WHITE : std_logic_vector(23 downto 0) := X"FFFFFF";
constant BLACK : std_logic_vector(23 downto 0) := X"000000";

signal counter : unsigned(17 downto 0) := (others => '0');
signal reset_btn : std_logic := '0';

begin

--Create a PLL that takes in sys_clk and drives the pclk signal.
--pclk should be 74.25MHz
--You may connect the locked output to open - we aren't using it.
--You may connect the reset input to '0' as in Lab4

pixel_clock_gen : entity work.pxl_clk_gen port map (
    clk_in1 => sys_clk,
    clk_out1 => pclk,
    locked => open,
    reset => '0'
);

timing_inst : entity work.timing port map (
	tc_hsblnk=>tc_hsblnk, --input
	tc_hssync=>tc_hssync, --input
	tc_hesync=>tc_hesync, --input
	tc_heblnk=>tc_heblnk, --input
	hcount=>hcount, --output
	hsync=>hsync, --output
	hblnk=>bgnd_hblnk, --output
	tc_vsblnk=>tc_vsblnk, --input
	tc_vssync=>tc_vssync, --input
	tc_vesync=>tc_vesync, --input
	tc_veblnk=>tc_veblnk, --input
	vcount=>vcount, --output
	vsync=>vsync, --output
	vblnk=>bgnd_vblnk, --output
	restart=>reset_btn,
	clk=>pclk);
	
hdmi_controller : entity work.rgb2dvi 
    generic map (
        kClkRange => 2
    )
    port map (
        TMDS_Clk_p => TMDS(3),
        TMDS_Clk_n => TMDSB(3),
        TMDS_Data_p => TMDS(2 downto 0),
        TMDS_Data_n => TMDSB(2 downto 0),
        aRst => '0',
        aRst_n => '1',
        vid_pData => rgb_data,
        vid_pVDE => active,
        vid_pHSync => hsync,
        vid_pVSync => vsync,
        PixelClk => pclk, 
        SerialClk => '0');
        
        
active <= not(bgnd_hblnk) and not(bgnd_vblnk); 
--rgb_data <= red_data & blue_data & green_data;	 

--To simplify the code, I suggest using a combinational process like this, to drive red_data, green_data, and blue_data
--To draw shapes, just add conditions based on hcount and vcount.
--Assign a color to these signals when hcount and vcount are within the shape you want to draw
--And assign zero otherwise, to paint the rest of the screen black.

process(pclk)
begin
    if rising_edge(pclk) then
        counter <= counter + 1;
        if(counter = to_unsigned(142788, 18)) then
            counter <= (others => '0');
            
            -- Move the ball
            ball_x <= unsigned(signed(ball_x) + ball_dx);
            ball_y <= unsigned(signed(ball_y) + ball_dy);
            
            -- Bounce the ball
            if (ball_y-ball_rad)<1 then
                ball_y <= unsigned(signed(ball_y) - ball_dy);
                ball_dy <= 0 - ball_dy;
            elsif (ball_y+ball_rad)>718 then
                ball_y <= unsigned(signed(ball_y) - ball_dy);
                ball_dy <= 0 - ball_dy;
            elsif (ball_x-ball_rad)<(lpad_left+pad_width) and (ball_x-ball_rad)>lpad_left then
                if (
                    ((ball_y+ball_rad)>lpad_top and (ball_y+ball_rad)<(lpad_top+pad_height)) or 
                    ((ball_y-ball_rad)>lpad_top and (ball_y-ball_rad)<(lpad_top+pad_height))
                   ) then
                        ball_x <= unsigned(signed(ball_x) - ball_dx);
                        ball_dx <= 0 - ball_dx;
                end if;
            elsif (ball_x+ball_rad)>(rpad_left) and (ball_x+ball_rad)<(rpad_left+pad_width) then
                if (
                    ((ball_y+ball_rad)>rpad_top and (ball_y+ball_rad)<(rpad_top+pad_height)) or 
                    ((ball_y-ball_rad)>rpad_top and (ball_y-ball_rad)<(rpad_top+pad_height))
                   ) then
                        ball_x <= unsigned(signed(ball_x) - ball_dx);
                        ball_dx <= 0 - ball_dx;
                end if;
            end if;
            
            -- Check for point winning
            if ball_x<1 then
                ball_x <= to_unsigned(640, 11);
                ball_y <= to_unsigned(360, 11);
                ball_dx <= to_signed(1, 8);
                ball_dy <= to_signed(1, 8);
            elsif ball_x>1279 then
                ball_x <= to_unsigned(640, 11);
                ball_y <= to_unsigned(360, 11);
                ball_dx <= to_signed(-1, 8);
                ball_dy <= to_signed(1, 8);
            end if;
            
            -- Player one controls
            if(p1_up='1' and p1_dn='0' and lpad_top>1) then -- move up
                lpad_top <= lpad_top - 1;
            elsif(p1_up='0' and p1_dn='1' and (lpad_top+pad_height)<719) then -- move down
                lpad_top <= lpad_top + 1;
            else -- don't move (no input or both buttons)
                lpad_top <= lpad_top + 0;
            end if;
            
            -- Player two controls
            if(p2_up='1' and p2_dn='0' and rpad_top>1) then -- move up
                rpad_top <= rpad_top - 1;
            elsif(p2_up='0' and p2_dn='1' and (rpad_top+pad_height)<719) then -- move down
                rpad_top <= rpad_top + 1;
            else -- don't move (no input or both buttons)
                rpad_top <= rpad_top + 0;
            end if;
            
        end if;
    end if;
end process;

process(hcount, vcount)
    variable uhcount : unsigned(10 downto 0) := unsigned(hcount);
    variable uvcount : unsigned(10 downto 0) := unsigned(vcount);
begin
    -- draw paddles and ball
    if (uhcount>(ball_x-ball_rad) and uhcount<(ball_x+ball_rad) and uvcount>(ball_y-ball_rad) and uvcount<(ball_y+ball_rad)) then
        rgb_data <= WHITE;
--        red_data <= ONN;
--        green_data <= ONN;
--        blue_data <= ONN
    elsif(uhcount>lpad_left and uhcount<(lpad_left+pad_width) and uvcount>lpad_top and uvcount<(lpad_top+pad_height)) then
        rgb_data <= WHITE;
--        red_data <= ONN;
--        green_data <= ONN;
--        blue_data <= ONN;
    elsif (uhcount>rpad_left and uhcount<(rpad_left+pad_width) and uvcount>rpad_top and uvcount<(rpad_top+pad_height)) then
        rgb_data <= WHITE;
--        red_data <= ONN;
--        green_data <= ONN;
--        blue_data <= ONN;
    else
        rgb_data <= BLACK;
--        red_data <= OFF;
--        green_data <= OFF;
--        blue_data <= OFF;
    end if;
    -- end right paddle
end process;
     
end Behavioral;

package REF_PACK is

end REF_PACK;

