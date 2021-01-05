/*
 * uart_ip.h
 *
 *  Created on: Nov 28, 2020
 *      Author: sonali
 */

#ifndef UART_IP_H_
#define UART_IP_H_



#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>

//-----------------------------------------------------------------------------
// Subroutines
//-----------------------------------------------------------------------------

void selectPinPushPullOutput(uint8_t pin);
void selectPinOpenDrainOutput(uint8_t pin);
void selectPinDigitalInput(uint8_t pin);

void selectPinInterruptRisingEdge(uint8_t pin);
void selectPinInterruptFallingEdge(uint8_t pin);
void selectPinInterruptBothEdges(uint8_t pin);
void selectPinInterruptHighLevel(uint8_t pin);
void selectPinInterruptLowLevel(uint8_t pin);
void enablePinInterrupt(uint8_t pin);
void disablePinInterrupt(uint8_t pin);

void setPinValue(uint8_t pin, bool value);
bool getPinValue(uint8_t pin);
void setPortValue(uint32_t value);
bool gpioOpen();

bool uartOpen();
void write_value(uint32_t value);
void read_TxFifoValue();
void write1c_STATUS(uint32_t value);
void read_StatusReg();
void write_CONTROL(uint32_t value);
void read_CONTROL();
void write_BRD(uint32_t value);
void read_BRD();
void read_dummy();

#endif /* UART_IP_H_ */

