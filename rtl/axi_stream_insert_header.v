module axi_stream_insert_header #(
    parameter DATA_WD = 32,
    parameter DATA_BYTE_WD = DATA_WD / 8
) (
    input clk,
    input rst_n,

    // AXI Stream input original data
    input valid_in,
    input [DATA_WD-1 : 0] data_in,
    input [DATA_BYTE_WD-1 : 0] keep_in,
    input last_in,
    output reg ready_in,

    // AXI Stream output with header inserted
    output reg valid_out,
    output reg [DATA_WD-1 : 0] data_out,
    output reg [DATA_BYTE_WD-1 : 0] keep_out,
    output reg last_out,
    input ready_out,

    // The header to be inserted to AXI Stream input
    input valid_insert,
    input [DATA_WD-1 : 0] header_insert,
    input [DATA_BYTE_WD-1 : 0] keep_insert,
    output reg ready_insert
);

function integer clog2;
input integer n;
begin
    for (clog2 = 0; n > 0; clog2 = clog2 + 1)
        n = n >> 1;
end
endfunction

// -------------reg define---------------//
// input reg 
reg [DATA_WD-1:0] data_in_d;
reg [DATA_BYTE_WD-1:0] keep_insert_d;
reg ready_in_d;

wire ready_in_rise;

reg last_in_d,last_in_dd;

wire [DATA_WD*2-1:0] header_r;
wire [DATA_WD*2-1:0] data_r;

localparam ZEROS_WD = clog2(DATA_BYTE_WD);

wire [ZEROS_WD-1:0] header_zeros;
reg [ZEROS_WD-1:0] header_zeros_d;

wire [ZEROS_WD-1:0] final_zeros;
wire [ZEROS_WD-1:0] total_zeros;					// 0的总数不会超过4


wire [DATA_WD-1 : 0] data_out_header;
wire [DATA_WD-1:0] data_out_payload;

reg [DATA_WD*2-1 : 0] data_out_tail_shift;

// ---------------assign-----------------//
assign ready_in_rise = ready_in & ~ready_in_d;

// 2个周期宽度的DATA寄存器
assign header_r = {header_insert, data_in};
assign data_r = {data_in_d, data_in};

// 统计keep信号中1和0的个数，得到移位次数
function [ZEROS_WD-1:0] cal_zeros;
    input [DATA_BYTE_WD-1:0] keep;
    integer i;
begin
    cal_zeros = {ZEROS_WD{1'b0}};
    for(i=0; i<DATA_BYTE_WD; i=i+1)begin
        if(~keep[i])
            cal_zeros = cal_zeros + 1'b1;
        else
            cal_zeros = cal_zeros;
    end
end
endfunction

assign header_zeros = $unsigned(cal_zeros(keep_insert));
assign final_zeros = $unsigned(cal_zeros(keep_in));
assign total_zeros = final_zeros + header_zeros_d;


assign data_out_header = header_r[DATA_WD*2-1-(header_zeros*8) -: DATA_WD];
assign data_out_payload = data_r[DATA_WD*2-1-(header_zeros_d*8) -: DATA_WD];


always @(posedge clk or negedge rst_n) begin 
    if(~rst_n) begin
        ready_in_d <= 0;
    end
    else begin
        ready_in_d <= ready_in;
    end
end

//hand-shake
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        ready_in <= 0;
    else if(~ready_in & ~valid_out & ready_out & valid_insert & valid_in)			
        ready_in <= 1;
    else if(ready_in & last_in)
        ready_in <= 0;
    else
        ready_in <= ready_in;
end

always @(posedge clk or negedge rst_n) begin 
    if(~rst_n)
        ready_insert <= 0;
    else if (ready_in)
        ready_insert <= 0;
    else if (~valid_out & ready_out & valid_insert & valid_in)
        ready_insert <= 1;
    else
        ready_insert <= ready_insert;
end


always @(posedge clk or negedge rst_n) begin 
    if(~rst_n)
        last_in_d <= 0;
    else if(ready_in)
        last_in_d <= last_in;
    else
        last_in_d <= 0;
end

always @(posedge clk or negedge rst_n) begin 
    if(~rst_n)
        data_in_d <= 0;
    else if (valid_in)
        data_in_d <= data_in;
    else
        data_in_d <= data_in_d;
end

always @(posedge clk or negedge rst_n) begin 
    if(~rst_n) begin
        data_out <= 0;
        keep_out <= 0;
        last_out <= 0;
        valid_out <= 0;
        header_zeros_d <= 0;
    end
    else if (ready_in_rise) begin
        data_out <= data_out_header;
        valid_out <= 1;
        keep_out <= {DATA_BYTE_WD{1'b1}};
        last_out <= 0;
        header_zeros_d <= header_zeros;
    end
    else if (last_in_d) begin
        data_out <= data_out_payload;
        keep_out <= {DATA_BYTE_WD{1'b1}} << total_zeros;
        valid_out <= 1;
        last_out <= 1;
    end
    else if(ready_in) begin
        data_out  <= data_out_payload;
        keep_out <= {DATA_BYTE_WD{1'b1}};
        valid_out <= 1;
        last_out <= 0;
    end
    else begin
        data_out <= {DATA_WD{1'b0}};
        keep_out <= {DATA_BYTE_WD{1'b0}};
        keep_insert_d <= {DATA_BYTE_WD{1'b0}};
        last_out <= 0;
        valid_out <= 0;
    end
end

endmodule
