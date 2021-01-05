/*
 * read_write.c
 *
 *  Created on: 18-Nov-2020
 *      Author: jeffr
 */
#include <stdint.h>
#include <stdbool.h>
#include "uart_ip.h"



void initHw()
{
    // Initialize GPIO IP
   // gpioOpen();

	// Initialize UART IP
	uartOpen();
	uartOpen();


}

int main(int argc, char* argv[])
{   // Initialize hardware
	initHw();
	int baud_rate;
	int value,i;
	write_CONTROL(25);
	//write_BRD(115200);
	if (strcmp(argv[1], "write_data")==0)
	{
		value = atoi(argv[2]);

	for (i=0; i<value;i++)
		{
			write_value(atoi(argv[i+3]));

		}
	}
	 if(strcmp(argv[1], "status")==0)
				read_StatusReg();

	 if (strcmp(argv[1], "read_data")==0)
	 {    value = atoi(argv[2]);
	 for (i=0; i<value;i++)
	 {
	 				read_TxFifoValue();
	 }
	 }
	if(strcmp(argv[1], "baud_rate")==0)
		{	baud_rate = atoi(argv[2]);
			write_BRD(baud_rate);
		}
	if(strcmp(argv[1], "clear")==0)
		write1c_STATUS(value);

	// new changes
	/*
        read_TxFifoValue();
        read_TxFifoValue();
        read_TxFifoValue();
        write_value(65);
        	write_value(66);
        	write_value(67);
        	write_value(68);
        	write_value(69);
        	write_value(70);
	read_StatusReg();
	*/


}
