`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2023 12:46:09
// Design Name: 
// Module Name: SPI_master
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
                                                                     
module SPI_master 
      #(                                             
        parameter     CLOCK_DIVIDER = 8,
        parameter     SPI_MODE = 0
        // SPI MODE = 0, CPOL = 0, CPHA = 0
        // SPI MODE = 1, CPOL = 0, CPHA = 1
        // SPI MODE = 2, CPOL = 1, CPHA = 0
        // SPI MODE = 3, CPOL = 1, CPHA = 1 
      )
      ( 
        input               P_CLK,
        input               reset,
        
        // TX
        output reg          o_TX_READY,
        input[7:0]          i_TX_DATA,
        input               i_TX_START,
        
        // RX
        output reg[7:0]     o_RX_DATA,
        output reg          o_RX_DONE,
        
        // SPI
        output reg          S_CLK,
        output reg          o_MOSI,
        input               i_MISO
    );
    
    // constants
    localparam          clock_div = $clog2(CLOCK_DIVIDER);
    localparam          cpol = (SPI_MODE == 2 | SPI_MODE == 3);
    localparam          cpha = (SPI_MODE == 1 | SPI_MODE == 3);

    reg[4:0]            edge_counter;
    reg[clock_div-1:0]  p_clk_counter;
    reg                 leading_edge;
    reg                 trailing_edge;
    reg                 spi_clk;
    reg                 r_tx_ready;
    reg[3:0]            rx_counter;
    reg[7:0]            r_rx_data;
    reg[2:0]            tx_counter;
    reg[7:0]            tx_data;        
    reg                 r_tx_start;
    reg                 r_rx_done;
    
    // Serial Clock
    always@(posedge P_CLK, posedge reset) begin
        if(reset) begin
            edge_counter <= 3'b000;
            p_clk_counter <= {clock_div{1'b0}};
            leading_edge <= 1'b0;
            trailing_edge <= 1'b0;             
            spi_clk <= cpol;
        end
        else begin
            if(i_TX_START) begin
                edge_counter <= 5'b10000;
                p_clk_counter <= {clock_div{1'b0}};
            end  
            trailing_edge <= 1'b0;
            leading_edge <= 1'b0;
            if(edge_counter > 5'b00000) begin
                if(p_clk_counter == CLOCK_DIVIDER/2 - 1'b1) begin
                    leading_edge <= 1'b1;
                    edge_counter <= edge_counter - 1'b1;
                    spi_clk <= ~spi_clk; 
                    p_clk_counter <= p_clk_counter + 1'b1;
                end
                else if(p_clk_counter == CLOCK_DIVIDER - 1'b1) begin
                    trailing_edge <= 1'b1;
                    edge_counter <= edge_counter - 1'b1;
                    spi_clk <= ~spi_clk;
                    p_clk_counter <= 4'b0000;
                end
                else p_clk_counter <= p_clk_counter + 1'b1;
            end
        end
    end
    
    // MOSI    
    always@(posedge P_CLK, posedge reset) begin
        if(reset) begin
            o_MOSI <= 1'b0;
            tx_counter <= 3'b000;
            o_TX_READY <= 1'b0;
        end    
        else begin
            if(i_TX_START) begin
                tx_counter <= 3'b000;
                o_TX_READY <= 1'b0;
            end
            else begin
            
                // when the data is being sampled at the first leading edge
                if(~cpha & r_tx_start) begin
                    o_MOSI <= tx_data[tx_counter];
                    tx_counter <= tx_counter + 1'b1;
                end 
               
                // when the data is being sampled at other edges
                else if((cpha & leading_edge) | (~cpha & trailing_edge) ) begin
                    o_MOSI <= tx_data[tx_counter];
                    tx_counter <= tx_counter + 1'b1;
                end
                
                if(tx_counter == 3'b111) o_TX_READY <= 1'b1;
            end
        end
    end
    
    // MISO    
     always@(posedge P_CLK, posedge reset) begin
        if(reset) begin
            rx_counter <= 3'b111;
            r_rx_data <= {8{1'b0}};
            o_RX_DONE <= 1'b0;
            o_RX_DATA <= {8{1'b0}};
        end    
        else begin
            if(i_TX_START) begin
                rx_counter <= 3'b111;
                o_RX_DONE <= 1'b0;
            end
            else begin   
                if((cpha & trailing_edge) | (~cpha & leading_edge)) begin
                    o_RX_DATA[rx_counter] <= i_MISO;
                    rx_counter <= rx_counter - 1'b1;
                end
                if(rx_counter == 3'b000) o_RX_DONE <= 1'b1;
            end
        end
    end
    
    always@(posedge P_CLK, posedge reset) begin
        if(reset) begin
            r_tx_start <= 1'b0;
            S_CLK <= cpol;
        end
        else begin
            S_CLK <= spi_clk;
            r_tx_start <= i_TX_START;
            if(i_TX_START) tx_data <= i_TX_DATA;
        end
    end
    
endmodule
