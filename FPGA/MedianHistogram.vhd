library ieee;                                               
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;
use work.CustomTypes.all;

entity MedianHistogram is 
	generic
	(
		in_dimension	: unsigned (7 downto 0) := to_unsigned(15, 8)
	);
	port
	(
		in_clk			: in 	std_logic;
		in_write		: in 	std_logic;
		in_data			: in 	window_matrix;

		out_median		: out 	pixel;
		out_maximum		: out 	pixel;
		out_minimum		: out 	pixel;
		out_ready		: out 	std_logic := '0'
	);

end MedianHistogram;

architecture median_histogram of MedianHistogram is

	signal decoder_out 	: histogram_dec_out;
	signal adder_in 	: histogram_add_in;
	signal c_histogram 	: histogram;
	signal pixel_enable	: histogram_in_bin;

	signal write_dec	: std_logic := '0';
	signal write_add	: std_logic := '0';
	signal write_enc	: std_logic := '0';

begin
		
	PXL_ENB_1 : for a in 0 to 14 generate
		PXL_ENB_1 : for b in 0 to 14 generate
			PXL_ENB_3 : if (b < (15 - in_dimension) / 2 or b >= (15 - in_dimension) / 2 + in_dimension) or
						   (a < (15 - in_dimension) / 2 or a >= (15 - in_dimension) / 2 + in_dimension) generate
				pixel_enable(15 * a + b) <= '0';
			end generate;
			PXL_ENB_4 : if (b >= (15 - in_dimension) / 2 and b < (15 - in_dimension) / 2 + in_dimension) and
						   (a >= (15 - in_dimension) / 2 and a < (15 - in_dimension) / 2 + in_dimension) generate
				pixel_enable(15 * a + b) <= '1';
			end generate;
		end generate;
	end generate;

	DEC_ADD_1 : for d in 0 to 224 generate
		DEC_ADD_2 : for a in 0 to 255 generate
			adder_in(a)(d) <= decoder_out(d)(a);
		end generate;
	end generate;

	DEC_GEN : for p in 0 to kernel_dimension * kernel_dimension - 1 generate
		DEC : entity work.PriorityDecoder(priority_decoder)
		port map (
			in_clk 		=> in_clk,
			in_write	=> write_dec,
			in_value 	=> in_data(p),
			out_values 	=> decoder_out(p)
		);
	end generate;

	ADD_GEN : for p in 0 to 255 generate
		ADD : entity work.HistogramAdder(histogram_adder)
		port map (
			in_clk 		=> in_clk,
			in_write	=> write_add,
			in_values 	=> adder_in(p),
			in_enabled 	=> pixel_enable,
			out_sum 	=> c_histogram(p)
		);
	end generate;

	MIN : entity work.PriorityEncoder(priority_encoder)
	generic map
	( 
		gen_lookup 		=> "min",
		gen_dimension	=> in_dimension
	)
	port map (
		in_clk 			=> in_clk,
		in_write		=> write_enc,
		in_histogram 	=> c_histogram,
		out_value 		=> out_minimum
	);

	MED : entity work.PriorityEncoder(priority_encoder)
	generic map
	( 
		gen_lookup 		=> "med",
		gen_dimension	=> in_dimension
	)
	port map (
		in_clk 		 	=> in_clk,
		in_write	 	=> write_enc,
		in_histogram 	=> c_histogram,
		out_value 	 	=> out_median
	);

	MAX : entity work.PriorityEncoder(priority_encoder)
	generic map
	( 
		gen_lookup 		=> "max",
		gen_dimension	=> in_dimension
	)
	port map (
		in_clk 			=> in_clk,
		in_write		=> write_enc,
		in_histogram 	=> c_histogram,
		out_value 		=> out_maximum
	);

	process(in_clk)
	begin

		if rising_edge(in_clk) then
			write_dec <= in_write;
			write_add <= write_dec;
			write_enc <= write_add;
			out_ready <= write_enc;
		end if;

		-- for a in 0 to 14 loop
		-- 	for b in 0 to 14 loop
		-- 		if b = 0 or b = 14 then
		-- 			pixel_enable(15 * a + b) <= '0';
		-- 		else
		-- 			pixel_enable(15 * a + b) <= '1';
		-- 		end if;
		-- 	end loop;
		-- end loop;

		-- for d in 0 to 224 loop
		-- 	for a in 0 to 255 loop
		-- 		adder_in(a)(d) <= decoder_out(d)(a);
		-- 	end loop;
		-- end loop;
		
	end process;

end median_histogram;