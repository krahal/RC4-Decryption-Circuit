module FSM3(
input logic clk,						
input logic task3_start,				// Task2b is finished and this starts
input logic [7:0] q_ram2,				// decrypted_output[counter]
output logic [9:0] LED,
output logic [4:0] address_ram2,		// Sends address to RAM2 for new data
output logic [23:0] secret_key,		// Sends new secret_key to FSM2a
output logic reset						// Resets all state machines
);

parameter [4:0] IDLE				= 5'b00000;
parameter [4:0] LOADQ			= 5'b00001;
parameter [4:0] WAIT1			= 5'b00010;
parameter [4:0] WAIT2			= 5'b00011;
parameter [4:0] CHECK_DCY  	= 5'b00100;
parameter [4:0] CHECK_DCY1 	= 5'b00101;
parameter [4:0] CHECK_DCY2 	= 5'b00110;
parameter [4:0] CHECK_CUNTR	= 5'b00111;
parameter [4:0] INC_CUNTR  	= 5'b01000;
parameter [4:0] CHK_SC_KEY 	= 5'b01001;
parameter [4:0] INC_SC_KEY		= 5'b01010;
parameter [4:0] WAITx			= 5'b01011;
parameter [4:0] WAITy			= 5'b01100;	
parameter [4:0] FNH_GUD			= 5'b11101;
parameter [4:0] FNH_FAIL		= 5'b01110;

parameter [4:0] WAITx1			= 5'b10000;
parameter [4:0] WAITx2			= 5'b11000;
parameter [4:0] WAIT3			= 5'b11111;

logic [4:0] state;
logic [5:0] counter;						// Counter is for decrypted outputs

always_ff @ (posedge clk)
	begin
	if(!task3_start) begin
			state <= IDLE;
			address_ram2 <= 5'b00000;
			reset <= 1'b0;
			end
	else begin
		case(state)
			IDLE:			begin
							state <= LOADQ;
							address_ram2 <= 5'b00000;
							reset <= 1'b0;
							counter <= 6'b00_0000;
							LED <= 10'b00_0000_0000;
							end
			LOADQ:		begin
							state <= WAIT1;
							address_ram2 <= counter[4:0];
							end
			WAIT1:		state <= WAIT2;
			WAIT2:		state <= WAIT3;
			WAIT3:		state <= CHECK_DCY;
			CHECK_DCY:	begin
							if (q_ram2 <= 8'b0111_1010) begin		// 122
							state <= CHECK_DCY1; 					// Value out of range
							end
							else state <= CHK_SC_KEY;
							end
			CHECK_DCY1: begin
							if (q_ram2 >= 8'b0110_0001) begin		// 97
							state <= CHECK_CUNTR;						// Value out of range
							end
							else state <= CHECK_DCY2;
							end
			CHECK_DCY2: begin
							if (q_ram2 == 8'b0010_0000) begin	// 32
							state <= CHECK_CUNTR;
							end
							else state <= CHK_SC_KEY;
							end
			CHECK_CUNTR:begin	
							if (counter >= 6'b10_0000) begin
							state <= FNH_GUD;
							end
							else state <= INC_CUNTR;
							end
			INC_CUNTR:	begin
							state <= LOADQ;
							counter <= counter + 1'b1;
							end
			CHK_SC_KEY:	begin
							if (secret_key >= 24'b0000_0000_0000_0100_0000_0000) begin
								state <= FNH_FAIL;
							end
							else begin
								state <= INC_SC_KEY;
							end
							end
			INC_SC_KEY:	begin
								state <= WAITx;
								secret_key <= secret_key + 24'b0000_0000_0000_0000_0000_0001;
								reset <= 1'b1;
								counter <= 6'b00_0000;
							end
			WAITx:		state <= WAITx1;
			WAITx1:		state <= WAITx2;
			WAITx2:		state <= WAITy;
			WAITy:		begin
							state <= IDLE;
							reset <= 1'b0;
							end
			FNH_GUD:		begin
							state <= FNH_GUD;
							LED <= 10'b00_0000_1001;
							end
			FNH_FAIL:	begin
							state <= FNH_FAIL;
							LED <= 10'b11_1111_1111;
							end
			default:		begin
							state <= IDLE;
							address_ram2 <= 5'b00000;
							reset <= 1'b0;
							counter <= 6'b00_0000;
							LED <= 10'b00_0000_0000;
							secret_key <= 24'b0000_0000_0000_0000_0000_0000;
							end
			endcase
			end
		end
endmodule
		