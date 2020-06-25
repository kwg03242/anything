/*
* @Author: Donghyeon Lee (dhlee@capp.snu.ac.kr)
* @Date:   2017-06-27 10:58:43
* @Last Modified by:   Donghyeon Lee (dhlee@capp.snu.ac.kr)
* @Last Modified time: 2017-08-14 14:25:21
*/

`include "vdsr_defines.v"

// --------------------------------------
// Main Module: conv_layer
// --------------------------------------
module conv_layer
#(
	parameter 	IMG_PIX_W 		= 8,
				FILTER_COEF_W	= 8, // Filter coefficient bitwidth
				FILTER_WIDTH 	= 3,
				FILTER_HEIGHT 	= 3,
				NUM_FILTER		= 1,
				IFMAP_CH		= 1,
				RELU_ON 		= 1
)
(
	input																			clk,
	input																			rst_n,
	input																			i_valid, /*Receiving valid ifmap data*/
	input	[IFMAP_CH*IMG_PIX_W - 1: 0]												i_ifdata,
	input 																			i_filter_coeff_valid,
	input 	[NUM_FILTER*IFMAP_CH*FILTER_COEF_W*FILTER_WIDTH*FILTER_HEIGHT - 1: 0] 	i_filter_coeff,
	input   [NUM_FILTER*FILTER_COEF_W - 1: 0] 										i_filter_bias,

	output 																			o_filter_ready,
	output																			o_valid, /*valid ofmap data output*/
	output	[NUM_FILTER*IMG_PIX_W - 1: 0]											o_ofdata,
	output																			conv_done
);
// ---------------------------------------
// internal signals
// ---------------------------------------
localparam	ST_IDLE = 0, 		// default state
			ST_BUFF = 1,		// wait 2*IMAGE_WIDTH cycles and store input into line buffer
			ST_WAIT = 2, 		// wait 2*IMAGE_WIDTH cycles and store input into line buffer
			ST_RUN	= 3, 		// Convolution operation
			ST_RUN_WAIT = 4, 	// use same control signal with ST_RUN
			ST_RUN1 = 5, 		// Convolution operation last row.
			ST_RUN2 = 6;		// last row convolution operation. (Output remaining data)
integer i;
integer ch, col, row;
integer idx_f, ch_f, row_f, col_f;
integer idx_b;

localparam NUM_LINEBUFF	= (FILTER_HEIGHT - 1 > 0)? FILTER_HEIGHT - 1:1;
localparam NUM_LINEBUFF_REAL = FILTER_HEIGHT - 1; // dhlee ++ 20170801 // for generate Linebuffers

 reg [2:0] c_state, n_state;
 reg ctrl_st_idle, ctrl_st_buff, ctrl_st_wait, ctrl_st_run, ctrl_st_run_wait, ctrl_st_run1, ctrl_st_run2;

 reg [GetBitWidth(`IMAGE_WIDTH) - 1 :0] i_col_cnt; // input counter (col)
 reg [GetBitWidth(`IMAGE_HEIGHT) - 1:0] i_row_cnt; // input counter (row)
 reg [GetBitWidth(`IMAGE_WIDTH) - 1 :0] c_col_cnt; // CONV output counter (col)
 reg [GetBitWidth(`IMAGE_HEIGHT) - 1:0] c_row_cnt; // CONV output counter (row)
 reg [GetBitWidth(`IMAGE_WIDTH) - 1 :0] b_col_cnt; // buff counter (col)
 reg [GetBitWidth(`IMAGE_HEIGHT) - 1:0] b_row_cnt; // buff counter (row)
 reg [GetBitWidth(`IMAGE_HEIGHT) - 1:0] buff_row_cnt_r; 	// linebuff counter (row)
 reg [GetBitWidth(`IMAGE_HEIGHT) - 1:0] buff_row_cnt_r_abs; 
wire [GetBitWidth(`IMAGE_WIDTH) - 1 :0] ifmap_cen_addr_col = i_col_cnt;
wire [GetBitWidth(`IMAGE_HEIGHT) - 1:0] ifmap_cen_addr_row = i_row_cnt;

wire ifmap_linebuff_valid, all_ifmap_received;
 reg ifmap_linebuff_valid_d;

 reg q_i_valid_d[0:FILTER_WIDTH]; // dhlee ++ 20170724, mod 20170801
wire [GetBitWidth(FILTER_WIDTH + 1) - 1: 0] sel_q_i_valid_d_cond0, sel_q_i_valid_d_cond1; // dhlee ++ 20170801
 reg q_ctrl_st_run1_d1, q_ctrl_st_run1_d2;
 reg [NUM_FILTER*IMG_PIX_W - 1: 0] temp_buff, i_temp_buff;
 reg alu_out_valid;
// --- Filter coefficient signals --- //
 reg [FILTER_COEF_W - 1: 0] filter_coeff_patch 	[0: NUM_FILTER - 1][0: IFMAP_CH - 1][0: FILTER_HEIGHT - 1][0: FILTER_WIDTH - 1];
 
 (* ram_style = "block" *) reg [FILTER_COEF_W - 1: 0] q_filter_coeff 		[0: NUM_FILTER - 1][0: IFMAP_CH - 1][0: FILTER_HEIGHT - 1][0: FILTER_WIDTH - 1];
 reg [FILTER_COEF_W - 1: 0] q_filter_bias		[0: NUM_FILTER - 1];
 reg filter_coeff_stored;
 
// --- Direct input to ALU --- //
 reg [IFMAP_CH*IMG_PIX_W*FILTER_HEIGHT*FILTER_WIDTH - 1    : 0] filter_in_feature;
 reg [IFMAP_CH*FILTER_COEF_W*FILTER_HEIGHT*FILTER_WIDTH - 1: 0]  filter_in_coeff   [0: NUM_FILTER - 1];
wire [IMG_PIX_W - 1: 0] filter_out_feature [0: NUM_FILTER - 1];
wire [IMG_PIX_W - 1: 0] ofmap_relu		   [0: NUM_FILTER - 1];

// --- linebuffer signals --- //
 reg we [0:NUM_LINEBUFF - 1];
wire [GetBitWidth(NUM_LINEBUFF) - 1: 0] linebuff_sel 	= ifmap_cen_addr_row%(NUM_LINEBUFF);
wire [GetBitWidth(`IMAGE_WIDTH) - 1: 0] linebuff_waddr 	= i_col_cnt;
 reg [GetBitWidth(`IMAGE_WIDTH) - 1: 0] linebuff_raddr;
wire [IMG_PIX_W*IFMAP_CH - 1 	   : 0] linebuff_din 	= i_ifdata;
wire [IMG_PIX_W*IFMAP_CH - 1 	   : 0] linebuff_dout [0:NUM_LINEBUFF - 1];	

// ---------------------------------------
// FSM
// ---------------------------------------
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		// reset
		c_state <= ST_IDLE;
	end	else begin
		c_state <= n_state;
	end
end

always @(*) begin
	n_state = ST_IDLE;
	case (c_state)
		ST_IDLE: begin // c_state = 0
			if (i_valid) begin
				n_state = ST_BUFF;
			end else begin
				n_state = ST_IDLE;
			end
		end
		ST_BUFF: begin // c_state = 1
			if (ifmap_linebuff_valid) begin
				n_state = ST_WAIT;
			end else begin
				n_state = ST_BUFF;
			end
		end
		ST_WAIT: begin // c_state = 2
			if (i_valid) begin
				n_state = ST_RUN;
			end else begin
				n_state = ST_WAIT;
			end
		end
		ST_RUN: begin // c_state = 3
			if (all_ifmap_received) begin
				n_state = ST_RUN1;
			end else begin
				n_state = ST_RUN;
			end
		end
		ST_RUN1: begin // last frame after all input data received processing // c_state = 5
			if ((FILTER_HEIGHT == 1) && conv_done) begin
				n_state = ST_IDLE;
			end else
			if ((c_row_cnt == `IMAGE_HEIGHT - 1) && (linebuff_raddr == `IMAGE_WIDTH - 1)) begin // dhlee ++ 20170724
				n_state = ST_RUN2;
			end else begin
				n_state = ST_RUN1;
			end
		end
		ST_RUN2: begin // c_state = 6
			if (conv_done) begin
				if (ifmap_linebuff_valid || ifmap_linebuff_valid_d) begin
					if (i_valid) begin
						n_state = ST_RUN;
					end else begin
						n_state = ST_WAIT;
					end
				end else begin
					n_state = ST_IDLE;
				end
			end else begin
				n_state = ST_RUN2;
			end			
		end
	endcase
end

// ---------------------------------------
// Main control signals (conv_layer)
// ---------------------------------------
always @(*) begin
	ctrl_st_idle = 0;
	ctrl_st_buff = 0;
	ctrl_st_wait = 0;
	ctrl_st_run  = 0;
	ctrl_st_run_wait = 0;
	ctrl_st_run1 = 0;
	ctrl_st_run2 = 0;
	if (c_state == ST_IDLE) begin
		ctrl_st_idle = 1;
	end else if (c_state == ST_BUFF) begin
		ctrl_st_buff = 1;
	end else if (c_state == ST_WAIT) begin
		ctrl_st_wait = 1;
	end else if (c_state == ST_RUN) begin
		ctrl_st_run = 1;
	end else if (c_state == ST_RUN_WAIT) begin
		ctrl_st_run1 = 1;
		ctrl_st_run_wait = 1;		
	end else if (c_state == ST_RUN1) begin
		ctrl_st_run1 = 1;
	end else if (c_state == ST_RUN2) begin
		ctrl_st_run2 = 1;
	end
end

assign ifmap_linebuff_valid = (FILTER_HEIGHT == 1)? 1: ((i_row_cnt == (FILTER_HEIGHT - 1)/2 - 1) && (i_col_cnt == `IMAGE_WIDTH - 1))? 1:0;  // the first line buffer is valid 
assign all_ifmap_received 	= ((i_row_cnt == `IMAGE_HEIGHT - 1) && (i_col_cnt == `IMAGE_WIDTH - 1))? 1:0; // all ifmap data received
assign conv_done 			= ((c_row_cnt == `IMAGE_HEIGHT - 1) && (c_col_cnt == `IMAGE_WIDTH - 1))? 1:0; // all ALU operation done


// --- i_valid delay to control --- //
integer int_valid_idx;
always @(*) begin
	q_i_valid_d[0] = i_valid;
end

always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		for (int_valid_idx = 1; int_valid_idx < FILTER_WIDTH; int_valid_idx = int_valid_idx + 1) begin
			q_i_valid_d[int_valid_idx] <= 0;
		end
		q_ctrl_st_run1_d1 <= 0;
		q_ctrl_st_run1_d2 <= 0;
	end else begin
		q_i_valid_d[1] <= i_valid;
		for (int_valid_idx = 1; int_valid_idx < FILTER_WIDTH - 1; int_valid_idx = int_valid_idx + 1) begin
			q_i_valid_d[int_valid_idx + 1] <= q_i_valid_d[int_valid_idx];
		end
		q_ctrl_st_run1_d1 <= ctrl_st_run1;
		q_ctrl_st_run1_d2 <= q_ctrl_st_run1_d1;
	end
end

// ---- ifmap valid delay --- //
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		ifmap_linebuff_valid_d <= 0;
	end else begin
		if (ifmap_linebuff_valid) begin
			ifmap_linebuff_valid_d <= 1;
		end 
		if (ctrl_st_wait || ctrl_st_run) begin
			ifmap_linebuff_valid_d <= 0;
		end
	end
end
// ---------------------------------------
// Filter coefficient store (idle state)
// ---------------------------------------
always @(*) begin
// filter coefficient parser (1D --> 2D. f(ch, 0, 0), f(ch, 0, 1), f(ch, 0, 2)... raster scan order)
// Channel base addr: ch*FILTER_HEIGHT*FILTER_WIDTH*FILTER_COEF_W
// Row base addr: row*FILTER_WIDTH*FILTER_COEFF_W
// Col base addr: col*FILTER_COEFF_W
// Coeff 1D addr: (ch*FILTER_HEIGHT*FILTER_WIDTH + row*FILTER_WIDTH + col)*FILTER_COEF_W
// channel base addr: FILTER_HEIGHT*FILTER_WIDTH*IFMAP_CH*FILTER_COEF_W
    for (idx_f = 0; idx_f < NUM_FILTER; idx_f = idx_f + 1) begin
        for (ch_f = 0; ch_f < IFMAP_CH; ch_f = ch_f + 1) begin
            for (row_f = 0; row_f < FILTER_HEIGHT; row_f = row_f + 1) begin
                for (col_f = 0; col_f < FILTER_WIDTH; col_f = col_f + 1) begin
                    filter_coeff_patch[idx_f][ch_f][row_f][col_f] 
                        = i_filter_coeff[(((idx_f*IFMAP_CH*FILTER_HEIGHT*FILTER_WIDTH) 
                            + (ch_f*FILTER_HEIGHT*FILTER_WIDTH + row_f*FILTER_WIDTH + col_f))*FILTER_COEF_W) +: FILTER_COEF_W];
                end
            end
        end
    end
end

// --- Store filter coefficient into registers --- //
always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        filter_coeff_stored <= 0;
    end
    else if(i_filter_coeff_valid)begin
        filter_coeff_stored<=1;
    end
end

always @(posedge clk) begin
    if (i_filter_coeff_valid) begin 
		// --- data --- //
		for (idx_f = 0; idx_f < NUM_FILTER; idx_f = idx_f + 1) begin
			for (ch_f = 0; ch_f < IFMAP_CH; ch_f = ch_f + 1) begin
				for (row_f = 0; row_f < FILTER_HEIGHT; row_f = row_f + 1) begin
					for (col_f = 0; col_f < FILTER_WIDTH; col_f = col_f + 1) begin
						q_filter_coeff[idx_f][ch_f][row_f][col_f] <= filter_coeff_patch[idx_f][ch_f][row_f][col_f];
					end
				end
			end
		end
	end
end

always @(posedge clk) begin
    if (i_filter_coeff_valid) begin 
		for (idx_b = 0; idx_b < NUM_FILTER; idx_b = idx_b + 1) begin
			q_filter_bias[idx_b] <= i_filter_bias[idx_b*FILTER_COEF_W +: FILTER_COEF_W];
		end
	end
end

// ---------------------------------------
// ifmap line buffer select for ifmap write
// ---------------------------------------
always @(*) begin
	// initialize
	for (i = 0; i < NUM_LINEBUFF; i = i + 1) we[i] = 0;
	if (i_valid) begin
		we[linebuff_sel] = 1;
	end
end

// ---------------------------------------
// ifmap register buffer
// ---------------------------------------
// --- ifmap patch control signals --- //
 reg [GetBitWidth(NUM_LINEBUFF): 0] linebuff_sel_start_idx;
 reg ctrl_linebuff_full;
 reg ctrl_ifmap_patch_valid; // valid: after 1 cycle linebuff_raddr = 0, invalid: c_col_cnt = (`image_width - filter width + 1) //shlee -- 20171126
 reg ctrl_shift_left;		 // valid: after 1 cycle linebuff_raddr = 1, invalid: c_col_cnt = (`image_width - filter width + 1)
 reg ctrl_ifmap_buff_ready;  // valid: after 1 cycle linebuff_raddr = 2, invalid: c_col_cnt = (`image_width - filter width + 2)
// --- ifmap patch data signals --- //
 reg [IMG_PIX_W - 1					: 0] ifmap_prefetch_din [0:IFMAP_CH - 1][0:FILTER_HEIGHT - 2]; 					  // Address: Ch, row
 reg [IMG_PIX_W - 1					: 0] ifmap_buff_din 	[0:IFMAP_CH - 1][0:FILTER_HEIGHT - 1][0:FILTER_WIDTH - 1];  // Address: Ch, row, col
 reg [IMG_PIX_W - 1					: 0] q_ifmap_buff 		[0:IFMAP_CH - 1][0:FILTER_HEIGHT - 1][0:FILTER_WIDTH - 1];  // Address: Ch, row, col
 reg [IMG_PIX_W - 1					: 0] q_ifmap_buff_mask	[0:IFMAP_CH - 1][0:FILTER_HEIGHT - 1][0:FILTER_WIDTH - 1];  // Address: Ch, row, col
wire last_row_in_frame = (c_row_cnt == `IMAGE_HEIGHT - 1)? 1:0;
 reg [GetBitWidth(FILTER_HEIGHT - 1): 0] addr_prefetch_din, addr_prefetch_linebuff; // address for prefetch data, linebuff
// --- Etc. --- //
wire boundary_col_begin = ((b_col_cnt <= (FILTER_WIDTH - 1)/2 - 1))? 1:0;
wire boundary_col_end	= ((b_col_cnt >= `IMAGE_WIDTH - (FILTER_WIDTH - 1)/2))? 1:0;
wire boundary_ceil 		= (c_row_cnt < (FILTER_HEIGHT - 1)/2)? 1:0;

// --- (CTRL) ifmap patch control signals --- //
assign sel_q_i_valid_d_cond0 = (FILTER_WIDTH >= 2)? FILTER_WIDTH - 2: 0;
assign sel_q_i_valid_d_cond1 = (FILTER_WIDTH >= 2)? (FILTER_WIDTH - 1)/2 + 1: 1;

always @(*) begin
	ctrl_shift_left = 0;
	ctrl_ifmap_patch_valid = 0; //shlee -- 20171126
	ctrl_ifmap_buff_ready = 0;
 //shlee -- 20171126
	// --- patch valid --- //
	if ((FILTER_HEIGHT == 1) && i_valid) begin
		ctrl_ifmap_patch_valid = 1;
	end else
	if ((ctrl_st_wait || ctrl_st_run) && (i_valid || q_i_valid_d[sel_q_i_valid_d_cond0])) begin // dhlee ++ 20170724
		ctrl_ifmap_patch_valid = 1; 
	end else if (ctrl_st_run1 && (i_valid || q_i_valid_d[sel_q_i_valid_d_cond0])) begin // dhlee ++ 20170724
		ctrl_ifmap_patch_valid = 1;	
	end else if (ctrl_st_run1 && (c_row_cnt < `IMAGE_HEIGHT - 1)) begin
		ctrl_ifmap_patch_valid = 1;
	end else if (ctrl_st_run1 && (c_row_cnt == `IMAGE_HEIGHT - 1) && (linebuff_raddr >= 1)
		&& (!last_row_in_frame || c_col_cnt <= `IMAGE_WIDTH - FILTER_WIDTH)) begin
		ctrl_ifmap_patch_valid = 1;
	end else if (ctrl_st_run1 && (FILTER_WIDTH == 1) && (c_row_cnt == `IMAGE_HEIGHT - 1) 
		&& (!last_row_in_frame || c_col_cnt <= `IMAGE_WIDTH - FILTER_WIDTH)) begin
		ctrl_ifmap_patch_valid = 1;
	end else if (ctrl_st_run2 && (b_col_cnt <= `IMAGE_WIDTH - 2) && (b_row_cnt == `IMAGE_HEIGHT - 1)) begin // dhlee ++ 20170724
		ctrl_ifmap_patch_valid = 1;
	end

	// --- shift left --- //
	if ((FILTER_HEIGHT == 1) && q_i_valid_d[1]) begin
		ctrl_shift_left = 1;
	end else	
	if (ctrl_st_run && (q_i_valid_d[1] || q_i_valid_d[sel_q_i_valid_d_cond0])) begin 
		ctrl_shift_left = 1;
	end else if (ctrl_st_run1 && (q_i_valid_d[1] || q_i_valid_d[sel_q_i_valid_d_cond0])) begin 
		ctrl_shift_left = 1;
	end else if (ctrl_st_run1 && (c_row_cnt < `IMAGE_HEIGHT - 1)) begin
		ctrl_shift_left = 1;
	end else if (ctrl_st_run1 && (c_row_cnt == `IMAGE_HEIGHT - 1) && (linebuff_raddr >= 2) 
		&& (!last_row_in_frame || c_col_cnt <= `IMAGE_WIDTH - FILTER_WIDTH)) begin 
		ctrl_shift_left = 1;
	end else if (ctrl_st_run1 && (FILTER_WIDTH == 1) && (c_row_cnt == `IMAGE_HEIGHT - 1) 
		&& (!last_row_in_frame || c_col_cnt <= `IMAGE_WIDTH - FILTER_WIDTH)) begin 
		ctrl_shift_left = 1;
	end else if (ctrl_st_run2 && (b_col_cnt <= `IMAGE_WIDTH - 2) && (b_row_cnt == `IMAGE_HEIGHT - 1)) begin 
		ctrl_shift_left = 1;
	end

	// --- ifmap buff ready --- //
	if (ctrl_st_run && q_i_valid_d[sel_q_i_valid_d_cond1]) begin 
		ctrl_ifmap_buff_ready = 1;
	end else if (ctrl_st_run1 && q_i_valid_d[sel_q_i_valid_d_cond1]) begin 
		ctrl_ifmap_buff_ready = 1;
	end else if (ctrl_st_run1 && (c_row_cnt < `IMAGE_HEIGHT - 1)) begin
		ctrl_ifmap_buff_ready = 1;		
	end else if (ctrl_st_run1 && (c_row_cnt == `IMAGE_HEIGHT - 1) && (linebuff_raddr >= 3) 
		&& (!last_row_in_frame || c_col_cnt <= `IMAGE_WIDTH - FILTER_WIDTH + 1)) begin
		ctrl_ifmap_buff_ready = 1;
	end else if (ctrl_st_run1 && (FILTER_WIDTH == 1) && (c_row_cnt == `IMAGE_HEIGHT - 1) 
		&& (!last_row_in_frame || c_col_cnt <= `IMAGE_WIDTH - FILTER_WIDTH + 1)) begin
		ctrl_ifmap_buff_ready = 1;
	end else if (ctrl_st_run2 && (b_col_cnt <= `IMAGE_WIDTH - 1) && (b_row_cnt == `IMAGE_HEIGHT - 1)) begin 
		ctrl_ifmap_buff_ready = 1;
	end
end

// --- (ADDR) ifmap patch address signals --- //
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		ctrl_linebuff_full <= 0;
	end else if ((i_row_cnt == NUM_LINEBUFF - 1) && (i_col_cnt == `IMAGE_WIDTH - 1)) begin
		ctrl_linebuff_full <= 1;
	end
end
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		linebuff_sel_start_idx <= 0;
	end else begin
		if (b_row_cnt < (`FILTER_HEIGHT - 1)/2) begin
			linebuff_sel_start_idx <= 0;
		end else if ((b_row_cnt == (`IMAGE_HEIGHT - 1)) && (b_col_cnt == `IMAGE_WIDTH - ((FILTER_WIDTH - 1)/2 + 2))) begin
			linebuff_sel_start_idx <= 0;
		end else
		if ((ctrl_st_run || ctrl_st_run1 || ctrl_st_run2) 
			&& (b_col_cnt == `IMAGE_WIDTH - ((FILTER_WIDTH - 1)/2 + 2)) 
			&& ctrl_linebuff_full) begin		
			linebuff_sel_start_idx <= (linebuff_sel_start_idx + 1)%NUM_LINEBUFF;
		end
	end
end

always @(*) begin
	linebuff_raddr = 0;
	if (((ctrl_st_wait || ctrl_st_run) && i_valid)) begin 
		if (linebuff_waddr + 1 == `IMAGE_WIDTH) begin
			linebuff_raddr = 0;
		end else begin
			linebuff_raddr = linebuff_waddr + 1;
		end
	end else if (ctrl_st_run1) begin
		if (c_col_cnt + (3 + (FILTER_WIDTH - 1)/2) >= `IMAGE_WIDTH) begin 
			linebuff_raddr = c_col_cnt + (3 + (FILTER_WIDTH - 1)/2) - `IMAGE_WIDTH; 
		end else begin
			linebuff_raddr = c_col_cnt + (3 + (FILTER_WIDTH - 1)/2); 
		end
		linebuff_raddr = linebuff_raddr%`IMAGE_WIDTH;
	end
end

// --- (DATA) prefetch ifmap data from line buffer --- //
wire ifmap_prefetch_cond0 = !ctrl_st_run1 && boundary_ceil && !last_row_in_frame;
wire ifmap_prefetch_cond1 = buff_row_cnt_r >= (`IMAGE_HEIGHT - (FILTER_HEIGHT - 1)/2)? 1: (ctrl_st_run1 || ctrl_st_run2); 
always @(*) begin
	buff_row_cnt_r_abs = 0;
	if ((FILTER_WIDTH == 1)) begin // boundary condition 
		if (ifmap_prefetch_cond1 && (linebuff_raddr == 0) && (buff_row_cnt_r == `IMAGE_HEIGHT - 1)) begin
			buff_row_cnt_r_abs = 1;
		end	else begin
			if ((`IMAGE_HEIGHT - 1 - buff_row_cnt_r < 0) || (buff_row_cnt_r == 0)) begin
				buff_row_cnt_r_abs = 0;
			end else begin
				buff_row_cnt_r_abs = `IMAGE_HEIGHT - 1 - buff_row_cnt_r;
			end			
		end
	end else begin
		if ((`IMAGE_HEIGHT - 1 - buff_row_cnt_r < 0) || (buff_row_cnt_r == 0)) begin
			buff_row_cnt_r_abs = 0;
		end else begin
			buff_row_cnt_r_abs = `IMAGE_HEIGHT - 1 - buff_row_cnt_r;
		end
	end
end

always @(*) begin
	// initialization
	addr_prefetch_din = 0;
	addr_prefetch_linebuff = 0;
	for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
		for (row = 0; row < FILTER_HEIGHT - 1; row = row + 1) begin
			ifmap_prefetch_din[ch][row] = 0;
		end
	end	
	// valid data
	if (NUM_LINEBUFF_REAL > 0) begin // dhlee ++ 20170801 // condition.
		for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
			if (ifmap_prefetch_cond0) begin
				for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin 
					if (row < (FILTER_HEIGHT - 1)/2 + c_row_cnt) begin 
						addr_prefetch_din = (row[GetBitWidth(NUM_LINEBUFF):0] + ((FILTER_HEIGHT - 1)/2) - c_row_cnt)%NUM_LINEBUFF; // 1, 2 ... NUM_LINEBUFF
						addr_prefetch_linebuff = (linebuff_sel_start_idx + row[GetBitWidth(NUM_LINEBUFF):0])%NUM_LINEBUFF;
						ifmap_prefetch_din[ch][addr_prefetch_din] = linebuff_dout[addr_prefetch_linebuff][ch*IMG_PIX_W +: IMG_PIX_W];
					end
				end
			end else if (ifmap_prefetch_cond1) begin
				for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin 
					if (row <= (FILTER_HEIGHT - 1)/2 + buff_row_cnt_r_abs) begin 
						addr_prefetch_din = row[GetBitWidth(NUM_LINEBUFF):0]; // 0, 1 ... NUM_LINEBUFF
						addr_prefetch_linebuff = (linebuff_sel_start_idx + row[GetBitWidth(NUM_LINEBUFF):0])%NUM_LINEBUFF;
						ifmap_prefetch_din[ch][addr_prefetch_din] = linebuff_dout[addr_prefetch_linebuff][ch*IMG_PIX_W +: IMG_PIX_W];
					end
				end						
			end else begin
				for (row = 0; row < FILTER_HEIGHT - 1; row = row + 1) begin
					addr_prefetch_din = row[GetBitWidth(NUM_LINEBUFF):0]; // 0, 1 ...
					addr_prefetch_linebuff = (linebuff_sel_start_idx + row[GetBitWidth(NUM_LINEBUFF):0])%NUM_LINEBUFF;
					ifmap_prefetch_din[ch][addr_prefetch_din] = linebuff_dout[addr_prefetch_linebuff][ch*IMG_PIX_W +: IMG_PIX_W];
				end
			end
		end	
	end
end

// --- (DATA) ifmap data patch parser --- //
always @(*) begin
	// Initialization
	for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
		for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin
			for (col = 0; col < FILTER_WIDTH; col = col + 1) begin
				ifmap_buff_din[ch][row][col] = 0;
			end
		end
	end
	// Shift left: preparing next cycle data. (for each cycle)
	if (ctrl_shift_left) begin
		for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
			for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin
				for (col = 0; col < FILTER_WIDTH - 1; col = col + 1) begin
					ifmap_buff_din[ch][row][col] = q_ifmap_buff[ch][row][col + 1];
				end
			end
		end
	end
	// Data patch parsing
    // incomming data should put into right and botton of buffer.
    if ((FILTER_HEIGHT == 1) && i_valid) begin
		for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
			ifmap_buff_din[ch][FILTER_HEIGHT - 1][FILTER_WIDTH - 1] = i_ifdata[ch*IMG_PIX_W +: IMG_PIX_W]; // dhlee mod. 20170705 input_debug --> i_ifdata // 20170731: Channel
		end    	
    end else 
 	if ((ctrl_st_buff || ctrl_st_wait || ctrl_st_run) && i_valid) begin
		for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
			if (NUM_LINEBUFF_REAL > 0) begin // dhlee ++ 20170801 // condition.
				for (row = 0; row < FILTER_HEIGHT - 1; row = row + 1) begin
					ifmap_buff_din[ch][row][FILTER_WIDTH - 1] = ifmap_prefetch_din[ch][row];
				end
			end
			ifmap_buff_din[ch][FILTER_HEIGHT - 1][FILTER_WIDTH - 1] = i_ifdata[ch*IMG_PIX_W +: IMG_PIX_W]; // dhlee mod. 20170705 input_debug --> i_ifdata // 20170731: Channel
		end
	end else if (ifmap_prefetch_cond1 && (NUM_LINEBUFF_REAL > 0)) begin 
		for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
			for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin 
				if (row <= (FILTER_HEIGHT - 1)/2 + buff_row_cnt_r_abs) begin 
	 				ifmap_buff_din[ch][row][FILTER_WIDTH - 1] = ifmap_prefetch_din[ch][row];
 				end
 			end
		end
	end
end


// --- (DATA) ifmap register --- //
always @(posedge clk) begin //shlee -- 20171126
	if (ctrl_ifmap_patch_valid) begin 
		 //register update
		for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
			for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin
				for (col = 0; col < FILTER_WIDTH; col = col + 1) begin
					q_ifmap_buff[ch][row][col] <= ifmap_buff_din[ch][row][col];
				end
			end
		end
	end 
end


// --- (DATA) ifmap register mask: For making input of MAC module --- //
always @(*) begin
	// initialization
	for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
		for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin
			for (col = 0; col < FILTER_WIDTH; col = col + 1) begin
				q_ifmap_buff_mask[ch][row][col] = q_ifmap_buff[ch][row][col];
			end
		end
	end
	// start, end boundary case of each col.
	if (boundary_col_begin && (FILTER_WIDTH > 1)) begin
		for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
			for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin
				for (col = 0; col < FILTER_WIDTH; col = col + 1) begin
					if (col < (FILTER_WIDTH - 1)/2 - b_col_cnt) begin
						q_ifmap_buff_mask[ch][row][col] = 0;  // Left side of the ifmap patch.
					end
				end
			end
		end
	end else if (boundary_col_end && (FILTER_WIDTH > 1)) begin
		for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
			for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin
				for (col = 0; col < FILTER_WIDTH; col = col + 1) begin // dhlee -- 20170814
					if (col >= (FILTER_WIDTH - 1)/2 + (`IMAGE_WIDTH - b_col_cnt)) begin
						q_ifmap_buff_mask[ch][row][col] = 0; // Right side of the ifmap patch.
					end
				end
			end
		end
	end
end

// --- (DATA) ifmap 1D patch: Real input of MAC module --- //
integer ch_1d, row_1d, col_1d;
reg [GetBitWidth(IFMAP_CH*FILTER_HEIGHT*FILTER_WIDTH) - 1: 0] addr_ifmap_1d;
always @(*) begin
	filter_in_feature = 0;
	// --- parsing for filter 0 --- //
	for (ch_1d = 0; ch_1d < IFMAP_CH; ch_1d = ch_1d + 1) begin
		for (row_1d = 0; row_1d < FILTER_HEIGHT; row_1d = row_1d + 1) begin
			for (col_1d = 0; col_1d < FILTER_WIDTH; col_1d = col_1d + 1) begin
				addr_ifmap_1d = (ch_1d*FILTER_HEIGHT*FILTER_WIDTH) + row_1d*(FILTER_WIDTH) + col_1d;
				filter_in_feature[addr_ifmap_1d*IMG_PIX_W +: IMG_PIX_W] = q_ifmap_buff_mask[ch_1d][row_1d][col_1d];
			end
		end
	end
end

integer fidx_coeff, ch_1d_coeff, row_1d_coeff, col_1d_coeff;
reg [GetBitWidth(IFMAP_CH*FILTER_HEIGHT*FILTER_WIDTH) - 1: 0] addr_coeff_1d;
always @(*) begin
	for (fidx_coeff = 0; fidx_coeff < NUM_FILTER; fidx_coeff = fidx_coeff + 1) begin
		for (ch_1d_coeff = 0; ch_1d_coeff < IFMAP_CH; ch_1d_coeff = ch_1d_coeff + 1) begin
			for (row_1d_coeff = 0; row_1d_coeff < FILTER_HEIGHT; row_1d_coeff = row_1d_coeff + 1) begin
				for (col_1d_coeff = 0; col_1d_coeff < FILTER_WIDTH; col_1d_coeff = col_1d_coeff + 1) begin
					addr_coeff_1d = (ch_1d_coeff*FILTER_HEIGHT*FILTER_WIDTH) + row_1d_coeff*FILTER_WIDTH + col_1d_coeff;
					filter_in_coeff[fidx_coeff][addr_coeff_1d*IMG_PIX_W +: IMG_PIX_W] = q_filter_coeff[fidx_coeff][ch_1d_coeff][row_1d_coeff][col_1d_coeff];
				end
			end
		end
	end
end

// ---------------------------------------
// COMPONENTS: ifmap line buffer (# line buffers: Filter height - 1)
// ---------------------------------------
generate
	genvar buff_idx;
	for (buff_idx = 0; buff_idx < NUM_LINEBUFF_REAL; buff_idx = buff_idx + 1) begin: GENED_BLK
		ramSyncDPSimple 
		#(
			.WIDTH(IMG_PIX_W*IFMAP_CH),
			.N_DEPTH(`IMAGE_WIDTH),
			.W_DEPTH(GetBitWidth(`IMAGE_WIDTH))
		)
		u_linebuff
		(
			.clk		(clk						),
			.din 		(linebuff_din				),
			.waddr 		(linebuff_waddr				),
			.we 		(we[buff_idx]				),
			.raddr 		(linebuff_raddr				),
			.dout		(linebuff_dout[buff_idx]	)
		);
	end
endgenerate

// ---------------------------------------
// COMPONENTS: MAC
// ---------------------------------------
generate
	genvar alu_idx;
	for (alu_idx = 0; alu_idx < NUM_FILTER/2; alu_idx = alu_idx + 1) begin: GENED_ALU
	
		(* keep_hierarchy = "yes" *)
		convolution
		#
		(
			.NUM_CHANNEL       (IFMAP_CH                  ),
			.FILTER_SIZE       (FILTER_HEIGHT*FILTER_WIDTH),
			.TOTAL_WIDTH       (IMG_PIX_W                 ),
			.FLOAT_WIDTH       (`FRACTIONAL_BITWIDTH      ),
			.EXTRA_BITS_UPPER  (0                         ), // 2
			.EXTRA_BITS_LOWER  (`FRACTIONAL_BITWIDTH      ) // 10
		)		
		u_ALU_CONV
		(
			.fmap    (filter_in_feature          ),
			.weight_1  (filter_in_coeff   [2*alu_idx]),
			.weight_2  (filter_in_coeff   [2*alu_idx+1]),
			.bias_1 	 (q_filter_bias     [2*alu_idx]),
			.bias_2 	 (q_filter_bias     [2*alu_idx+1]),
			.conv_out_1(filter_out_feature[2*alu_idx]),
			.conv_out_2(filter_out_feature[2*alu_idx+1])
		);
	end
endgenerate

// ---------------------------------------
// COMPONENTS: ReLU
// ---------------------------------------
generate
	genvar relu_idx;
	for (relu_idx = 0; relu_idx < NUM_FILTER; relu_idx = relu_idx + 1) begin: GENED_RELU
		ReLU
		#(.IMG_PIX_W(IMG_PIX_W))
		u_ReLU
		(
			.i_relu(filter_out_feature[relu_idx]),
			.o_relu(ofmap_relu[relu_idx]        )
		);
	end
endgenerate

// ---------------------------------------
// Output: (1 cycle delay)
// ---------------------------------------
// --- Filter coefficient store done --- //
assign o_filter_ready = filter_coeff_stored;
// --- CONV output --- //
assign o_ofdata = temp_buff;
assign o_valid = alu_out_valid;
integer temp_buff_idx;

// output buffer parser according to variable filter sizes
always @(*) begin
	i_temp_buff = 0;
	if (ctrl_ifmap_buff_ready) begin
		if (RELU_ON == 1) begin
			for (temp_buff_idx = 0; temp_buff_idx < NUM_FILTER; temp_buff_idx = temp_buff_idx + 1) begin
				i_temp_buff[IMG_PIX_W*temp_buff_idx +: IMG_PIX_W] = ofmap_relu[temp_buff_idx];
			end
		end else begin
			for (temp_buff_idx = 0; temp_buff_idx < NUM_FILTER; temp_buff_idx = temp_buff_idx + 1) begin
				i_temp_buff[IMG_PIX_W*temp_buff_idx +: IMG_PIX_W] = filter_out_feature[temp_buff_idx];
			end			
		end
	end
end

always @ (posedge clk) begin
    alu_out_valid <= ctrl_ifmap_buff_ready;
end

always @(posedge clk) begin 
	if (ctrl_ifmap_buff_ready) begin
		temp_buff <= i_temp_buff;
	end	
end
// -------------------------------------
// ---------------------------------------
// Counters
// ---------------------------------------
// ifmap counter
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		i_col_cnt <= 0;
		i_row_cnt <= 0;
	end else if (i_valid) begin
		i_col_cnt <= i_col_cnt + 1;
		if (i_col_cnt == `IMAGE_WIDTH - 1) begin
			i_col_cnt <= 0;
			i_row_cnt <= i_row_cnt + 1;
		end
		if ((i_row_cnt == `IMAGE_HEIGHT - 1) && (i_col_cnt == `IMAGE_WIDTH - 1)) begin
			i_row_cnt <= 0;
		end
	end
end

// conv counter
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		c_col_cnt <= 0;
		c_row_cnt <= 0;
	end else if (ctrl_st_idle) begin
		c_col_cnt <= 0;
		c_row_cnt <= 0;
	end else begin
		if (c_col_cnt == `IMAGE_WIDTH - 1) begin
			c_col_cnt <= 0;
		end else if (alu_out_valid) begin
			c_col_cnt <= c_col_cnt + 1;
		end else begin
			c_col_cnt <= c_col_cnt;
		end
		if ((c_row_cnt == `IMAGE_HEIGHT - 1) && (c_col_cnt == `IMAGE_WIDTH - 1)) begin
			c_row_cnt <= 0;
		end else if ((c_col_cnt == `IMAGE_WIDTH - 1)) begin
			c_row_cnt <= c_row_cnt + 1;
		end else begin
			c_row_cnt <= c_row_cnt;
		end
	end
end

// patch buffer counter
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		b_col_cnt <= 0;
		b_row_cnt <= 0;
	end else if (ctrl_ifmap_buff_ready) begin
		if (b_col_cnt == `IMAGE_WIDTH - 1) begin
			b_col_cnt <= 0;
		end else begin
			b_col_cnt <= b_col_cnt + 1;
		end
		if ((b_row_cnt == `IMAGE_HEIGHT - 1) && (b_col_cnt == `IMAGE_WIDTH - 1)) begin
			b_row_cnt <= 0;
		end else if (b_col_cnt == `IMAGE_WIDTH - 1) begin
			b_row_cnt <= b_row_cnt + 1;
		end
	end
end

// line buffer counter
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		buff_row_cnt_r <= 0;
	end else if (linebuff_raddr == `IMAGE_WIDTH - 1) begin
		if (buff_row_cnt_r == `IMAGE_HEIGHT - 1) begin
			buff_row_cnt_r <= 0;
		end else begin
			buff_row_cnt_r <= buff_row_cnt_r + 1;
		end
	end
end
// --------------------------------
// Functions 
// --------------------------------
function integer GetBitWidth(input integer num);
begin
    if(num > 1)
    begin
            GetBitWidth = 0;
            for(num = num - 1; num>0; GetBitWidth=GetBitWidth+1)
                    num = num >> 1;
    end
    else
            GetBitWidth = 1;
end
endfunction


endmodule

module conv_layer_no_dsp
#(
	parameter 	IMG_PIX_W 		= 8,
				FILTER_COEF_W	= 8, // Filter coefficient bitwidth
				FILTER_WIDTH 	= 3,
				FILTER_HEIGHT 	= 3,
				NUM_FILTER		= 1,
				IFMAP_CH		= 1,
				RELU_ON 		= 1
)
(
	input																			clk,
	input																			rst_n,
	input																			i_valid, /*Receiving valid ifmap data*/
	input	[IFMAP_CH*IMG_PIX_W - 1: 0]												i_ifdata,
	input 																			i_filter_coeff_valid,
	input 	[NUM_FILTER*IFMAP_CH*FILTER_COEF_W*FILTER_WIDTH*FILTER_HEIGHT - 1: 0] 	i_filter_coeff,
	input   [NUM_FILTER*FILTER_COEF_W - 1: 0] 										i_filter_bias,

	output 																			o_filter_ready,
	output																			o_valid, /*valid ofmap data output*/
	output	[NUM_FILTER*IMG_PIX_W - 1: 0]											o_ofdata,
	output																			conv_done
);
// ---------------------------------------
// internal signals
// ---------------------------------------
localparam	ST_IDLE = 0, 		// default state
			ST_BUFF = 1,		// wait 2*IMAGE_WIDTH cycles and store input into line buffer
			ST_WAIT = 2, 		// wait 2*IMAGE_WIDTH cycles and store input into line buffer
			ST_RUN	= 3, 		// Convolution operation
			ST_RUN_WAIT = 4, 	// use same control signal with ST_RUN
			ST_RUN1 = 5, 		// Convolution operation last row.
			ST_RUN2 = 6;		// last row convolution operation. (Output remaining data)
integer i;
integer ch, col, row;
integer idx_f, ch_f, row_f, col_f;
integer idx_b;

localparam NUM_LINEBUFF	= (FILTER_HEIGHT - 1 > 0)? FILTER_HEIGHT - 1:1;
localparam NUM_LINEBUFF_REAL = FILTER_HEIGHT - 1; // dhlee ++ 20170801 // for generate Linebuffers

 reg [2:0] c_state, n_state;
 reg ctrl_st_idle, ctrl_st_buff, ctrl_st_wait, ctrl_st_run, ctrl_st_run_wait, ctrl_st_run1, ctrl_st_run2;

 reg [GetBitWidth(`IMAGE_WIDTH) - 1 :0] i_col_cnt; // input counter (col)
 reg [GetBitWidth(`IMAGE_HEIGHT) - 1:0] i_row_cnt; // input counter (row)
 reg [GetBitWidth(`IMAGE_WIDTH) - 1 :0] c_col_cnt; // CONV output counter (col)
 reg [GetBitWidth(`IMAGE_HEIGHT) - 1:0] c_row_cnt; // CONV output counter (row)
 reg [GetBitWidth(`IMAGE_WIDTH) - 1 :0] b_col_cnt; // buff counter (col)
 reg [GetBitWidth(`IMAGE_HEIGHT) - 1:0] b_row_cnt; // buff counter (row)
 reg [GetBitWidth(`IMAGE_HEIGHT) - 1:0] buff_row_cnt_r; 	// linebuff counter (row)
 reg [GetBitWidth(`IMAGE_HEIGHT) - 1:0] buff_row_cnt_r_abs; 
wire [GetBitWidth(`IMAGE_WIDTH) - 1 :0] ifmap_cen_addr_col = i_col_cnt;
wire [GetBitWidth(`IMAGE_HEIGHT) - 1:0] ifmap_cen_addr_row = i_row_cnt;

wire ifmap_linebuff_valid, all_ifmap_received;
 reg ifmap_linebuff_valid_d;

 reg q_i_valid_d[0:FILTER_WIDTH]; // dhlee ++ 20170724, mod 20170801
wire [GetBitWidth(FILTER_WIDTH + 1) - 1: 0] sel_q_i_valid_d_cond0, sel_q_i_valid_d_cond1; // dhlee ++ 20170801
 reg q_ctrl_st_run1_d1, q_ctrl_st_run1_d2;
 reg [NUM_FILTER*IMG_PIX_W - 1: 0] temp_buff, i_temp_buff;
 reg alu_out_valid;
// --- Filter coefficient signals --- //
 reg [FILTER_COEF_W - 1: 0] filter_coeff_patch 	[0: NUM_FILTER - 1][0: IFMAP_CH - 1][0: FILTER_HEIGHT - 1][0: FILTER_WIDTH - 1];
 
 (* ram_style = "block" *) reg [FILTER_COEF_W - 1: 0] q_filter_coeff 		[0: NUM_FILTER - 1][0: IFMAP_CH - 1][0: FILTER_HEIGHT - 1][0: FILTER_WIDTH - 1];
 reg [FILTER_COEF_W - 1: 0] q_filter_bias		[0: NUM_FILTER - 1];
 reg filter_coeff_stored;
 
// --- Direct input to ALU --- //
 reg [IFMAP_CH*IMG_PIX_W*FILTER_HEIGHT*FILTER_WIDTH - 1    : 0] filter_in_feature;
 reg [IFMAP_CH*FILTER_COEF_W*FILTER_HEIGHT*FILTER_WIDTH - 1: 0]  filter_in_coeff   [0: NUM_FILTER - 1];
wire [IMG_PIX_W - 1: 0] filter_out_feature [0: NUM_FILTER - 1];
wire [IMG_PIX_W - 1: 0] ofmap_relu		   [0: NUM_FILTER - 1];

// --- linebuffer signals --- //
 reg we [0:NUM_LINEBUFF - 1];
wire [GetBitWidth(NUM_LINEBUFF) - 1: 0] linebuff_sel 	= ifmap_cen_addr_row%(NUM_LINEBUFF);
wire [GetBitWidth(`IMAGE_WIDTH) - 1: 0] linebuff_waddr 	= i_col_cnt;
 reg [GetBitWidth(`IMAGE_WIDTH) - 1: 0] linebuff_raddr;
wire [IMG_PIX_W*IFMAP_CH - 1 	   : 0] linebuff_din 	= i_ifdata;
wire [IMG_PIX_W*IFMAP_CH - 1 	   : 0] linebuff_dout [0:NUM_LINEBUFF - 1];	

// ---------------------------------------
// FSM
// ---------------------------------------
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		// reset
		c_state <= ST_IDLE;
	end	else begin
		c_state <= n_state;
	end
end

always @(*) begin
	n_state = ST_IDLE;
	case (c_state)
		ST_IDLE: begin // c_state = 0
			if (i_valid) begin
				n_state = ST_BUFF;
			end else begin
				n_state = ST_IDLE;
			end
		end
		ST_BUFF: begin // c_state = 1
			if (ifmap_linebuff_valid) begin
				n_state = ST_WAIT;
			end else begin
				n_state = ST_BUFF;
			end
		end
		ST_WAIT: begin // c_state = 2
			if (i_valid) begin
				n_state = ST_RUN;
			end else begin
				n_state = ST_WAIT;
			end
		end
		ST_RUN: begin // c_state = 3
			if (all_ifmap_received) begin
				n_state = ST_RUN1;
			end else begin
				n_state = ST_RUN;
			end
		end
		ST_RUN1: begin // last frame after all input data received processing // c_state = 5
			if ((FILTER_HEIGHT == 1) && conv_done) begin
				n_state = ST_IDLE;
			end else
			if ((c_row_cnt == `IMAGE_HEIGHT - 1) && (linebuff_raddr == `IMAGE_WIDTH - 1)) begin // dhlee ++ 20170724
				n_state = ST_RUN2;
			end else begin
				n_state = ST_RUN1;
			end
		end
		ST_RUN2: begin // c_state = 6
			if (conv_done) begin
				if (ifmap_linebuff_valid || ifmap_linebuff_valid_d) begin
					if (i_valid) begin
						n_state = ST_RUN;
					end else begin
						n_state = ST_WAIT;
					end
				end else begin
					n_state = ST_IDLE;
				end
			end else begin
				n_state = ST_RUN2;
			end			
		end
	endcase
end

// ---------------------------------------
// Main control signals (conv_layer)
// ---------------------------------------
always @(*) begin
	ctrl_st_idle = 0;
	ctrl_st_buff = 0;
	ctrl_st_wait = 0;
	ctrl_st_run  = 0;
	ctrl_st_run_wait = 0;
	ctrl_st_run1 = 0;
	ctrl_st_run2 = 0;
	if (c_state == ST_IDLE) begin
		ctrl_st_idle = 1;
	end else if (c_state == ST_BUFF) begin
		ctrl_st_buff = 1;
	end else if (c_state == ST_WAIT) begin
		ctrl_st_wait = 1;
	end else if (c_state == ST_RUN) begin
		ctrl_st_run = 1;
	end else if (c_state == ST_RUN_WAIT) begin
		ctrl_st_run1 = 1;
		ctrl_st_run_wait = 1;		
	end else if (c_state == ST_RUN1) begin
		ctrl_st_run1 = 1;
	end else if (c_state == ST_RUN2) begin
		ctrl_st_run2 = 1;
	end
end

assign ifmap_linebuff_valid = (FILTER_HEIGHT == 1)? 1: ((i_row_cnt == (FILTER_HEIGHT - 1)/2 - 1) && (i_col_cnt == `IMAGE_WIDTH - 1))? 1:0;  // the first line buffer is valid 
assign all_ifmap_received 	= ((i_row_cnt == `IMAGE_HEIGHT - 1) && (i_col_cnt == `IMAGE_WIDTH - 1))? 1:0; // all ifmap data received
assign conv_done 			= ((c_row_cnt == `IMAGE_HEIGHT - 1) && (c_col_cnt == `IMAGE_WIDTH - 1))? 1:0; // all ALU operation done


// --- i_valid delay to control --- //
integer int_valid_idx;
always @(*) begin
	q_i_valid_d[0] = i_valid;
end

always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		for (int_valid_idx = 1; int_valid_idx < FILTER_WIDTH; int_valid_idx = int_valid_idx + 1) begin
			q_i_valid_d[int_valid_idx] <= 0;
		end
		q_ctrl_st_run1_d1 <= 0;
		q_ctrl_st_run1_d2 <= 0;
	end else begin
		q_i_valid_d[1] <= i_valid;
		for (int_valid_idx = 1; int_valid_idx < FILTER_WIDTH - 1; int_valid_idx = int_valid_idx + 1) begin
			q_i_valid_d[int_valid_idx + 1] <= q_i_valid_d[int_valid_idx];
		end
		q_ctrl_st_run1_d1 <= ctrl_st_run1;
		q_ctrl_st_run1_d2 <= q_ctrl_st_run1_d1;
	end
end

// ---- ifmap valid delay --- //
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		ifmap_linebuff_valid_d <= 0;
	end else begin
		if (ifmap_linebuff_valid) begin
			ifmap_linebuff_valid_d <= 1;
		end 
		if (ctrl_st_wait || ctrl_st_run) begin
			ifmap_linebuff_valid_d <= 0;
		end
	end
end
// ---------------------------------------
// Filter coefficient store (idle state)
// ---------------------------------------
always @(*) begin
// filter coefficient parser (1D --> 2D. f(ch, 0, 0), f(ch, 0, 1), f(ch, 0, 2)... raster scan order)
// Channel base addr: ch*FILTER_HEIGHT*FILTER_WIDTH*FILTER_COEF_W
// Row base addr: row*FILTER_WIDTH*FILTER_COEFF_W
// Col base addr: col*FILTER_COEFF_W
// Coeff 1D addr: (ch*FILTER_HEIGHT*FILTER_WIDTH + row*FILTER_WIDTH + col)*FILTER_COEF_W
// channel base addr: FILTER_HEIGHT*FILTER_WIDTH*IFMAP_CH*FILTER_COEF_W
    for (idx_f = 0; idx_f < NUM_FILTER; idx_f = idx_f + 1) begin
        for (ch_f = 0; ch_f < IFMAP_CH; ch_f = ch_f + 1) begin
            for (row_f = 0; row_f < FILTER_HEIGHT; row_f = row_f + 1) begin
                for (col_f = 0; col_f < FILTER_WIDTH; col_f = col_f + 1) begin
                    filter_coeff_patch[idx_f][ch_f][row_f][col_f] 
                        = i_filter_coeff[(((idx_f*IFMAP_CH*FILTER_HEIGHT*FILTER_WIDTH) 
                            + (ch_f*FILTER_HEIGHT*FILTER_WIDTH + row_f*FILTER_WIDTH + col_f))*FILTER_COEF_W) +: FILTER_COEF_W];
                end
            end
        end
    end
end

// --- Store filter coefficient into registers --- //
always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        filter_coeff_stored <= 0;
    end
    else if(i_filter_coeff_valid)begin
        filter_coeff_stored<=1;
    end
end

always @(posedge clk) begin
    if (i_filter_coeff_valid) begin 
		// --- data --- //
		for (idx_f = 0; idx_f < NUM_FILTER; idx_f = idx_f + 1) begin
			for (ch_f = 0; ch_f < IFMAP_CH; ch_f = ch_f + 1) begin
				for (row_f = 0; row_f < FILTER_HEIGHT; row_f = row_f + 1) begin
					for (col_f = 0; col_f < FILTER_WIDTH; col_f = col_f + 1) begin
						q_filter_coeff[idx_f][ch_f][row_f][col_f] <= filter_coeff_patch[idx_f][ch_f][row_f][col_f];
					end
				end
			end
		end
	end
end

always @(posedge clk) begin
    if (i_filter_coeff_valid) begin 
		for (idx_b = 0; idx_b < NUM_FILTER; idx_b = idx_b + 1) begin
			q_filter_bias[idx_b] <= i_filter_bias[idx_b*FILTER_COEF_W +: FILTER_COEF_W];
		end
	end
end

// ---------------------------------------
// ifmap line buffer select for ifmap write
// ---------------------------------------
always @(*) begin
	// initialize
	for (i = 0; i < NUM_LINEBUFF; i = i + 1) we[i] = 0;
	if (i_valid) begin
		we[linebuff_sel] = 1;
	end
end

// ---------------------------------------
// ifmap register buffer
// ---------------------------------------
// --- ifmap patch control signals --- //
 reg [GetBitWidth(NUM_LINEBUFF): 0] linebuff_sel_start_idx;
 reg ctrl_linebuff_full;
 reg ctrl_ifmap_patch_valid; // valid: after 1 cycle linebuff_raddr = 0, invalid: c_col_cnt = (`image_width - filter width + 1) //shlee -- 20171126
 reg ctrl_shift_left;		 // valid: after 1 cycle linebuff_raddr = 1, invalid: c_col_cnt = (`image_width - filter width + 1)
 reg ctrl_ifmap_buff_ready;  // valid: after 1 cycle linebuff_raddr = 2, invalid: c_col_cnt = (`image_width - filter width + 2)
// --- ifmap patch data signals --- //
 reg [IMG_PIX_W - 1					: 0] ifmap_prefetch_din [0:IFMAP_CH - 1][0:FILTER_HEIGHT - 2]; 					  // Address: Ch, row
 reg [IMG_PIX_W - 1					: 0] ifmap_buff_din 	[0:IFMAP_CH - 1][0:FILTER_HEIGHT - 1][0:FILTER_WIDTH - 1];  // Address: Ch, row, col
 reg [IMG_PIX_W - 1					: 0] q_ifmap_buff 		[0:IFMAP_CH - 1][0:FILTER_HEIGHT - 1][0:FILTER_WIDTH - 1];  // Address: Ch, row, col
 reg [IMG_PIX_W - 1					: 0] q_ifmap_buff_mask	[0:IFMAP_CH - 1][0:FILTER_HEIGHT - 1][0:FILTER_WIDTH - 1];  // Address: Ch, row, col
wire last_row_in_frame = (c_row_cnt == `IMAGE_HEIGHT - 1)? 1:0;
 reg [GetBitWidth(FILTER_HEIGHT - 1): 0] addr_prefetch_din, addr_prefetch_linebuff; // address for prefetch data, linebuff
// --- Etc. --- //
wire boundary_col_begin = ((b_col_cnt <= (FILTER_WIDTH - 1)/2 - 1))? 1:0;
wire boundary_col_end	= ((b_col_cnt >= `IMAGE_WIDTH - (FILTER_WIDTH - 1)/2))? 1:0;
wire boundary_ceil 		= (c_row_cnt < (FILTER_HEIGHT - 1)/2)? 1:0;

// --- (CTRL) ifmap patch control signals --- //
assign sel_q_i_valid_d_cond0 = (FILTER_WIDTH >= 2)? FILTER_WIDTH - 2: 0;
assign sel_q_i_valid_d_cond1 = (FILTER_WIDTH >= 2)? (FILTER_WIDTH - 1)/2 + 1: 1;

always @(*) begin
	ctrl_shift_left = 0;
	ctrl_ifmap_patch_valid = 0; //shlee -- 20171126
	ctrl_ifmap_buff_ready = 0;
 //shlee -- 20171126
	// --- patch valid --- //
	if ((FILTER_HEIGHT == 1) && i_valid) begin
		ctrl_ifmap_patch_valid = 1;
	end else
	if ((ctrl_st_wait || ctrl_st_run) && (i_valid || q_i_valid_d[sel_q_i_valid_d_cond0])) begin // dhlee ++ 20170724
		ctrl_ifmap_patch_valid = 1; 
	end else if (ctrl_st_run1 && (i_valid || q_i_valid_d[sel_q_i_valid_d_cond0])) begin // dhlee ++ 20170724
		ctrl_ifmap_patch_valid = 1;	
	end else if (ctrl_st_run1 && (c_row_cnt < `IMAGE_HEIGHT - 1)) begin
		ctrl_ifmap_patch_valid = 1;
	end else if (ctrl_st_run1 && (c_row_cnt == `IMAGE_HEIGHT - 1) && (linebuff_raddr >= 1)
		&& (!last_row_in_frame || c_col_cnt <= `IMAGE_WIDTH - FILTER_WIDTH)) begin
		ctrl_ifmap_patch_valid = 1;
	end else if (ctrl_st_run1 && (FILTER_WIDTH == 1) && (c_row_cnt == `IMAGE_HEIGHT - 1) 
		&& (!last_row_in_frame || c_col_cnt <= `IMAGE_WIDTH - FILTER_WIDTH)) begin
		ctrl_ifmap_patch_valid = 1;
	end else if (ctrl_st_run2 && (b_col_cnt <= `IMAGE_WIDTH - 2) && (b_row_cnt == `IMAGE_HEIGHT - 1)) begin // dhlee ++ 20170724
		ctrl_ifmap_patch_valid = 1;
	end

	// --- shift left --- //
	if ((FILTER_HEIGHT == 1) && q_i_valid_d[1]) begin
		ctrl_shift_left = 1;
	end else	
	if (ctrl_st_run && (q_i_valid_d[1] || q_i_valid_d[sel_q_i_valid_d_cond0])) begin 
		ctrl_shift_left = 1;
	end else if (ctrl_st_run1 && (q_i_valid_d[1] || q_i_valid_d[sel_q_i_valid_d_cond0])) begin 
		ctrl_shift_left = 1;
	end else if (ctrl_st_run1 && (c_row_cnt < `IMAGE_HEIGHT - 1)) begin
		ctrl_shift_left = 1;
	end else if (ctrl_st_run1 && (c_row_cnt == `IMAGE_HEIGHT - 1) && (linebuff_raddr >= 2) 
		&& (!last_row_in_frame || c_col_cnt <= `IMAGE_WIDTH - FILTER_WIDTH)) begin 
		ctrl_shift_left = 1;
	end else if (ctrl_st_run1 && (FILTER_WIDTH == 1) && (c_row_cnt == `IMAGE_HEIGHT - 1) 
		&& (!last_row_in_frame || c_col_cnt <= `IMAGE_WIDTH - FILTER_WIDTH)) begin 
		ctrl_shift_left = 1;
	end else if (ctrl_st_run2 && (b_col_cnt <= `IMAGE_WIDTH - 2) && (b_row_cnt == `IMAGE_HEIGHT - 1)) begin 
		ctrl_shift_left = 1;
	end

	// --- ifmap buff ready --- //
	if (ctrl_st_run && q_i_valid_d[sel_q_i_valid_d_cond1]) begin 
		ctrl_ifmap_buff_ready = 1;
	end else if (ctrl_st_run1 && q_i_valid_d[sel_q_i_valid_d_cond1]) begin 
		ctrl_ifmap_buff_ready = 1;
	end else if (ctrl_st_run1 && (c_row_cnt < `IMAGE_HEIGHT - 1)) begin
		ctrl_ifmap_buff_ready = 1;		
	end else if (ctrl_st_run1 && (c_row_cnt == `IMAGE_HEIGHT - 1) && (linebuff_raddr >= 3) 
		&& (!last_row_in_frame || c_col_cnt <= `IMAGE_WIDTH - FILTER_WIDTH + 1)) begin
		ctrl_ifmap_buff_ready = 1;
	end else if (ctrl_st_run1 && (FILTER_WIDTH == 1) && (c_row_cnt == `IMAGE_HEIGHT - 1) 
		&& (!last_row_in_frame || c_col_cnt <= `IMAGE_WIDTH - FILTER_WIDTH + 1)) begin
		ctrl_ifmap_buff_ready = 1;
	end else if (ctrl_st_run2 && (b_col_cnt <= `IMAGE_WIDTH - 1) && (b_row_cnt == `IMAGE_HEIGHT - 1)) begin 
		ctrl_ifmap_buff_ready = 1;
	end
end

// --- (ADDR) ifmap patch address signals --- //
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		ctrl_linebuff_full <= 0;
	end else if ((i_row_cnt == NUM_LINEBUFF - 1) && (i_col_cnt == `IMAGE_WIDTH - 1)) begin
		ctrl_linebuff_full <= 1;
	end
end
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		linebuff_sel_start_idx <= 0;
	end else begin
		if (b_row_cnt < (`FILTER_HEIGHT - 1)/2) begin
			linebuff_sel_start_idx <= 0;
		end else if ((b_row_cnt == (`IMAGE_HEIGHT - 1)) && (b_col_cnt == `IMAGE_WIDTH - ((FILTER_WIDTH - 1)/2 + 2))) begin
			linebuff_sel_start_idx <= 0;
		end else
		if ((ctrl_st_run || ctrl_st_run1 || ctrl_st_run2) 
			&& (b_col_cnt == `IMAGE_WIDTH - ((FILTER_WIDTH - 1)/2 + 2)) 
			&& ctrl_linebuff_full) begin		
			linebuff_sel_start_idx <= (linebuff_sel_start_idx + 1)%NUM_LINEBUFF;
		end
	end
end

always @(*) begin
	linebuff_raddr = 0;
	if (((ctrl_st_wait || ctrl_st_run) && i_valid)) begin 
		if (linebuff_waddr + 1 == `IMAGE_WIDTH) begin
			linebuff_raddr = 0;
		end else begin
			linebuff_raddr = linebuff_waddr + 1;
		end
	end else if (ctrl_st_run1) begin
		if (c_col_cnt + (3 + (FILTER_WIDTH - 1)/2) >= `IMAGE_WIDTH) begin 
			linebuff_raddr = c_col_cnt + (3 + (FILTER_WIDTH - 1)/2) - `IMAGE_WIDTH; 
		end else begin
			linebuff_raddr = c_col_cnt + (3 + (FILTER_WIDTH - 1)/2); 
		end
		linebuff_raddr = linebuff_raddr%`IMAGE_WIDTH;
	end
end

// --- (DATA) prefetch ifmap data from line buffer --- //
wire ifmap_prefetch_cond0 = !ctrl_st_run1 && boundary_ceil && !last_row_in_frame;
wire ifmap_prefetch_cond1 = buff_row_cnt_r >= (`IMAGE_HEIGHT - (FILTER_HEIGHT - 1)/2)? 1: (ctrl_st_run1 || ctrl_st_run2); 
always @(*) begin
	buff_row_cnt_r_abs = 0;
	if ((FILTER_WIDTH == 1)) begin // boundary condition 
		if (ifmap_prefetch_cond1 && (linebuff_raddr == 0) && (buff_row_cnt_r == `IMAGE_HEIGHT - 1)) begin
			buff_row_cnt_r_abs = 1;
		end	else begin
			if ((`IMAGE_HEIGHT - 1 - buff_row_cnt_r < 0) || (buff_row_cnt_r == 0)) begin
				buff_row_cnt_r_abs = 0;
			end else begin
				buff_row_cnt_r_abs = `IMAGE_HEIGHT - 1 - buff_row_cnt_r;
			end			
		end
	end else begin
		if ((`IMAGE_HEIGHT - 1 - buff_row_cnt_r < 0) || (buff_row_cnt_r == 0)) begin
			buff_row_cnt_r_abs = 0;
		end else begin
			buff_row_cnt_r_abs = `IMAGE_HEIGHT - 1 - buff_row_cnt_r;
		end
	end
end

always @(*) begin
	// initialization
	addr_prefetch_din = 0;
	addr_prefetch_linebuff = 0;
	for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
		for (row = 0; row < FILTER_HEIGHT - 1; row = row + 1) begin
			ifmap_prefetch_din[ch][row] = 0;
		end
	end	
	// valid data
	if (NUM_LINEBUFF_REAL > 0) begin // dhlee ++ 20170801 // condition.
		for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
			if (ifmap_prefetch_cond0) begin
				for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin 
					if (row < (FILTER_HEIGHT - 1)/2 + c_row_cnt) begin 
						addr_prefetch_din = (row[GetBitWidth(NUM_LINEBUFF):0] + ((FILTER_HEIGHT - 1)/2) - c_row_cnt)%NUM_LINEBUFF; // 1, 2 ... NUM_LINEBUFF
						addr_prefetch_linebuff = (linebuff_sel_start_idx + row[GetBitWidth(NUM_LINEBUFF):0])%NUM_LINEBUFF;
						ifmap_prefetch_din[ch][addr_prefetch_din] = linebuff_dout[addr_prefetch_linebuff][ch*IMG_PIX_W +: IMG_PIX_W];
					end
				end
			end else if (ifmap_prefetch_cond1) begin
				for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin 
					if (row <= (FILTER_HEIGHT - 1)/2 + buff_row_cnt_r_abs) begin 
						addr_prefetch_din = row[GetBitWidth(NUM_LINEBUFF):0]; // 0, 1 ... NUM_LINEBUFF
						addr_prefetch_linebuff = (linebuff_sel_start_idx + row[GetBitWidth(NUM_LINEBUFF):0])%NUM_LINEBUFF;
						ifmap_prefetch_din[ch][addr_prefetch_din] = linebuff_dout[addr_prefetch_linebuff][ch*IMG_PIX_W +: IMG_PIX_W];
					end
				end						
			end else begin
				for (row = 0; row < FILTER_HEIGHT - 1; row = row + 1) begin
					addr_prefetch_din = row[GetBitWidth(NUM_LINEBUFF):0]; // 0, 1 ...
					addr_prefetch_linebuff = (linebuff_sel_start_idx + row[GetBitWidth(NUM_LINEBUFF):0])%NUM_LINEBUFF;
					ifmap_prefetch_din[ch][addr_prefetch_din] = linebuff_dout[addr_prefetch_linebuff][ch*IMG_PIX_W +: IMG_PIX_W];
				end
			end
		end	
	end
end

// --- (DATA) ifmap data patch parser --- //
always @(*) begin
	// Initialization
	for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
		for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin
			for (col = 0; col < FILTER_WIDTH; col = col + 1) begin
				ifmap_buff_din[ch][row][col] = 0;
			end
		end
	end
	// Shift left: preparing next cycle data. (for each cycle)
	if (ctrl_shift_left) begin
		for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
			for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin
				for (col = 0; col < FILTER_WIDTH - 1; col = col + 1) begin
					ifmap_buff_din[ch][row][col] = q_ifmap_buff[ch][row][col + 1];
				end
			end
		end
	end
	// Data patch parsing
    // incomming data should put into right and botton of buffer.
    if ((FILTER_HEIGHT == 1) && i_valid) begin
		for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
			ifmap_buff_din[ch][FILTER_HEIGHT - 1][FILTER_WIDTH - 1] = i_ifdata[ch*IMG_PIX_W +: IMG_PIX_W]; // dhlee mod. 20170705 input_debug --> i_ifdata // 20170731: Channel
		end    	
    end else 
 	if ((ctrl_st_buff || ctrl_st_wait || ctrl_st_run) && i_valid) begin
		for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
			if (NUM_LINEBUFF_REAL > 0) begin // dhlee ++ 20170801 // condition.
				for (row = 0; row < FILTER_HEIGHT - 1; row = row + 1) begin
					ifmap_buff_din[ch][row][FILTER_WIDTH - 1] = ifmap_prefetch_din[ch][row];
				end
			end
			ifmap_buff_din[ch][FILTER_HEIGHT - 1][FILTER_WIDTH - 1] = i_ifdata[ch*IMG_PIX_W +: IMG_PIX_W]; // dhlee mod. 20170705 input_debug --> i_ifdata // 20170731: Channel
		end
	end else if (ifmap_prefetch_cond1 && (NUM_LINEBUFF_REAL > 0)) begin 
		for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
			for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin 
				if (row <= (FILTER_HEIGHT - 1)/2 + buff_row_cnt_r_abs) begin 
	 				ifmap_buff_din[ch][row][FILTER_WIDTH - 1] = ifmap_prefetch_din[ch][row];
 				end
 			end
		end
	end
end


// --- (DATA) ifmap register --- //
always @(posedge clk) begin //shlee -- 20171126
	if (ctrl_ifmap_patch_valid) begin 
		 //register update
		for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
			for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin
				for (col = 0; col < FILTER_WIDTH; col = col + 1) begin
					q_ifmap_buff[ch][row][col] <= ifmap_buff_din[ch][row][col];
				end
			end
		end
	end 
end


// --- (DATA) ifmap register mask: For making input of MAC module --- //
always @(*) begin
	// initialization
	for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
		for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin
			for (col = 0; col < FILTER_WIDTH; col = col + 1) begin
				q_ifmap_buff_mask[ch][row][col] = q_ifmap_buff[ch][row][col];
			end
		end
	end
	// start, end boundary case of each col.
	if (boundary_col_begin && (FILTER_WIDTH > 1)) begin
		for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
			for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin
				for (col = 0; col < FILTER_WIDTH; col = col + 1) begin
					if (col < (FILTER_WIDTH - 1)/2 - b_col_cnt) begin
						q_ifmap_buff_mask[ch][row][col] = 0;  // Left side of the ifmap patch.
					end
				end
			end
		end
	end else if (boundary_col_end && (FILTER_WIDTH > 1)) begin
		for (ch = 0; ch < IFMAP_CH; ch = ch + 1) begin
			for (row = 0; row < FILTER_HEIGHT; row = row + 1) begin
				for (col = 0; col < FILTER_WIDTH; col = col + 1) begin // dhlee -- 20170814
					if (col >= (FILTER_WIDTH - 1)/2 + (`IMAGE_WIDTH - b_col_cnt)) begin
						q_ifmap_buff_mask[ch][row][col] = 0; // Right side of the ifmap patch.
					end
				end
			end
		end
	end
end

// --- (DATA) ifmap 1D patch: Real input of MAC module --- //
integer ch_1d, row_1d, col_1d;
reg [GetBitWidth(IFMAP_CH*FILTER_HEIGHT*FILTER_WIDTH) - 1: 0] addr_ifmap_1d;
always @(*) begin
	filter_in_feature = 0;
	// --- parsing for filter 0 --- //
	for (ch_1d = 0; ch_1d < IFMAP_CH; ch_1d = ch_1d + 1) begin
		for (row_1d = 0; row_1d < FILTER_HEIGHT; row_1d = row_1d + 1) begin
			for (col_1d = 0; col_1d < FILTER_WIDTH; col_1d = col_1d + 1) begin
				addr_ifmap_1d = (ch_1d*FILTER_HEIGHT*FILTER_WIDTH) + row_1d*(FILTER_WIDTH) + col_1d;
				filter_in_feature[addr_ifmap_1d*IMG_PIX_W +: IMG_PIX_W] = q_ifmap_buff_mask[ch_1d][row_1d][col_1d];
			end
		end
	end
end

integer fidx_coeff, ch_1d_coeff, row_1d_coeff, col_1d_coeff;
reg [GetBitWidth(IFMAP_CH*FILTER_HEIGHT*FILTER_WIDTH) - 1: 0] addr_coeff_1d;
always @(*) begin
	for (fidx_coeff = 0; fidx_coeff < NUM_FILTER; fidx_coeff = fidx_coeff + 1) begin
		for (ch_1d_coeff = 0; ch_1d_coeff < IFMAP_CH; ch_1d_coeff = ch_1d_coeff + 1) begin
			for (row_1d_coeff = 0; row_1d_coeff < FILTER_HEIGHT; row_1d_coeff = row_1d_coeff + 1) begin
				for (col_1d_coeff = 0; col_1d_coeff < FILTER_WIDTH; col_1d_coeff = col_1d_coeff + 1) begin
					addr_coeff_1d = (ch_1d_coeff*FILTER_HEIGHT*FILTER_WIDTH) + row_1d_coeff*FILTER_WIDTH + col_1d_coeff;
					filter_in_coeff[fidx_coeff][addr_coeff_1d*IMG_PIX_W +: IMG_PIX_W] = q_filter_coeff[fidx_coeff][ch_1d_coeff][row_1d_coeff][col_1d_coeff];
				end
			end
		end
	end
end

// ---------------------------------------
// COMPONENTS: ifmap line buffer (# line buffers: Filter height - 1)
// ---------------------------------------
generate
	genvar buff_idx;
	for (buff_idx = 0; buff_idx < NUM_LINEBUFF_REAL; buff_idx = buff_idx + 1) begin: GENED_BLK
		ramSyncDPSimple 
		#(
			.WIDTH(IMG_PIX_W*IFMAP_CH),
			.N_DEPTH(`IMAGE_WIDTH),
			.W_DEPTH(GetBitWidth(`IMAGE_WIDTH))
		)
		u_linebuff
		(
			.clk		(clk						),
			.din 		(linebuff_din				),
			.waddr 		(linebuff_waddr				),
			.we 		(we[buff_idx]				),
			.raddr 		(linebuff_raddr				),
			.dout		(linebuff_dout[buff_idx]	)
		);
	end
endgenerate

// ---------------------------------------
// COMPONENTS: MAC
// ---------------------------------------
//generate
//	genvar alu_idx;
//	for (alu_idx = 0; alu_idx < NUM_FILTER/2; alu_idx = alu_idx + 1) begin: GENED_ALU
	
//		(* keep_hierarchy = "yes" *)
//		convolution_no_dsp
//		#
//		(
//			.NUM_CHANNEL       (IFMAP_CH                  ),
//			.FILTER_SIZE       (FILTER_HEIGHT*FILTER_WIDTH),
//			.TOTAL_WIDTH       (IMG_PIX_W                 ),
//			.FLOAT_WIDTH       (`FRACTIONAL_BITWIDTH      ),
//			.EXTRA_BITS_UPPER  (0                         ), // 2
//			.EXTRA_BITS_LOWER  (`FRACTIONAL_BITWIDTH      ) // 10
//		)		
//		u_ALU_CONV
//		(
//			.fmap    (filter_in_feature          ),
//			.weight_1  (filter_in_coeff   [2*alu_idx]),
//			.weight_2  (filter_in_coeff   [2*alu_idx+1]),
//			.bias_1 	 (q_filter_bias     [2*alu_idx]),
//			.bias_2 	 (q_filter_bias     [2*alu_idx+1]),
//			.conv_out_1(filter_out_feature[2*alu_idx]),
//			.conv_out_2(filter_out_feature[2*alu_idx+1])
//		);
//	end
//endgenerate
generate
	genvar alu_idx;
	for (alu_idx = 0; alu_idx < NUM_FILTER; alu_idx = alu_idx + 1) begin: GENED_ALU
	
		(* keep_hierarchy = "yes" *)
		convolution_no_dsp
		#
		(
			.NUM_CHANNEL       (IFMAP_CH                  ),
			.FILTER_SIZE       (FILTER_HEIGHT*FILTER_WIDTH),
			.TOTAL_WIDTH       (IMG_PIX_W                 ),
			.FLOAT_WIDTH       (`FRACTIONAL_BITWIDTH      ),
			.EXTRA_BITS_UPPER  (0                         ), // 2
			.EXTRA_BITS_LOWER  (`FRACTIONAL_BITWIDTH      ) // 10
		)		
		u_ALU_CONV
		(
			.fmap    (filter_in_feature          ),
			.weight  (filter_in_coeff   [alu_idx]),
			.bias 	 (q_filter_bias     [alu_idx]),
			.conv_out(filter_out_feature[alu_idx])
		);
	end
endgenerate


// ---------------------------------------
// COMPONENTS: ReLU
// ---------------------------------------
generate
	genvar relu_idx;
	for (relu_idx = 0; relu_idx < NUM_FILTER; relu_idx = relu_idx + 1) begin: GENED_RELU
		ReLU
		#(.IMG_PIX_W(IMG_PIX_W))
		u_ReLU
		(
			.i_relu(filter_out_feature[relu_idx]),
			.o_relu(ofmap_relu[relu_idx]        )
		);
	end
endgenerate

// ---------------------------------------
// Output: (1 cycle delay)
// ---------------------------------------
// --- Filter coefficient store done --- //
assign o_filter_ready = filter_coeff_stored;
// --- CONV output --- //
assign o_ofdata = temp_buff;
assign o_valid = alu_out_valid;
integer temp_buff_idx;

// output buffer parser according to variable filter sizes
always @(*) begin
	i_temp_buff = 0;
	if (ctrl_ifmap_buff_ready) begin
		if (RELU_ON == 1) begin
			for (temp_buff_idx = 0; temp_buff_idx < NUM_FILTER; temp_buff_idx = temp_buff_idx + 1) begin
				i_temp_buff[IMG_PIX_W*temp_buff_idx +: IMG_PIX_W] = ofmap_relu[temp_buff_idx];
			end
		end else begin
			for (temp_buff_idx = 0; temp_buff_idx < NUM_FILTER; temp_buff_idx = temp_buff_idx + 1) begin
				i_temp_buff[IMG_PIX_W*temp_buff_idx +: IMG_PIX_W] = filter_out_feature[temp_buff_idx];
			end			
		end
	end
end

always @ (posedge clk) begin
    alu_out_valid <= ctrl_ifmap_buff_ready;
end

always @(posedge clk) begin 
	if (ctrl_ifmap_buff_ready) begin
		temp_buff <= i_temp_buff;
	end	
end
// -------------------------------------
// ---------------------------------------
// Counters
// ---------------------------------------
// ifmap counter
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		i_col_cnt <= 0;
		i_row_cnt <= 0;
	end else if (i_valid) begin
		i_col_cnt <= i_col_cnt + 1;
		if (i_col_cnt == `IMAGE_WIDTH - 1) begin
			i_col_cnt <= 0;
			i_row_cnt <= i_row_cnt + 1;
		end
		if ((i_row_cnt == `IMAGE_HEIGHT - 1) && (i_col_cnt == `IMAGE_WIDTH - 1)) begin
			i_row_cnt <= 0;
		end
	end
end

// conv counter
always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		c_col_cnt <= 0;
		c_row_cnt <= 0;
	end else if (ctrl_st_idle) begin
		c_col_cnt <= 0;
		c_row_cnt <= 0;
	end else begin
		if (c_col_cnt == `IMAGE_WIDTH - 1) begin
			c_col_cnt <= 0;
		end else if (alu_out_valid) begin
			c_col_cnt <= c_col_cnt + 1;
		end else begin
			c_col_cnt <= c_col_cnt;
		end
		if ((c_row_cnt == `IMAGE_HEIGHT - 1) && (c_col_cnt == `IMAGE_WIDTH - 1)) begin
			c_row_cnt <= 0;
		end else if ((c_col_cnt == `IMAGE_WIDTH - 1)) begin
			c_row_cnt <= c_row_cnt + 1;
		end else begin
			c_row_cnt <= c_row_cnt;
		end
	end
end

// patch buffer counter
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		b_col_cnt <= 0;
		b_row_cnt <= 0;
	end else if (ctrl_ifmap_buff_ready) begin
		if (b_col_cnt == `IMAGE_WIDTH - 1) begin
			b_col_cnt <= 0;
		end else begin
			b_col_cnt <= b_col_cnt + 1;
		end
		if ((b_row_cnt == `IMAGE_HEIGHT - 1) && (b_col_cnt == `IMAGE_WIDTH - 1)) begin
			b_row_cnt <= 0;
		end else if (b_col_cnt == `IMAGE_WIDTH - 1) begin
			b_row_cnt <= b_row_cnt + 1;
		end
	end
end

// line buffer counter
always @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		buff_row_cnt_r <= 0;
	end else if (linebuff_raddr == `IMAGE_WIDTH - 1) begin
		if (buff_row_cnt_r == `IMAGE_HEIGHT - 1) begin
			buff_row_cnt_r <= 0;
		end else begin
			buff_row_cnt_r <= buff_row_cnt_r + 1;
		end
	end
end
// --------------------------------
// Functions 
// --------------------------------
function integer GetBitWidth(input integer num);
begin
    if(num > 1)
    begin
            GetBitWidth = 0;
            for(num = num - 1; num>0; GetBitWidth=GetBitWidth+1)
                    num = num >> 1;
    end
    else
            GetBitWidth = 1;
end
endfunction


endmodule

// --------------------------------
// Sub module
// --------------------------------
module ReLU
#
(
	parameter IMG_PIX_W    = 8
)
(
	input  [IMG_PIX_W - 1: 0] i_relu,
	output [IMG_PIX_W - 1: 0] o_relu
);

reg [IMG_PIX_W - 1: 0] temp_o_relu;
always @(*) begin
	temp_o_relu = 0;
	if (i_relu[IMG_PIX_W - 1] == 0) temp_o_relu = i_relu; // MSB is sign bit (1's complement)
end
assign o_relu = temp_o_relu;

endmodule
