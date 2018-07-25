--Library and package declaration
library ieee;                                               
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all;
use work.CustomTypes.all;

entity DataProxy is
	port
	(
		in_clk			: in std_logic;
		in_ready		: in std_logic;
		in_data			: in std_logic_vector (7 downto 0);

		out_image_write	: out std_logic;
		out_kernel_write: out std_logic;
		out_image		: out std_logic_vector (7 downto 0);
		out_kernel		: out std_logic_vector (7 downto 0)
	);

end DataProxy;

architecture data_proxy of DataProxy is

	signal pixel_count 	: unsigned (7 downto 0) := "00000000";

begin

	process (
	in_clk
	)
	begin

		if rising_edge(in_clk) then
			if in_ready = '1' then
				if pixel_count < (kernel_dimension * kernel_dimension) then
					pixel_count <= pixel_count + 1;
					out_kernel_write <= '1';
					out_image_write <= '0';
					out_kernel <= in_data;
				else
					out_kernel_write <= '0';
					out_image_write <= '1';
					out_image <= in_data;
				end if;
			end if;
		end if;
	end process;

end data_proxy;