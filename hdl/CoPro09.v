`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:26:16 05/23/2018 
// Design Name: 
// Module Name:    C6409 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module CoPro09(
               input _reset,
               input clock, 
               input dotclk,
               input clk_mult,
               input r_w,
               input [2:1]_io,
               output _exrom,
               output _game,
               input [15:0]address_cpu, 
               inout [7:0]data_cpu,
               output _enbus,
               output reg [18:0]address_mem,
               inout [7:0]data_mem,
               output reg _we_mem,
               output reg _ce_ram,
               output reg _ce_dat,
               output [1:0]clk_cfg,
               output _reset_09,
               output clock_e,
               output clock_q,
               input [15:13]address_09,
               input r_w_09,
               //input busy_09,
               //input bs_09,
               //input avma_09,
               //input lic_09,
               output _irq_09,
               output _nmi_09,
               output _firq_09,
               output _halt_09,
               //input sw0,
               output led,
               output [7:0]test
              );
wire ce_regbase;
wire ce_config;
reg [2:0]ctr;
reg clock_prev;
reg [7:0]data_cpu_out;
reg [7:0]data_mem_out;
wire [6:0]page;

assign test[0] =              clock;assign test[1] =              dotclk;assign test[2] =              clock_q;assign test[3] =              clock_e;assign test[4] =              dotclk;assign test[5] =              dotclk;assign test[6] =              dotclk;assign test[7] =              dotclk;


assign ce_regbase =        !_io[2] & (address_cpu[7:4] == 4'hf) & (address_cpu[3:2] == 2'b11);
assign ce_config =         ce_regbase & (address_cpu[1:0] == 0);
assign ce_page =           ce_regbase & (address_cpu[1:0] == 1);
//assign ce_task_page =      ce_regbase & (address_cpu[1:0] == 2);
//assign ce_extra =          ce_regbase & (address_cpu[1:0] == 3);
assign _enbus =            !(_reset_09 & _halt_09 & clock_e); // for now, it's active on low half of phi2
assign clock_e =           !clock;
assign clk_cfg =           2'b11; // *8
assign _game =             'bz;
assign _exrom =            'bz;
assign data_cpu =          data_cpu_out;assign data_mem =          data_mem_out;
assign clock_q =           (ctr[2] ^ ctr[1]);
assign _irq_09 =           1;
assign _nmi_09 =           1;
assign _firq_09 =          1;

register #(.WIDTH(1))      reg_led(clock, !_reset, ce_config & !r_w, data_cpu[0], led);
register #(.WIDTH(1))      reg_reset(clock, !_reset, ce_config & !r_w, data_cpu[7], _reset_09);
register #(.WIDTH(1))      reg_halt(clock, !_reset, ce_config & !r_w, data_cpu[6], _halt_09);

register #(.WIDTH(7))      reg_page(clock, !_reset, ce_page & !r_w, data_cpu[6:0], page);

always @(*)
begin
   if(clock_e)
      _we_mem = r_w_09;
   else
      _we_mem = r_w;
end

always @(*)
begin
   if(!_io[1] & clock)
      _ce_dat = 0;
   else if(!clock)
      _ce_dat = 0;
   else
      _ce_dat = 1;
end

always @(*)
begin
   if (clock & r_w & !_io[1])
      data_cpu_out = data_mem;
   else
      data_cpu_out = 8'bz;
end

always @(*)
begin
   if(clock & !r_w & !_io[1])
      data_mem_out = data_cpu;
   else
      data_mem_out = 8'bz;
end

always @(*)
begin
   if(clock & _io[1])
      address_mem = {page, address_cpu[7:0]};
   else
      address_mem = {6'b0,13'bz};
end

always @(negedge dotclk)
begin
   clock_prev <= clock;
end

always @(posedge dotclk)
begin
   if(!clock)
      if(clock_prev)
         ctr <= 0;
      else
         ctr <= ctr + 1;
   else
      ctr <= ctr + 1;
end

endmodule
