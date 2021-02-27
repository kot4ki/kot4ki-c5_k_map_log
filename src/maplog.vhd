--=======================================================
-- Descricao do PRNG baseado no k-mapa logistico
-- Matheus Mitsuo de A. Kotaki, São Carlos-SP
-- EESC - USP - 2021
--=======================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity maplog is
	
	generic (
		size : natural := 32
	);
	
	port(
		-- Entradas
		x0   : in std_logic_vector (size-1 DOWNTO 0);
		rst  : in std_logic;
		clk  : in std_logic;
		start: in std_logic;
		
		--Saidas
		xt_out : out std_logic_vector (size-1 DOWNTO 0)
	);
	
end maplog;

architecture archmap of maplog is

--Componente Complemento de dois
component twocomp 

	generic(
		size: natural
	);
	
	port(
		n			: in std_logic_vector  (size-1 DOWNTO 0);
		result	: out std_logic_vector (size-1 DOWNTO 0)	
	);
	
end component;

--Componente Multiplicacao
component mult

	port
	(
		dataa			: in  std_logic_vector (size-1   DOWNTO 0);
		datab			: in  std_logic_vector (size-1   DOWNTO 0);
		result		: out std_logic_vector (2*size-1 DOWNTO 0)
	);
	
end component;	

component soma1 	
	generic(
		P	: natural
	);

	port(
		dataa			: in std_logic_vector  (P DOWNTO 0);
		datab			: in std_logic_vector  (P DOWNTO 0);
		result		: out std_logic_vector (P DOWNTO 0)
	);
end component;

--Signals
	signal xt     : std_logic_vector (size-1    DOWNTO 0); -- valor de entrada da equacao
	signal xt1    : std_logic_vector (size-1    DOWNTO 0); -- valor de realimentacao 
	signal d      : std_logic_vector (size-1    DOWNTO 0); -- entrada do flip-flop
	signal eq1    : std_logic_vector (size-1    DOWNTO 0); -- resultado do complemento de dois
	signal eq2    : std_logic_vector (2*size-1  DOWNTO 0); -- resultado da multiplicacao
	signal s1     : std_logic_vector (2*size-6  DOWNTO 0);
	signal s2     : std_logic_vector (2*size-6  DOWNTO 0);
	signal s3     : std_logic_vector (2*size-9  DOWNTO 0);
	signal s4     : std_logic_vector (2*size-9  DOWNTO 0);
	signal s5     : std_logic_vector (2*size-12 DOWNTO 0);
	signal s6     : std_logic_vector (2*size-12 DOWNTO 0);
	signal s7     : std_logic_vector (2*size-15 DOWNTO 0);
	signal s8     : std_logic_vector (2*size-15 DOWNTO 0);
	signal s9     : std_logic_vector (2*size-18 DOWNTO 0);
	signal s10    : std_logic_vector (2*size-18 DOWNTO 0);
	signal s11    : std_logic_vector (2*size-21 DOWNTO 0);
	signal s12    : std_logic_vector (2*size-21 DOWNTO 0);
	signal s13    : std_logic_vector (2*size-24 DOWNTO 0);
	signal s14    : std_logic_vector (2*size-24 DOWNTO 0);
	signal s15    : std_logic_vector (2*size-27 DOWNTO 0);
	signal s16    : std_logic_vector (2*size-27 DOWNTO 0);
	signal s17    : std_logic_vector (2*size-30 DOWNTO 0);
	signal s18    : std_logic_vector (2*size-30 DOWNTO 0);
	signal s19    : std_logic_vector (2*size-33 DOWNTO 0);
	signal s20    : std_logic_vector (2*size-33 DOWNTO 0);
	signal soma01 : std_logic_vector (2*size-6  DOWNTO 0);
	signal soma02 : std_logic_vector (2*size-9  DOWNTO 0);
	signal soma03 : std_logic_vector (2*size-12 DOWNTO 0);
	signal soma04 : std_logic_vector (2*size-15 DOWNTO 0);
	signal soma05 : std_logic_vector (2*size-18 DOWNTO 0);
	signal soma06 : std_logic_vector (2*size-21 DOWNTO 0);
	signal soma07 : std_logic_vector (2*size-24 DOWNTO 0);
	signal soma08 : std_logic_vector (2*size-27 DOWNTO 0);
	signal soma09 : std_logic_vector (2*size-30 DOWNTO 0);
	signal soma10 : std_logic_vector (2*size-33 DOWNTO 0);

begin	
	
	-- Multiplexador
	process (rst,xt1)
	begin
		if (rst = '1') then 
			d <= x0; -- se reset for ativado xt recebe o valor inicial x0
		else
			d <= xt1; -- se nao for ativado o reset, xt passa a valer xt1
		end if;
	end process;

	-- Registrador
	process (clk)
	begin
		if(clk'event and clk = '1') then
			if start ='0' then
				xt<=d;
			end if;
		end if;
	end process;
	
	-- Unidade aritmetica
	
	-- 1-xt
	sub: twocomp
		generic map(size)
		port map (
					n      => xt,
					result => eq1
					);
	
	-- multiplicacao por xt
	-- para alterar abrir o arquivo mult.vhd
	multplic: mult
		port map (
					dataa  => eq1,
					datab  => xt,
					result => eq2
					);
	
	-- mult. por mi (realimentacao original) 
	xt1 <= eq2(2*size-3 DOWNTO size-2);

	--multiplicacao por 4 feita em s1 e s2
	

	--mult. por 10 (k=1):
	
	s1 <= eq2(2*size-6 DOWNTO 0); 
	s2 <= eq2(2*size-4 DOWNTO 2);
	
	somaa: soma1
		generic map(2*size-6)
		port map (
					dataa  => s1,
					datab  => s2,
					result => soma01
		);
		


--mult. por 100 (k=2)
	
	s3 <= soma01(2*size-9 DOWNTO 0);
	s4 <= soma01(2*size-7 DOWNTO 2);
	
	somaB: soma1
		generic map(2*size-9)
		port map (
					dataa  => s3,
					datab  => s4,
					result => soma02
		);


--mult. por 1000 (k=3)

	s5 <= soma02(2*size-12 DOWNTO 0);
	s6 <= soma02(2*size-10 DOWNTO 2);

	somaC: soma1
		generic map(2*size-12)
		port map (
					dataa  => s5,
					datab  => s6,
					result => soma03
		);
	

	
--mult por 10000 (k=4)
	s7 <= soma03(2*size-15 DOWNTO 0);
	s8 <= soma03(2*size-13 DOWNTO 2);

	somaD: soma1
		generic map(2*size-15)
		port map (
					dataa  => s7,
					datab  => s8,
					result => soma04
		);

	
--mult. por 100000 (k=5)

	s9  <= soma04(2*size-18 DOWNTO 0);
	s10 <= soma04(2*size-16 DOWNTO 2);
	
	somaE: soma1
		generic map(2*size-18)
		port map (
					dataa  => s9,
					datab  => s10,
					result => soma05
		);
		
-- mult. por 1000000 (k=6)

	s11 <= soma05(2*size-21 DOWNTO 0);
	s12 <= soma05(2*size-19 DOWNTO 2);

	somaF: soma1
		generic map(2*size-21)
		port map (
					dataa  => s11,
					datab  => s12,
					result => soma06
		);
		
--mult por 10^7 (k=7)

	s13 <= soma06(2*size-24 DOWNTO 0);
	s14 <= soma06(2*size-22 DOWNTO 2);

	somaG: soma1
		generic map(2*size-24)
		port map (
					dataa  => s13,
					datab  => s14,
					result => soma07
		);
		
--mult por 10^8 (k=8)

	s15 <= soma07(2*size-27 DOWNTO 0);
	s16 <= soma07(2*size-25 DOWNTO 2);

	somaH: soma1
		generic map(2*size-27)
		port map (
					dataa  => s15,
					datab  => s16,
					result => soma08
		);
		
--mult por 10^9 (k=9)

	s17 <= soma08(2*size-30 DOWNTO 0);
	s18 <= soma08(2*size-28 DOWNTO 2);

	somaI: soma1
		generic map(2*size-30)
		port map (
					dataa  => s17,
					datab  => s18,
					result => soma09
		);
		
--mult por 10^10 (k=10)

	s19 <= soma09(2*size-33 DOWNTO 0);
	s20 <= soma09(2*size-31 DOWNTO 2);

	somaJ: soma1
		generic map(2*size-33)
		port map (
					dataa  => s19,
					datab  => s20,
					result => soma10
		);
	
	
	-- k=0 (mapa original)
	--xt_out <= xt1; 
	
	--k=1
	--xt_out <= soma01(2*size-6 DOWNTO size-5);

	
	--k=2
	--xt_out <= soma02(2*size-9 DOWNTO size-8);
  

	--k=3
	--xt_out <= soma03(2*size-12 DOWNTO size-11);
	
	
	--k=4
	--xt_out <= soma04(2*size-15 DOWNTO size-14);
	
	
	--k=5
	--xt_out <= soma05(2*size-18 DOWNTO size-17);
	  

	--k=6
	--xt_out <= soma06(2*size-21 DOWNTO size-20);
 

	--k=7
	--xt_out <= soma07(2*size-24 DOWNTO size-23);


	--k=8
	--xt_out <= soma08(2*size-27 DOWNTO size-26);
	

	--k=9
	--xt_out <= soma09(2*size-30 DOWNTO size-29);
	

	--k=10
	xt_out <= soma10(2*size-33 DOWNTO size-32);
	
	
	
	
	
	
end archmap;
	