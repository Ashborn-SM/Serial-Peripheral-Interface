`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.10.2023 20:25:31
// Design Name: 
// Module Name: test_bench
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


module test_bench();
    reg P_clk, reset;
    
    // Master
    reg[7:0]    tx_data_m;
    wire[7:0]   rx_data_m;
    reg         tx_start_m;
    reg[1:0]    ss_m;
    wire        s0_m, s1_m, s2_m, s3_m;
    wire        s_clk_m, mosi_m, miso_m, spic_m;
    reg         i_mode_set;
    reg[1:0]    SPI_MODE;
    
    // Slave
    reg[7:0]    tx_data_s;
    wire[7:0]   rx_data_s_2, rx_data_s_3;
    reg         tx_dv_s;
    wire        spic_s_2, spic_s_3;
    
    SPI_master dut1(P_clk, reset, tx_data_m, tx_start_m, rx_data_m, ss_m, s0_m, s1_m, s2_m, s3_m,
                    s_clk_m, mosi_m, miso_m, i_mode_set, SPI_MODE, spic_m);
    SPI_slave_00 dut2(P_clk, s_clk_m, reset, s0_m, tx_data_s, tx_dv_s, rx_data_s_2, mosi_m, miso_m, spic_s_2);
    SPI_slave_11 dut3(P_clk, s_clk_m, reset, s1_m, tx_data_s, tx_dv_s, rx_data_s_3, mosi_m, miso_m, spic_s_3);
    
    always #50 P_clk = ~P_clk;
    initial begin
        P_clk = 1;
        reset = 1;
        
        tx_data_m = {8{1'b0}};
        tx_data_s = {8{1'b0}};
        
        tx_start_m = 1'b0;
        tx_dv_s = 1'b0;
        
        ss_m = 2'b00;
        SPI_MODE = 2'b00; // cpol = 0, cpha = 0
        #500
        reset = 1'b0;
        tx_data_m = 8'haa;
        tx_data_s = 8'hbb;
        i_mode_set = 1'b1;
        #100
        i_mode_set = 1'b0;
        tx_dv_s = 1'b1;
        #100
        tx_dv_s = 1'b0;
        tx_start_m = 1'b1;
        #100
        tx_start_m = 1'b0;
        
        #7000
        SPI_MODE = 2'b11; // cpol = 1, chpa = 1
        #100 
        i_mode_set = 1'b1;
        tx_data_m = 8'h77;
        tx_data_s = 8'h88;
        ss_m = 2'b01;
        #100
        i_mode_set = 1'b0;
        tx_dv_s = 1'b1;
        #100
        tx_dv_s = 1'b0;
        tx_start_m = 1'b1;
        #100
        tx_start_m = 1'b0;
    end
endmodule
