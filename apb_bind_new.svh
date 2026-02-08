bind apb_top apb_formal_tb apb_fv (
    .pclk(pclk),
    .presetn(presetn),
    .transfer(transfer),
    .wdata(wdata),
    .addr(addr),
    .pready(pready),
    .data_out(data_out),
    .write(write),
    .pslverr(pslverr),
    .penable(penable),
    .psel(psel),
    .pwrite(pwrite),
    .paddr(paddr),
    .pwdata(pwdata),
    .prdata(prdata)
);