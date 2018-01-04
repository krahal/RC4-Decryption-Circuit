module FSM2b (
input logic clk,								// Clock
input logic task2b_start,					// FSM2a sends a finish signal to start this FSM
input logic [7:0] q_RAM1,			// Q from RAM1

output logic [7:0] address_out_RAM1,		// Sends to RAM for Q or for write
output logic [7:0] data_to_RAM1,			// Sends to RAM for rewriting data_out
output logic wren_to_RAM1,					// wren, 0 or 1 for read and write
output logic done,								// Signalling that it is done and onto the next FSM

// I/O for ROM and Second RAM 
input logic [7:0] ROM_data,					// Data from ROM
output logic [4:0] address_ROM,				// Sends to ROM for data @ address 

output logic [4:0] address_out_RAM2,		// Sends to Second RAM for Q or for write
output logic [7:0] data_to_RAM2,			// Sends to Second RAM for rewriting data_out
output logic wren_to_RAM2,					// wren for decrypted message RAM
input logic master_reset
);

// State Parameter
parameter [4:0] IDLE  		= 5'b0_0000;
parameter [4:0] INC1  		= 5'b0_0001;
parameter [4:0] GETSI 		= 5'b0_0010;
parameter [4:0] WAIT1 		= 5'b0_0011;
parameter [4:0] WAIT2 		= 5'b0_0100;
parameter [4:0] CALCJ 		= 5'b0_0101;
parameter [4:0] GETSJ 		= 5'b0_0110;
parameter [4:0] WAIT3 		= 5'b0_0111;
parameter [4:0] WAIT4 		= 5'b0_1000;
parameter [4:0] SAVESJ 		= 5'b0_1001;	
parameter [4:0] SWAP_ItoJ 	= 5'b0_1010;	
parameter [4:0] WAIT5 		= 5'b0_1011;		
parameter [4:0] WAIT6 		= 5'b0_1100;	
parameter [4:0] WAIT7 		= 5'b0_1101;	
parameter [4:0] SWAP_JtoI 	= 5'b0_1110;
parameter [4:0] WAIT8 		= 5'b0_1111;	
parameter [4:0] WAIT9 		= 5'b1_0000;	
parameter [4:0] WAIT10 		= 5'b1_0001;
parameter [4:0] CALCF 		= 5'b1_0010;		
parameter [4:0] GETENC 		= 5'b1_0011;	
parameter [4:0] WAIT11 		= 5'b1_0100;	
parameter [4:0] WAIT12 		= 5'b1_0101;	
parameter [4:0] CALCK 		= 5'b1_0110;	
parameter [4:0] WAIT13 		= 5'b1_0111;	
parameter [4:0] WAIT14 		= 5'b1_1000;	
parameter [4:0] WAIT15 		= 5'b1_1001;	
parameter [4:0] INCK 		= 5'b1_1010;	
parameter [4:0] FINISH 		= 5'b1_1011;
parameter [4:0] CALCSISJ 	= 5'b1_1100;
parameter [4:0] REQ_S 		= 5'b1_1101;
parameter [4:0] WAITX 		= 5'b1_1110;
parameter [4:0] WAITY 		= 5'b1_1111;

logic [4:0] state;		// State variable
logic [5:0] k_index_2b; 	// k index value
logic [7:0] j_index_2b;		// j index value
logic [8:0] i_index_2b; 	// 255 = 0_1111_1111 also i (this was counter before)
logic [7:0] saved_si_2b;	// Saving value of s[i]
logic [7:0] saved_sj_2b; 	// Saving value of s[j]
logic [7:0] saved_sisj_2b; // Saving s[i] + s[j]

logic [7:0] f; 			// From loop
 
always_ff @(posedge clk)
	begin
	if (!task2b_start) begin
					state <= IDLE;
					i_index_2b <= 9'b0_0000_0000;
					j_index_2b <= 8'b0000_0000;
					k_index_2b <= 6'b00_0000;
				
					address_out_RAM1 <= 8'b0000_0000;
					data_to_RAM1 <= 8'b0000_0000;
					wren_to_RAM1 <= 1'b0;
					
					address_ROM <= 5'b0_0000;
					
					address_out_RAM2 <= 5'b0_0000;
					data_to_RAM2 <= 8'b0000_0000;
					wren_to_RAM2 <= 1'b0;
					
					done <= 1'b0;
					end
	else
	 begin
	 case (state) 
	 IDLE:		begin
					state <= INC1;
					i_index_2b <= 9'b0_0000_0000;
					j_index_2b <= 8'b0000_0000;
					k_index_2b <= 6'b00_0000;
				
					address_out_RAM1 <= 8'b0000_0000;
					data_to_RAM1 <= 8'b0000_0000;
					wren_to_RAM1 <= 1'b0;
				
					address_ROM <= 5'b0_0000;
					
					address_out_RAM2 <= 5'b0_0000;
					data_to_RAM2 <= 8'b0000_0000;
					wren_to_RAM2 <= 1'b0;
					
					done <= 1'b0;
					end
	INC1:			if (k_index_2b >= 6'b10_0000)
					state <= FINISH;
					else begin
					state <= GETSI;
				   i_index_2b <= i_index_2b + 1;
					end
	GETSI:		begin
					state <= WAIT1;
					address_out_RAM1 <= i_index_2b;
					wren_to_RAM1 <= 1'b0;
					end
	WAIT1:		state <= WAIT2;
	WAIT2:		state <= CALCJ;
	CALCJ:		begin
					state <= GETSJ;
					saved_si_2b <= q_RAM1;
					j_index_2b <= j_index_2b + q_RAM1;
					end
	GETSJ:		begin
					state <= WAIT3;
					address_out_RAM1 <= j_index_2b;
					wren_to_RAM1 <= 1'b0;
					end
	WAIT3:		state <= WAIT4;
	WAIT4:		state <= SAVESJ;
	SAVESJ:		begin
					state <= SWAP_ItoJ;
					saved_sj_2b <= q_RAM1;
					end
	SWAP_ItoJ:	begin
					state <= WAIT5;
					address_out_RAM1 <= j_index_2b;
					data_to_RAM1 <= saved_si_2b;
					wren_to_RAM1 <= 1'b1;					
					end 
	WAIT5:		state <= WAIT6;
	WAIT6:		state <= WAIT7;
	WAIT7:		state <= SWAP_JtoI;
	SWAP_JtoI:	begin
					state <= WAIT8;
					address_out_RAM1 <= i_index_2b;
					data_to_RAM1 <= saved_sj_2b;
					wren_to_RAM1 <= 1'b1;
					end
	WAIT8:		state <= WAIT9;
	WAIT9:		state <= WAIT10;
	WAIT10:		state <= CALCSISJ;
	CALCSISJ:	begin
					state <= REQ_S;
					saved_sisj_2b <= saved_si_2b + saved_sj_2b;
					end
	REQ_S:		begin
					state <= WAITX;
					address_out_RAM1 <= saved_sisj_2b;
					wren_to_RAM1 <= 1'b0;
					end
	WAITX:		state <= WAITY;
	WAITY:		state <= GETENC;
	GETENC:		begin 								// Get encrypted value to XOR for next part 
					f <= q_RAM1;
					state <= WAIT11;
					address_ROM <= k_index_2b[4:0];
					end
	WAIT11:		state <= WAIT12;		
	WAIT12:		state <= CALCK;
	CALCK:		begin
					state <= WAIT13;
					address_out_RAM2 <= k_index_2b[4:0];
					data_to_RAM2 <= f ^ ROM_data;
					wren_to_RAM2 <= 1'b1;
					end
	WAIT13:		state <= WAIT14;
	WAIT14:		state <= WAIT15;
	WAIT15:		state <= INCK;
	INCK:			begin
					state <= INC1;
					k_index_2b <= k_index_2b + 1;
					wren_to_RAM2 <= 1'b0;
					end
	FINISH:		begin
					if (master_reset == 1'b0) begin
					state <= FINISH;
					done <= 1'b1;
					end
					else begin
					state <= IDLE;
					done <= 1'b0;
					end
					end
   default:		begin
					state <= IDLE;
					i_index_2b <= 9'b0_0000_0000;
					j_index_2b <= 8'b0000_0000;
					k_index_2b <= 6'b00_0000;
				
					address_out_RAM1 <= 8'b0000_0000;
					data_to_RAM1 <= 8'b0000_0000;
					wren_to_RAM1 <= 1'b0;
					
					address_ROM <= 5'b0_0000;
					
					address_out_RAM2 <= 5'b0_0000;
					data_to_RAM2 <= 8'b0000_0000;
					wren_to_RAM2 <= 1'b0;
					
					done <= 1'b0;
					end
	endcase
	end
	end
endmodule