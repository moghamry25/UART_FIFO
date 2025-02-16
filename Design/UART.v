module UART(
    input clk, reset, rx, rd_uart, wr_uart,
    input [7:0] w_data,
    input [31:0] dvsr,
    output tx, rx_empty, tx_full,
    output [7:0] r_data,
    output full, almostempty1, almostempty2,
    output wr_ack1, wr_ack2, overflow1, overflow2,
    output underflow1, underflow2, almostfull1, almostfull2
);

    // Baud rate generator instantiation
    wire s_tick;
    baud_rate_generator baud_gen(
        .clk(clk),
        .reset(reset),
        .dvsr(dvsr),
        .tick(s_tick)
    );

    // Receiver section
    wire [7:0] rx_data_out;
    wire rx_done;
    rx receiver(
        .s_tick(s_tick),
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .dout(rx_data_out),
        .rx_done_tick(rx_done)
    );

    // Transmitter section
    wire tx_empty;
    wire [7:0] tx_data_in;
    wire tx_done, tx_start;
    assign tx_start = ~tx_empty;  // Start when FIFO has data
    
    tx transmitter(
        .s_tick(s_tick),
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .din(tx_data_in),
        .tx(tx),
        .tx_done_tick(tx_done)
    );

    // FIFO instantiation for receive path
    FIFO rx_fifo(
        .data_in(rx_data_out),
        .wr_en(rx_done),
        .rd_en(rd_uart),
        .clk(clk),
        .rst_n(~reset),
        .data_out(r_data),
        .full(full),
        .empty(rx_empty),
        .almostfull(almostfull1),
        .almostempty(almostempty1),
        .wr_ack(wr_ack1),
        .overflow(overflow1),
        .underflow(underflow1)
    );

    // FIFO instantiation for transmit path
    FIFO tx_fifo(
        .data_in(w_data),
        .wr_en(wr_uart),
        .rd_en(~tx_start),
        .clk(clk),
        .rst_n(~reset),
        .data_out(tx_data_in),
        .full(tx_full),
        .empty(tx_empty),
        .almostfull(almostfull2),
        .almostempty(almostempty2),
        .wr_ack(wr_ack2),
        .overflow(overflow2),
        .underflow(underflow2)
    );

endmodule