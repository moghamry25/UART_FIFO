module baud_rate_generator(
    input clk,
    input reset,
    input [31:0] dvsr,
    output reg tick
);

reg [31:0] count;




always @(posedge clk or posedge reset ) begin

    if(reset) begin
        count <= 0;
        tick <= 0;
    end
    else begin
        if(count == dvsr) begin
            count <= 0;
            tick <= ~tick;
        end
        else begin
            count <= count + 1;
        end
    end


end
endmodule