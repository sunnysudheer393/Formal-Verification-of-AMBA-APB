module apb_master(
    input logic pclk, presetn,
    input logic [31:0] wdata, prdata, addr,
    input logic transfer, pready, write,

    output logic [31:0] pwdata, data_out, paddr,
    output logic penable, psel, pwrite,
    
    input logic pslverr

);

//logic invalid_state_error, invalid_read_addr, invalid_write_addr, invalid_write_data;

typedef enum logic [1:0] { Idle = 2'b00, Setup = 2'b01, Enable = 2'b10  } state_r;
state_r current_state, next_state;

//Current state update
always_ff @(posedge pclk) begin
    if(!presetn) current_state <= Idle;
    else current_state <= next_state;
end

//next state logic and output logic
always_comb begin
    penable = 1'b0;
    psel = 1'b0;
    next_state = current_state;
    case (current_state)
        Idle: begin
            penable = 1'b0;
            psel = 1'b0;
            if(transfer) begin
                next_state = Setup;
            end else next_state = Idle;
        end
        Setup: begin
            psel = 1'b1;
            penable = 1'b0;
            next_state = Enable;
        end
        Enable: begin
            psel = 1'b1;
            penable = 1'b1;
            if(pready) begin
                next_state = transfer ? Setup : Idle;
            end else next_state = Enable;
        end
        default: next_state = Idle;
    endcase
end

logic pwrite_reg;
//Data and address latching
always_ff @(posedge pclk) begin
    if(!presetn) begin
        pwdata <= '0;
        paddr <= '0;
        data_out <= '0;
        pwrite <= 1'b0;
    end else if (current_state == Idle && next_state == Setup) begin
        paddr <= addr;
        pwdata <= wdata;
        pwrite <= write;
    end else if(current_state == Enable && pready && !pwrite) begin
        data_out <= prdata;
    end
end

logic transfer_error;
//Output transfer error signal
always_ff @(posedge pclk) begin
    if(!presetn) begin
        transfer_error <= 1'b0;
    end else if(current_state == Enable && pready) begin
        transfer_error <= pslverr;
    end
end

endmodule
