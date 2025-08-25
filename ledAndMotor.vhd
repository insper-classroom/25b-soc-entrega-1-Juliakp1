library IEEE;
use IEEE.std_logic_1164.all;

entity Lab1_FPGA_RTL is
    port (
        -- Globals
        fpga_clk_50   : in  std_logic;        

        -- I/Os
		  fpga_buttons : in std_logic_vector(3 downto 0);
		  fpga_switches : in std_logic_vector(3 downto 0);
        fpga_led_pio  : out std_logic_vector(5 downto 0);
        fpga_motor_pio  : out std_logic_vector(3 downto 0)
  );
end entity Lab1_FPGA_RTL;

architecture rtl of Lab1_FPGA_RTL is

-- signal
TYPE STATE_TYPE IS (s0, s01, s1, s12, s2, s23, s3, s30);
signal state  : STATE_TYPE := s0;
signal nextState : std_logic  := '0';

begin

  -- ============================================================================ --
  
	process(fpga_clk_50)
	begin
    if (rising_edge(fpga_clk_50)) then
	 
		if ((fpga_switches(1) = '1')) then
		
			CASE state IS
			WHEN s0=>
			  if (nextState = '1') then
				 state <= s01;
			  end if;
			WHEN s01=>
			  if (nextState = '1') then
				 state <= s1;
			  end if;
			WHEN s1=>
			  if (nextState = '1') then
				 state <= s12;
			  end if;
			WHEN s12=>
			  if (nextState = '1') then
				 state <= s2;
			  end if;
			WHEN s2=>
			  if (nextState = '1') then
				 state <= s23;
			  end if;
			WHEN s23=>
			  if (nextState = '1') then
				 state <= s3;
			  end if;
			WHEN s3=>
			  if (nextState = '1') then
				 state <= s30;
			  end if;
			WHEN s30=>
			  if (nextState = '1') then
				 state <= s0;
			  end if;
			when others=>
			  state <= s0;
			END CASE;
			
		else
			CASE state IS
			WHEN s0=>
			  if (nextState = '1') then
				 state <= s30;
			  end if;
			WHEN s01=>
			  if (nextState = '1') then
				 state <= s0;
			  end if;
			WHEN s1=>
			  if (nextState = '1') then
				 state <= s01;
			  end if;
			WHEN s12=>
			  if (nextState = '1') then
				 state <= s1;
			  end if;
			WHEN s2=>
			  if (nextState = '1') then
				 state <= s12;
			  end if;
			WHEN s23=>
			  if (nextState = '1') then
				 state <= s2;
			  end if;
			WHEN s3=>
			  if (nextState = '1') then
				 state <= s23;
			  end if;
			WHEN s30=>
			  if (nextState = '1') then
				 state <= s3;
			  end if;
			when others=>
			  state <= s0;
			END CASE;
		
		end if;
    end if;
  end process;

  -- ============================================================================ --
  
	PROCESS (state)
   BEGIN
		fpga_motor_pio(0) <= '0';
		fpga_motor_pio(1) <= '0';
		fpga_motor_pio(2) <= '0';
		fpga_motor_pio(3) <= '0';
		
		fpga_led_pio(0) <= '0';
		fpga_led_pio(1) <= '0';
		fpga_led_pio(2) <= '0';
		fpga_led_pio(3) <= '0';
		
      CASE state IS
        WHEN s0 =>
			 fpga_motor_pio(0) <= '1';
			 fpga_led_pio(0) <= '1';
        WHEN s01 =>
			 fpga_motor_pio(0) <= '1';
			 fpga_motor_pio(1) <= '1';
			 fpga_led_pio(0) <= '1';
			 fpga_led_pio(1) <= '1';
        WHEN s1 =>
          fpga_motor_pio(1) <= '1';
          fpga_led_pio(1) <= '1';
        WHEN s12 =>
			 fpga_motor_pio(1) <= '1';
			 fpga_motor_pio(2) <= '1';
			 fpga_led_pio(1) <= '1';
			 fpga_led_pio(2) <= '1';
        WHEN s2 =>
          fpga_motor_pio(2) <= '1';
          fpga_led_pio(2) <= '1';
        WHEN s23 =>
			 fpga_motor_pio(2) <= '1';
			 fpga_motor_pio(3) <= '1';
			 fpga_led_pio(2) <= '1';
			 fpga_led_pio(3) <= '1';
        WHEN s3 =>
          fpga_motor_pio(3) <= '1';
          fpga_led_pio(3) <= '1';
        WHEN s30 =>
			 fpga_motor_pio(3) <= '1';
			 fpga_motor_pio(0) <= '1';
			 fpga_led_pio(3) <= '1';
			 fpga_led_pio(0) <= '1';
      END CASE;
	END PROCESS;
  
  -- ============================================================================ --

  process(fpga_clk_50) 
  
      variable counter : integer range 0 to 1000000000 := 0;
		variable counter_limit : integer range 0 to 1000000000 := 100000000;
		variable full_spin : integer range 0 to 2048 := 0;
		
	begin
        if (rising_edge(fpga_clk_50)) then
		  
				if ((fpga_switches(0) = '1') and (full_spin < 2048)) then
				
						if (counter < counter_limit) then
						  counter := counter + 1;
						  nextState  <= '0';
						else
							counter := 0;
							nextState  <= '1';
							if (fpga_switches(2) = '1') then
								full_spin := full_spin + 1;
							end if;
							if (counter_limit > 50000) then
								counter_limit := counter_limit-100;
							end if;
						end if;
						
				end if;
				
				-- Single Spin
				if (fpga_switches(2) = '0') then
					full_spin := 0;
				end if;
				
				-- Reset Button
				if ((fpga_buttons(0) = '0')) then
					counter_limit := 1000000000;
				end if;
				if ((fpga_buttons(1) = '0')) then
					counter_limit := 40000000;
				end if;
				if ((fpga_buttons(2) = '0')) then
					counter_limit := 2000000;
				end if;
				if ((fpga_buttons(3) = '0')) then
					counter_limit := 100000;
				end if;
				
        end if;
  end process;

end rtl;
