module top (
    output logic my_pin_27,
    output logic my_pin_28
);
 
    logic base_clock;
 
    // Lattice iCE40UP oscillator primitive
    HSOSC #(
        .CLKHF_DIV("0b00")     // 0b00=48MHz, 0b01=24MHz, 0b10=12MHz, 0b11=6MHz
    ) u_hfosc (
        .CLKHFPU (1'b1),       
        .CLKHFEN (1'b1),       
        .CLKHF   (base_clock)  
    );
 
    logic [31:0] clk;
    logic SYSTEM_CLOCK;
 
	/**
    clock_divider divider (
        .clock          (base_clock),
        .divided_clocks (clk)
    );
	**/
 
	assign SYSTEM_CLOCK = base_clock;  // Questa: full speed
	 
	state_m clock_differential (
		.clk (SYSTEM_CLOCK),
		.my_pin_27 (my_pin_27),
		.my_pin_28 (my_pin_28)
	);

endmodule

/**
module clock_divider (
    input  logic clock,
    output logic [31:0] divided_clocks
);
    // Safer initialization for Synplify
    initial divided_clocks = 32'b0;
    always_ff @(posedge clock) begin
        divided_clocks <= divided_clocks + 1'b1;
    end
endmodule
**/
 
module state_m (
    input  logic clk,
    output logic my_pin_27,
    output logic my_pin_28
);
 
    // FIX: Shifted the enum values so the initial state is zero.
    typedef enum logic [1:0] {
        stage1 = 2'b00,
        stage2 = 2'b01
    } state_t;
 
    state_t ps, ns;
    
    // Synplify on iCE40 now sees a '0' initialization, which hardware supports natively.
    initial ps = stage1; 

    always_comb begin
        my_pin_27 = 1'b0;
        my_pin_28 = 1'b0;
        ns        = stage1;
        case (ps)
            stage1:  begin my_pin_27 = 1'b1; ns = stage2; end
            stage2:  begin my_pin_28 = 1'b1; ns = stage1; end
            default: begin ns = stage1; end
        endcase
    end
    
    always_ff @(posedge clk) begin
        ps <= ns;
    end
endmodule
