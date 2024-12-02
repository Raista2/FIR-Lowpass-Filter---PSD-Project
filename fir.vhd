library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fir is
    port (
        clk : in std_logic;
        noisy_signal : in std_logic_vector(15 downto 0);
        filtered_signal : out std_logic_vector(15 downto 0)
    );
end entity fir;

architecture arch of fir is
    type coeff_type is array(0 to 8) of integer signed(15 downto 0);
    signal coeff : coeff_type := (X"04F6", X"0AE4", X"1089",X"1496", X"160F", X"1496", X"1089", X"0AE4", X"04F6");
    type delayed_signal_type is array(0 to 8) of signed(15 downto 0);
    type prod_type is array(0 to 8) of signed(31 downto 0);
    type sum_0_type is array(0 to 4) of signed(32 downto 0);
    type sum_1_type is array(0 to 2) of signed(33 downto 0);
    type sum_2_type is array(0 to 1) of signed(34 downto 0);

    signal delayed_signal : delayed_signal_type := (others => (others => '0'));
    signal prod : prod_type := (others => (others => '0'));
    signal sum_0 : sum_0_type := (others => (others => '0'));
    signal sum_1 : sum_1_type := (others => (others => '0'));
    signal sum_2 : sum_2_type := (others => (others => '0'));
    signal sum_3 : signed(35 downto 0) := (others => '0');
begin
    
    proccess (clk)
    begin
        if rising_edge(clk) then
            delayed_signal(0) <= noisy_signal;
            for i in 1 to 8 loop
                delayed_signal(i) <= delayed_signal(i-1);
            end loop;

            for i in 0 to 8 loop
                prod(i) <= delayed_signal(i) * coeff(i);
            end loop;

            sum_0(0) <= (prod(0)(31) & prod(0)) + (prod(1)(31) & prod(1));
            sum_0(1) <= (prod(2)(31) & prod(2)) + (prod(3)(31) & prod(3));
            sum_0(2) <= (prod(4)(31) & prod(4)) + (prod(5)(31) & prod(5));
            sum_0(3) <= (prod(6)(31) & prod(6)) + (prod(7)(31) & prod(7));
            sum_0(4) <= (prod(8)(31) & prod(8));

            sum_1(0) <= (sum_0(0)(32) & sum_0(0)) + (sum_0(1)(32) & sum_0(1));
            sum_1(1) <= (sum_0(2)(32) & sum_0(2)) + (sum_0(3)(32) & sum_0(3));
            sum_1(2) <= (sum_0(4)(32) & sum_0(4));

            sum_2(0) <= (sum_1(0)(33) & sum_1(0)) + (sum_1(1)(33) & sum_1(1));
            sum_2(1) <= (sum_1(2)(33) & sum_1(2));

            sum_3 <= (sum_2(0)(34) & sum_2(0)) + (sum_2(1)(34) & sum_2(1));

            filtered_signal <= std_logic_vector(sum_3(15 downto 0));
        end if;
    end process;
end architecture arch;