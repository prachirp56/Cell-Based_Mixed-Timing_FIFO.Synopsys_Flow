////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016, University of British Columbia (UBC)  All rights reserved. //
//                                                                                //
// Redistribution  and  use  in  source   and  binary  forms,   with  or  without //
// modification,  are permitted  provided that  the following conditions are met: //
//   * Redistributions   of  source   code  must  retain   the   above  copyright //
//     notice,  this   list   of   conditions   and   the  following  disclaimer. //
//   * Redistributions  in  binary  form  must  reproduce  the  above   copyright //
//     notice, this  list  of  conditions  and the  following  disclaimer in  the //
//     documentation and/or  other  materials  provided  with  the  distribution. //
//   * Neither the name of the University of British Columbia (UBC) nor the names //
//     of   its   contributors  may  be  used  to  endorse  or   promote products //
//     derived from  this  software without  specific  prior  written permission. //
//                                                                                //
// THIS  SOFTWARE IS  PROVIDED  BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" //
// AND  ANY EXPRESS  OR IMPLIED WARRANTIES,  INCLUDING,  BUT NOT LIMITED TO,  THE //
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE //
// DISCLAIMED.  IN NO  EVENT SHALL University of British Columbia (UBC) BE LIABLE //
// FOR ANY DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY, OR CONSEQUENTIAL //
// DAMAGES  (INCLUDING,  BUT NOT LIMITED TO,  PROCUREMENT OF  SUBSTITUTE GOODS OR //
// SERVICES;  LOSS OF USE,  DATA,  OR PROFITS;  OR BUSINESS INTERRUPTION) HOWEVER //
// CAUSED AND ON ANY THEORY OF LIABILITY,  WHETHER IN CONTRACT, STRICT LIABILITY, //
// OR TORT  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE //
// OF  THIS SOFTWARE,  EVEN  IF  ADVISED  OF  THE  POSSIBILITY  OF  SUCH  DAMAGE. //
////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////
//       vacancy.v: generate fifo vacancy / pipelined spaceav/datav signals       //
//   Author: Ameer M.S. Abdelhadi (ameer.abdelhadi@gmail.com; ameer@ece.ubc.ca)   //
// Cell-based Mixed FIFOs :: University of British Columbia (UBC) :: July 2016    //
////////////////////////////////////////////////////////////////////////////////////

// include configuration file; generated by scr/do; defines DATAWD, STAGES &  SYNCDP
`include "config.h"

module vacancy
  #( parameter          STAGES = `STAGES )  // number of FIFO stages
   ( input              rst              ,  // global reset 
     input              clk              ,  // clock for sender/receiver domain
     input              req              ,  // request (put/get)
     input [STAGES-1:0] vac_stgs         ,  // stages vacancy (write/read enables)
     output             vac_fifo         ); // fifo vacancy (spaveav/datav)

  wire [STAGES-1:0] vac_stgs_ror1 = {vac_stgs[  0],vac_stgs[STAGES-1:1]};
  wire [STAGES-1:0] vac_stgs_ror2 = {vac_stgs[1:0],vac_stgs[STAGES-1:2]};

// e   : e3 e2 e1 e0
// ror1: e0 e3 e2 e1
// ror2: e1 e0 e3 e2

  wire upd = req && vac_fifo;
  reg  upd_r;
  reg  upd_rr;

  wire stat_1slot = (|vac_stgs);
  wire stat_2slot = |(vac_stgs & vac_stgs_ror1);
  wire stat_3slot = |(vac_stgs & vac_stgs_ror1 &  vac_stgs_ror2);

  reg stat_1slot_r;
  reg stat_2slot_r;
  reg stat_3slot_r;

  reg stat_1slot_rr;
  reg stat_2slot_rr;
  reg stat_3slot_rr;

  always @(posedge clk or posedge rst)
    if (rst) stat_1slot_r <= 1'b0; else stat_1slot_r <= stat_1slot;
  always @(posedge clk or posedge rst)
    if (rst) stat_1slot_rr <= 1'b0; else stat_1slot_rr <= stat_1slot_r;

  always @(posedge clk or posedge rst)
    if (rst) stat_2slot_r <= 1'b0; else stat_2slot_r <= stat_2slot;
  always @(posedge clk or posedge rst)
    if (rst) stat_2slot_rr <= 1'b0; else stat_2slot_rr <= stat_2slot_r;

  always @(posedge clk or posedge rst)
    if (rst) stat_3slot_r <= 1'b0; else stat_3slot_r <= stat_3slot;
  always @(posedge clk or posedge rst)
    if (rst) stat_3slot_rr <= 1'b0; else stat_3slot_rr <= stat_3slot_r;

  always @(posedge clk or posedge rst)
    if (rst) upd_r <= 1'b0; else upd_r <= upd;
  always @(posedge clk or posedge rst)
    if (rst) upd_rr <= 1'b0; else upd_rr <= upd_r;


  assign vac_fifo = stat_3slot_rr || (stat_2slot_rr && !(upd_r && upd_rr)) || (stat_1slot_rr && !(upd_r || upd_rr));

endmodule // vacancy
