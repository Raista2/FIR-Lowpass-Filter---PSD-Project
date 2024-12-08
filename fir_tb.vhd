-- Updated simple_fir_tb.vhd
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity simple_fir_tb is
end entity simple_fir_tb;

architecture testbench of simple_fir_tb is
    -- Simulation parameters
    constant SAMPLE_RATE : real := 100_000.0;  -- 100 kHz sampling rate
    constant CLK_PERIOD : time := 10 ns;
    
    -- Signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal input_signal : std_logic_vector(15 downto 0);
    signal output_signal : std_logic_vector(15 downto 0);
    signal sine_1kHz : std_logic_vector(15 downto 0);
    signal sine_15kHz : std_logic_vector(15 downto 0);

begin
    -- Clock generation
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- Device Under Test (DUT)
    dut: entity work.simple_fir
        port map (
            clk => clk,
            reset => reset,
            input_signal => input_signal,
            sine_1kHz => sine_1kHz,
            sine_15kHz => sine_15kHz,
            output_signal => output_signal
        );
    
    -- Stimulus process
    stimulus: process
        variable low_freq_amp : real := 32767.0 * 0.8;  -- 1 kHz sine wave
        variable high_freq_amp : real := 32767.0 * 0.2;  -- 15 kHz sine wave
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

            wait for CLK_PERIOD;
        end loop;
        
        -- End simulation
        wait;
    end process;
end architecture testbench;