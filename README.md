# Simple FIR Filter Documentation

This documentation covers the implementation of a simple Finite Impulse Response (FIR) filter and its associated testbench for simulation. The FIR filter processes input signals to produce a filtered output using predefined coefficients.

---

## FIR Filter: `simple_fir`

### **Entity Declaration**
The `simple_fir` entity defines the input, output, and control signals for the FIR filter.

#### **Ports**
- **clk**: `in std_logic`  
  Clock signal for synchronous operations.
- **reset**: `in std_logic`  
  Resets the filter to its initial state.
- **input_signal**: `in std_logic_vector(15 downto 0)`  
  The input signal to the filter.
- **sine_15kHz**: `in std_logic_vector(15 downto 0)`  
  Reference 15 kHz sine wave.
- **sine_1kHz**: `in std_logic_vector(15 downto 0)`  
  Reference 1 kHz sine wave.
- **output_signal**: `out std_logic_vector(15 downto 0)`  
  Filtered output signal.
- **state_out**: `out std_logic_vector(1 downto 0)`  
  Exposed FSM state for debugging.

---

### **Architecture: `rtl`**
Implements the FIR filter logic using a finite state machine (FSM).

#### **Key Features**
- **FSM States**:
  - `idle`: Initialization and idle state.
  - `load`: Shifts the delay line and updates it with the latest input.
  - `compute`: Performs multiply-accumulate operations using filter coefficients.
  - `output_result`: Outputs the final filtered value.
  
- **Coefficients**: Predefined FIR filter coefficients stored in a constant array `COEFFS`.

- **Delay Line**: Stores the previous input samples for FIR processing.

- **Multiply-Accumulate (MAC)**: Sequential MAC operations to compute the filter output.

#### **Signals**
- `current_state`: Tracks the current FSM state.
- `delay_line`: Stores delayed input samples.
- `acc`: Accumulator for MAC operations.
- `mac_count`: Counter for MAC operations.

---

## Testbench: `simple_fir_tb`

### **Entity Declaration**
The testbench provides an environment to simulate the behavior of the `simple_fir` design under various input conditions.

### **Architecture: `testbench`
Simulates the `simple_fir` filter with a 100 kHz sampling rate.

#### **Key Features**
- **Clock Generation**: A process generates a clock signal with a 10 ns period.
- **Reset Logic**: Resets the FIR filter at the start of simulation.
- **Stimulus Generation**: Creates input signals combining 1 kHz and 15 kHz sine waves for testing.
- **State Monitoring**: Reports the current FSM state and filter output during simulation.

---

### **Packages**
1. **`state_mapping_pkg`**
   - Contains the FSM state type and a utility function `get_state_name` to map state enumeration to human-readable strings.

---

### **Processes**
#### 1. **Clock Process**
Generates a clock signal with a 10 ns period.

#### 2. **Stimulus Process**
- Generates test signals using sine waves:
  - **1 kHz**: 80% of the maximum amplitude.
  - **15 kHz**: 20% of the maximum amplitude.
- Combines the sine waves to create a composite input signal.

#### 3. **Monitoring Process**
- Reports FSM state using the `get_state_name` function.
- Outputs the filtered signal value as an integer.

---

### **Simulation Parameters**
- **SAMPLE_RATE**: `100_000.0 Hz` (100 kHz sampling rate).
- **CLK_PERIOD**: `10 ns`.

---

### **Usage**
1. Add the FIR filter design and testbench files to your VHDL project.
2. Compile the design and testbench using your simulation tool.
3. Run the testbench to verify the FIR filter behavior.
4. Analyze the simulation output for FSM transitions and signal values.

---

### **Expected Output**
- FSM states transition as per input signals.
- Filter output closely approximates the 1 kHz sine wave, attenuating the 15 kHz component.
![FIR Lowpass Filter Simulation](https://hackmd.io/_uploads/BkY2CBXEyx.jpg)

---

### **Module Used**
- Dataflow
- Behavorial
- Testbench
- Structural
- Looping
- Function
- FSM


---

### **Kelompok P-25**
- Ahmad Fariz Khairi (2306211370)
- Christover Angelo Lasut (2306220343)
- Muhammad Raihan Mustofa (2306161946)
- Ryan Adidaru Excel Barnabi (2306266994)
