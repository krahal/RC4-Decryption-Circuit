
module FSM2a (
input logic clk,							// Clock
input logic task2a_start,				// FSM1c sends a finish signal to start this FSM
input logic [23:0] SW,					
input logic [7:0] mem_data,			// Q from RAM
input logic master_reset,

output logic [7:0] address_out,		// Sends to RAM for Q or for write
output logic [7:0] data_out,			// Sends to RAM for rewriting data_out
output logic write_out,					// wren, 0 or 1 for read and write
output logic done							// Signalling that it is done and onto the next FSM
);

parameter [4:0] IDLE 		= 5'b00000; 	// Wait for task2a_start (FSM1c done signal)
parameter [4:0] GET_SI	 	= 5'b00001;		// Send request for s[i]
parameter [4:0] WAIT1  	   = 5'b00010;		
parameter [4:0] WAIT2		= 5'b00011;	
parameter [4:0] CALC		   = 5'b00100;		// Calculate J using J, s[i], and case statement for mod <save s[i]>
parameter [4:0] GET_SJ		= 5'b00101;		// Send request for s[j]
parameter [4:0] WAIT3		= 5'b00110;
parameter [4:0] WAIT4		= 5'b00111;
parameter [4:0] SAVE_JS		= 5'b01000;		// Save s[j] for future swap 
parameter [4:0] SWAP_JI		= 5'b01001;		// Swap - write s[i] into address J 
parameter [4:0] WAIT5		= 5'b01010;
parameter [4:0] WAIT6		= 5'b01011;

parameter [4:0] WAITx		= 5'b10001;

parameter [4:0] SWAP_IJ		= 5'b01100; 	// Swap - write s[j] (variable saved) into i
parameter [4:0] WAIT7		= 5'b01101;
parameter [4:0] WAIT8		= 5'b01110;

parameter [4:0] WAITy		= 5'b10010;

parameter [4:0] INC			= 5'b01111;		// Increment counter
parameter [4:0] FINISH		= 5'b10000;


logic [2:0] key_mod;		// Variable for mod
logic [4:0] state;		// State variable
logic [7:0] j_index;		// j index value	
logic [7:0] saved_si;	// Saving value of s[i]
logic [7:0] saved_sj; 	// Saving value of s[j]
logic [8:0] i_index; 	// 255 = 0_1111_1111 also i (this was counter before)
logic [23:0] scrt_key;	// Done with SWITCHES

assign scrt_key = SW;
 
always_ff @(posedge clk)
	begin
	if (!task2a_start) begin
					state <= IDLE;
					i_index <= 9'b0_0000_0000;
					j_index <= 8'b0000_0000;
				
					address_out <= 8'b0000_0000;
					data_out <= 8'b0000_0000;
					write_out <= 1'b0;
					done <= 1'b0;
					end
	else
	 begin
	 case (state) 
	 IDLE:		begin
					state <= GET_SI;
					i_index <= 9'b0_0000_0000;
					j_index <= 8'b0000_0000;
					
					data_out <= 8'b0000_0000;
					address_out <= 8'b0000_0000;
					write_out <= 1'b0;
					done <= 1'b0;
					end
	 
	 GET_SI:		if (i_index >= 9'b1_0000_0000) begin
					state <= FINISH;
					end 
					else begin
					state <= WAIT1;
					
					data_out <= 8'b0000_0000;
					address_out <= i_index[7:0];
					write_out <= 1'b0;
					done <= 1'b0;
					end
	 
	 WAIT1:		state <= WAIT2;
	 
	 WAIT2:		begin
					state <= CALC;
					key_mod <= (i_index[7:0])%3;
					end
	 
	 CALC: 		begin
					if (key_mod == 0) begin
								j_index <= (j_index + mem_data + scrt_key[23:16]);
								state <= GET_SJ;
								saved_si <= mem_data;
								end
					else if (key_mod == 1) begin
								j_index <= (j_index + mem_data + scrt_key[15:8]);
								state <= GET_SJ;
								saved_si <= mem_data;
								end
					else begin
								j_index <= (j_index + mem_data + scrt_key[7:0]);
								state <= GET_SJ;
								saved_si <= mem_data;
								end
					end
					
	 GET_SJ:		begin
					state <= WAIT3;
					data_out <= 8'b0000_0000;
					address_out <= j_index;
					write_out <= 1'b0;
					end
					
	 WAIT3:		state <= WAIT4;
	 
	 WAIT4:		state <= SAVE_JS;
	 
	 SAVE_JS:	begin
					state <= SWAP_JI;
					saved_sj <= mem_data;
					end
					
	 SWAP_JI:	begin
					state <= WAIT5;
					address_out <= i_index;
					data_out <= saved_sj;
					write_out <= 1'b1;
					end
					
	 WAIT5:		state <= WAIT6;
	 
	 WAIT6:		state <= WAITx;
	 
	 WAITx:		state <= SWAP_IJ;
	 
	 SWAP_IJ:	begin
					state <= WAIT7;
					address_out <= j_index;
					data_out <= saved_si;
					write_out <= 1'b1;
					end
	 
	 WAIT7:		state <= WAIT8;
	 
	 WAIT8:		state <= WAITy;
	 
	 WAITy:		state <= INC;
	 
	 INC: 		begin
					state <= GET_SI;
					i_index <= i_index + 1;
					end
	 
	 FINISH:		begin
					if (master_reset == 1'b0) begin
					state <= FINISH;
					data_out <= 8'b0000_0000;
					address_out <= 8'b0000_0000;
					write_out <= 1'b0;
					done <= 1'b1;
					end
					else begin
					state <= IDLE;
					data_out <= 8'b0000_0000;
					address_out <= 8'b0000_0000;
					write_out <= 1'b0;
					done <= 1'b0;
					end
					end
					
	 default:	begin
					state <= IDLE;
					i_index <= 8'b0000_0000;
					j_index <= 8'b0000_0000;
					saved_si <= 8'b0000_0000;
					saved_sj <= 8'b0000_0000;
					
					data_out <= 8'b0000_0000;
					address_out <= 8'b0000_0000;
					write_out <= 1'b0;
					done <= 1'b0;
					end
	endcase
	end
	end
	
	
endmodule