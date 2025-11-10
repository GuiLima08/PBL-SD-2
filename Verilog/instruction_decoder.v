module instruction_decoder(
	input [25:0] instruction,
	output [2:0] opcode,
	output [3:0] factor,
	output [7:0] data,
	output [18:0] address
	);
	
	assign opcode = instruction[25:23];
	assign factor = instruction[22:19];
	assign data = instruction[22:15];
	assign address = instruction[14:0];
	
endmodule