library IEEE;
use IEEE.std_logic_1164.all;

package state_mapping_pkg is
    -- State enumeration type
    type state_type is (idle, load, compute, output_result);
    
    -- Function to convert state to string
    function get_state_name(state : state_type) return string;
end package state_mapping_pkg;

package body state_mapping_pkg is
    -- Implementation of the state-to-string function
    function get_state_name(state : state_type) return string is
    begin
        case state is
            when idle           => return "idle";
            when load           => return "load";
            when compute        => return "compute";
            when output_result  => return "output_result";
            when others         => return "unknown"; -- Optional for safety
        end case;
    end function;
end package body state_mapping_pkg;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use work.state_mapping_pkg.all;  -- Use the state mapping package

entity simple_fir_tb is
end entity simple_fir_tb;

architecture testbench of simple_fir_tb is
    -- Simulation parameters
    constant SAMPLE_RATE : real := 500_000.0;  -- 500 kHz sampling rate
    constant CLK_PERIOD : time := 10 ns;

    -- Signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal input_signal : std_logic_vector(15 downto 0);
    signal output_signal : std_logic_vector(15 downto 0);
    signal sine_1kHz : std_logic_vector(15 downto 0);
    signal sine_15kHz : std_logic_vector(15 downto 0);
    signal current_state : state_type := idle;
    signal state_out_tb : std_logic_vector(1 downto 0) := (others => '0');

begin
    -- Clock generation process
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- Device Under Test (DUT)
    dut: entity work.simple_fir
        port map (
            clk          => clk,
            reset        => reset,
            input_signal => input_signal,
            sine_1kHz    => sine_1kHz,
            sine_15kHz   => sine_15kHz,
            output_signal => output_signal,
            state_out    => state_out_tb
        );

    -- Convert the DUT's state_out to the local enumerated type
    state_decoder: process(state_out_tb)
    begin
        current_state <= state_type'val(to_integer(unsigned(state_out_tb)));
    end process;

    -- Stimulus process to generate input signals
    stimulus: process
        variable low_freq_amp : real := 32767.0 * 0.8;  -- 1 kHz sine wave amplitude
        variable high_freq_amp : real := 32767.0 * 0.2;  -- 15 kHz sine wave amplitude
        variable t : real := 0.0;
    begin
        -- Initial reset
        reset <= '1';
        input_signal <= (others => '0');
        wait for CLK_PERIOD * 3;

        -- Release reset
        reset <= '0';

        -- Generate test signals
        for i in 0 to 2000 loop
            -- Calculate time
            t := real(i) / SAMPLE_RATE;

            -- Create input signal: 1 kHz + 15 kHz sine waves
            input_signal <= std_logic_vector(to_signed(
                integer(
                    low_freq_amp * sin(2.0 * MATH_PI * 1000.0 * t) +  -- 1 kHz sine wave
                    high_freq_amp * sin(2.0 * MATH_PI * 15000.0 * t)  -- 15 kHz sine wave
                ),
                16
            ));

            -- Generate individual sine waves for analysis
            sine_1kHz <= std_logic_vector(to_signed(
                integer(low_freq_amp * sin(2.0 * MATH_PI * 1000.0 * t)),
                16
            ));

            sine_15kHz <= std_logic_vector(to_signed(
                integer(high_freq_amp * sin(2.0 * MATH_PI * 15000.0 * t)),
                16
            ));

            -- Wait for next clock cycle
            wait for CLK_PERIOD;
        end loop;

        -- End simulation
        wait;
    end process;

    -- Monitoring FSM state and output signals
    monitor: process
    begin
        wait for CLK_PERIOD;
        report "Simulation started";
        while true loop
            wait for CLK_PERIOD;

            -- Report FSM state and output signal
            report "FSM State: " & get_state_name(current_state);
            report "Output Signal: " & integer'image(to_integer(signed(output_signal)));
        end loop;
    end process;

end architecture testbench;