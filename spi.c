
/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights res_adcerved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without res_adctriction, including without limitation the rights
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
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPres_adcS OR
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
 * This application configures_adc UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures_adc it to baud rate 115200
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
#include "spi_data.h"

// DAC
static int* sdi_store_dac = (int*) 0x44a21408;
static int* spi_data_width_dac =(int*) 0x44a21080;
static int* clk_per_sample_dac =(int*) 0x44a21010;
static int* enable_dac =(int*) 0x44a21500;
static int* l_or_r_dac =(int*) 0x44a21530;
static int* res_dac =(int*) 0x44a2157C;

// ADC
static int* sdi_store_adc =(int*) 0x44a31408;
static int* spi_data_width_adc =(int*) 0x44a31080;
static int* clk_per_sample_adc =(int*) 0x44a31010;
static int* enable_adc =(int*) 0x44a31500;
static int* l_or_r_adc =(int*) 0x44a31530;
static int* res_adc =(int*) 0x44a3157C;

int spiAdc()
{
    //ADC
    *enable_adc = 1;
    *clk_per_sample_adc = 600;
    *spi_data_width_adc = 16;

	int past = 2;
	int pres;
    for(int i = 0; i <1000; i++){
		while (past == pres){
			pres = *l_or_r_adc;
		}
    	if(pres == 0){
			*sdi_store_adc = 0b1000000000000000;
		} else{
			*sdi_store_adc = 0b1100000000000000;
		}
		past = pres;
		xil_printf("%d", *res_adc);
		xil_printf("\n");
    }

    return 0;
}

int spiDac()
{
    *enable_dac = 1;

    *clk_per_sample_dac = 600;


    *spi_data_width_dac = 24;

	int pres = *l_or_r_dac;
	int past = pres;
	int response = 0;

	for(int i = 0; i < 1000; i++){
		while (past == pres){
			pres = *l_or_r_dac;
		}
		if(i == 0){
			*sdi_store_dac = 5242880;
		}
		else{
			if(pres == 0){
				*sdi_store_dac = left[i-1];
				xil_printf("%d\n", left[i-1]);
			}
			else{
				*sdi_store_dac = 32768 + left[i-1];
			}
		}
		response = *res_dac;
		past = pres;
		xil_printf("%d", response);
		xil_printf("\n");
	}
    return 0;
}


int spiBoth()
{
    // ADC
    *enable_adc = 1;
    *clk_per_sample_adc = 600;
    *spi_data_width_adc = 16;

    // DAC
    *enable_dac = 1;
    *clk_per_sample_dac = 600;
    *spi_data_width_dac = 24;


	//ADC->DAC

        int past = 2;
		int pres = 0;
		for(int i = 0; i <1001; i++){
			while (past == pres){
				pres = *l_or_r_dac;
			}
			if(pres == 0){
				*sdi_store_adc = 0b1000000000000000;
			} else{
				*sdi_store_adc = 0b1100000000000000;
			}

			past = pres;
			xil_printf("%d\n", *res_dac);
			xil_printf("\n");
		}

    return 0;
}




#define numSamples 100
unsigned short responses1[numSamples];
unsigned short responses2[numSamples];

int main(){
	init_platform();
	print("Hello World\n\r");

	*clk_per_sample_adc = 600;
	*spi_data_width_adc = 16;

	int pres = *l_or_r_adc;
	int past = pres;
	int response = 0;

	*enable_adc = 1;
	for(int i = 0; i < numSamples * 2; i++){
		while (past == pres){
			pres = *l_or_r_adc;
		}

		if(pres == 0){
			*sdi_store_adc =  32768; //0b1000000000000000
			responses1[i/2] = *res_adc;
		} else{
			*sdi_store_adc =  49152; //0b1100000000000000
			responses2[i/2] = *res_adc;
		}

		past = pres;
//		xil_printf("%d\n", response);
	}

	for(int i = 0; i < numSamples; i++){
		xil_printf("%d\n", responses1[i]);
	}

	xil_printf("---------End of Right Samples------------\n");

	for(int i = 0; i < numSamples; i++){
		xil_printf("%d\n", responses2[i]);
	}


//    *enable_adc = 1;
//    *clk_per_sample_adc = 600;
//    *spi_data_width_adc = 16;
//
//	int past = 2;
//	int pres;
//    for(int i = 0; i <1000; i++){
//		while (past == pres){
//			pres = *l_or_r_adc;
//		}
//    	if(pres == 0){
//			*sdi_store_adc = 0b1000000000000000;
//		} else{
//			*sdi_store_adc = 0b1100000000000000;
//		}
//		past = pres;
//		xil_printf("%d", *res_adc);
//		xil_printf("\n");
//    }
	//spiAdc();
	//spiDac();
	//spiBoth();
    cleanup_platform();
	return 0;
}


