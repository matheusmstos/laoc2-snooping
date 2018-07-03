module maq_emissora(bit_escolha, estado, op, estado_op, estado_prox_emissor, estado_wb_emissor, emissor_bus);

input bit_escolha; //escolha qual das maquinas de estado
input [1:0] estado; //estado atual da mauqiona
input op; //leitura ou escrita
input estado_op; //se a op de leitura ou escrita de miss ou hit

output reg [1:0] estado_prox_emissor; //qual o proximo estado?
output reg estado_wb_emissor; //vai ter write-back?
output reg [1:0] emissor_bus; //bus geral que liga todos os processadores

parameter exclusive = 2'b10;
parameter shared   = 2'b01;
parameter invalid  = 2'b00;

parameter read  = 1'b0;
parameter write = 1'b1;

parameter read_miss = 2'b11;
parameter write_miss = 2'b01;
parameter invalidate = 2'b10;

parameter hit = 1'b1;
parameter miss = 1'b0;

always @(op or bit_escolha) begin
	if(bit_escolha == 0) begin
		estado_wb_emissor = 0;
		emissor_bus = 0;

		case(estado)
			exclusive: begin
				if(estado_op == hit) begin
					estado_prox_emissor = exclusive;
				end
				else if (op == read) begin
					estado_prox_emissor = shared;
					estado_wb_emissor = 1'b1;
					emissor_bus = read_miss;
					end
				else if (op == write) begin
					estado_prox_emissor = exclusive;
					estado_wb_emissor = 1'b1;
					emissor_bus = write_miss;
				end
			end

			shared: begin
				if(op == read) begin
					estado_prox_emissor = shared;
					if(estado_op == miss) begin
						emissor_bus = read_miss;
					end
				end
				else if(op == write) begin
					estado_prox_emissor = exclusive;
					if(estado_op == hit) begin
						emissor_bus = invalidate;
					end
					else if(estado_op == miss) begin
						emissor_bus = write_miss;
					end
				end
			end
			invalid: begin
				if(op == read) begin
					estado_prox_emissor = shared;
					emissor_bus = read_miss;
				end
				else if(op == write) begin
					estado_prox_emissor = exclusive;
					emissor_bus = write_miss;
				end
			end
		endcase
	end
end
endmodule

module maq_receptora(bit_escolha, receptor_bus, estado, estado_prox_receptor, estado_wb_receptor, aborta_acesso_mem);

input bit_escolha; //escolha qual das maquinas de estado
input [1:0] receptor_bus; //bus geral que liga todos os processadores
input [1:0] estado; //estado atual da mauqiona

output reg [1:0] estado_prox_receptor; //qual o proximo estado?
output reg estado_wb_receptor; //vai ter write-back?
output reg aborta_acesso_mem;

parameter exclusive = 2'b10;
parameter shared   = 2'b01;
parameter invalid  = 2'b00;

parameter read  = 1'b0;
parameter write = 1'b1;

parameter read_miss = 2'b11;
parameter write_miss = 2'b01;
parameter invalidate = 2'b10;

parameter hit = 1'b1;
parameter miss = 1'b0;


always @(estado or bit_escolha) begin
	if(bit_escolha == 1) begin
		estado_wb_receptor = 0;
		aborta_acesso_mem = 0;
		estado_prox_receptor = estado; //porque no invalido ele mantem

		case(estado)
			exclusive: begin
				if(receptor_bus == write_miss) begin
					aborta_acesso_mem = 1'b1;
					estado_wb_receptor = 1'b1;
					estado_prox_receptor = invalid;
				end
				else if(receptor_bus == read_miss) begin
					estado_prox_receptor = shared;
					aborta_acesso_mem = 1'b1;
					estado_wb_receptor = 1'b1;
				end
			end
			shared: begin
				if(receptor_bus == write_miss) begin
					estado_prox_receptor = invalid;
				end
				else if(receptor_bus == read_miss) begin
					estado_prox_receptor = shared;
				end
				else if(receptor_bus == invalidate) begin
					estado_prox_receptor = invalid;
				end
			end
		endcase
	end
end
endmodule

module Snooping (SW,LEDR,LEDG);

input  [17:0]SW;
output [17:0]LEDR;
output [7:0]LEDG;

wire bit_escolha = SW[0];
wire op = SW[1];
wire estado_op = SW[2];
wire [1:0]estado = SW[4:3];

wire [1:0]emissor_bus;
wire [1:0]estado_prox_emissor;
wire estado_wb_emissor;

wire [1:0] receptor_bus = SW[2:1];
wire aborta_acesso_mem;
wire [1:0]estado_prox_receptor;
wire estado_wb_receptor;

maq_emissora me1(bit_escolha, estado, op, estado_op, estado_prox_emissor, estado_wb_emissor, emissor_bus);
maq_receptora mr1 (bit_escolha, receptor_bus, estado, estado_prox_receptor, estado_wb_receptor, aborta_acesso_mem);

assign LEDG[7:6] = estado;
assign LEDG[5:4] = estado_prox_emissor;
assign LEDG[3:2] = emissor_bus;
assign LEDG[0] = estado_wb_emissor;

assign LEDR[0] = aborta_acesso_mem;
assign LEDR[1] = estado_wb_receptor;
assign LEDR[3:2] = estado_prox_receptor;
assign LEDR[5:4] = estado;
assign LEDR[17] = bit_escolha;

endmodule 