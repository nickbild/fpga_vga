module ram1024 (din, addr, write_en, mem_clk, dout);  // 1024x4
  parameter addr_width = 10;
  parameter addr_depth = 1024;
  parameter data_width = 4;

  input [addr_width-1:0] addr;
  input [data_width-1:0] din;
  input write_en, mem_clk;
  output [data_width-1:0] dout;

  reg [data_width-1:0] dout; // Register for output.
  // reg [data_width-1:0] mem [(1<<addr_width)-1:0];
  reg [data_width-1:0] mem [0:addr_depth-1];

  // Initialize memory.
  // integer i;
  // initial begin
  //   for (i=0; i<addr_depth; i=i+1)
  //   begin
  //     mem[i] <= 4'b1111;
  //   end
  // end

  always @(posedge mem_clk)
  begin
    if (write_en) begin
      mem[addr] <= din;
    end
    dout = mem[addr]; // Output register controlled by clock.
  end
endmodule
