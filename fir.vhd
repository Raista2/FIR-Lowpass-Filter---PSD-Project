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
        output_signal : out std_logic_vector(15 downto 0)
    );
end entity simple_fir;

architecture rtl of simple_fir is
    -- Design a 6 kHz lowpass filter with MATLAB coefficients
    type coeff_array is array(0 to 8) of signed(17 downto 0);
    constant COEFFS : coeff_array := (
        to_signed(integer(-0.0024 * 2**17), 18), -- -0.0024
        to_signed(integer(0.0073 * 2**17), 18),  --  0.0073
        to_signed(integer(0.0606 * 2**17), 18),  --  0.0606
        to_signed(integer(0.1691 * 2**17), 18),  --  0.1691
        to_signed(integer(0.2654 * 2**17), 18),  --  0.2654 (center)
        to_signed(integer(0.1691 * 2**17), 18),  --  0.1691
        to_signed(integer(0.0606 * 2**17), 18),  --  0.0606
        to_signed(integer(0.0073 * 2**17), 18),  --  0.0073
        to_signed(integer(-0.0024 * 2**17), 18)  -- -0.0024
    );

    -- Delay line for input samples
    type delay_line_type is array(0 to 8) of signed(17 downto 0);
    signal delay_line : delay_line_type;

begin
    process(clk, reset)
        -- Declare accumulator as variable
        variable accumulator : signed(35 downto 0);
        variable temp_mult : signed(35 downto 0);
    begin
        if reset = '1' then
            -- Reset everything
            delay_line <= (others => (others => '0'));
            output_signal <= (others => '0');
        elsif rising_edge(clk) then
            -- Shift delay line
            for i in 8 downto 1 loop
                delay_line(i) <= delay_line(i-1);
            end loop;
            -- Sign extend input to match delay line width
            delay_line(0) <= resize(signed(input_signal), 18);

            -- Compute FIR filter (direct form)
            accumulator := (others => '0');
            for i in 0 to 8 loop
                temp_mult := delay_line(i) * COEFFS(i);
                accumulator := accumulator + temp_mult;
            end loop;

            -- Scale and output (right shift to reduce precision)
            output_signal <= std_logic_vector(resize(shift_right(accumulator, 17), 16));
        end if;
    end process;
end architecture rtl;