--Library and package declaration
library ieee;                                               
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;                                                             

library work;
use work.customtypes.all;


-- Empty testbench entity
entity ImageTestbench is																	
end ImageTestbench;


architecture image_testbench of ImageTestbench is

	-- constants   
	constant clk_period 	: time := 10 ns;

	-- signals                                                   
	signal in_data 			: pixel;
	signal out_data 		: kernel_row;
	signal in_clk 			: std_logic;
	signal in_write			: std_logic;
	signal out_ready 		: std_logic;

	--files
	file in_file 			: text;
	file out_file 			: text;

	--UUT component
	component Image
		port (
			in_clk 			: in std_logic;
			in_write 		: in std_logic;
			out_ready 		: buffer std_logic;
			out_data 		: buffer kernel_row;
			in_data 		: in pixel
		);
	end component;

	--Signal mapping
	begin
		i1 : Image
		port map (
			in_clk => in_clk,
			in_data => in_data,
			in_write => in_write,
			out_data => out_data,
			out_ready => out_ready
		);


	-- Generates clock for UUT
	clk_process : process                                                                               
	begin      
		-- in_write <= '1';
		in_clk <= '1';
		wait for clk_period/2; 

		-- in_write <= '0';
		in_clk <= '0';
		wait for clk_period/2; 
													
	end process clk_process;       


	--Sends inputs and reads outputs of UUT
	send_kernel : process                                         

		variable in_line			: line;
		variable out_line			: line;
		variable pixel_var			: pixel;
		variable pixel_vect_var		: std_logic_vector(7 downto 0);

	begin    
		--File opening
		file_open(in_file, "image_input.in",  read_mode);
		file_open(out_file, "image_test.out", write_mode);  
				

		--Reading the in file
		while not endfile(in_file) loop
			readline(in_file, in_line);	
			read(in_line, pixel_vect_var);
			in_write <= '1';

			--Converting std_vector to pixel
			for i in 0 to 7 loop
				pixel_var(i) := pixel_vect_var(i);
			end loop;
			in_data <= pixel_var;
				
			wait until rising_edge(in_clk);

			if out_ready = '1' then
				for i in 0 to 14 loop
					pixel_var := out_data(i);
					for j in 0 to 7 loop
						pixel_vect_var(j) := pixel_var(j);
					end loop;
					write(out_line, pixel_vect_var);
				end loop;
				writeline(out_file, out_line);
			end if;
		end loop;

		wait until rising_edge(in_clk);

			if out_ready = '1' then
				for i in 0 to 14 loop
					pixel_var := out_data(i);
					for j in 0 to 7 loop
						pixel_vect_var(j) := pixel_var(j);
					end loop;
					write(out_line, pixel_vect_var);
				end loop;
				writeline(out_file, out_line);
			end if;

		in_write <= '0';

		file_close(in_file);
		file_close(out_file);

		wait;
	end process send_kernel;	
end image_testbench;