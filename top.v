module top (
    // 16MHz clock
    input CLK,

    // USB pull-up resistor
    output USBPU,

    // GPIO Outputs.
    output PIN_8,
    output PIN_9,
    output PIN_10,
    // output PIN_11,  Pin looks to be dead.
    output PIN_12,
    output PIN_13,

    // GPIO Inputs.
    input PIN_1,
    input PIN_2,
    input PIN_3,
    input PIN_4,
    input PIN_5,
    input PIN_6,
    input PIN_7,
    input PIN_14,
    input PIN_15,
    input PIN_16,
    input PIN_17,
    input PIN_18,
    input PIN_19,
    input PIN_20,
    input PIN_21,
    input PIN_22,
    input PIN_23,
    input PIN_24,
    input PIN_31
);

    // drive USB pull-up resistor to '0' to disable USB
    assign USBPU = 0;

    // VGA output signals.
    wire clk_10mhz;
    assign PIN_8 = red;
    assign PIN_9 = green;
    assign PIN_10 = blue;
    assign PIN_12 = h_sync;
    assign PIN_13 = v_sync;

    reg [8:0] h_counter;
    reg [0:0] h_sync;

    reg [9:0] v_counter;
    reg [0:0] v_sync;

    reg [0:0] red;
    reg [0:0] green;
    reg [0:0] blue;

    // Interrupt input.
    wire interrupt;
    assign interrupt = PIN_31;

    // Address inputs.
    wire a0;
    wire a1;
    wire a2;
    wire a3;
    wire a4;
    wire a5;
    wire a6;
    wire a7;
    wire a8;
    wire a9;
    wire a10;
    wire a11;
    wire a12;
    wire a13;
    wire a14;

    assign a0 = PIN_1;
    assign a1 = PIN_2;
    assign a2 = PIN_3;
    assign a3 = PIN_4;
    assign a4 = PIN_5;
    assign a5 = PIN_6;
    assign a6 = PIN_7;
    assign a7 = PIN_14;
    assign a8 = PIN_15;
    assign a9 = PIN_16;
    assign a10 = PIN_17;
    assign a11 = PIN_18;
    assign a12 = PIN_19;
    assign a13 = PIN_20;
    assign a14 = PIN_21;

    reg [2:0] memory_array [0:30000];
    reg [14:0] address;

    // RGB data inputs.
    wire r_in;
    wire g_in;
    wire b_in;

    assign r_in = PIN_22;
    assign g_in = PIN_23;
    assign b_in = PIN_24;

    reg [2:0] rgb_in;

    // Create a 10MHz clock.
    // http://martin.hinner.info/vga/timing.html
    // 40 MHz = 800x600@60Hz
    // 10 MHz = 200x150
    SB_PLL40_CORE #(
      .DIVR(0),
      .DIVF(9),
      .DIVQ(4),
      .FILTER_RANGE(3'b001),
      .FEEDBACK_PATH("SIMPLE"),
      .DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
      .FDA_FEEDBACK(4'b0000),
      .DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
      .FDA_RELATIVE(4'b0000),
      .SHIFTREG_DIV_MODE(2'b00),
      .PLLOUT_SELECT("GENCLK"),
      .ENABLE_ICEGATE(1'b0)
    ) pll (
      .REFERENCECLK(CLK),
      .PLLOUTCORE(clk_10mhz),
      .RESETB(1),
      .BYPASS(0)
    );

    // Zero out display.
    initial begin
      $readmemb("memory_array.mem", memory_array);
    end

    // <= : every line executed in parallel in always block
    always @(posedge clk_10mhz) begin
        // Display pixel.
        if (h_counter > 199)  // Horizontal blanking.
      	begin
      	  red <= 0;
          green <= 0;
          blue <= 0;
      	end else if (v_counter > 599)  // Vertical blanking.
      	begin
      	  red <= 0;
          green <= 0;
          blue <= 0;
      	end else // Active video.
        begin
          red <= memory_array[h_counter + ((v_counter / 4) * 200)][0];
          green <= memory_array[h_counter + ((v_counter / 4) * 200)][1];
          blue <= memory_array[h_counter + ((v_counter / 4) * 200)][2];
        end

        // Horitonal sync.
        if (h_counter > 209 && h_counter < 242)
        begin
          h_sync <= 1;
        end else
        begin
          h_sync <= 0;
        end

        // Vertical sync.
        if (v_counter > 600 && v_counter < 605)
        begin
          v_sync <= 1;
        end else
        begin
          v_sync <= 0;
        end

        // Increment / reset counters.
        h_counter <= h_counter + 1'b1;

        if (h_counter == 264)
        begin
          h_counter <= 0;
          v_counter <= v_counter + 1'b1;
        end

        if (v_counter == 628)
        begin
          v_counter <= 0;
        end
    end

    // Load pixel data into memory.
    always @(posedge interrupt) begin
      // Convoluted method of concatenating GPIO pin bits to get an address -- keeps place and route
      // working without using too many LUs for the TinyFPGA.
      address = (a14 * 2**14) + (a13 * 2**13) + (a12 * 2**12) + (a11 * 2**11) + (a10 * 2**10) + (a9 * 2**9) + (a8 * 2**8);
      address = address + (a7 * 2**7) + (a6 * 2**6) + (a5 * 2**5) + (a4 * 2**4) + (a3 * 2**3) + (a2 * 2**2) + (a1 * 2**1) + (a0 * 2**0);

      rgb_in = (b_in * 2**2) + (g_in * 2**1) + (r_in * 2**0);

      memory_array[address] <= rgb_in;
    end

endmodule
