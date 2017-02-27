// Radboy mapper
// CC-BY-NC furrtek 2017

module rad_mapper(
	input nRESET,			// Cart edge
	output OSCOUT,			// HV oscillator enable output
	input nCS,				// Cart edge
	input nRD,				// Cart edge
	input nWR,				// Cart edge
	input A13,				// Cart edge
	input A14,				// Cart edge
	input A15,				// Cart edge
	input TICK,				// GM tube tick input
	input nCHARGED,		// HV detect input (low when ok)
	inout DATA				// Cart edge
);

	// Write $0000~$3FFF to latch SR and turn high voltage on/off
	// Write $4000~$7FFF to reset counter and SR
	// Read $A000~$BFFF to read 1 bit from SR

	reg [5:0] TICK_CNT;	// 0~31
	reg [7:0] LATCH;		// HVCCCCCC
	reg OVF;					// V
	reg [2:0] BIT_CNT;	// 0~7
	reg HV_EN;
	wire nREGRD;
	wire nREGWR_LATCH;
	wire nREGWR_RESET;
	
	assign OSCOUT = HV_EN & nCHARGED;
	
	// Read $A000~$BFFF 101x
	assign nREGRD = |{~A15, A14, ~A13, nRD, nCS, ~nWR};
	
	// Write $0000~$3FFF 00xx
	assign nREGWR_LATCH = |{A15, A14, ~nRD, ~nCS, nWR};
	// Write $4000~$7FFF 01xx
	assign nREGWR_RESET = |{A15, ~A14, ~nRD, ~nCS, nWR};
	
	assign DATA = nREGRD ? 1'bz : LATCH[BIT_CNT];
	
	always @(negedge nREGWR_RESET or posedge nREGRD)
	begin
		if (!nREGWR_RESET)
		begin
			// Latch SR and reset SR index
			BIT_CNT <= 3'b0;
		end
		else
		begin
			// Read from SR
			BIT_CNT <= BIT_CNT + 1'b1;
		end
	end

	// Latch
	always @(posedge nREGWR_LATCH or negedge nRESET)
	begin
		if (!nRESET)
			HV_EN <= 1'b0;		// Disable HV at startup
		else
		begin
			HV_EN <= DATA;
			LATCH <= {nCHARGED, OVF, TICK_CNT};	// Write $0000~$3FFF
		end
	end
	
	// Counter
	always @(negedge nREGWR_RESET or posedge TICK)
	begin
		if (!nREGWR_RESET)
		begin
			OVF <= 1'b0;
			TICK_CNT <= 5'b0;
		end
		else
		begin
			if (~&{TICK_CNT})
			begin
				TICK_CNT <= TICK_CNT + 1'b1;
				OVF <= 1'b0;
			end
			else
				OVF <= 1'b1;
		end
	end

endmodule
