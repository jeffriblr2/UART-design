module transmitter(reset, clk, clk_enable, word_size, parity_mode, tx_request, tx_ack, tx_data, tx_out, tx_enable, tc_clk);

input reset,clk, clk_enable, word_size;
input[1:0] parity_mode;
input tx_request;
output  tx_ack;
input[8:0] tx_data;
output  tx_out;
input tx_enable;
output tc_clk;

reg[3:0] state;
reg[7:0] data;
reg      R_tx_out;
reg      R_tx_ack;
reg [3:0] nextstate;

reg lastclk,tx_clk_edge, tx_clk_enable;
wire [31:0] N;
wire rs;

//states
parameter START = 4'b0000, BIT0 = 4'b0001,  BIT1 = 4'b0010, BIT2 = 4'b0011;
parameter BIT3 = 4'b0100, BIT4 = 4'b0101, BIT5 = 4'b0110,  BIT6 = 4'b0111;
parameter BIT7 = 4'b1000,  TX_PARITY = 4'b1001, STOP = 4'b1010, IDLE = 4'b1011;
assign N = 32'd16;
always @(posedge clk)
begin

lastclk <= clk_enable;
tx_clk_edge <= clk_enable & (~lastclk);
end

always @(posedge clk or posedge reset)
begin
          if(reset)
			 state<=IDLE;
		    else if (tx_clk_enable)
           state<=nextstate;
end


always @(posedge tx_clk_enable)
	begin
				case(state)
					IDLE:
					   begin
					   if((tx_request == 1'b1))
						nextstate <= START;
						end
					START:
					   begin
						if((tx_request == 1'b1)) begin
						R_tx_ack <= 1'b1;
						R_tx_out <=1'b0;
						data<=tx_data[7:0];
						nextstate <= BIT0;
						end
						end
					BIT0:
					   begin
						R_tx_ack <= 1'b0;
						R_tx_out <= data[0];
						nextstate <= BIT1;
						end
					BIT1:
					   begin
						R_tx_out <= data[1];
						nextstate <= BIT2;
						end
					BIT2:
					   begin
						R_tx_out <= data[2];
						nextstate <= BIT3;
						end
					BIT3:
					   begin
						R_tx_out <= data[3];
						nextstate <= BIT4;
						end
					BIT4:
					   begin
						R_tx_out <= data[4];
						nextstate <= BIT5;
						end
					BIT5:
					   begin
						R_tx_out <= data[5];
						nextstate <= BIT6;
						end
					BIT6:
					   begin
						R_tx_out <= data[6];
						if(word_size)
							nextstate <= BIT7;
						else if(parity_mode == 2'b00)
							nextstate <= STOP;
						else 
							nextstate <= TX_PARITY;
							if(nextstate==STOP)
							R_tx_out<=1'b1;							
						end	
					BIT7:
					   begin
						R_tx_out <= data[7];
						if(parity_mode == 2'b00)
							nextstate <= STOP; 
						else
							nextstate <= TX_PARITY;
							if(nextstate==STOP)
							R_tx_out<=1'b1;							
						end	
					TX_PARITY:
					   begin
						if(parity_mode == 2'b10)
							R_tx_out <= 1'b1;
						else
							R_tx_out <= 1'b0;
							nextstate <= STOP;
							if(nextstate==STOP)
							R_tx_out<=1'b1;							
						end
					STOP:
					   begin
						if(state==STOP)
						R_tx_out <= 1'b1;
						nextstate <= IDLE;
						end			
				endcase
			end
		
	
	assign tx_out = R_tx_out;
	assign tx_ack = R_tx_ack;
	assign rs=~reset;
	assign tc_clk=tx_clk_enable;
			
dividex16 divideby16(
	.CLK(tx_clk_edge), //baudclock
	.CLEAR(rs),
	.OUT(tx_clk_enable) 	
);
 


endmodule
