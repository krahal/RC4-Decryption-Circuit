module ksaSV (
    //////////// CLOCK //////////
    CLOCK_50,

    //////////// LED //////////
    LEDR,

    //////////// KEY //////////
    KEY,

    //////////// SW //////////
    SW,

    //////////// SEG7 //////////
    HEX0,
    HEX1,
    HEX2,
    HEX3,
    HEX4,
    HEX5
    
);

//=======================================================
//  PORT declarations
//=======================================================

//////////// CLOCK //////////
input                       CLOCK_50;

//////////// LED //////////
output           [9:0]      LEDR;

//////////// KEY //////////
input            [3:0]      KEY;

//////////// SW //////////
input            [9:0]      SW;

//////////// SEG7 //////////
output           [6:0]      HEX0;
output           [6:0]      HEX1;
output           [6:0]      HEX2;
output           [6:0]      HEX3;
output           [6:0]      HEX4;
output           [6:0]      HEX5;

logic CLK_50M;
//logic  [7:0] LED;
assign CLK_50M =  CLOCK_50;
//assign LEDR[7:0] = LED[7:0];

// rtl of ksa
logic [7:0] Seven_Seg_Val[5:0];
logic [3:0] Seven_Seg_Data[5:0];

assign HEX0 = Seven_Seg_Val[0];
assign HEX1 = Seven_Seg_Val[1];
assign HEX2 = Seven_Seg_Val[2];
assign HEX3 = Seven_Seg_Val[3];
assign HEX4 = Seven_Seg_Val[4];
assign HEX5 = Seven_Seg_Val[5];

assign Seven_Seg_Data[0] = HEX_data[3:0];
assign Seven_Seg_Data[1] = HEX_data[7:4];
assign Seven_Seg_Data[2] = HEX_data[11:8];
assign Seven_Seg_Data[3] = HEX_data[15:12];
assign Seven_Seg_Data[4] = HEX_data[19:16];
assign Seven_Seg_Data[5] = HEX_data[23:20];

SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst0(.ssOut(Seven_Seg_Val[0]), .nIn(Seven_Seg_Data[0]));
SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst1(.ssOut(Seven_Seg_Val[1]), .nIn(Seven_Seg_Data[1]));
SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst2(.ssOut(Seven_Seg_Val[2]), .nIn(Seven_Seg_Data[2]));
SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst3(.ssOut(Seven_Seg_Val[3]), .nIn(Seven_Seg_Data[3]));
SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst4(.ssOut(Seven_Seg_Val[4]), .nIn(Seven_Seg_Data[4]));
SevenSegmentDisplayDecoder SevenSegmentDisplayDecoder_inst5(.ssOut(Seven_Seg_Val[5]), .nIn(Seven_Seg_Data[5]));

s_memory task1a (.address(address_1a), .clock(CLK_50M), .data(s), .wren(wren_1a), .q(q_1a));
ROM1 task2b_ROM (.address(address_2rom_2b), .clock(CLK_50M), .q(romdata_2b));
dec_msg task2b_RAM2b (.address(address_RAM2), .clock(CLK_50M), .data(ramdata_2b), .wren(wren_2b_ram2), .q(q_2b));

logic [7:0] address_1a;
logic [7:0] s;
logic wren_1a;
logic [7:0] q_1a;

logic wren_2b;
logic wren_2b_ram2;

logic [4:0] address_2rom_2b; // 5'b1_1111 = 5'd31 address for rom
logic [4:0] address_RAM2;
logic [7:0] q_2b;			// data from ram 2
logic [7:0] ramdata_2b;	// data to ram 2
logic [7:0] romdata_2b; // data from rom
logic [23:0] HEX_data;

FSM_f Task3 (
.clk(CLK_50M),
.q_RAM1(q_1a),
.address_out_RAM1(address_1a),
.data_to_RAM1(s),
.wren_to_RAM1(wren_1a),

.ROM_data(romdata_2b),					// Data from ROM
.address_ROM(address_2rom_2b),				// Sends to ROM for data @ address 

.q_RAM2(q_2b),
.address_out_RAM2(address_RAM2),		// Sends to Second RAM for Q or for write
.data_to_RAM2(ramdata_2b),			// Sends to Second RAM for rewriting data_out
.wren_to_RAM2(wren_2b_ram2),					// wren for decrypted message RAM
.LED(LEDR),
.HEX_out(HEX_data)
);

/* Task 1a - Instantiating Memory
// wren - write enable; address - address memory; data - data within the address memory 
logic [7:0] address_1a;
logic [7:0] s;
logic wren_1a;
logic [7:0] q_1a;

assign address_1a = address_1c | address_2a | address_2b; 
assign s 			= s_1c | s_2a | s_2b;
assign wren_1a 	= wren_1c | wren_2a | wren_2b;

s_memory task1a (.address(address_1a), .clock(CLK_50M), .data(s), .wren(wren_1a), .q(q_1a));

// Task 1c
logic [7:0] address_1c;
logic [7:0] s_1c;
logic wren_1c;
logic task1c_finish;

FSM1c task1c (.clk(CLK_50M), .address_out(address_1c), .data_out(s_1c), .write_out(wren_1c), .done(task1c_finish), .master_reset(MASTER_RESET));

// Task 2a
logic [7:0] address_2a;
logic [7:0] s_2a;
logic wren_2a;
logic task2a_finish;

FSM2a task2a (.clk(CLK_50M), .task2a_start(task1c_finish), .SW(secret_key), 
.mem_data(q_1a), .address_out(address_2a), .data_out(s_2a), .write_out(wren_2a), .done(task2a_finish), .master_reset(MASTER_RESET));

//Task 2b
logic task2b_finish;
logic wren_2b;
logic wren_2b_ram2;

logic [4:0] address_2rom_2b; // 5'b1_1111 = 5'd31 address for rom
logic [4:0] address_2b_ram2; // address for ram 2
logic [4:0] address_RAM2;
logic [7:0] address_2b;	// address for ram 1
logic [7:0] q_2b;			// data from ram 2
logic [7:0] s_2b;			// data to ram 1
logic [7:0] ramdata_2b;	// data to ram 2
logic [7:0] romdata_2b; // data from rom

assign address_RAM2 = address_2b_ram2 | address_3;

ROM1 task2b_ROM (.address(address_2rom_2b), .clock(CLK_50M), .q(romdata_2b));
dec_msg task2b_RAM2b (.address(address_RAM2), .clock(CLK_50M), .data(ramdata_2b), .wren(wren_2b_ram2), .q(q_2b));

FSM2b task2b (.clk(CLK_50M), .task2b_start(task2a_finish), 
.q_data_ram1(q_1a), .address_out_ram1(address_2b), .data_out_ram1(s_2b), .write_out_ram1(wren_2b), .done(task2b_finish), 
.ROM_data(romdata_2b), .address_ROM(address_2rom_2b), 
.address_out_ram2(address_2b_ram2), .data_out_ram2(ramdata_2b), .write_out_ram2(wren_2b_ram2), .master_reset(MASTER_RESET));

//Task 3
logic MASTER_RESET;
logic [4:0] address_3;
logic [23:0] secret_key;

FSM3 task3(.clk(CLK_50M), .task3_start(task2b_finish), .q_ram2(q_2b), .LED(LEDR), 
.address_ram2(address_3), .secret_key(secret_key), .reset(MASTER_RESET));
*/
endmodule