library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity simple_fir is
    port (
        clk : in std_logic;
        reset : in std_logic;
        input_signal : in std_logic_vector(15 downto 0);
        sine_15kHz : in std_logic_vector(15 downto 0);
        sine_1kHz : in std_logic_vector(15 downto 0);
        output_signal : out std_logic_vector(15 downto 0);
        state_out : out std_logic_vector(1 downto 0) -- Expose FSM state
    );
end entity simple_fir;


architecture rtl of simple_fir is
    type state_type is (idle, load, compute, output_result);
    signal current_state : state_type := idle;
    
    -- Coefficients and delay line
    type coeff_array is array(0 to 8) of signed(17 downto 0);
    constant COEFFS : coeff_array := (
        to_signed(integer(-0.0024 * 2**17), 18),
        to_signed(integer(0.0073 * 2**17), 18),
        to_signed(integer(0.0606 * 2**17), 18),
        to_signed(integer(0.1691 * 2**17), 18),
        to_signed(integer(0.2654 * 2**17), 18),
        to_signed(integer(0.1691 * 2**17), 18),
        to_signed(integer(0.0606 * 2**17), 18),
        to_signed(integer(0.0073 * 2**17), 18),
        to_signed(integer(-0.0024 * 2**17), 18)
    );

    type delay_line_type is array(0 to 8) of signed(17 downto 0);
    signal delay_line : delay_line_type := (others => (others => '0'));
    signal acc : signed(35 downto 0);
    signal mac_count : integer range 0 to 8;

begin
    process(clk, reset)
        variable temp_mult : signed(35 downto 0);
    begin
        if reset = '1' then
            current_state <= idle;
            delay_line <= (others => (others => '0'));
            acc <= (others => '0');
            output_signal <= (others => '0');
            mac_count <= 0;
        elsif rising_edge(clk) then
            case current_state is
                when idle =>
                    acc <= (others => '0');
                    mac_count <= 0;
                    current_state <= load;

                when load =>
                    -- Shift delay line
                    for i in 8 downto 1 loop
                        delay_line(i) <= delay_line(i-1);
                    end loop;
                    delay_line(0) <= resize(signed(input_signal), 18);
                    current_state <= compute;

                when compute =>
                    if mac_count = 0 then
                        -- First multiplication
                        temp_mult := delay_line(0) * COEFFS(0);
                        acc <= temp_mult;
                        mac_count <= mac_count + 1;
                    elsif mac_count < 8 then
                        -- Subsequent multiply-accumulate
                        temp_mult := delay_line(mac_count) * COEFFS(mac_count);
                        acc <= acc + temp_mult;
                        mac_count <= mac_count + 1;
                    else
                        -- Final multiply-accumulate
                        temp_mult := delay_line(8) * COEFFS(8);
                        acc <= acc + temp_mult;
                        current_state <= output_result;
                    end if;

                when output_result =>
                    output_signal <= std_logic_vector(resize(shift_right(acc, 17), 16));
                    current_state <= idle;

            end case;
        end if;
    end process;
    state_out <= std_logic_vector(to_unsigned(state_type'pos(current_state), 2));
end architecture rtl;