module FIFO (
output reg[8:0] DataOut,                         //Data output
output Full, Empty, OV,                          //Status outputs
output reg[3:0] ReadPtr, WritePtr,               //Read and write pointers
       
input [8:0] DataIn,                              //Data input
input Read, Write, Clock, Clear, ClearOV         //Control inputs
);
reg[4:0] PtrDiff;                                //Pointer difference
reg[8:0] Stack [15:0];                           //Storage array

assign Empty=(PtrDiff==1'b0)?1'b1:1'b0;          //Empty?
assign Full=(PtrDiff>=5'd16)?1'b1:1'b0;          //Full?
assign OV=(PtrDiff>=5'd17)?1'b1:1'b0;            //Overflow?

    always @ (posedge Clock) begin      //Data transfers
       if (!Clear) begin                                 //Test for Clear
         DataOut<= 1'b0;                                  //Clear data out buffer
         ReadPtr<= 1'b0;                                  //Clear read pointer
         WritePtr<= 1'b0;                                 //Clear write pointer
         PtrDiff<= 1'b0;                                  //Clear pointer difference
       end
       else begin                                       //Begin read or write operations
			 if(Read && Write) begin
			if(!Empty && !OV && !Full) begin
           Stack[WritePtr] = DataIn;                       //store data in stack
           WritePtr = WritePtr+ 1'b1;                       //Update write pointer
           PtrDiff = PtrDiff+ 1'b1;
           DataOut = Stack[ReadPtr];                        //Transfer data to output
           ReadPtr = ReadPtr+ 1'b1;                         //Update read pointer
           PtrDiff = PtrDiff-1'b1;                          //update pointer difference			  
			end
         else begin
			if(Full)
			PtrDiff<= 5'd17;                                 //Update pointer difference
			else if(OV) begin
			  DataOut<= Stack[ReadPtr];                        //Transfer data to output
           ReadPtr<= ReadPtr+ 1'b1;                         //Update read pointer
           PtrDiff<= PtrDiff-2'b10;                         //update pointer difference
			end
         end			
			end
        else if (Read && !Empty)                              //Check for read
         if (!OV) begin
           DataOut<= Stack[ReadPtr];                        //Transfer data to output
           ReadPtr<= ReadPtr+ 1'b1;                         //Update read pointer
           PtrDiff<= PtrDiff-1'b1;                          //update pointer difference
         end
         else begin
           DataOut<= Stack[ReadPtr];                        //Transfer data to output
           ReadPtr<= ReadPtr+ 1'b1;                         //Update read pointer
           PtrDiff<= PtrDiff-2'b10;                         //update pointer difference
         end
        else if (Write)                                  //Check for write
         if (!Full) begin                                 //Check for Full
           Stack[WritePtr] <= DataIn;                       //If not full store data in stack
           WritePtr<= WritePtr+ 1'b1;                       //Update write pointer
           PtrDiff<= PtrDiff+ 1'b1;                         //Update pointer difference
         end
         else begin
           PtrDiff<= 5'd17;                                 //Update pointer difference
         end
			else if(ClearOV) begin
			if(OV)
			PtrDiff<= PtrDiff-1'b1;
			end
       end
		end

endmodule