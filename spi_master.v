module spi_master #(
    parameter size = 16,
    parameter mode = 0
) (
    input wire clk,
    input wire en,
    input wire rst,
    input wire tx_en,
    input wire rx_en,
    input wire miso,
    input wire [7:0] address,
    input wire [7:0] data_out,
    output reg sclk = 1'b0,
    output reg cs_n = 1'b1,
    output reg mosi = 1'b0,
    output reg [7:0] data_in = 0,
    output reg rx_valid = 0
);

    reg [7:0] count;
    reg [7:0] bit_count;
    reg [15:0] tx_data;
    reg [7:0] rx_data;

    localparam LIMIT = 8'b0000_0001;
    localparam FINAL = size+1; // 17

    reg tx_en_reg;
    reg rx_en_reg;

    reg is_write;

    wire CPOL = mode[1];
    wire CPHA = mode[0];

    always @(posedge clk) begin
        if (rst) begin
            count <= 0;
            bit_count <= 0;
            sclk <= mode[1];
            cs_n <= 1;
            mosi <= 1'b0;
            tx_data <= 0;
            rx_data <= 0;
            data_in <= 0;
            tx_en_reg <= 0;
            rx_en_reg <= 0;
            rx_valid <= 0;
            is_write <= 0;

        end else begin
            tx_en_reg <= tx_en;
            rx_en_reg <= rx_en;
            rx_valid  <= 1'b0;

            if (en == 1) begin

                if (cs_n == 1'b1) begin

                    if (tx_en_reg == 1'b1 && tx_en == 1'b0) begin
                        cs_n <= 1'b0;
                        bit_count <= 0;
                        count <= 0;
                        sclk <= CPOL;
                        is_write <= 1'b1;
                        tx_data <= {address, data_out};
                        mosi <= 1'b1;
                        rx_data <= 8'b0;
                    end
                    else if (rx_en_reg == 1'b1 && rx_en == 1'b0) begin
                        cs_n <= 1'b0;
                        bit_count <= 0;
                        count <= 0;
                        sclk <= CPOL;
                        is_write <= 1'b0;
                        tx_data <= {address, 8'b0};
                        rx_data <= 8'b0;
                        mosi <= 1'b0;
                    end

                end else begin
                    if (count == LIMIT) begin
                        count <= 0;
                        sclk <= ~sclk;

                        // Sample edge
                        if ((CPHA == 0 && sclk == CPOL) ||
                            (CPHA == 1 && sclk != CPOL)) begin

                            if (!is_write && bit_count >= 9 && bit_count < (FINAL)) begin
                                rx_data <= {rx_data[6:0], miso};
                            end

                            bit_count <= bit_count + 1;

                        end else begin
                            // Shift edge
                            if (bit_count < FINAL) begin

                                if (!is_write && bit_count >= 8) begin
                                    mosi <= 1'b0;
                                end else begin
                                    tx_data <= {tx_data[14:0],1'b0};
                                    mosi <= tx_data[15];
                                end

                            end else begin

                                cs_n <= 1'b1;
                                mosi <= 1'b0;
                                sclk <= CPOL;

                                if (!is_write) begin
                                    data_in <= rx_data[7:0];
                                    rx_valid <= 1'b1;
                                end
                            end
                        end

                    end else begin
                        count <= count + 1;
                    end
                end

            end else begin
                cs_n <= 1'b1;
                sclk <= CPOL;
                mosi <= 1'b0;
            end
        end
    end

endmodule





