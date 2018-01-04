module FSM1c (
input logic clk,
input logic master_reset,
output logic [7:0] address_out,
output logic [7:0] data_out,
output logic write_out,
output logic done
);

parameter [2:0] idle 		= 3'b000;
parameter [2:0] write 		= 3'b101;
parameter [2:0] increment  = 3'b001;
parameter [2:0] pfinish		= 3'b100;
parameter [2:0] finish 	   = 3'b011; 

logic [2:0] state;
logic [7:0] counter; // 255 = 1111_1111

always_ff @(posedge clk)
	begin
	 case (state) 
	 idle:		begin
						state <= write;
						counter <= 8'b0000_0000;
						data_out <= 8'b0000_0000;
						address_out <= 8'b0000_0000;
					end
	 write:		if (counter == 8'b1111_1111) begin
						state <= pfinish;
						data_out <= counter;
						address_out <= counter;
					end
					else begin
						state <= increment;
						data_out <= counter;
						address_out <= counter;
					end
	 increment: begin
						counter <= counter + 1;
						state <= write;
					end
	 pfinish:	state <= finish;
	 finish:		begin
					if (master_reset == 1'b0) begin
						state <= finish;
						data_out <= 8'b0000_0000;
						address_out <= 8'b0000_0000;
					end
					else state <= idle;
					end
	 default:	begin
						state <= idle;
						counter <= 8'b0000_0000;
						data_out <= 8'b0000_0000;
						address_out <= 8'b0000_0000;
					end
	endcase
	end
  
always_comb
 begin
  write_out = state[2];
  done = state[1];
 end
endmodule