/*
Instrucao:
	[6:5] 	= qual processador
	[4] 	= read ou write
	[3] 	= tag
	[2:0] 	= dado

Processador:
	Cache:
		[5:4] 	= estado (exclusive, shared, invalid)
		[3] 	= tag
		[2:0] 	= dado
	Requisicao:
		[2] = read ou write
		[1] = Hit ou miss
		[0] = EstadoCompartilhado

Memoria:
	[3] 	= tag
	[2:0] 	= dado

Barramento:
	[10] 	= Se há um dado vindo da CPU
	[9:8]	= Qual CPU o dado está vindo
	[7]		= Se há writeback do dado
	[6]		= TAG para o qual irá fazer o writeback
	[5:4]	= Mensagem do Barramento
	[3]		= TAG
	[2:0]	= Dado
*/
module Snooping
	(
		input clock,
		input [6:0]instrucao
	);

	wire [10:0]bus1;
	wire [10:0]bus2;
	wire [10:0]bus3;
	wire [10:0]busMem;
	wire [10:0]busWire;

	processador p1(clock, 2'b01, instrucao, busWire, bus1);
	processador p2(clock, 2'b10, instrucao, busWire, bus2);
	processador p3(clock, 2'b11, instrucao, busWire, bus3);
	memoria m1(clock, busWire, busMem);
	bus b(clock, bus1, bus2, bus3, busMem, busWire);
endmodule

module processador
	(
		input clock,
		input [6:0] instrucao,
		input [1:0] processador,
		input [10:0] barramento_in,

		output reg [10:0] barramento_out,
	);

	reg [5:0] cache = 6'b0;
	reg write_back;
	reg req_for_rec; //requisicao para maquina receptora
	reg req_for_emi; //requisicao para maquina emissora
	reg bit_de_escolha;
	reg [2:0] info_req; //info da requisicao

	wire[1:0] estado;

	parameter exclusive = 2'b10;
	parameter shared   = 2'b01;
	parameter invalid  = 2'b00;

	parameter read  = 1'b0;
	parameter write = 1'b1;

	//mensagem
	parameter read_miss = 2'b11; //pede dado a outros processadores
	parameter invalidate = 2'b10; //sinal para invalidar um dado
	parameter read_miss_retorno = 2'b01; //retorna dado do pedido de read_miss


	always @ (posedge clock) begin
		// req_for_emi = 0;
		// req_for_rec = 0;
		bit_de_escolha = 1; //maquina receptora
		barramento_out = 11'b0;
		cache[5:4] = estado;

		//o processador requisitado existe?
		if (instrucao[6:5] == processador) begin
			// req_for_emi = 1;
			bit_de_escolha = 0; //maquina emissora
			info_req[2] = instrucao[4]; //r ou w
			info_req[0] = 0; //nao eh compartilhado

			//Read hit
			//read && mesmas tags && estado do bloco diferente de invalido
			if (instrucao[4] = read && instrucao[3] == cache[3]
				&& cache[5:4] != invalid) begin

				info_req[1] = 1; //hit
				barramento_out[3] = cache[3]; //envia tag
				barramento_out[2:0] = cache[2:0]; //envia dado
			end

			//Read  miss
			else if (instrucao[4] = read) begin
				barramento_out[9:8] = processador; //proc emissor
				barramento_out[5:4] = read_miss; //mensagem
				barramento_out[3] = instrucao[3]; //tag
				//req_for_emi = 0;

				if (Cache[5:4] == modified) begin
					barramento_out[7] = 1; //tem wb
					barramento_out[6] = cache[3]; //tag do wb
					barramento_out[2:0] = cache[2:0]; //dado do wb
				end
			end

			//Write hit
			//write && mesmas tags && estado do bloco diferente de invalido
			else if (instrucao[4] = write && instrucao[3] == cache[3]
				&& cache[5:4] != invalid) begin

				info_req[1] = 1; //hit
				cache[2:0] = instrucao [2:0]; //escreve

				if (cache[5:4] = shared) begin
					barramento_out[9:8] = processador; //proc emissor
					barramento_out[5:4] = invalidate; //mensagem
					barramento_out[3] = cache[3]; //tag
				end
			end

			//Write Miss
			else if (instrucao[4] = write) begin
				info_req[1] = 0;
				barramento_out[9:8] = processador; //proc emissor
				barramento_out[5:4] = invalidate; //mensagem
				barramento_out[3] = instrucao[3]; //tag

				cache[3] = instrucao[3]; //tag proc = tag inst
				cache[2:0] = instrucao[2:0]; //dado proc = dado inst

				if (Cache[5:4] == modified) begin
					barramento_out[7] = 1; //tem wb
					barramento_out[6] = cache[3]; //tag do wb
					barramento_out[2:0] = cache[2:0]; //dado do wb
				end

			end
		end

		//processadores que recebem uma mensagem
		else if (barramento_in[5:4] != 2'b00) begin

			//invalida tag
			if(barramento_in[5:4] == invalidate
				&& barramento_in[3] == cache[3]
				&& barramento_in[9:8] != processador) begin

				cache[5:4] = invalid;
			end

			//busca tag
			else if(barramento_in[5:4] == read_miss
				&& barramento_in[3] == cache[3]
				&& cache[5:4] != invalid) begin

				if(cache[5:4] = modified) begin
					barramento_out[7] = 1; //tem wb
					barramento_out[6] = cache[3]; //tag do wb
				end

				barramento_out[10] = 1; //vem dado da CPU
				barramento_out[9:8] = barramento_in[9:8]; //qual CPU
				barramento_out[5:4] = read_miss_retorno; //qual mensagem
				barramento_out[3] = cache[3]; //em qual tag
				barramento_out[2:0] = cache[2:0]; //qual dado
			end

			//retorno de um pedido
			else if(barramento_in[5:4] == read_miss_retorno
				&& barramento_in[9:8] == processador) begin

				if(barramento_in[10] == 1)
					cache[5:4] = shared;
				end
				else
				 	cache[5:4] = shared;
				end

				cache[3] = barramento_in[3]; //tag
				cache[2:0] = barramento_in[2:0]; //dado
			end
		end
	end

	maq_emissora pistolinha(clock, bit_escolha, cache[5:4], info_req[2],
		info_req[1], info_req[0], estado);
endmodule

/*
Barramento:
	[10] 	= Se há um dado vindo da CPU
	[9:8]	= Qual CPU o dado está vindo
	[7]		= Se há writeback do dado
	[6]		= TAG para o qual irá fazer o writeback
	[5:4]	= Mensagem do Barramento
	[3]		= TAG
	[2:0]	= Dado
*/

module memoria
	(
		input clock,
		input [10:0] barramneto_in,
		input [10:0] barramento_out
	);

	reg [3:0] memoria[1:0]

	//mensagem
	parameter read_miss = 2'b11; //pede dado a outros processadores
	parameter invalidate = 2'b10; //sinal para invalidar um dado
	parameter read_miss_retorno = 2'b01; //retorna dado do pedido de read_miss

	always @ (posedge clock) begin
		barramento_out = 11'b0;

		//busca dado da mem se der read miss
		if(barramento_in[5:4] == read_miss) begin
			barramento_out[10] = 0;
			barramento_out[9:8] = barramento_in[9:8];
			barramento_out[5:4] = read_miss_retorno;
			barramento_out[3] = barramento_in[3];

			if (barramento_in[3] = 0;) begin
				barramento_out[2:0] = memoria[0][2:0];
			end
			else begin
				barramento_out[2:0] = memoria[1][2:0];
			end
		end

		//tem write back?
		if (barramento_in[7] == 1) begin
			if (barramento_in[6] == 0) begin
				memoria[0][2:0] = barramento_out[2:0]
			end
			else
				memoria[1][2:0] = barramento_out[2:0]
			end
		end
	end
endmodule

module bus
	(
		input clock,
		input [10:0]bus1,
		input [10:0]bus2,
		input [10:0]bus3,
		input [10:0]busMem,
		output reg [10:0]busWire
	);

	always @(clock) begin
		busWire = 11'b00000000000;
		if(bus1[7] == 1 || bus1[5:4] != 2'b00)  busWire = bus1;
		else if(bus2[7] == 1 || bus2[5:4] != 2'b00)  busWire = bus2;
		else if(bus3[7] == 1 || bus3[5:4] != 2'b00)  busWire = bus3;
		else if(busMem[5:4] != 2'b00)  busWire = busMem;
	end
endmodule

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
