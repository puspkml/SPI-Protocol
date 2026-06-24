module spi_slave #(
    parameter size = 16,
    parameter mode = 0
)(
    input  wire rst,
    input  wire cs_n,
    input  wire sclk,
    input  wire mosi,
    output wire miso,
    output reg [7:0] address = 0,
    output reg [7:0] data_out = 0
);

    localparam FINAL = size;

    reg [7:0] bit_count;
    reg rw;

    reg [7:0] address_shift;
    reg [7:0] rx_data;
    reg [7:0] tx_data;

    reg miso_reg;
    reg miso_en;

    assign miso = miso_en ? miso_reg : 1'bz;

    initial begin
        tx_data = 8'h5A;
    end

generate

if (mode == 0 || mode == 2) begin

    always @(posedge sclk or posedge rst or posedge cs_n) begin

        if (rst) begin
            bit_count <= 0;
            rw <= 0;
            address_shift <= 0;
            rx_data <= 0;
            address <= 0;
            data_out <= 0;
            miso_en <= 0;
            miso_reg <= 0;
        end
        else if (cs_n) begin
            bit_count <= 0;
            rw <= 0;
            address_shift <= 0;
            rx_data <= 0;
            miso_en <= 0;
            miso_reg <= 0;
        end
        else begin

            if (bit_count == 0) begin
                rw <= mosi;
            end

            else if (bit_count >= 1 && bit_count <= 8) begin

                address_shift <= {address_shift[6:0], mosi};

                if (bit_count == 8) begin
                    address <= {address_shift[6:0], mosi};

                    if (!rw) begin
                        miso_en  <= 1'b1;
                        miso_reg <= tx_data[7];
                    end
                end
            end

            else if (rw && bit_count >= 9 && bit_count <= FINAL) begin

                rx_data <= {rx_data[6:0], mosi};

                if (bit_count == (FINAL))
                    data_out <= {rx_data[6:0], mosi};

            end

            else if (!rw && bit_count >= 9 && bit_count < FINAL) begin

                miso_reg <= tx_data[7 - (bit_count - 8)];

            end

            bit_count <= bit_count + 1;

        end
    end

end
else begin

    always @(negedge sclk or posedge rst or posedge cs_n) begin

        if (rst) begin
            bit_count <= 0;
            rw <= 0;
            address_shift <= 0;
            rx_data <= 0;
            address <= 0;
            data_out <= 0;
            miso_en <= 0;
            miso_reg <= 0;
        end
        else if (cs_n) begin
            bit_count <= 0;
            rw <= 0;
            address_shift <= 0;
            rx_data <= 0;
            miso_en <= 0;
            miso_reg <= 0;
        end
        else begin

            if (bit_count == 0) begin
                rw <= mosi;
            end

            else if (bit_count >= 1 && bit_count <= 8) begin

                address_shift <= {address_shift[6:0], mosi};

                if (bit_count == 8) begin
                    address <= {address_shift[6:0], mosi};

                    if (!rw) begin
                        miso_en  <= 1'b1;
                        miso_reg <= tx_data[7];
                    end
                end
            end

            else if (rw && bit_count >= 9 && bit_count < FINAL) begin

                rx_data <= {rx_data[6:0], mosi};

                if (bit_count == (FINAL - 1))
                    data_out <= {rx_data[6:0], mosi};

            end

            else if (!rw && bit_count >= 9 && bit_count < FINAL) begin

                miso_reg <= tx_data[7 - (bit_count - 8)];

            end

            bit_count <= bit_count + 1;

        end
    end

end

endgenerate

endmodule
