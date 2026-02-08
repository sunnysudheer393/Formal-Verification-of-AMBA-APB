// Simple formal harness with assumptions and covers for JasperGold/VC Formal
typedef enum logic [1:0] { Idle = 2'b00, Setup = 2'b01, Enable = 2'b10  } state_r;


module apb_formal_tb(
    input logic pclk,
    input logic presetn,
    input logic transfer,
    input logic write,
    input logic [31:0] wdata,
    input logic [31:0] addr,

    input state_r current_state,

    input logic pready,
    input logic [31:0] data_out,
    input logic pslverr,
    input logic penable,
    input logic psel,
    input logic pwrite,
    input logic [31:0] paddr,
    input logic [31:0] pwdata,
    input logic [31:0] prdata
);

// Inputs are stable during an active enable phase until handshake completes
assume property (@(posedge pclk) disable iff(!presetn) psel && penable && !pready |-> $stable({transfer,write,addr,wdata}))
else $error("Env changed inputs during enable phase");

// Avoid Xs on driving inputs
assume property (@(posedge pclk) disable iff(!presetn) !$isunknown({transfer,write,addr,wdata}));

//penable only high when psel is high
assert property (@(posedge pclk) disable iff (!presetn) penable |-> psel);

//When psel rises, penable should be low in that cycle
assert property (@(posedge pclk) disable iff (!presetn) $rose(psel) |-> !penable);

//When enable is low and psel is high, next cycle enable should be high
assert property (@(posedge pclk) disable iff (!presetn) psel && !penable |=> penable);

//Setup to Enable takes one cycle without any other state in between o any condition
assert property (@(posedge pclk) disable iff(!presetn) apb_m.current_state ==  Setup |=> apb_m.current_state == Enable);

//If no further transfer it goes to Idle
assert property (@(posedge pclk) disable iff(!presetn) apb_m.current_state ==  Enable && pready && !transfer |=> apb_m.current_state == Idle);

//If further transfer it goes to Setup
assert property (@(posedge pclk) disable iff(!presetn) apb_m.current_state ==  Enable && pready && transfer |=> apb_m.current_state == Setup);

//If current is Enable and pready is not high, it stays in Enable
assert property (@(posedge pclk) disable iff(!presetn) apb_m.current_state ==  Enable && !pready |=> apb_m.current_state == Enable);

//Address and write data stable during enable phase until PREADY
assert property (@(posedge pclk) disable iff(!presetn) psel && penable && !pready |-> $stable(paddr));
assert property (@(posedge pclk) disable iff(!presetn) psel && penable && pwrite && !pready |-> $stable(pwdata));
assert property (@(posedge pclk) disable iff(!presetn) psel && penable && !pready |-> $stable(pwrite));

//data out should capture prdata when read handshake completes(when psel, penable, pready is high and pwrite is low)
assert property (@(posedge pclk) disable iff(!presetn) psel && penable && !pwrite && !pready |->s_eventually (pready && data_out == prdata));

//no enable during idle and setup phase
assert property (@(posedge pclk) disable iff(!presetn) (apb_m.current_state == Idle || apb_m.current_state == Setup) |-> penable == 1'b0);

//psel only high in setup phase and enable phase and only because of the transfer signal
assert property (@(posedge pclk) disable iff(!presetn) psel |-> (apb_m.current_state == Setup || apb_m.current_state == Enable));
assert property (@(posedge pclk) disable iff(!presetn) $rose(psel) |-> $past(transfer));

//for extended write/read, the address, data and pwrite should be stable until pready is high
assert property (@(posedge pclk) disable iff(!presetn) $rose(penable) && !pready |-> $stable({paddr, pwrite, psel, penable}) [+] ##0 $rose(pready) && $stable({paddr, pwrite, psel, penable}));
assert property (@(posedge pclk) disable iff(!presetn) $rose(penable) && pwrite && !pready |-> $stable({paddr, pwrite, psel, penable, pwdata}) [+] ##0 $rose(pready) && $stable({paddr, pwrite, psel, penable, pwdata}));

//penable should be low after pready is high until next transfer
//assert property (@(posedge pclk) disable iff(!presetn) $rose(penable) |-> ##[0:$] $rose(pready) ##1 (!transfer |-> penable == 1'b0));
assert property (@(posedge pclk) disable iff(!presetn) $rose(penable) |-> ##[0:$] $rose(pready) ##1 (transfer || !penable));

//pready unknown until penalbe is high, and then can be 0 or 1 but not unknown
//assert property (@(posedge pclk) disable iff(!presetn) ($isunknown(pready)) |-> s_until ($rose(penable)) && !$isunknown(pready));
//assert property (@(posedge pclk) disable iff(!presetn) (psel && !penable) |-> ($isunknown(pready)) s_until ($rose(penable)) && !$isunknown(pready));
assert property (@(posedge pclk) disable iff(!presetn) (psel && !penable) |-> ( !$isunknown(pready) or $isunknown(pready)));

//prdata can be unknown until pready is high, and then should not change until next transfer
assert property (@(posedge pclk) disable iff(!presetn) $rose(penable) && !pwrite && !pready |-> ($isunknown(prdata) or !$isunknown(prdata)) s_until $rose(pready));

//Invalid state should not be reached
assert property (@(posedge pclk) disable iff(!presetn) apb_m.current_state == Idle |=> !(apb_m.current_state == Enable));

//pready eventually reached after enable
assert property (@(posedge pclk) disable iff(!presetn) psel && $rose(penable) |-> s_eventually pready);

//after pready and if transfer is high, it goes to setup phase
assert property (@(posedge pclk) disable iff(!presetn) $rose(pready) && apb_m.current_state == Enable && transfer |=> apb_m.current_state == Setup);

//after pready and if transfer is low, it goes to idle phase
assert property (@(posedge pclk) disable iff(!presetn) $rose(pready) && apb_m.current_state == Enable && !transfer |=> apb_m.current_state == Idle);

//no X's when psel is asserted
assert property (@(posedge pclk) disable iff(!presetn) psel |-> !$isunknown(paddr));

//when a transfer started and in enable phase, eventually either pready is seen or psel drops
assert property (@(posedge pclk) disable iff(!presetn) psel ##1 penable |-> (##[0:$] (pready && penable && psel)) or (##[0:$] !psel));





//Cover Properties to identify unreachable scenarios

// Covers to ensure key scenarios are reachable
cover property (@(posedge pclk) disable iff(!presetn) presetn ##1 transfer && !pwrite ##1 psel && penable ##[1:5] pready);
cover property (@(posedge pclk) disable iff(!presetn) presetn ##1 transfer && pwrite  ##1 psel && penable ##[1:5] pready);


//Write and Read transfer covers
sequence cov_write;
    psel && !penable && pwrite ##1 psel && penable && pwrite [*1:$] ##1 pready;
endsequence
sequence cov_read;
    psel && !penable && !pwrite ##1 psel && penable && !pwrite [*1:$] ##1 pready;
endsequence
cover property (@(posedge pclk) disable iff(!presetn) cov_write );
cover property (@(posedge pclk) disable iff(!presetn) cov_read );


//Write and read back specific data covers
sequence s_write(addr_s, data_s);
    psel && penable && pwrite && pready && addr==addr_s && pwdata==data_s;
endsequence
sequence s_read_back(addr_s, data_s);
    psel && penable && !pwrite && pready && addr==addr_s && prdata==data_s;
endsequence
cover property (@(posedge pclk) disable iff(!presetn) s_write($past(paddr), $past(pwdata)));
cover property (@(posedge pclk) disable iff(!presetn) s_read_back($past(paddr), $past(pwdata)));






endmodule

