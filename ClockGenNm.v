// Divide by N clock generator
module ClockGenNm(clock, reset,enable, BRD, baud_out, count, target);
input clock, reset, enable;
input [31:0] BRD;
output reg baud_out;
output reg [31:0] count;
output reg [31:0] target;
always @ (posedge clock, negedge reset)
begin
if (reset == 0)
begin
baud_out <= 1'b0;
count <= 32'b0;
target <= BRD;
end
else if (clock & enable == 1'b1)
	begin
		count <= count + 8'b10000000;
		if (count[31:7] == target[31:7])
		begin
			target <= target + BRD;
			baud_out <= ~baud_out;
		end
	end
		else baud_out <= baud_out;

end
endmodule
