module CA3_t7b(input logic clk,
	     input logic[5:0]pc, 
	     output logic[0:7]P,P_next, [7:0]Q);

logic[13:0]instr;
logic[6:0]tap;
logic[0:7]seed;
logic[7:0]r_addr,cycles,j,k,Seed_C,R;
logic[7:0]M[255:0];
logic[5:0]op;
logic[3:0]Ham=4'b0000;
logic[3:0]HD=4'b0000;  
int i;
always_comb			
begin				//program counter
case(pc)
6'b000000: instr= 14'b00101000010100; //config_C 00010100;
6'b000001: instr= 14'b00101100010000; //init_C 00010000;  
6'b000010: instr= 14'b00010011111010; //init_addr 11111010;   250
6'b000011: instr= 14'b00110000000000; //run_C;
6'b000100: instr= 14'b00110100000000; //st_M_C; M[250]=Q
6'b000101: instr= 14'b00011000000001; //add_addr 00000001; 251
6'b000110: instr= 14'b00110000000000; //run_C;
6'b000111: instr= 14'b00110100000000; //st_M_C;   M[251]=Q
6'b001000: instr= 14'b00011000000001; //add_addr 00000001; 252
6'b001001: instr= 14'b00110000000000; //run_C;
6'b001010: instr= 14'b00110100000000; //st_M_C; M[252]=Q
6'b001011: instr= 14'b00011000000001; //add_addr 00000001; 253
6'b001100: instr= 14'b00110000000000; //run_C;
6'b001101: instr= 14'b00110100000000; //st_M_C; M[253]=Q
6'b001110: instr= 14'b00011000000010; //add_addr 00000010; 255
6'b001111: instr= 14'b00110000000000; //run_C;
6'b010000: instr= 14'b00110100000000; //st_M_C; M[255]=Q
6'b010001: instr= 14'b00010011111010; //init_addr 11111010;   250
6'b010010: instr= 14'b00111100000000; //ld_M_C;  Q=M[250]
6'b010011: instr= 14'b00000000000000; //Halt
endcase
end

always@(posedge clk)
begin
op=instr[13:8];
cycles=instr[7:0];
	if(op==6'b000001)  //config
	tap=instr[6:0];
	
	else if(op==6'b000010)begin //init seed
        seed=instr[7:0];
	P=seed;end

	else if(op==6'b000011)      //run_L cycl1
	begin
	   if(cycles==0)
		P=P;
	   else
	     for(j=8'b00000000;j<=cycles;j++)
		begin
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
	end
	else if(op==6'b000100)   // init_addr
		r_addr=instr[7:0];

	
	else if(op==6'b000101)   //st_M_L 
		M[r_addr]=P;
	
	else if(op==6'b000110)  //add_addr
		r_addr=r_addr+instr[7:0];	
	
	else if(op==6'b000111)  //ld_M_L
		P=M[r_addr];
     
        else if(op==6'b001000)  //st_M_HD
		M[r_addr]=HD;

	else if(op==6'b001001)  //Batch run st_M_L cyl
	   begin
	     if(cycles==0)
               P=P;	
	     else	
		for(k=8'b00000001;k<=cycles;k++)
		begin
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
	M[r_addr]=P_next;
	end 
	r_addr=r_addr+1;	
	end

	else if(op==6'b000000)
		$stop;

	else if(op==6'b001010)  //Config_C
	   R=instr[7:0];  //Rule

	else if(op==6'b001011) begin  //init_C 
	   Seed_C=instr[7:0]; 
	   Q=Seed_C;end           //Q is the pattern from R	
	else if(op==6'b001100)  //run_C
	   begin
					
			Q[0]<=Q[1]?(Q[0]?(Q[7]?R[7]:R[6]):(Q[7]?R[5]:R[4])):(Q[0]?(Q[7]?R[3]:R[2]):(Q[7]?R[1]:R[0]));
			Q[1]<=Q[2]?(Q[1]?(Q[0]?R[7]:R[6]):(Q[0]?R[5]:R[4])):(Q[1]?(Q[0]?R[3]:R[2]):(Q[0]?R[1]:R[0]));
			Q[2]<=Q[3]?(Q[2]?(Q[1]?R[7]:R[6]):(Q[1]?R[5]:R[4])):(Q[2]?(Q[1]?R[3]:R[2]):(Q[1]?R[1]:R[0]));
			Q[3]<=Q[4]?(Q[3]?(Q[2]?R[7]:R[6]):(Q[2]?R[5]:R[4])):(Q[3]?(Q[2]?R[3]:R[2]):(Q[2]?R[1]:R[0]));
			Q[4]<=Q[5]?(Q[4]?(Q[3]?R[7]:R[6]):(Q[3]?R[5]:R[4])):(Q[4]?(Q[3]?R[3]:R[2]):(Q[3]?R[1]:R[0]));
			Q[5]<=Q[6]?(Q[5]?(Q[4]?R[7]:R[6]):(Q[4]?R[5]:R[4])):(Q[5]?(Q[4]?R[3]:R[2]):(Q[4]?R[1]:R[0]));
			Q[6]<=Q[7]?(Q[6]?(Q[5]?R[7]:R[6]):(Q[5]?R[5]:R[4])):(Q[6]?(Q[5]?R[3]:R[2]):(Q[5]?R[1]:R[0]));
			Q[7]<=Q[0]?(Q[7]?(Q[6]?R[7]:R[6]):(Q[6]?R[5]:R[4])):(Q[7]?(Q[6]?R[3]:R[2]):(Q[6]?R[1]:R[0]));  	
		end

	else if(op==6'b001101)   //st_M_C 
		M[r_addr]=Q;

	else if(op==6'b001111)  //ld_M_C
		Q=M[r_addr];
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
				Ham=Ham+1;
		end
HD=Ham;
Ham=4'b0000;
end
endmodule     
