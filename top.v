module top (
    // 16MHz clock
    input CLK,

    // USB pull-up resistor
    output USBPU,

    // R1, G1, B1
    output PIN_1,
    output PIN_2,
    output PIN_3,
    output PIN_4,
    output PIN_5

);

    // drive USB pull-up resistor to '0' to disable USB
    assign USBPU = 0;

    wire clk_10mhz;
    assign PIN_1 = red;
    assign PIN_2 = green;
    assign PIN_3 = blue;
    assign PIN_4 = h_sync;
    assign PIN_5 = v_sync;

    reg [8:0] h_counter;
    reg [0:0] h_sync;

    reg [9:0] v_counter;
    reg [0:0] v_sync;

    reg [0:0] red;
    reg [0:0] green;
    reg [0:0] blue;

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

    reg [2:0] memory_array [0:30000];

    // Zero out display.
    initial begin
      $readmemb("memory_array.mem", memory_array);
    end

    // <= : every line executed in parallel in always block
    always @(posedge clk_10mhz) begin
        // memory_array[0] <= 3'b001;
        // memory_array[1] <= 3'b010;
        // memory_array[200] <= 3'b010;
        // memory_array[201] <= 3'b001;
        // memory_array[400] <= 3'b001;

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

endmodule
