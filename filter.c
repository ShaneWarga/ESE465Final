/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "data.h"
#define TWO_TO_FIFTEEN 32768
#define TWO_TO_FOURTEEN 16384


int filter_init(struct cbuffer *cirbuffer, short * buffer)
{
	for(int i = 0; i < IR_SIZE; ++i)
	{
		buffer[i] = 0;
	}
	cirbuffer->buffer = buffer;
	cirbuffer->BUFFER_SIZE = IR_SIZE;
	cirbuffer->head = cirbuffer->tail = cirbuffer->full = 0;
	return 0;
}

void advance_pointer(struct cbuffer *cirbuffer)
{
	if (cirbuffer->full)
	{
		if ((cirbuffer->tail + 1) >= cirbuffer->BUFFER_SIZE)
		{
			cirbuffer->tail = (cirbuffer->tail + 1) - cirbuffer->BUFFER_SIZE;
		}
		else {
			cirbuffer->tail = (cirbuffer->tail + 1);
		}
	}
	if ((cirbuffer->head + 1) >= cirbuffer->BUFFER_SIZE)
	{
		cirbuffer->head = (cirbuffer->head + 1) - cirbuffer->BUFFER_SIZE;
	}
	else {
		cirbuffer->head = (cirbuffer->head + 1);
	}
	cirbuffer->full = (cirbuffer->head == cirbuffer->tail? 1 : 0);

}

void cbuffer_put(struct cbuffer *cirbuffer, short data)
{
	cirbuffer->buffer[cirbuffer->head] = data;
	advance_pointer(cirbuffer);
	return;
}

int filter(struct cbuffer *inbuffer, short *input, short *imp_resp, short *res)
{
	int i, j, k, res_tmp;

	i = 0;
	res_tmp = 0;
	while (1)
	{
		cbuffer_put(inbuffer, input[i]);
		if (i >= INPUT_SIZE) break;
		//convolution loop
		k = inbuffer->head - 1;
		res_tmp = 0;
		for(j = 0; j < IR_SIZE; ++j)
		{
			if ((k - j) < 0) k += inbuffer->BUFFER_SIZE;
			res_tmp += imp_resp[j] * inbuffer->buffer[k - j];
		}
		res_tmp = (res_tmp + TWO_TO_FOURTEEN) >> 15;
		res[i] = (short)(res_tmp);
		i += 1;
	}
	return 0;
}

int main()
{
    init_platform();

    print("Hello World\n");

    static struct cbuffer inbuffer;
    static short buffer[61];
    static short res_pass[1000];
    static short res_stop[1000];
    static int *counter = (int *)0x44a00000;
    filter_init(&inbuffer, buffer);
    *counter = 0x01;
    filter(&inbuffer, pass_band, impulse_resp, res_pass);
    *counter = 0x00;

    //for(int i = 0; i < INPUT_SIZE; ++i)
    //{
    	//xil_printf("%d\n",res_pass[i]);
    //}

    print("HELLO\n");

    filter_init(&inbuffer, buffer);

    filter(&inbuffer, stop_band, impulse_resp, res_stop);

    for(int i = 0; i < INPUT_SIZE; ++i)
	{
		xil_printf("%d\n", res_stop[i]);
	}

    //static int * ptr = (int *)0x44a00000;
    //*ptr = 0;
    //*ptr = 0x01;
    //*ptr = 0x02;
    //*ptr = 0x03;
    print("Finished!\n");

    cleanup_platform();
    return 0;
}
