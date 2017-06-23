`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: cfglut_gr
//////////////////////////////////////////////////////////////////////////////////


module cfglut_gr(
    input clk,
    input LD_ctrl,
    input result_ctrl,
    input [3:0] shield2cfg_data_in,
    input start,
    input [31:0] fn_init_value,
    output [3:0] cfg2shield_tri_out,
    output cfg2shield_data_o,
    output cfg2shield_tri_o,
    output LD
    );
    
   wire ce;
   wire CLR;
   wire LD_i;
   
   assign LD = (LD_ctrl==0) ? 1'b0 : LD_i;  // if LD_ctrl=0 then LD is not used; turn it OFF
   assign cfg2shield_tri_o = ~result_ctrl;  // if result_ctrl=0 then result is not used; enable tristate of the buffer
   assign cfg2shield_data_o = data_out;     // result output
   assign cfg2shield_tri_out = 4'b1111;     // tristate output buffers of the header/sw/led pins as they are being used as input only
   
   // Convert longer then 1 clocks pulse generated by GPIO write to one clock pulse
   FDCE #(
           .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
        ) FDCE_inst (
           .Q(Q1),      // 1-bit Data output
           .C(start),      // 1-bit Clock input
           .CE(1'b1),    // 1-bit Clock enable input
           .CLR(CLR),  // 1-bit Asynchronous clear input
           .D(1'b1)       // 1-bit Data input
        );

   FDCE #(
           .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
        ) FDCE_inst_1 (
           .Q(CLR),      // 1-bit Data output
           .C(clk),      // 1-bit Clock input
           .CE(1'b1),    // 1-bit Clock enable input
           .CLR(1'b0),  // 1-bit Asynchronous clear input
           .D(Q1)       // 1-bit Data input
        );

    cfglut_fsm fsm(
        .clk(clk), .start(CLR), .fn_init_value(fn_init_value), .cdi(cdi), .ce(ce), .done(done)
    );
    
    cfglut cfgbit0 (.clk(clk), .ce(ce), .data_in(shield2cfg_data_in), .CDI(cdi), .result(data_out));

    cfglut cfgbit1 (.clk(clk), .ce(ce), .data_in(shield2cfg_data_in), .CDI(cdi), .result(LD_i));
 
    
endmodule