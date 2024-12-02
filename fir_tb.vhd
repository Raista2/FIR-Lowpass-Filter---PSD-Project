library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fir_tb is
end entity fir_tb;

architecture arch of fir_tb is

constant CORDIC_CLK_PERIOD : time := 2 ns;
constant FIR_CLK_PERIOD : time := 10 ns;
constant PI_POS : signed(15 downto 0) := X"6488";
constant PI_NEG : signed(15 downto 0) := X"9878";
constant PHASE_INC_2MHZ : integer := 200;
constant PHASE_INC_30MHZ : integer := 3000;

signal cordic_clk : std_logic := '0';
signal fir_clk : std_logic := '0';
signal phase_tvalid : std_logic := '0';
signal phase_2MHz : signed(15 downto 0) := (others => '0');
signal phase_30MHz : signed(15 downto 0) := (others => '0');
signal sincos_2MHz_tvalid : std_logic ;
signal sin_2MHz, cos_2MHz : signed(15 downto 0);
signal sincos_30MHz_tvalid : std_logic ;
signal sin_30MHz, cos_30MHz : signed(15 downto 0);
signal noisy_signal : signed(15 downto 0);
signal filtered_signal : signaed(15 downto 0);

begin 
    cordic_inst_0: entity work.cordic_0
        port map (
            aclk => cordic_clk,
            s_axis_phase_tvalid => phase_tvalid,
            s_axis_phase_tdata => std_logic(phase_2MHz),
            m_axis_dout_tvalid => sincos_2MHz_tvalid,
            m_axis_dout_tdata(31 downto 16) => sin_2MHz,
            m_axis_dout_tdata(15 downto 0) => cos_2MHz
        );

    cordic_inst_1: entity work.cordic_0
        port map (
            aclk => cordic_clk,
            s_axis_phase_tvalid => phase_tvalid,
            s_axis_phase_tdata => std_logic(phase_30MHz),
            m_axis_dout_tvalid => sincos_30MHz_tvalid,
            m_axis_dout_tdata(31 downto 16) => sin_30MHz,
            m_axis_dout_tdata(15 downto 0) => cos_30MHz
        );

process (cordic_clk)
begin
    if rising_edge(cordic_clk) then
        phase_tvalid <= '1';

        if (phase_2MHz + PHASE_INC_2MHZ < PI_POS) then
            phase_2MHz <= phase_2MHz + PHASE_INC_2MHZ;
        else
            phase_2MHz <= PI_NEG + (phase_2MHz + PHASE_INC_2MHZ - PI_POS);
        end if;

        if(phase_30MHz + PHASE_INC_30MHZ < PI_POS) then
            phase_30MHz <= phase_30MHz + PHASE_INC_30MHZ;
        else
            phase_30MHz <= PI_NEG + (phase_30MHz + PHASE_INC_30MHZ - PI_POS);
        end if;

    end if;
end process;

process
begin
    cordic_clk <= '0';
    wait for CORDIC_CLK_PERIOD/2;
    cordic_clk <= '1';
    wait for CORDIC_CLK_PERIOD/2;
end process;

process
begin
    fir_clk <= '0';
    wait for FIR_CLK_PERIOD/2;
    fir_clk <= '1';
    wait for FIR_CLK_PERIOD/2;
end process;

process (fir_clk)
begin
    if rising_edge(fir_clk) then
        noisy_signal <= (signed(sin_2MHz) + sign(sin_30MHz))/2;
    end if;
end process;

fir_inst: entity work.fir
    port map (
        clk => fir_clk,
        noisy_signal => noisy_signal,
        filtered_signal => filtered_signal
    );

end architecture arch;