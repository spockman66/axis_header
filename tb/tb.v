`timescale 1ns/1ns

`include "../rtl/axi_stream_insert_header.v"

module tb; 

    // clock
    reg clk;
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // reset 
    reg rst_n;
    initial begin
        rst_n <= 1'b0;
        #10
        rst_n <= 1'b1;
    end

    parameter      DATA_WD = 16;
    parameter DATA_BYTE_WD = DATA_WD / 8;

    reg                       valid_in;
    reg      [DATA_WD-1 : 0]  data_in;
    reg [DATA_BYTE_WD-1 : 0]  keep_in;
    reg                       last_in;
    wire                      ready_in;

    reg                       valid_insert;
    reg      [DATA_WD-1 : 0]  header_insert;
    reg [DATA_BYTE_WD-1 : 0]  keep_insert;
    wire                      ready_insert;

    wire                      valid_out;
    wire     [DATA_WD-1 : 0]  data_out;
    wire [DATA_BYTE_WD-1 : 0] keep_out;
    wire                      last_out;
    reg                       ready_out;

    reg  shakehand_succ;


    always @(posedge clk) begin
        if(valid_in & ready_in)
            shakehand_succ <= 1'b1;
        else
            shakehand_succ <= 1'b0;
    end

    initial begin
        init();

        start(1);
        wait(shakehand_succ); 
        last(1);

        repeat(2)@(negedge clk);

        single(1);

        repeat(2)@(negedge clk);

        start(1);
        repeat(1) begin 
            wait(shakehand_succ); 
            load();
        end
        last(1);

        repeat(2)@(negedge clk);
        
        start(3);
        repeat(4) begin 
            wait(shakehand_succ); 
            load();
        end
        last(1);

        repeat(2)@(negedge clk);

        start(1);
        repeat(4) begin 
            wait(shakehand_succ); 
            load();
        end
        last(1);

        start(1);
        repeat(2) begin 
            wait(shakehand_succ); 
            load();
        end
        last(2);

        start(0);
        repeat(6) begin 
            wait(shakehand_succ); 
            load();
        end
        last(1);

        repeat(2)@(negedge clk);

        start(0);
        repeat(1) begin 
            wait(shakehand_succ); 
            load();
        end
        last(0);

        close();

    end


    axi_stream_insert_header #(
            .DATA_WD            	(DATA_WD),
            .DATA_BYTE_WD       	(DATA_BYTE_WD)
    ) u_inst (
            .clk           			(clk),
            .rst_n         			(rst_n),
            .valid_in      			(valid_in),
            .data_in       			(data_in),
            .keep_in       			(keep_in),
            .last_in       			(last_in),
            .ready_in      			(ready_in),
            .valid_insert  			(valid_insert),
            .header_insert 			(header_insert),
            .keep_insert   			(keep_insert),
            .ready_insert  			(ready_insert),
            .valid_out     			(valid_out),
            .data_out      			(data_out),
            .keep_out      			(keep_out),
            .last_out      			(last_out),
            .ready_out     			(ready_out)
    );


    reg seed;
    initial begin
        seed <= 1;
    end
    
    task init; 
    begin
        valid_in      <= 1'b0;
        data_in       <= 1'b0;
        keep_in       <= 1'b0;
        last_in       <= 1'b0;
        valid_insert  <= 1'b0;
        header_insert <= 1'b0;
        keep_insert   <= 1'b0;
        ready_out     <= 1'b0;
    end
    endtask

    task start; 
    input [2:0] type;
    begin
        repeat(1)@(negedge clk);
        keep_in       <= {DATA_BYTE_WD{1'b1}};
        data_in       <= {$random};
        valid_in  	  <= 1;
        last_in       <= 0;
        
        keep_insert <= {DATA_BYTE_WD{1'b1}}>>type;

        header_insert <= {$random};
        valid_insert  <= 1;

        repeat(1)@(negedge clk);
        ready_out     <= 1;				// 验证反压
    end
    endtask

    task load;
    begin
        data_in       <= {$random};
        keep_in       <= {DATA_BYTE_WD{1'b1}};
        @(posedge clk);
    end
    endtask

    task last;
    input [2:0] type;
    begin
        keep_insert <= {DATA_BYTE_WD{1'b1}}>>type;

        last_in       <= 1;
        data_in       <= {$random};
        @(posedge clk);
        last_in       	<= 0;
        valid_in		<= 0;
        valid_insert 	<= 0;
    end
    endtask

    task close;
    begin
        valid_in  	  <= 0;
        valid_insert  <= 0;
        repeat(2)@(negedge clk);
        ready_out     <= 0;
        @(negedge clk);
    end
    endtask

    // 一个beat传输的情况
    task single;
    input [2:0] type;
    begin
        keep_in       <= {DATA_BYTE_WD{1'b1}};
        data_in       <= {$random};
        valid_in  	  <= 1;
        last_in       <= 1;
        
        keep_insert <= {DATA_BYTE_WD{1'b1}}>>type;
        header_insert <= {$random};
        valid_insert  <= 1;

        repeat(1)@(negedge clk);
        ready_out     <= 1;				// 验证反压

        wait(shakehand_succ);
        last_in       	<= 0;
        valid_in		<= 0;
        valid_insert 	<= 0;
    end
    endtask


endmodule