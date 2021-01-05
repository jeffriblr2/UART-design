module uart(reset, clk, UART_TX, UART_RX, UART_CLK_OUT, address, chipselect, read, readdata, write, writedata);

    // Clock, and reset
    input   clk, reset;

    // Avalon MM interface (8 word aperature)
    input             read, write, chipselect;
    input [2:0]       address;
    input [31:0]      writedata;
    output reg [31:0] readdata;

    input UART_TX, UART_RX;
    output UART_CLK_OUT;
	 
    // register numbers
    parameter DATA_REG             = 3'b000;
	 
    // internal    
    reg addressmatch, lastwrite, lastread, w_r, r_d;
    wire W_r, R_d;	 
    reg [31:0] latch_data;	
	 reg [31:0] send_data;
	
// Logic
always @(posedge clk) begin
if(address == 3'b000)
addressmatch <= 1'b1;
else
addressmatch <= 1'b0;
end

always @(posedge clk)
begin
lastwrite <= write;
w_r <= write & (~lastwrite) & chipselect & addressmatch;
end

always @(posedge clk)
begin
lastread  <= read;
r_d <= read & (~lastread) & chipselect & addressmatch;
end

assign W_r = w_r;
assign R_d = r_d;	

    // read register
    always @ (*)
    begin
        if (read && chipselect)
            case (address)
                DATA_REG: 
                    readdata = latch_data;

            endcase
        else
            readdata = 32'b0;
    end
	 
    // write register
    always @ (posedge clk)
    begin
        if (reset)
        begin
            send_data[31:0] <= 32'b0;

        end
        else
        begin
            begin
                if (write && chipselect)
                begin
                    case (address)
                        DATA_REG: 
                            send_data <= writedata;

                    endcase
                end
            end
        end
    end	 
	 
FIFO tx_fifo(

.DataOut(latch_data[8:0]),
//.Full(Full), .Empty(Empty), .OV(OV),
//.ReadPtr(latch_data[3:0]),
//.WritePtr(WritePtr),
.DataIn(send_data[8:0]),
.Clock(clk),
//.ClearOV(ClearOV),
.Clear(reset),
.Write(W_r),
.Read(R_d)
);	 
	 
endmodule