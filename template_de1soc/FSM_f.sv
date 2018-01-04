module FSM_f (
input logic clk,
input logic [7:0] q_RAM1,

output logic [7:0] address_out_RAM1,
output logic [7:0] data_to_RAM1,
output logic wren_to_RAM1,

// I/O for ROM and Second RAM 
input logic [7:0] ROM_data,					// Data from ROM
output logic [4:0] address_ROM,				// Sends to ROM for data @ address 

input logic [7:0] q_RAM2,
output logic [4:0] address_out_RAM2,		// Sends to Second RAM for Q or for write
output logic [7:0] data_to_RAM2,			// Sends to Second RAM for rewriting data_out
output logic wren_to_RAM2,					// wren for decrypted message RAM

output logic [9:0] LED,
output logic [23:0] HEX_out
);

// General
logic [8:0] state;
logic [23:0] secret_key;

assign HEX_out = secret_key;

// Task 1c
parameter [8:0] idle_1c 	= 9'b0_0000_0000;
parameter [8:0] write 		= 9'b0_0000_0101;
parameter [8:0] increment  = 9'b0_0000_0001;
parameter [8:0] pfinish		= 9'b0_0000_0100;
parameter [8:0] finish_1c 	= 9'b0_0000_0011; 

// Task 2a
parameter [8:0] IDLE_2a			= 9'b0_0010_0000; 	// Wait for task2a_start (FSM1c done signal)
parameter [8:0] GET_SI_2a	 	= 9'b0_0010_0001;		// Send request for s[i]
parameter [8:0] WAIT1_2a  	   = 9'b0_0010_0010;		
parameter [8:0] WAIT2_2a		= 9'b0_0010_0011;	
parameter [8:0] CALC_2a		   = 9'b0_0010_0100;		// Calculate J using J, s[i], and case statement for mod <save s[i]>
parameter [8:0] GET_SJ_2a		= 9'b0_0010_0101;		// Send request for s[j]
parameter [8:0] WAIT3_2a		= 9'b0_0010_0110;
parameter [8:0] WAIT4_2a		= 9'b0_0010_0111;
parameter [8:0] SAVE_JS_2a		= 9'b0_0010_1000;		// Save s[j] for future swap 
parameter [8:0] SWAP_JI_2a		= 9'b0_0010_1001;		// Swap - write s[i] into address J 
parameter [8:0] WAIT5_2a		= 9'b0_0010_1010;
parameter [8:0] WAIT6_2a		= 9'b0_0010_1011;
parameter [8:0] WAITx_2a		= 9'b0_0011_0001;
parameter [8:0] SWAP_IJ_2a		= 9'b0_0010_1100; 	// Swap - write s[j] (variable saved) into i
parameter [8:0] WAIT7_2a		= 9'b0_0010_1101;
parameter [8:0] WAIT8_2a		= 9'b0_0010_1110;
parameter [8:0] WAITy_2a		= 9'b0_0011_0010;
parameter [8:0] INC_2a			= 9'b0_0010_1111;		// Increment counter
parameter [8:0] FINISH_2a		= 9'b0_0011_0000;

// Task 2b
parameter [8:0] IDLE_2b 		= 9'b0_0100_0000;
parameter [8:0] INC1_2b  		= 9'b0_0100_0001;
parameter [8:0] GETSI_2b 		= 9'b0_0100_0010;
parameter [8:0] WAIT1_2b 		= 9'b0_0100_0011;
parameter [8:0] WAIT2_2b 		= 9'b0_0100_0100;
parameter [8:0] CALCJ_2b 		= 9'b0_0100_0101;
parameter [8:0] GETSJ_2b 		= 9'b0_0100_0110;
parameter [8:0] WAIT3_2b 		= 9'b0_0100_0111;
parameter [8:0] WAIT4_2b 		= 9'b0_0100_1000;
parameter [8:0] SAVESJ_2b 		= 9'b0_0100_1001;	
parameter [8:0] SWAP_ItoJ_2b 	= 9'b0_0100_1010;	
parameter [8:0] WAIT5_2b 		= 9'b0_0100_1011;		
parameter [8:0] WAIT6_2b 		= 9'b0_0100_1100;	
parameter [8:0] WAIT7_2b 		= 9'b0_0100_1101;	
parameter [8:0] SWAP_JtoI_2b 	= 9'b0_0100_1110;
parameter [8:0] WAIT8_2b 		= 9'b0_0100_1111;	
parameter [8:0] WAIT9_2b 		= 9'b0_0101_0000;	
parameter [8:0] WAIT10_2b 		= 9'b0_0101_0001;
parameter [8:0] CALCF_2b 		= 9'b0_0101_0010;		
parameter [8:0] GETENC_2b 		= 9'b0_0101_0011;	
parameter [8:0] WAIT11_2b 		= 9'b0_0101_0100;	
parameter [8:0] WAIT12_2b 		= 9'b0_0101_0101;	
parameter [8:0] CALCK_2b 		= 9'b0_0101_0110;	
parameter [8:0] WAIT13_2b 		= 9'b0_0101_0111;	
parameter [8:0] WAIT14_2b 		= 9'b0_0101_1000;	
parameter [8:0] WAIT15_2b 		= 9'b0_0101_1001;	
parameter [8:0] INCK_2b 		= 9'b0_0101_1010;	
parameter [8:0] FINISH_2b 		= 9'b0_0101_1011;
parameter [8:0] CALCSISJ_2b 	= 9'b0_0101_1100;
parameter [8:0] REQ_S_2b 		= 9'b0_0101_1101;
parameter [8:0] WAITX_2b 		= 9'b0_0101_1110;
parameter [8:0] WAITY_2b 		= 9'b0_0101_1111;

// Task 3
parameter [8:0] IDLE_3			= 9'b1_0000_0000;
parameter [8:0] LOADQ_3			= 9'b1_0000_0001;
parameter [8:0] WAIT1_3			= 9'b1_0000_0010;
parameter [8:0] WAIT2_3			= 9'b1_0000_0011;
parameter [8:0] CHECK_DCY_3  	= 9'b1_0000_0100;
parameter [8:0] CHECK_DCY1_3 	= 9'b1_0000_0101;
parameter [8:0] CHECK_DCY2_3 	= 9'b1_0000_0110;
parameter [8:0] CHECK_CUNTR_3	= 9'b1_0000_0111;
parameter [8:0] INC_CUNTR_3  	= 9'b1_0000_1000;
parameter [8:0] CHK_SC_KEY_3 	= 9'b1_0000_1001;
parameter [8:0] INC_SC_KEY_3	= 9'b1_0000_1010;
parameter [8:0] FNH_GUD_3		= 9'b1_0001_1101;
parameter [8:0] FNH_FAIL_3		= 9'b1_0000_1110;
parameter [8:0] WAIT3_3			= 9'b1_0001_1111;

// Task 1c
logic [8:0] counter; // 255 = 1111_1111

// Task 2a
logic [2:0] key_mod;		// Variable for mod
logic [7:0] j_index;		// j index value	
logic [7:0] saved_si;	// Saving value of s[i]
logic [7:0] saved_sj; 	// Saving value of s[j]
logic [8:0] i_index; 	// 255 = 0_1111_1111 also i (this was counter before)

// Task 2b
logic [5:0] k_index_2b; 	// k index value
logic [7:0] j_index_2b;		// j index value
logic [8:0] i_index_2b; 	// 255 = 0_1111_1111 also i (this was counter before)
logic [7:0] saved_si_2b;	// Saving value of s[i]
logic [7:0] saved_sj_2b; 	// Saving value of s[j]
logic [7:0] saved_sisj_2b; // Saving s[i] + s[j]
logic [7:0] f; 			// From loop

// Task 3
logic [5:0] counter3;

always_ff @(posedge clk)
	begin
	 case (state) 
// Task 1c - Setting up the RAM
	 idle_1c:		begin
						state <= write;
						counter <= 8'b0000_0000;
						data_to_RAM1 <= 8'b0000_0000;
						address_out_RAM1 <= 8'b0000_0000;
						wren_to_RAM1 <= 1'b0;
					end
	 write:		if (counter == 8'b1111_1111) begin
						state <= pfinish;
						data_to_RAM1 <= counter;
						address_out_RAM1 <= counter;
						wren_to_RAM1 <= 1'b1;
					end
					else begin
						state <= increment;
						data_to_RAM1 <= counter;
						address_out_RAM1 <= counter;
						wren_to_RAM1 <= 1'b1;
					end
	 increment: begin
						counter <= counter + 1'b1;
						state <= write;
						wren_to_RAM1 <= 1'b0;
					end
	 pfinish:	state <= finish_1c;
	 finish_1c:	begin
						state <= IDLE_2a;
						data_to_RAM1 <= 8'b0000_0000;
						address_out_RAM1 <= 8'b0000_0000;
						wren_to_RAM1 <= 1'b0;
					end

// Task 2a		
					
	IDLE_2a:		begin
					state <= GET_SI_2a;
					i_index <= 9'b0_0000_0000;
					j_index <= 8'b0000_0000;
					
					data_to_RAM1 <= 8'b0000_0000;
					address_out_RAM1 <= 8'b0000_0000;
					wren_to_RAM1 <= 1'b0;
					end
	 
	 GET_SI_2a:	if (i_index >= 9'b1_0000_0000) begin
					state <= FINISH_2a;
					end 
					else begin
					state <= WAIT1_2a;
					
					data_to_RAM1 <= 8'b0000_0000;
					address_out_RAM1 <= i_index[7:0];
					wren_to_RAM1 <= 1'b0;
					end
	 
	 WAIT1_2a:	state <= WAIT2_2a;
	 
	 WAIT2_2a:	begin
					state <= CALC_2a;
					key_mod <= (i_index[7:0])%3;
					end
	 
	 CALC_2a: 	begin
					if (key_mod == 0) begin
								j_index <= (j_index + q_RAM1 + secret_key[23:16]);
								state <= GET_SJ_2a;
								saved_si <= q_RAM1;
								end
					else if (key_mod == 1) begin
								j_index <= (j_index + q_RAM1 + secret_key[15:8]);
								state <= GET_SJ_2a;
								saved_si <= q_RAM1;
								end
					else begin
								j_index <= (j_index + q_RAM1 + secret_key[7:0]);
								state <= GET_SJ_2a;
								saved_si <= q_RAM1;
								end
					end
					
	 GET_SJ_2a:	begin
					state <= WAIT3_2a;
					data_to_RAM1 <= 8'b0000_0000;
					address_out_RAM1 <= j_index;
					wren_to_RAM1 <= 1'b0;
					end
					
	 WAIT3_2a:	state <= WAIT4_2a;
	 
	 WAIT4_2a:		state <= SAVE_JS_2a;
	 
	 SAVE_JS_2a: begin
					state <= SWAP_JI_2a;
					saved_sj <= q_RAM1;
					end
					
	 SWAP_JI_2a: begin
					state <= WAIT5_2a;
					address_out_RAM1 <= i_index;
					data_to_RAM1 <= saved_sj;
					wren_to_RAM1 <= 1'b1;
					end
					
	 WAIT5_2a:	state <= WAIT6_2a;
	 
	 WAIT6_2a:	state <= WAITx_2a;
	 
	 WAITx_2a:	state <= SWAP_IJ_2a;
	 
	 SWAP_IJ_2a: begin
					state <= WAIT7_2a;
					address_out_RAM1 <= j_index;
					data_to_RAM1 <= saved_si;
					wren_to_RAM1 <= 1'b1;
					end
	 
	 WAIT7_2a:	state <= WAIT8_2a;
	 
	 WAIT8_2a:	state <= WAITy_2a;
	 
	 WAITy_2a:	state <= INC_2a;
	 
	 INC_2a:		begin
					state <= GET_SI_2a;
					i_index <= i_index + 1'b1;
					end
	 
	 FINISH_2a:	begin
					state <= IDLE_2b;
					data_to_RAM1 <= 8'b0000_0000;
					address_out_RAM1 <= 8'b0000_0000;
					wren_to_RAM1 <= 1'b0;
					end
					
// Task 2b

	 IDLE_2b:	begin
					state <= INC1_2b;
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
					end
	INC1_2b:		if (k_index_2b >= 6'b10_0000)
					state <= FINISH_2b;
					else begin
					state <= GETSI_2b;
				   i_index_2b <= i_index_2b + 1'b1;
					end
	GETSI_2b:		begin
					state <= WAIT1_2b;
					address_out_RAM1 <= i_index_2b[8:0];
					wren_to_RAM1 <= 1'b0;
					end
	WAIT1_2b:		state <= WAIT2_2b;
	WAIT2_2b:		state <= CALCJ_2b;
	CALCJ_2b:		begin
					state <= GETSJ_2b;
					saved_si_2b <= q_RAM1;
					j_index_2b <= j_index_2b + q_RAM1;
					end
	GETSJ_2b:		begin
					state <= WAIT3_2b;
					address_out_RAM1 <= j_index_2b;
					wren_to_RAM1 <= 1'b0;
					end
	WAIT3_2b:		state <= WAIT4_2b;
	WAIT4_2b:		state <= SAVESJ_2b;
	SAVESJ_2b:		begin
					state <= SWAP_ItoJ_2b;
					saved_sj_2b <= q_RAM1;
					end
	SWAP_ItoJ_2b:	begin
					state <= WAIT5_2b;
					address_out_RAM1 <= j_index_2b;
					data_to_RAM1 <= saved_si_2b;
					wren_to_RAM1 <= 1'b1;					
					end 
	WAIT5_2b:		state <= WAIT6_2b;
	WAIT6_2b:		state <= WAIT7_2b;
	WAIT7_2b:		state <= SWAP_JtoI_2b;
	SWAP_JtoI_2b:	begin
					state <= WAIT8_2b;
					address_out_RAM1 <= i_index_2b[8:0];
					data_to_RAM1 <= saved_sj_2b;
					wren_to_RAM1 <= 1'b1;
					end
	WAIT8_2b:		state <= WAIT9_2b;
	WAIT9_2b:		state <= WAIT10_2b;
	WAIT10_2b:		state <= CALCSISJ_2b;
	CALCSISJ_2b:	begin
					state <= REQ_S_2b;
					saved_sisj_2b <= saved_si_2b + saved_sj_2b;
					end
	REQ_S_2b:		begin
					state <= WAITX_2b;
					address_out_RAM1 <= saved_sisj_2b;
					wren_to_RAM1 <= 1'b0;
					end
	WAITX_2b:		state <= WAITY_2b;
	WAITY_2b:		state <= GETENC_2b;
	GETENC_2b:		begin 								// Get encrypted value to XOR for next part 
					f <= q_RAM1;
					state <= WAIT11_2b;
					address_ROM <= k_index_2b[4:0];
					end
	WAIT11_2b:		state <= WAIT12_2b;		
	WAIT12_2b:		state <= CALCK_2b;
	CALCK_2b:		begin
					state <= WAIT13_2b;
					address_out_RAM2 <= k_index_2b[4:0];
					data_to_RAM2 <= f ^ ROM_data;
					wren_to_RAM2 <= 1'b1;
					end
	WAIT13_2b:		state <= WAIT14_2b;
	WAIT14_2b:		state <= WAIT15_2b;
	WAIT15_2b:		state <= INCK_2b;
	INCK_2b:			begin
					state <= INC1_2b;
					k_index_2b <= k_index_2b + 1'b1;
					wren_to_RAM2 <= 1'b0;
					end
	FINISH_2b:	begin
					state <= IDLE_3;
					end
					
////////////////////////////////////////////////////////////////////////
	 
			IDLE_3:		begin
							state <= LOADQ_3;
							address_out_RAM2 <= 5'b00000;
							counter3 <= 6'b00_0000;
							LED <= 10'b00_0000_0000;
							
							wren_to_RAM2 <= 1'b0;
							
							end
			LOADQ_3:		begin
							state <= WAIT1_3;
							address_out_RAM2 <= counter3[4:0];
							wren_to_RAM2 <= 1'b0;
							end
			WAIT1_3:		state <= WAIT2_3;
			WAIT2_3:		state <= WAIT3_3;
			WAIT3_3:		state <= CHECK_DCY_3;
			CHECK_DCY_3: begin
							if (q_RAM2 <= 8'b0111_1010) begin	// 122
							state <= CHECK_DCY1_3; 					// Value out of range
							end
							else state <= CHK_SC_KEY_3;
							end
			CHECK_DCY1_3: begin
							if (q_RAM2 >= 8'b0110_0001) begin		// 97
							state <= CHECK_CUNTR_3;						// Value out of range
							end
							else state <= CHECK_DCY2_3;
							end
			CHECK_DCY2_3: begin
							if (q_RAM2 == 8'b0010_0000) begin	// 32
							state <= CHECK_CUNTR_3;
							end
							else state <= CHK_SC_KEY_3;
							end
			CHECK_CUNTR_3: begin	
							if (counter3 >= 6'b10_0000) begin
							state <= FNH_GUD_3;
							end
							else state <= INC_CUNTR_3;
							end
			INC_CUNTR_3:	begin
							state <= LOADQ_3;
							counter3 <= counter3 + 1'b1;
							end
			CHK_SC_KEY_3:	begin
							if (secret_key == 24'b1111_1111_1111_1111_1111_1111) begin
								state <= FNH_FAIL_3;
							end
							else begin
								state <= INC_SC_KEY_3;
							end
							end
			INC_SC_KEY_3:	begin
								state <= idle_1c;
								secret_key <= secret_key + 24'b0000_0000_0000_0000_0000_0001;
								counter3 <= 6'b00_0000;
							end
			FNH_GUD_3:		begin
							state <= FNH_GUD_3;
							LED <= 10'b11_1100_0000;
							end
			FNH_FAIL_3:	begin
							state <= FNH_FAIL_3;
							LED <= 10'b00_0011_1111;
							end
	 
////////////////////////////////////////////////////////////////////////
	 
	 default:	begin
					state <= idle_1c;
					counter <= 8'b0000_0000;
					data_to_RAM1 <= 8'b0000_0000;
					address_out_RAM1 <= 8'b0000_0000;
					wren_to_RAM1 <= 1'b0;
					
					i_index_2b <= 9'b0_0000_0000;
					j_index_2b <= 8'b0000_0000;
					k_index_2b <= 6'b00_0000;
					
					address_ROM <= 5'b0_0000;
					
					address_out_RAM2 <= 5'b0_0000;
					data_to_RAM2 <= 8'b0000_0000;
					wren_to_RAM2 <= 1'b0;
			
					secret_key <= 24'b0000_0000_0000_0000_0000_0000;					
					end
	endcase
	end
endmodule
