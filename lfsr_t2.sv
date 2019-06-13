module lfsr_t2(input logic clk,
	     input logic[5:0]pc, 
	     output logic[0:7]q);

logic[13:0]instr;
logic[6:0]tap;
logic[0:7]seed;
logic[7:0]r_addr;
logic[7:0]M[0:225]; 
logic[5:0]op;

always_comb			
begin				//program counter
case(pc)
6'b000000: instr= 14'b00000100100101; //config_L 0100101;
6'b000001: instr= 14'b00001000001111; //init_L 00001111;  
6'b000010: instr= 14'b00001100000000; //run_L;
6'b000011: instr= 14'b00010000000000; //init_addr 00000000;; 
6'b000100: instr= 14'b00010100000000; //st_M_L;
6'b000101: instr= 14'b00001100000000; //run_L; 
6'b000110: instr= 14'b00011000000001; //add_addr 00000001;
6'b000111: instr= 14'b00010100000000; //st_M_L;
6'b001000: instr= 14'b00001100000000; //run_L; 
6'b001001: instr= 14'b00010100000000; //st_M_L;
6'b001010: instr= 14'b00011000000010; //add_addr 00000010;
6'b001011: instr= 14'b00010100000000; //st_M_L;
6'b001100: instr= 14'b00011100000000; //ld_M_L;
6'b001101: instr= 14'b00000000000000; //halt;
endcase
end

always_comb
begin
op=instr[13:8];

	if(op==6'b000001)  //config
	tap=instr[6:0];
	
	else if(op==6'b000010)begin //init seed
        seed=instr[7:0];
	q=seed;end

	else if(op==6'b000011) begin //run_L
	
		q[0]<=q[7];
		if(tap[6]==1'b1)
			q[1]<=q[7]^q[0];
		else    q[1]<=q[0];

		if(tap[5]==1'b1)
			q[2]<=q[7]^q[1];
		else    q[2]<=q[1]; 

		if(tap[4]==1'b1)
			q[3]<=q[7]^q[2];
		else    q[3]<=q[2];
	
		if(tap[3]==1'b1)
			q[4]<=q[7]^q[3];
		else    q[4]<=q[3];
 
        	if(tap[2]==1'b1)
			q[5]<=q[7]^q[4];
		else    q[5]<=q[4];

		if(tap[1]==1'b1)
			q[6]<=q[7]^q[5];
		else    q[6]<=q[5];
       		
		if(tap[0]==1'b1)
			q[7]<=q[7]^q[6];
		else    q[7]<=q[6];

		end 
	
	else if(op==6'b000100)   // init_addr
		r_addr=instr[7:0];

	
	else if(op==6'b000101)   //store 
		M[r_addr]=q;
	
	else if(op==6'b000111)  //load
		q=M[r_addr];

	else if(op==6'b000110)  //add_addr
		r_addr=r_addr+instr[7:0];
     
        else if(op==6'b000000)
		$stop;
end
endmodule     
