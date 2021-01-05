module receiver(
input clk,
input clk_enable,
input reset,
input UART_RX,
input parity_mode,
input word_size,
input clear_PE,
input clear_FE,
output PE,
output FE,
output Rx_available,
output [8:0]RX_FIFO
);
reg [3:0] phase;
reg [3:0] state, nextstate;
reg [2:0] checkbit;
reg [2:0] checkbit0, checkbit1, checkbit2, checkbit3, checkbit4;
reg [2:0] checkbit5, checkbit6, checkbit7, checkbitP, checkbitS;
reg [8:0] data;
reg r_available;

parameter IDLE = 4'b0000, LOOK_FE = 4'b0001;
parameter VSTART = 4'b0010, RxBIT0 = 4'b0011;
parameter RxBIT1 = 4'b0100, RxBIT2 = 4'b0101;
parameter RxBIT3 = 4'b0110, RxBIT4 = 4'b0111;
parameter RxBIT5 = 4'b1000, RxBIT6 = 4'b1001;
parameter RxBIT7 = 4'b1010, RxPARITY = 4'b1011;
parameter CSTOP = 4'b1100;

always@(posedge clk or posedge reset)
begin
      if(reset)
		state <= IDLE;
		else if(clk_enable)
		state <= nextstate;
end

always@(posedge clk_enable)
begin
     phase <= phase + 1'b1;
	  
	  case(state)
	      IDLE:
			begin
			r_available <= 1'b0;
			if(UART_RX) begin
			if(phase < 4'd8)
			 nextstate <= IDLE;
			else if(phase == 4'd8)
			 nextstate <= LOOK_FE;
			end
			
			else begin
			 phase <= 4'b0;
			 nextstate <= IDLE;
			end
			
			end
			
			LOOK_FE:
			begin
			
			if(!UART_RX)begin
			 phase <= 4'b0;
			 nextstate <= VSTART;
			end
			
			else
			 nextstate <= LOOK_FE;
			end
			
	      VSTART:
	      begin
			if(phase < 4'd7)
			nextstate <= VSTART;
			else if((phase == 4'd7) && (~UART_RX)) begin
			checkbit[0] <= UART_RX;
			nextstate <= VSTART;
			end
			else if((phase == 4'd8) && (checkbit[0] == 1'b0)) begin
         checkbit[1] <= UART_RX;
         nextstate <= VSTART;			
         end  
			else if((phase == 4'd9) && (checkbit[1] == 1'b0)) begin
         checkbit[2] <= UART_RX;
         nextstate <= VSTART;			
         end
         else if ((phase < 4'd15) && (checkbit[2] == 1'b0))
         nextstate <= VSTART;		
         else if ((phase == 4'd15) && (checkbit[2] == 1'b0))
         nextstate <= RxBIT0;
         else
         nextstate <= IDLE;			
         end	
	
         RxBIT0:
	      begin
			if(phase < 4'd7)
			nextstate <= RxBIT0;
			else if((phase == 4'd7)) begin
			checkbit0[0] <= UART_RX;
			nextstate <= RxBIT0;
			end
			else if((phase == 4'd8) && (checkbit0[0] == UART_RX)) begin
         checkbit0[1] <= UART_RX;
         nextstate <= RxBIT0;			
         end  
			else if((phase == 4'd9) && (checkbit0[1] == checkbit0[0])) begin
         checkbit0[2] <= UART_RX;
         nextstate <= RxBIT0;	
         end
	      else if((phase == 4'd10) && (checkbit0[2] == checkbit0[1]))
	      data[0]<= checkbit0[2];				
         else if ((phase < 4'd15) && (checkbit0[2] == checkbit0[1]))
         nextstate <= RxBIT0;		
         else if ((phase == 4'd15) && (checkbit0[2] == checkbit0[1]))
         nextstate <= RxBIT1;
         else
         nextstate <= IDLE;			
         end
         
			RxBIT1:
	      begin
			if(phase < 4'd7)
			nextstate <= RxBIT1;
			else if((phase == 4'd7)) begin
			checkbit1[0] <= UART_RX;
			nextstate <= RxBIT1;
			end
			else if((phase == 4'd8) && (checkbit1[0] == UART_RX)) begin
         checkbit1[1] <= UART_RX;
         nextstate <= RxBIT1;			
         end  
			else if((phase == 4'd9) && (checkbit1[1] == checkbit1[0])) begin
         checkbit1[2] <= UART_RX;
         nextstate <= RxBIT1;	
         end
	      else if((phase == 4'd10) && (checkbit1[2] == checkbit1[1]))
	      data[1]<= checkbit1[2];				
         else if ((phase < 4'd15) && (checkbit1[2] == checkbit1[1]))
         nextstate <= RxBIT1;		
         else if ((phase == 4'd15) && (checkbit1[2] == checkbit1[1]))
         nextstate <= RxBIT2;
         else
         nextstate <= IDLE;			
         end
		
			RxBIT2:
	      begin
			if(phase < 4'd7)
			nextstate <= RxBIT2;
			else if((phase == 4'd7)) begin
			checkbit2[0] <= UART_RX;
			nextstate <= RxBIT2;
			end
			else if((phase == 4'd8) && (checkbit2[0] == UART_RX)) begin
         checkbit2[1] <= UART_RX;
         nextstate <= RxBIT2;			
         end  
			else if((phase == 4'd9) && (checkbit2[1] == checkbit2[0])) begin
         checkbit2[2] <= UART_RX;
         nextstate <= RxBIT2;	
         end
	      else if((phase == 4'd10) && (checkbit2[2] == checkbit2[1]))
	      data[2]<= checkbit2[2];				
         else if ((phase < 4'd15) && (checkbit2[2] == checkbit2[1]))
         nextstate <= RxBIT2;		
         else if ((phase == 4'd15) && (checkbit2[2] == checkbit2[1]))
         nextstate <= RxBIT3;
         else
         nextstate <= IDLE;			
         end

			RxBIT3:
	      begin
			if(phase < 4'd7)
			nextstate <= RxBIT3;
			else if((phase == 4'd7)) begin
			checkbit3[0] <= UART_RX;
			nextstate <= RxBIT3;
			end
			else if((phase == 4'd8) && (checkbit3[0] == UART_RX)) begin
         checkbit3[1] <= UART_RX;
         nextstate <= RxBIT3;			
         end  
			else if((phase == 4'd9) && (checkbit3[1] == checkbit3[0])) begin
         checkbit3[2] <= UART_RX;
         nextstate <= RxBIT3;	
         end
	      else if((phase == 4'd10) && (checkbit3[2] == checkbit3[1]))
	      data[3]<= checkbit3[2];				
         else if ((phase < 4'd15) && (checkbit3[2] == checkbit3[1]))
         nextstate <= RxBIT3;		
         else if ((phase == 4'd15) && (checkbit3[2] == checkbit3[1]))
         nextstate <= RxBIT4;
         else
         nextstate <= IDLE;			
         end		
		
			RxBIT4:
	      begin
			if(phase < 4'd7)
			nextstate <= RxBIT4;
			else if((phase == 4'd7)) begin
			checkbit4[0] <= UART_RX;
			nextstate <= RxBIT4;
			end
			else if((phase == 4'd8) && (checkbit4[0] == UART_RX)) begin
         checkbit4[1] <= UART_RX;
         nextstate <= RxBIT4;			
         end  
			else if((phase == 4'd9) && (checkbit4[1] == checkbit4[0])) begin
         checkbit4[2] <= UART_RX;
         nextstate <= RxBIT4;	
         end
	      else if((phase == 4'd10) && (checkbit4[2] == checkbit4[1]))
	      data[4]<= checkbit4[2];				
         else if ((phase < 4'd15) && (checkbit4[2] == checkbit4[1]))
         nextstate <= RxBIT4;		
         else if ((phase == 4'd15) && (checkbit4[2] == checkbit4[1]))
         nextstate <= RxBIT5;
         else
         nextstate <= IDLE;			
         end	
		
			RxBIT5:
	      begin
			if(phase < 4'd7)
			nextstate <= RxBIT5;
			else if((phase == 4'd7)) begin
			checkbit5[0] <= UART_RX;
			nextstate <= RxBIT5;
			end
			else if((phase == 4'd8) && (checkbit5[0] == UART_RX)) begin
         checkbit5[1] <= UART_RX;
         nextstate <= RxBIT5;			
         end  
			else if((phase == 4'd9) && (checkbit5[1] == checkbit5[0])) begin
         checkbit5[2] <= UART_RX;
         nextstate <= RxBIT5;	
         end
	      else if((phase == 4'd10) && (checkbit5[2] == checkbit5[1]))
	      data[5]<= checkbit5[2];				
         else if ((phase < 4'd15) && (checkbit5[2] == checkbit5[1]))
         nextstate <= RxBIT5;		
         else if ((phase == 4'd15) && (checkbit5[2] == checkbit5[1]))
         nextstate <= RxBIT6;
         else
         nextstate <= IDLE;			
         end		
			
			RxBIT6:
		   begin
			if(phase < 4'd7)
			nextstate <= RxBIT6;
			else if((phase == 4'd7)) begin
			checkbit6[0] <= UART_RX;
			nextstate <= RxBIT6;
			end
			else if((phase == 4'd8) && (checkbit6[0] == UART_RX)) begin
         checkbit6[1] <= UART_RX;
         nextstate <= RxBIT6;			
         end  
			else if((phase == 4'd9) && (checkbit6[1] == checkbit6[0])) begin
         checkbit6[2] <= UART_RX;
         nextstate <= RxBIT6;	
         end
	      else if((phase == 4'd10) && (checkbit6[2] == checkbit6[1]))
	      data[6]<= checkbit6[2];				
         else if ((phase < 4'd15) && (checkbit6[2] == checkbit6[1]))
         nextstate <= RxBIT6;	
         else if ((phase == 4'd15) && (checkbit6[2] == checkbit6[1])) begin
				if(word_size)                           //parity change
					nextstate <= RxBIT7;
				else if(parity_mode == 2'b00)
					nextstate <= CSTOP;
				else	
				   nextstate <= RxPARITY;
         end       			
			 
         else
         nextstate <= IDLE;				
		   end

			RxBIT7:
		   begin
			if(phase < 4'd7)
			nextstate <= RxBIT7;
			else if((phase == 4'd7)) begin
			checkbit7[0] <= UART_RX;
			nextstate <= RxBIT7;
			end
			else if((phase == 4'd8) && (checkbit7[0] == UART_RX)) begin
         checkbit7[1] <= UART_RX;
         nextstate <= RxBIT7;			
         end  
			else if((phase == 4'd9) && (checkbit7[1] == checkbit7[0])) begin
         checkbit7[2] <= UART_RX;
         nextstate <= RxBIT7;	
         end
	      else if((phase == 4'd10) && (checkbit7[2] == checkbit7[1]))
	      data[7]<= checkbit7[2];				
         else if ((phase < 4'd15) && (checkbit7[2] == checkbit7[1]))
         nextstate <= RxBIT7;				
         else if ((phase == 4'd15) && (checkbit7[2] == checkbit7[1])) begin
            if((parity_mode == 2'b00)||(parity_mode == 2'b01))
					nextstate <= CSTOP;
				else	
				   nextstate <= RxPARITY;
         end       			
			 
         else
         nextstate <= IDLE;				
		   end	
	
         RxPARITY:
			begin 
         if (phase < 4'd15)
         nextstate <= RxPARITY;
         else if (phase == 4'd15)
         nextstate <= CSTOP;			
			end
			
	      CSTOP:
	      begin
			if(phase < 4'd7)
			nextstate <= CSTOP;
			else if((phase == 4'd7) && (UART_RX)) begin
			checkbitS[0] <= UART_RX;
			nextstate <= CSTOP;
			end
			else if((phase == 4'd8) && (checkbitS[0] == 1'b1)) begin
         checkbitS[1] <= UART_RX;
         nextstate <= CSTOP;			
         end  
			else if((phase == 4'd9) && (checkbitS[1] == 1'b1)) begin
         checkbitS[2] <= UART_RX;
         nextstate <= CSTOP;
         r_available <= 1'b1;			
         end
         else if ((phase < 4'd15) && (checkbitS[2] == 1'b1))
         nextstate <= CSTOP;		
         else if ((phase == 4'd15) && (checkbitS[2] == 1'b1))
         nextstate <= IDLE;
         else
         nextstate <= IDLE;			
         end				
					   	
			
	  endcase		
end

assign RX_FIFO = data;
assign Rx_available = r_available;
endmodule