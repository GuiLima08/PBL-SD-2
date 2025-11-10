module control_unit (
    input  wire        clk,
    input  wire        rst_n,
	 input  wire [25:0] instruction,
	 input  wire 		  flag_in,
    input  wire        alu_done,
	 input  wire [18:0] addr_alu,
	 output reg			  write,
    output reg         start_alu,
	 output reg	 [3:0]  factor,
	 output reg	 [2:0]  opcode,
	 output 		 [7:0]  data,
	 output      [18:0] address,
	 output reg         flag_out
);

	 reg [25:0] instruction_reg;
	 wire [18:0] addr;
    // Estados da UC
    localparam FETCH    = 3'b000;
    localparam DECODE   = 3'b001;
	 localparam EXECUTE  = 3'b010;
    localparam MEMORY   = 3'b011;
	 localparam RESPONSE = 3'b100;
	 assign address = addr;
    reg [2:0] state;
	 wire [3:0] w_factor;
	 wire [2:0] w_opcode;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state       <= FETCH;
            start_alu   <= 1'b0;
				flag_out    <= 1'b0;
          
        end else begin
            case (state)
                FETCH: begin
						  
                    start_alu   <= 1'b0;
						  if(flag_in) begin
							  flag_out      <= 1'b0;
							  instruction_reg <= instruction;
							  state <= DECODE;
						  end 
						  else state <= FETCH;
                end
			
					 DECODE: begin
						  
						  if(w_opcode == 3'b110 || w_opcode == 3'b111) begin
							   state <= MEMORY;
						  end
						  else begin
								factor <= w_factor;
								opcode <= w_opcode;
								state <= EXECUTE;
						  end
					 
					 end
					 
                // Estado de execução da ALU
                EXECUTE: begin
                    start_alu <= 1'b1;
                    if (alu_done) begin
                        start_alu   <= 1'b0;
                        state       <= RESPONSE;
                    end
                end
					 
					 MEMORY: begin
						write   <= 1'b1;
						state	  <= RESPONSE;
					 end

                RESPONSE: begin
						  flag_out    <= 1'b1;
						  write		  <= 1'b0;
                    if (!flag_in) begin
                        state      <= FETCH;
                    end
                end

                default: state <= FETCH;
            endcase
        end
    end
	 
	instruction_decoder decoder (
		.instruction(instruction_reg),
		.opcode(w_opcode),
		.factor(w_factor),
		.data(data),
		.address(addr),
	 );

endmodule