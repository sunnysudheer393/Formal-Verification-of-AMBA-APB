module apb_top(
    input logic pclk, presetn,
    input logic transfer, write,
    input logic [31:0] wdata, addr,

    output logic pready,
    output logic [31:0] data_out

);

logic penable, pslverr, psel, pwrite;
logic [31:0] paddr, pwdata, prdata;

apb_master apb_m (.pclk(pclk), .presetn(presetn), .wdata(wdata), .prdata(prdata), .addr(addr), .transfer(transfer), .pready(pready), 
                    .write(write), .pwdata(pwdata), .data_out(data_out), .paddr(paddr), .penable(penable), .psel(psel), .pwrite(pwrite),
                    .pslverr(pslverr)
                    );

apb_slave apb_s1 (.pclk(pclk), .presetn(presetn), .pwrite(pwrite), .psel(psel), .penable(penable), .paddr(paddr),
                .pwdata(pwdata), .prdata(prdata), .pready(pready), .pslverr(pslverr)
                );

endmodule
