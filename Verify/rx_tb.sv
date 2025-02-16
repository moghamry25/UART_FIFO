
module rx_tb;
    reg clk;
    reg reset;
    reg [31:0] dvsr;
    wire tick;
    reg rx;
    wire [7:0] dout;
    wire rx_done_tick;
    logic rd_uart;
    logic [7:0]r_data;

    // Instantiate the baud rate generator
    baud_rate_generator brg (
        .clk(clk),
        .reset(reset),
        .dvsr(dvsr),
        .tick(tick)
    );

    // Instantiate the UART receiver
    rx u_rx (
        .s_tick(tick),
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .dout(dout),
        .rx_done_tick(rx_done_tick)
    );

      FIFO fifo(
        .data_in(dout),
        .wr_en(rx_done_tick),
        .rd_en(rd_uart), // Read when transmission is done
        .clk(clk),
        .rst_n(~reset),
        .full(full),
        .empty(empty),
        .data_out(r_data)
    );

    // Generate 100 MHz clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // Apply reset
    initial begin
        reset = 1;
        #20 reset = 0;
    end

    // Stimulus: Send data 0xA5 via UART
    initial begin
        dvsr = 0; // Set for 115200 baud with 100 MHz clock
        rx = 1; // Idle state
         rd_uart =  0 ;
        
        // Wait for reset to complete
        #30;

        // Send start bit (0)
        rx = 0;
        #320; // Wait for 1 bit duration (16 * 540ns)

        // Send data bits (LSB first: 1,0,1,0,0,1,0,1)
        rx = 1; // Bit 0
        #320;
        rx = 0; // Bit 1
        #320;
        rx = 1; // Bit 2
        #320;
        rx = 0; // Bit 3
        #320;
        rx = 0; // Bit 4
        #320;
        rx = 1; // Bit 5
        #320;
        rx = 0; // Bit 6
        #320;
        rx = 1; // Bit 7
        #320;

        // Send stop bit (1)
        rx = 1;
        #320;

        rd_uart = 1;
        #320;
        $display("Received Data: 0x%h", r_data);
        if (dout === 8'hA5)
            $display("Test Passed!");
        else
            $display("Test Failed!");
        $finish;
    end

  
endmodule