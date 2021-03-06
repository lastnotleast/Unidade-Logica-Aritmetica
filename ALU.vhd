library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
	port(
		--entradas
		a_in, b_in: in std_logic_vector(7 downto 0);
		c_in: in std_logic;
		op_sel: in std_logic_vector(3 downto 0);
		bit_sel: in std_logic_vector(2 downto 0);
		--saidas
		r_out: out std_logic_vector(7 downto 0);
		z_out, dc_out, c_out: out std_logic
	);
end entity;

architecture arch of ALU is 
	signal inc, dec, add, sub, bc, bs : std_logic_vector(7 downto 0);
	constant sel : integer := 4;
	begin
		inc <= std_logic_vector(unsigned(a_in) + 1);
		dec <= std_logic_vector(unsigned(a_in) - 1);
		add <= std_logic_vector(unsigned(a_in) + unsigned(b_in));
		sub <= std_logic_vector(unsigned(a_in) - unsigned(b_in));
		bc <= (sel => '0', others => '1');
		bs <= (sel => '1', others => '0');

		with op_sel select -- faz a sele��o da opera��o
			r_out <= a_in or b_in when "0000",
					 a_in and b_in when "0001",
					 a_in xor b_in when "0010",
					 not a_in  when "0011",
					 c_in & a_in(7 downto 1) when "0100",
					 a_in(6 downto 0) & c_in when "0101",
					 a_in(3 downto 0) & a_in(7 downto 4) when "0110",
					 "00000000" when "0111",
					 add when "1000",
					 sub when "1001",
					 inc when "1010",
					 dec when "1011",
					 bc and a_in when "1100",
					 bs or a_in when "1101",
					 a_in when "1110",
					 b_in when "1111";
					 
		z_out <= '1' when (a_in or b_in) = "00000000" and op_sel = "0000" else-- z_out define se o resultado de  r_out for zero ele recebe 1
				 '1' when (a_in and b_in) = "00000000" and op_sel = "0001" else-- ent�o � usado as entradas e a op_sel para definir se a saida ir� receber 1 ou 0
				 '1' when (a_in xor b_in) = "00000000" and op_sel = "0010" else
				 '1' when (not a_in) = "00000000" and op_sel = "0011" else
				 '1' when  op_sel = "0111" else
				 '1' when add = "00000000" and op_sel = "1000" else
				 '1' when sub = "00000000" and op_sel = "1001" else
				 '1' when inc = "00000000" and op_sel = "1010" else
				 '1' when dec = "00000000" and op_sel = "1011" else
				 '1' when a_in(to_integer(unsigned(bit_sel))) = '0' and op_sel = "1100" else
				 '1' when a_in(to_integer(unsigned(bit_sel))) = '1' and op_sel = "1101" else
				 '1' when a_in = "00000000" and op_sel = "1110" else
				 '1' when b_in = "00000000" and op_sel = "1111" else
				 '0';
				 
		c_out <= '1' when (to_integer(unsigned(a_in)) + to_integer(unsigned(b_in))) > 256 and op_sel = "1000" else
		         '1' when (to_integer(unsigned(a_in)) - to_integer(unsigned(b_in))) < 0 and op_sel = "1001" else
		         '1' when a_in(0) = '1' and op_sel = "0100" else
		         '1' when a_in(7) = '1' and op_sel = "0101" else
				 '0';-- carry ou borrow serve para opera��es de soma ou subtra��o se a soma for maior que um byte ou menor que 0
				 
		dc_out <= '1' when (to_integer(unsigned(a_in(3 downto 0))) + to_integer(unsigned(b_in(3 downto 0)))) > 128 and op_sel = "1000" else
				  '1' when (to_integer(unsigned(a_in(3 downto 0))) - to_integer(unsigned(b_in(3 downto 0)))) < 0 and op_sel = "1001" else
				  '0';
end arch;