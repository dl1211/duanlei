`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/05/29 09:29:55
// Design Name: 
// Module Name: iic_send_top
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
module iic_send_top
(
    input           clk           , // 系统50MHz时钟
    input           rst_n         , // 系统全局复位
	input           [1:0]wr_en    , // 读写使能，10---send,01---recieve
    
    // 标准的IIC设备总线
    output          scl           , // IIC总线的串行时钟线
    inout           sda            // IIC总线的双向数据线
);

	wire     s_done_flag ;
	wire     r_done_flag ;
	
	reg      send_en;
	reg      recv_en;
	
	wire     sda_send;
	wire     scl_send;
	wire     sda_recv;
	wire     scl_recv;
	
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n) begin
			send_en <= 1'b0;
			recv_en <= 1'b0;
		end	
		else begin 
			case (wr_en)
				2'b10:begin
					recv_en <= 1'b0;
					if(s_done_flag == 1'b1)
						send_en <= 1'b0;
					else 
						send_en <= 1'b1;
				end
				2'b01:begin
					send_en <= 1'b0;
					if(r_done_flag == 1'b1)
						recv_en <= 1'b0;
					else
						recv_en <= 1'b1;
				end
				default:begin
					send_en <= 1'b0;
					recv_en <= 1'b0;
				end			
			endcase
		end
	end
	
	assign scl = (send_en&(!recv_en))?scl_send:scl_recv;
	assign sda = (send_en&(!recv_en))?sda_send:sda_recv;
	

iic_send INST_iic_send
	(
		.I_clk           (clk            ), // 系统50MHz时钟
		.I_rst_n         (rst_n          ), // 系统全局复位
		.I_iic_send_en   (send_en        ), // 发送使能位，高电平有效
		
		.I_dev_addr      (7'b1010_000    ), // IIC设备的物理地址
		.I_word_addr     (8'h23          ), // IIC设备的字地址，即我们想操作的IIC的内部地址
		.I_write_data    (8'h45          ), // 往IIC设备的字地址写入的数据 
		.O_done_flag     (s_done_flag    ), // 读或写IIC设备结束标志位
		
		// 标准的IIC设备总线
		.O_scl           (scl_send       ), // IIC总线的串行时钟线
		.IO_sda          (sda_send       )  // IIC总线的双向数据线
	);
	
iic_recv INST_iic_recv
	(
		.I_clk           (clk            ), // 系统50MHz时钟
		.I_rst_n         (rst_n          ), // 系统全局复位
		.I_iic_recv_en   (recv_en        ), // 接收使能位，高电平有效
		
		.I_dev_addr      (7'b1010_000    ), // IIC设备的物理地址
		.I_word_addr     (8'h23          ), // IIC设备的字地址，即我们想操作的IIC的内部地址
		.O_read_data     (W_read_data    ), // 从IIC设备的字地址读出来的数据   
		.O_done_flag     (r_done_flag    ), // 读或写IIC设备结束标志位
		
		// 标准的IIC设备总线
		.O_scl           (scl_recv       ), // IIC总线的串行时钟线
		.IO_sda          (sda_recv       )  // IIC总线的双向数据线
	);



endmodule