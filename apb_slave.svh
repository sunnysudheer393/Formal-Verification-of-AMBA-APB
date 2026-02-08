 module apb_slave #(
    parameter int READ_WAIT_CYCLES  = 2,
    parameter int WRITE_WAIT_CYCLES = 1
)(
    input logic pclk, presetn, pwrite,psel, penable,
    input logic [31:0] paddr, pwdata,

    output logic [31:0] prdata,
    output logic pready, pslverr
);

logic [31:0] mem[0:31];
logic [4:0] addr_reg;

logic [$clog2(READ_WAIT_CYCLES+1)-1:0] rd_cnt;
logic [$clog2(WRITE_WAIT_CYCLES+1)-1:0] wr_cnt;

assign addr_reg = paddr[6:2]; // Assuming word-aligned addresses
assign pslverr = 1'b0;
//assign pready = 1'b1; // Always ready for simplicity

logic active_read, active_write;
//detect transfer type

assign active_write = psel && penable && pwrite;
assign active_read  = psel && penable && !pwrite;

//Pready with wait states
always_ff @(posedge pclk) begin
    if(!presetn) begin
        pready <= 1'b1;
        rd_cnt <= '0;
        wr_cnt <= '0;
    end else begin
        if(active_write) begin
            if(wr_cnt < WRITE_WAIT_CYCLES) begin
                pready <= 1'b0;
                wr_cnt <= wr_cnt + 1'b1;
            end else begin
                pready <= 1'b1;
                wr_cnt <= '0;
            end
        end else if(active_read) begin
            if(rd_cnt < READ_WAIT_CYCLES) begin
                pready <= 1'b0;
                rd_cnt <= rd_cnt + 1'b1;
            end else begin
                pready <= 1'b1;
                rd_cnt <= '0;
            end
        end else begin
            pready <= 1'b0; // Not active, ready for next transfer
            rd_cnt <= '0;
            wr_cnt <= '0;
        end
    end
end


// Write
always_ff @(posedge pclk) begin
    if (active_write && pready) begin
        mem[addr_reg] <= pwdata;
    end
end

// Read (combinational per APB spec)
always_ff @(posedge pclk) begin
    if(!presetn) begin
        prdata <= '0;
    end else if (active_read && pready) begin
        prdata <= mem[addr_reg];
    end else begin
        prdata <= '0;
    end
end


endmodule
