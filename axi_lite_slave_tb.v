`timescale 1ns / 1ps

module tb_axi_lite_memory;

    // AXI signals
    reg         ACLK;
    reg         ARESETN;

    reg  [31:0] S_AXIL_AWADDR;
    reg         S_AXIL_AWVALID;
    wire        S_AXIL_AWREADY;

    reg  [31:0] S_AXIL_WDATA;
    reg  [3:0]  S_AXIL_WSTRB;
    reg         S_AXIL_WVALID;
    wire        S_AXIL_WREADY;

    wire [1:0]  S_AXIL_BRESP;
    wire        S_AXIL_BVALID;
    reg         S_AXIL_BREADY;

    reg  [31:0] S_AXIL_ARADDR;
    reg         S_AXIL_ARVALID;
    wire        S_AXIL_ARREADY;

    wire [31:0] S_AXIL_RDATA;
    wire [1:0]  S_AXIL_RRESP;
    wire        S_AXIL_RVALID;
    reg         S_AXIL_RREADY;

    // Instantiate DUT
    axi_lite_memory dut (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .S_AXIL_AWADDR(S_AXIL_AWADDR),
        .S_AXIL_AWVALID(S_AXIL_AWVALID),
        .S_AXIL_AWREADY(S_AXIL_AWREADY),
        .S_AXIL_WDATA(S_AXIL_WDATA),
        .S_AXIL_WSTRB(S_AXIL_WSTRB),
        .S_AXIL_WVALID(S_AXIL_WVALID),
        .S_AXIL_WREADY(S_AXIL_WREADY),
        .S_AXIL_BRESP(S_AXIL_BRESP),
        .S_AXIL_BVALID(S_AXIL_BVALID),
        .S_AXIL_BREADY(S_AXIL_BREADY),
        .S_AXIL_ARADDR(S_AXIL_ARADDR),
        .S_AXIL_ARVALID(S_AXIL_ARVALID),
        .S_AXIL_ARREADY(S_AXIL_ARREADY),
        .S_AXIL_RDATA(S_AXIL_RDATA),
        .S_AXIL_RRESP(S_AXIL_RRESP),
        .S_AXIL_RVALID(S_AXIL_RVALID),
        .S_AXIL_RREADY(S_AXIL_RREADY)
    );

    // Clock generation: 100 MHz
    initial ACLK = 0;
    always #5 ACLK = ~ACLK;

    // Test sequence
    integer block = 0, offset = 0;
    reg [31:0] addr;
    reg [31:0] write_data;

    initial begin
        // Initialize signals
        ARESETN = 0;
        S_AXIL_AWADDR = 0;
        S_AXIL_AWVALID = 0;
        S_AXIL_WDATA = 0;
        S_AXIL_WSTRB = 4'hF;
        S_AXIL_WVALID = 0;
        S_AXIL_BREADY = 0;    // Start low - drive when BVALID is asserted
        S_AXIL_ARADDR = 0;
        S_AXIL_ARVALID = 0;
        S_AXIL_RREADY = 0;    // Start low - drive when RVALID is asserted

        #20 ARESETN = 1;
        #10;

        // Loop through blocks
        for (block = 0; block < 4; block = block + 1) begin
            $display("\n==== BLOCK %0d TEST ====", block);
            // Write 10 addresses
            for (offset = 0; offset < 10; offset = offset + 1) begin
                addr = {24'd0, block[1:0], offset[5:0]};  // [7:6]=block, [5:0]=offset
                write_data = {block, offset, 16'hABCD};   // Unique data per write
                axi_write(addr, write_data);
            end

            // Read 10 addresses
            for (offset = 0; offset < 10; offset = offset + 1) begin
                addr = {24'd0, block[1:0], offset[5:0]};
                axi_read(addr);
            end
        end

        #50 $finish;
    end

    // AXI Write Task with proper BREADY handshake
    task axi_write(input [31:0] addr, input [31:0] data);
    begin
        @(posedge ACLK);
        S_AXIL_AWADDR  <= addr;
        S_AXIL_AWVALID <= 1;
        S_AXIL_WDATA   <= data;
        S_AXIL_WSTRB   <= 4'hF;
        S_AXIL_WVALID  <= 1;
        S_AXIL_BREADY  <= 0;  // Initially low

        // Wait for AWREADY and WREADY together
        wait(S_AXIL_AWREADY && S_AXIL_WREADY);
        @(posedge ACLK);
        S_AXIL_AWVALID <= 0;
        S_AXIL_WVALID  <= 0;

        // Wait for BVALID from slave
        wait(S_AXIL_BVALID);
        @(posedge ACLK);
        S_AXIL_BREADY <= 1;  // Accept write response

        @(posedge ACLK);
        S_AXIL_BREADY <= 0;  // Deassert after handshake
    end
    endtask

    // AXI Read Task with proper RREADY handshake
    task axi_read(input [31:0] addr);
    begin
        @(posedge ACLK);
        S_AXIL_ARADDR  <= addr;
        S_AXIL_ARVALID <= 1;
        S_AXIL_RREADY  <= 0;  // Initially low

        // Wait for ARREADY
        wait(S_AXIL_ARREADY);
        @(posedge ACLK);
        S_AXIL_ARVALID <= 0;

        // Wait for RVALID from slave
        wait(S_AXIL_RVALID);
        @(posedge ACLK);
        S_AXIL_RREADY <= 1;   // Accept read data

        @(posedge ACLK);
        $display("Read Addr 0x%08h => Data: 0x%08h", addr, S_AXIL_RDATA);

        @(posedge ACLK);
        S_AXIL_RREADY <= 0;   // Deassert after handshake
    end
    endtask

endmodule
