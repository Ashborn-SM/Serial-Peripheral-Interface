`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2023 12:46:22
// Design Name: 
// Module Name: SPI_slave_00
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

// cpol = 0, cpha = 0

module SPI_slave_00
    (
        input           P_CLK,
        input           S_CLK,
        input           reset,
        // Slave
        input           i_SS,
        
        // TX
        input[7:0]      i_TX_DATA,
        input           i_TX_DV,
        
        // RX
        output reg[7:0] o_RX_DATA,
        
        // SPI
        input           i_MOSI,
        output          o_MISO,
        output          o_SPIC
    );
    
    reg[7:0]        r_tx_data;
    reg[2:0]        rx_counter;      
    reg[2:0]        tx_counter; 
    reg[7:0]        r_rx_data;
    reg             r_miso;
    reg             r_ss;
    
    // SPI I/O
    assign o_SPIC = i_SS;
    assign o_MISO = i_SS? 1'bz: r_miso;
    
    always@(posedge P_CLK, posedge reset) begin
        if(reset) begin
            r_tx_data <= {8{1'b0}};
            r_ss <= 1'b0;
            o_RX_DATA <= {8{1'b0}};
        end
        else begin
            r_ss <= i_SS;
            if(i_TX_DV) r_tx_data <= i_TX_DATA;
            o_RX_DATA <= i_SS? o_RX_DATA: r_rx_data;
        end
    end
    
    // RX
    always@(posedge S_CLK, posedge i_SS) begin
        if(i_SS) begin 
            rx_counter <= 3'b111;
            r_rx_data <= {8{1'b0}};
        end
        else begin
            r_rx_data <= {i_MOSI, r_rx_data[7:1]};
            rx_counter <= rx_counter - 1;
        end
    end
    
    // TX
    always@(negedge S_CLK, negedge i_SS) begin
         if(r_ss & ~i_SS) begin
            r_miso <= r_tx_data[3'b000];
            tx_counter <= 3'b001;
        end
        else begin
            tx_counter <= tx_counter + 1'b1;
            r_miso <= r_tx_data[tx_counter];
        end
    end   
    
endmodule
