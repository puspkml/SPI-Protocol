module tb_system();

    reg clk;
    reg rst;
    reg en;
    reg tx_en;
    reg rx_en;

    reg [7:0] address;
    reg [7:0] data_out;

    wire [7:0] data_in;
    wire rx_valid;

    wire sclk;
    wire cs_n;
    wire mosi;
    wire miso;

    wire [7:0] slave_address;
    wire [7:0] slave_data;

    initial begin
        clk = 0;
    end

    always #5 clk = ~clk;

    spi_master master (
        .clk(clk),
        .en(en),
        .rst(rst),
        .tx_en(tx_en),
        .rx_en(rx_en),
        .miso(miso),
        .address(address),
        .data_out(data_out),
        .sclk(sclk),
        .cs_n(cs_n),
        .mosi(mosi),
        .data_in(data_in),
        .rx_valid(rx_valid)
    );

    spi_slave slave (
        .rst(rst),
        .cs_n(cs_n),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .address(slave_address),
        .data_out(slave_data)
    );

    initial begin

        $dumpfile("spi_system.vcd");
        $dumpvars(0, tb_system);

        rst = 1;
        en = 0;
        tx_en = 0;
        rx_en = 0;
        address = 8'h00;
        data_out = 8'h00;

        #20;

        rst = 0;
        en = 1;

        // WRITE

        #20;

        address = 8'h12;
        data_out = 8'hAB;

        tx_en = 1;
        #20;
        tx_en = 0;

        #1000;

        $display("WRITE RESULT");
        $display("Slave Address = %h", slave_address);
        $display("Slave Data    = %h", slave_data);

        // READ

        address = 8'h34;

        rx_en = 1;
        #20;
        rx_en = 0;

        wait(rx_valid);

        #20;

        $display("READ RESULT");
        $display("Master Data = %h", data_in);

        #200;

        $finish;

    end

endmodule
