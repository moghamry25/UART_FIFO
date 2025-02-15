`timescale 1ns/1ps

module tx_tb;

    // Parameters
    parameter CLK_PERIOD = 10;  // 100 MHz clock
    parameter DVSR = 1;        // Baud rate divisor for 115200 baud (assuming oversampling of 16)

    // Signals
    reg clk, reset;
    reg wr_en;
    reg [7:0] data_in;
    wire tx, tx_done_tick;
    wire full, empty;
    
    // FIFO-TX connections
    wire [7:0] fifo_to_tx;
    wire tx_start = ~empty;  // Start when FIFO has data

    // Instantiate FIFO
    FIFO fifo(
        .data_in(data_in),
        .wr_en(wr_en),
        .rd_en(~tx_done_tick), // Read when transmission is done
        .clk(clk),
        .rst_n(~reset),
        .full(full),
        .empty(empty),
        .data_out(fifo_to_tx)
    );

    // Baud rate generator
    wire s_tick;
    baud_rate_generator brg(
        .clk(clk),
        .reset(reset),
        .tick(s_tick),
        .dvsr(DVSR)
    );

    // UART Transmitter
    tx uart_tx(
        .s_tick(s_tick),
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .din(fifo_to_tx),
        .tx(tx),
        .tx_done_tick(tx_done_tick)
    );

    // Clock generation
    always begin
        clk = 0;
        #(CLK_PERIOD/2);
        clk = 1;
        #(CLK_PERIOD/2);
    end

    // Test sequence
    initial begin
        // Initialize signals
        reset = 1;
        wr_en = 0;
        data_in = 8'h00;
        #100;

        // Release reset
        reset = 0;
        #100;

        // Send a single byte (0xA5)
        $display("Sending 0xA5");
        write_to_fifo(8'hA5);
        
        #100;
       

        #5000;
        $display("Test complete");
        $finish;
    end

    // Task to write to FIFO
    task write_to_fifo(input [7:0] data);
        begin
            @(negedge clk);
            wr_en = 1;
            data_in = data;
            @(negedge clk);
            wr_en = 0;
        end
    endtask

    // Task to wait for transmission
    task wait_for_transfer;
        begin
            wait(tx_done_tick);
            #100;
        end
    endtask

    // Monitoring
    initial begin
        $monitor("Time: %t | TX: %b | Data Sent: 0x%h | FIFO: %s",
                 $time, tx, fifo_to_tx, empty ? "Empty" : "Active");
    end

endmodule
