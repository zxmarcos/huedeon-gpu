`include "fixedpt.vh"
// Texture unit
module RasterPipelineEX3(
  input                   i_clk,
  input                   i_write_enable,
  input signed [15:0]     i_x_pos,
  input signed [15:0]     i_y_pos,
  input `FIXPT            i_w1,
  input `FIXPT            i_w2,
  input `FIXPT            i_w3,
  input [7:0]        			i_r,
  input [7:0]        			i_g,
  input [7:0]        			i_b,
  input `FIXPT			      i_v1_u,
  input `FIXPT			      i_v1_v,
  input `FIXPT			      i_v2_u,
  input `FIXPT			      i_v2_v,
  input `FIXPT			      i_v3_u,
  input `FIXPT			      i_v3_v,
  output reg              o_write_pixel,
  output reg signed[15:0] o_x,
  output reg signed[15:0] o_y,
  output reg [7:0]        o_r,
  output reg [7:0]        o_g,
  output reg [7:0]        o_b
);
	
	parameter PIPELINE_WIDTH = 4;
  wire valid;

  reg signed [15:0] x_pipe[0:PIPELINE_WIDTH];
  reg signed [15:0] y_pipe[0:PIPELINE_WIDTH];
  reg [7:0] r_pipe[0:PIPELINE_WIDTH];
  reg [7:0] g_pipe[0:PIPELINE_WIDTH];
  reg [7:0] b_pipe[0:PIPELINE_WIDTH];

  integer i;
  always @(posedge i_clk)
  begin
  	if (i_write_enable)
  	begin
  		r_pipe[0] <= i_r;
  		g_pipe[0] <= i_g;
  		b_pipe[0] <= i_b;
  		x_pipe[0] <= i_x_pos;
  		y_pipe[0] <= i_y_pos;
  	end
  	for (i = 1; i <= PIPELINE_WIDTH; i = i + 1)
  	begin
  		r_pipe[i] <= r_pipe[i - 1];
  		g_pipe[i] <= g_pipe[i - 1];
  		b_pipe[i] <= b_pipe[i - 1];
  		x_pipe[i] <= x_pipe[i - 1];
			y_pipe[i] <= y_pipe[i - 1];
  	end
  end

  pipeline_ctrl #(PIPELINE_WIDTH) pc(
    .i_clk      (i_clk),
    .i_enable   (i_write_enable),
    .o_ack      (valid)
  );

  wire [7:0] clut_index;
  wire [15:0] texel_address;

  wire `FIXPT u_v1_value_fixpt;
  wire `FIXPT u_v2_value_fixpt;
  wire `FIXPT u_v3_value_fixpt;

  wire `FIXPT v_v1_value_fixpt;
  wire `FIXPT v_v2_value_fixpt;
  wire `FIXPT v_v3_value_fixpt;

  Interpolator u_interp_v1(.i_a(i_v1_u), .i_w(i_w2), .o_res(u_v1_value_fixpt));
  Interpolator u_interp_v2(.i_a(i_v2_u), .i_w(i_w3), .o_res(u_v2_value_fixpt));
  Interpolator u_interp_v3(.i_a(i_v3_u), .i_w(i_w1), .o_res(u_v3_value_fixpt));
  Interpolator v_interp_v1(.i_a(i_v1_v), .i_w(i_w2), .o_res(v_v1_value_fixpt));
  Interpolator v_interp_v2(.i_a(i_v2_v), .i_w(i_w3), .o_res(v_v2_value_fixpt));
  Interpolator v_interp_v3(.i_a(i_v3_v), .i_w(i_w1), .o_res(v_v3_value_fixpt));

  wire `FIXPT tex_x_fp = u_v1_value_fixpt + u_v2_value_fixpt + u_v3_value_fixpt;
  wire `FIXPT tex_y_fp = v_v1_value_fixpt + v_v2_value_fixpt + v_v3_value_fixpt;

  wire [15:0] tex_x = `FIXPT_TO_INT(tex_x_fp);
  wire [15:0] tex_y = `FIXPT_TO_INT(tex_y_fp);
  wire [7:0] tex_r;
  wire [7:0] tex_g;
  wire [7:0] tex_b;

  reg [15:0] texel_address_ff;
  reg [7:0] clut_index_ff;

  always @(posedge i_clk)
  begin
  	if (i_write_enable)
  	begin
  		texel_address_ff <= texel_address;
  	end
  	clut_index_ff <= clut_index;
  end

  TextureUnit texel_unit(
    .i_clk            (i_clk),
    .i_x              (tex_x),
    .i_y              (tex_y),
    .o_address        (texel_address)
  );

  TextureRAM tex_ram(
    .i_clk            (i_clk),
    .i_address        (texel_address_ff),
    .i_data           (8'b0),
    .i_write_enable   (1'b0),
    .o_data           (clut_index)
  );

  ColorLutRAM clut_ram(
    .i_clk            (i_clk),
    .i_entry          (clut_index_ff),
    .i_data           (8'b0),
    .i_write_enable   (1'b0),
    .o_r              (tex_r),
    .o_g              (tex_g),
    .o_b              (tex_b)
  );

  always @(posedge i_clk)
  begin
    if (valid)
    begin
      o_write_pixel <= 1;
      o_x <= x_pipe[PIPELINE_WIDTH];
      o_y <= y_pipe[PIPELINE_WIDTH];
      o_r <= `SATURATE(8'd0, 8'd255, (r_pipe[PIPELINE_WIDTH] + {1'b0, tex_r}));
      o_g <= `SATURATE(8'd0, 8'd255, (g_pipe[PIPELINE_WIDTH] + {1'b0, tex_g}));
      o_b <= `SATURATE(8'd0, 8'd255, (b_pipe[PIPELINE_WIDTH] + {1'b0, tex_b}));
    end
    else
    begin
      o_write_pixel <= 0;
      o_x <= 32'bx;
			o_y <= 32'bx;
			o_r <= 32'bx;
			o_g <= 32'bx;
			o_b <= 32'bx;
    end
  end

endmodule
