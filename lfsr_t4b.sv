module lfsr_t4b(input logic clk,
	     input logic[5:0]pc, 
	     output logic[0:7]P,P_next,
	     output logic[6:0]HD_avg);

logic[13:0]instr;
logic[6:0]tap;
logic[0:7]seed;
logic[7:0]r_addr;
logic[7:0]M[0:225];
logic[5:0]op;
logic[3:0]Ham=4'b0000;
logic[6:0]Ham2=7'b0000000;
logic[3:0]HD=4'b0000; 
logic[4:0]run_num=5'b00000;

int i;
always_comb			
begin				//program counter
case(pc)
6'b000000: instr= 14'b00000100100101; //config_L 0100101;
6'b000001: instr= 14'b00001000001111; //init_L 00001111;  
6'b000010: instr= 14'b00001100000000; //run_L; 
6'b000011: instr= 14'b00001100000000; //run_L;   
6'b000100: instr= 14'b00001100000000; //run_L;
6'b000101: instr= 14'b00001100000000; //run_L; 
6'b000110: instr= 14'b00001100000000; //run_L; 
6'b000111: instr= 14'b00001100000000; //run_L;
6'b001000: instr= 14'b00001100000000; //run_L;
6'b001001: instr= 14'b00001100000000; //run_L;
6'b001010: instr= 14'b00001100000000; //run_L;
6'b001011: instr= 14'b00001100000000; //run_L;
6'b001100: instr= 14'b00100100000000; //avg HD
6'b001101: instr= 14'b00000000000000; //Halt
endcase
end

always@(posedge clk)
begin
op=instr[13:8];

	if(op==6'b000001)  //config
	tap=instr[6:0];
	
	else if(op==6'b000010)begin //init seed
        seed=instr[7:0];
	P=seed;end

	else if(op==6'b000011)      //run_L 
	begin
		run_num=run_num+1;
		P[0]<=P[7];
		if(tap[6]==1'b1)
			P[1]<=P[7]^P[0];
		else    P[1]<=P[0];

		if(tap[5]==1'b1)
			P[2]<=P[7]^P[1];
		else    P[2]<=P[1]; 

		if(tap[4]==1'b1)
			P[3]<=P[7]^P[2];
		else    P[3]<=P[2];
	
		if(tap[3]==1'b1)
			P[4]<=P[7]^P[3];
		else    P[4]<=P[3];
 
        	if(tap[2]==1'b1)
			P[5]<=P[7]^P[4];
		else    P[5]<=P[4];

		if(tap[1]==1'b1)
			P[6]<=P[7]^P[5];
		else    P[6]<=P[5];
       		
		if(tap[0]==1'b1)
			P[7]<=P[7]^P[6];
		else    P[7]<=P[6];

	end
	else if(op==6'b000100)   // init_addr
		r_addr=instr[7:0];

	
	else if(op==6'b000101)   //store 
		M[r_addr]=P;
	
	else if(op==6'b000110)  //add_addr
		r_addr=r_addr+instr[7:0];	
	
	else if(op==6'b000111)  //load
		P=M[r_addr];
     
        else if(op==6'b001000)  //st_M_HD
		M[r_addr]=HD;

	else if(op==6'b001001)  //avg HD
		begin HD_avg=Ham2/run_num;
			M[0]=HD_avg;end

	else if(op==6'b000000)  //halt
		$stop;
end

always_comb   // block for P_next
begin
P_next=P;
	begin
		P_next[0]<=P[7];
		if(tap[6]==1'b1) 
			P_next[1]<=P_next[7]^P_next[0];
		else    P_next[1]<=P_next[0];

		if(tap[5]==1'b1)
			P_next[2]<=P_next[7]^P_next[1];
		else    P_next[2]<=P_next[1]; 

		if(tap[4]==1'b1)
			P_next[3]<=P_next[7]^P_next[2];
		else    P_next[3]<=P_next[2];
	
		if(tap[3]==1'b1)
			P_next[4]<=P_next[7]^P_next[3];
		else    P_next[4]<=P_next[3];
 
        	if(tap[2]==1'b1)
			P_next[5]<=P_next[7]^P_next[4];
		else    P_next[5]<=P_next[4];

		if(tap[1]==1'b1)
			P_next[6]<=P_next[7]^P_next[5];
		else    P_next[6]<=P_next[5];
       		
		if(tap[0]==1'b1)
			P_next[7]<=P_next[7]^P_next[6];
		else    P_next[7]<=P_next[6]; 
	end
end
always_comb
begin
	for(i=0;i<8;i++)
		begin
			if(P[i]!=P_next[i])
				begin
				Ham=Ham+1;
				Ham2=Ham2+1;
	end
	end
HD=Ham;
Ham=4'b0000;
end
endmodule     
