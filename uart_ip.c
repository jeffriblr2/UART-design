/*
 * uart_ip.c
 *
 *  Created on: Nov 28, 2020
 *      Author: sonali
 */

#include <stdint.h>          // C99 integer types -- uint32_t
#include <stdbool.h>         // bool
#include <fcntl.h>           // open
#include <sys/mman.h>        // mmap
#include <unistd.h>          // close
#include "address_map.h"  // address map
#include "uart_ip.h"         // gpio
#include "uart_regs.h"       // registers

//-----------------------------------------------------------------------------
// Global variables
//-----------------------------------------------------------------------------

uint32_t *base = NULL;

//-----------------------------------------------------------------------------
// Subroutines for gpio
//-----------------------------------------------------------------------------

bool gpioOpen()
{
    // Open /dev/gpiomem
    // Use instead of /dev/mem since location does not change and no root access required
    int file = open("/dev/mem", O_RDWR | O_SYNC);
    bool bOK = (file >= 0);
    if (bOK)
    {
        // Create a map from the physical memory location of
        // /dev/mem at an offset to LW avalon interface
        // with an aperature of SPAN_IN_BYTES bytes
        // to any location in the virtual 32-bit memory space of the process
        base = mmap(NULL, SPAN_IN_BYTES, PROT_READ | PROT_WRITE, MAP_SHARED,
                    file, LW_BRIDGE_BASE + GPIO_BASE_OFFSET);
        bOK = (base != MAP_FAILED);

        // Close /dev/gpiomem
        close(file);
    }
    return bOK;
}

void selectPinPushPullOutput(uint8_t pin)
{
    uint32_t mask = 1 << pin;
    *(base+OFS_OD)  &= ~mask;
    *(base+OFS_OUT) |=  mask;
}

void selectPinOpenDrainOutput(uint8_t pin)
{
    uint32_t mask = 1 << pin;
    *(base+OFS_OD)  |= mask;
    *(base+OFS_OUT) |= mask;
}

void selectPinDigitalInput(uint8_t pin)
{
    uint32_t mask = 1 << pin;
    *(base+OFS_OUT) &= ~mask;
}

void selectPinInterruptRisingEdge(uint8_t pin)
{
    uint32_t mask = 1 << pin;
    *(base+OFS_INT_POSITIVE)  |=  mask;
    *(base+OFS_INT_NEGATIVE)  &= ~mask;
    *(base+OFS_INT_EDGE_MODE) |=  mask;
}

void selectPinInterruptFallingEdge(uint8_t pin)
{
    uint32_t mask = 1 << pin;
    *(base+OFS_INT_POSITIVE)  &= ~mask;
    *(base+OFS_INT_NEGATIVE)  |=  mask;
    *(base+OFS_INT_EDGE_MODE) |=  mask;
}

void selectPinInterruptBothEdges(uint8_t pin)
{
    uint32_t mask = 1 << pin;
    *(base+OFS_INT_POSITIVE)  |= mask;
    *(base+OFS_INT_NEGATIVE)  |= mask;
    *(base+OFS_INT_EDGE_MODE) |= mask;
}

void selectPinInterruptHighLevel(uint8_t pin)
{
    uint32_t mask = 1 << pin;
    *(base+OFS_INT_POSITIVE)  |=  mask;
    *(base+OFS_INT_NEGATIVE)  &= ~mask;
    *(base+OFS_INT_EDGE_MODE) &= ~mask;
}

void selectPinInterruptLowLevel(uint8_t pin)
{
    uint32_t mask = 1 << pin;
    *(base+OFS_INT_POSITIVE)  &= ~mask;
    *(base+OFS_INT_NEGATIVE)  |=  mask;
    *(base+OFS_INT_EDGE_MODE) &= ~mask;
}

void enablePinInterrupt(uint8_t pin)
{
    uint32_t mask = 1 << pin;
    *(base+OFS_INT_ENABLE) |= mask;
}

void disablePinInterrupt(uint8_t pin)
{
    uint32_t mask = 1 << pin;
    *(base+OFS_INT_ENABLE) &= ~mask;
}

void setPinValue(uint8_t pin, bool value)
{
    uint32_t mask = 1 << pin;
    if (value)
        *(base+OFS_DATA) |= mask;
    else
        *(base+OFS_DATA) &= ~mask;
}

bool getPinValue(uint8_t pin)
{
    uint32_t value = *(base+OFS_DATA);
    return (value >> pin) & 1;
}

void setPortValue(uint32_t value)
{
     *(base+OFS_DATA) = value;
}

uint32_t getPortValue()
{
    uint32_t value = *(base+OFS_DATA);
    return value;
}

//-----------------------------------------------------------------------------
// Subroutines for uart
//-----------------------------------------------------------------------------

bool uartOpen()
{
    // Open /dev/gpiomem
    // Use instead of /dev/mem since location does not change and no root access required
    int file = open("/dev/mem", O_RDWR | O_SYNC);
    bool bOK = (file >= 0);
    if (bOK)
    {
        // Create a map from the physical memory location of
        // /dev/mem at an offset to LW avalon interface
        // with an aperature of SPAN_IN_BYTES bytes
        // to any location in the virtual 32-bit memory space of the process
        base = mmap(NULL, SPAN_IN_BYTES, PROT_READ | PROT_WRITE, MAP_SHARED,
                    file, LW_BRIDGE_BASE + UART_BASE_OFFSET);
        bOK = (base != MAP_FAILED);

        // Close /dev/gpiomem
        close(file);
    }
    return bOK;
}

void write_value(uint32_t value)
{
	*(base+UART_OFS_DATA) = value;
}

void read_TxFifoValue()
{
    uint32_t value = *(base+UART_OFS_DATA);
    printf("%u\n",value);
}

void write1c_STATUS(uint32_t value)
{
	*(base+UART_OFS_STATUS) = value;
}

void read_StatusReg()
{   uint8_t full, empty, overflow;
    uint32_t readptr, writeptr;
    uint32_t value = *(base+UART_OFS_STATUS);
    uint32_t TEMP_F=1;
    uint32_t TEMP_O=1;
    uint32_t TEMP_E=1;
    TEMP_O= (TEMP_O<<3);
    TEMP_F= (TEMP_F<<4);
    TEMP_E= (TEMP_E<<5);
    readptr=value;
    writeptr=value;
    readptr=(readptr>>16) & 15;
    writeptr=(writeptr>>20) & 15;
    if((value&TEMP_O))
    	overflow=1;
    else
    	overflow=0;

    if((value&TEMP_F))
    	full=1;
    else
    	full=0;

    if((value&TEMP_E))
    	empty=1;
    else
    	empty=0;
    printf("\n EMPTY = %u FULL = %u OVERFLOW = %u \n",empty,full,overflow);
    printf("\n Read_ptr = %u Write_ptr = %u \n",readptr,writeptr);
   // return value;
 }

void write_CONTROL(uint32_t value)
{
	*(base+UART_OFS_CONTROL) = value;
}

void read_CONTROL()
{
    uint32_t value = *(base+UART_OFS_CONTROL);
    printf("%u\n",value);
}

void write_BRD(uint32_t value)
{    if(value == 115200)
	 { value=0x6C8;
	  *(base+UART_OFS_BRD) = value;
	 }
	else if(value == 230400)
	{
		value=0x364;
		*(base+UART_OFS_BRD) = value;
	}
	else if(value == 57600)
		{
			value=0xD90;
			*(base+UART_OFS_BRD) = value;
		}
	else if(value == 28800)
	{
		value=0x1B20;
		*(base+UART_OFS_BRD) = value;

	}
	else   if(value == 9600)
	 { value=0x5161;
	  *(base+UART_OFS_BRD) = value;
	 }
	else if(value == 1800)
		{
			value=0x1B20;
			*(base+UART_OFS_BRD) = value;

		}
	else if(value == 1200)
			{
				value=0x28B0A;
				*(base+UART_OFS_BRD) = value;

			}
	else if(value == 150)
			{
				value=0x145855;
				*(base+UART_OFS_BRD) = value;

			}
	else if(value == 75)
			{
				value=0x28B0AAA;
				*(base+UART_OFS_BRD) = value;

			}
}

void read_BRD()
{
    uint32_t value = *(base+UART_OFS_BRD);
    printf("%u\n",value);
}

void read_dummy()
{
    uint32_t value = *(base+UART_OFS_DATA);
}
