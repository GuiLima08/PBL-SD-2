module coprocessor (
    input  wire        		clk,
    input  wire        		rst_n,
	 input  wire [25:0] instruction,
	 input  wire flag_in,
    input  wire [7:0]  		color_in,         // pixel lido da RAM
	 output wire [9:0]  		CURRENT_HEIGHT,   // altura atual da imagem
	 output wire [9:0]  		CURRENT_WIDTH,		// largura atual da imagem
    output wire [18:0] 	   rdaddr_in_ram,      // endereco para leitura da RAM
	 output wire [18:0]     wraddr_in_ram, 
    output wire [7:0] 		color_out,        // pixel para escrita na RAM
    output wire [18:0] 	   addr_out_ram,     // endereco para escrita na RAM
    output wire        		wren,             // ativa escrita na RAM
	 output wire				wren_ini,
	 output wire [7:0]		data,
	 output wire				flag_out
);

    localparam ORIGINAL_WIDTH  = 10'd160;  // Largura da imagem padrao 
    localparam ORIGINAL_HEIGHT = 10'd120;  // Altura da imagem padrao

	 // ======================================
    // Fios
    // ======================================
	 wire [3:0] factor;
	 wire [2:0] opcode;
	 wire [18:0] address;
	 wire enable;
	 wire [18:0] addr_alu;
	 assign rdaddr_in_ram = addr_alu;
	 
    // ======================================
    // Sinais de controle para UC e ALU
    // ======================================
    wire start_alu;
    wire alu_done;

    // Instancia UC
    control_unit uc_inst (
        .clk(clk),
        .rst_n(rst_n),
		  .instruction(instruction),
		  .flag_in(flag_in),
        .alu_done(alu_done),
		  .addr_alu(addr_alu),
		  .write(wren_ini),
        .start_alu(start_alu),
		  .opcode(opcode),
		  .factor(factor),
		  .data(data),
		  .address(wraddr_in_ram),
		  .flag_out(flag_out)
    );

    // Instancia ALU
    alu alu_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_alu),
        .algo_sel(opcode),
        .FACTOR_IN(factor),
        .FACTOR_OUT(factor),
        .ORIGINAL_WIDTH(ORIGINAL_WIDTH),
        .ORIGINAL_HEIGHT(ORIGINAL_HEIGHT),
        .CURRENT_WIDTH(CURRENT_WIDTH),
        .CURRENT_HEIGHT(CURRENT_HEIGHT),
        .color_in(color_in),
        .addr_in(addr_alu),
        .addr_out(addr_out_ram),
        .data_out(color_out),
        .wren(wren),
        .alu_process_done(alu_done)
    );
	 
endmodule