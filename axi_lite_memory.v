`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/12/2025 07:18:29 PM
// Design Name: 
// Module Name: axi_lite_memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_lite_memory #(parameter DW = 32)
(
    input                   ACLK,
    input                   ARESETN,

    // Write Address Channel
    input       [31:0]      S_AXIL_AWADDR,
    input                   S_AXIL_AWVALID,
    output reg              S_AXIL_AWREADY,

    // Write Data Channel
    input       [DW-1:0]    S_AXIL_WDATA,
    input       [(DW/8)-1:0] S_AXIL_WSTRB,
    input                   S_AXIL_WVALID,
    output reg              S_AXIL_WREADY,

    // Write Response Channel
    output reg  [1:0]       S_AXIL_BRESP,
    output reg              S_AXIL_BVALID,
    input                   S_AXIL_BREADY,

    // Read Address Channel
    input       [31:0]      S_AXIL_ARADDR,
    input                   S_AXIL_ARVALID,
    output reg              S_AXIL_ARREADY,

    // Read Data Channel
    output reg  [DW-1:0]    S_AXIL_RDATA,
    output reg  [1:0]       S_AXIL_RRESP,
    output reg              S_AXIL_RVALID,
    input                   S_AXIL_RREADY 
  );
  
    integer i;  
    
    // 4 x 32 x 64 bit Memory Blocks 
    reg [DW-1:0] block0 [0:63];
    reg [DW-1:0] block1 [0:63];
    reg [DW-1:0] block2 [0:63];
    reg [DW-1:0] block3 [0:63];
    
    // Initializing Memory Blocks
    initial begin
        for(i = 0; i <64; i = i + 1)begin
            block0[i] = 32'h00000000;
            block1[i] = 32'h11111111;
            block2[i] = 32'h22222222;
            block3[i] = 32'h33333333;
        end
    end
           
    // Handshake Flags
    reg aw_handshake, w_handshake, ar_handshake;
    
    // Channel Registers
    reg [31:0] write_addr;
    reg [DW-1:0] write_data;
    reg [(DW/8)-1:0] write_strb;
    reg [31:0] read_addr;
    
    // Write Address Channel Logic 
    always @(posedge ACLK, negedge ARESETN)begin
        if(!ARESETN)begin
            S_AXIL_AWREADY <= 0;
            aw_handshake <= 0;
            write_addr <= 0;            
        end
        else begin
            S_AXIL_AWREADY <= (!S_AXIL_AWREADY && S_AXIL_AWVALID)
                              &&(!S_AXIL_BVALID || S_AXIL_BREADY);
            if(S_AXIL_AWREADY && S_AXIL_AWVALID)begin
                aw_handshake <= 1;
                write_addr <= S_AXIL_AWADDR;
            end
            else if(S_AXIL_BREADY && S_AXIL_BVALID)begin
                aw_handshake <= 0;
            end
        end
    end
    
    // Write Data Channel Logic 
    always @(posedge ACLK, negedge ARESETN)begin
        if(!ARESETN)begin
            S_AXIL_WREADY <= 0;
            w_handshake <= 0;
            write_data <= 0;
            write_strb <= 0;            
        end
        else begin
            S_AXIL_WREADY <= (!S_AXIL_WREADY && S_AXIL_WVALID)
                              &&(!S_AXIL_BVALID || S_AXIL_BREADY);
            if(S_AXIL_WREADY && S_AXIL_WVALID)begin 
                w_handshake <= 1;
                write_data <= S_AXIL_WDATA;
                write_strb <= S_AXIL_WSTRB;
            end
            else if(S_AXIL_BREADY && S_AXIL_BVALID)begin
                w_handshake <= 0;
            end
        end
    end
    
    // Write Response Channel Logic 
    always @(posedge ACLK, negedge ARESETN)begin
        if(!ARESETN)begin
            S_AXIL_BRESP <= 2'b00;
            S_AXIL_BVALID <= 0;           
        end
        else begin
            if(w_handshake && aw_handshake && !S_AXIL_BVALID)begin
                case(write_addr[7:6])
                    2'b00 : begin
                        for (i = 0; i < 4; i = i + 1)
                            if (write_strb[i]) block0[write_addr[5:0]][i*8 +: 8] <= write_data[i*8 +: 8];
                    end
                    2'b01 : begin
                        for (i = 0; i < 4; i = i + 1)
                            if (write_strb[i]) block1[write_addr[5:0]][i*8 +: 8] <= write_data[i*8 +: 8];
                    end
                    2'b10 : begin
                        for (i = 0; i < 4; i = i + 1)
                            if (write_strb[i]) block2[write_addr[5:0]][i*8 +: 8] <= write_data[i*8 +: 8];
                    end
                    2'b11 : begin
                        for (i = 0; i < 4; i = i + 1)
                            if (write_strb[i]) block3[write_addr[5:0]][i*8 +: 8] <= write_data[i*8 +: 8];
                    end
                endcase
                S_AXIL_BVALID <= 1;
                S_AXIL_BRESP <= 2'b00;
            end
            if(S_AXIL_BVALID && S_AXIL_BREADY)begin
                S_AXIL_BVALID <= 0;
            end
        end
    end
    
    // Read Address Channel Logic
    always @(posedge ACLK, negedge ARESETN)begin
        if(!ARESETN)begin
            S_AXIL_ARREADY <= 0;
            read_addr <= 0;
            ar_handshake <= 0;
        end
        else begin
            S_AXIL_ARREADY <= (!S_AXIL_ARREADY && S_AXIL_ARVALID && !S_AXIL_RVALID);
            if(S_AXIL_ARREADY && S_AXIL_ARVALID)begin
                read_addr <= S_AXIL_ARADDR;
                ar_handshake <= 1;
            end
            else if (S_AXIL_RVALID && S_AXIL_RREADY)begin
                ar_handshake <= 0;
            end
        end
    end
    
    // Read Data Channel Logic
    always @(posedge ACLK, negedge ARESETN)begin
        if(!ARESETN)begin
            S_AXIL_RVALID <= 0;
            S_AXIL_RRESP <= 2'b00;
            S_AXIL_RDATA <= 32'h00000000;
        end
        else begin
            if(ar_handshake && !S_AXIL_RVALID)begin
                case (read_addr[7:6])
                    2'b00: S_AXIL_RDATA <= block0[read_addr[5:0]];
                    2'b01: S_AXIL_RDATA <= block1[read_addr[5:0]];
                    2'b10: S_AXIL_RDATA <= block2[read_addr[5:0]];
                    2'b11: S_AXIL_RDATA <= block3[read_addr[5:0]];
                endcase
                S_AXIL_RVALID <= 1;
                S_AXIL_RRESP <= 2'b00;
            end
            if(S_AXIL_RVALID && S_AXIL_RREADY)begin
                S_AXIL_RVALID <= 0;
            end
        end
    end
endmodule
