/*
 * uart_regs.h
 *
 *  Created on: Nov 28, 2020
 *      Author: sonali
 */

#ifndef UART_REGS_H_
#define UART_REGS_H_

#define OFS_DATA             0
#define OFS_OUT              1
#define OFS_OD               2
#define OFS_INT_ENABLE       3
#define OFS_INT_POSITIVE     4
#define OFS_INT_NEGATIVE     5
#define OFS_INT_EDGE_MODE    6
#define OFS_INT_STATUS_CLEAR 7

#define SPAN_IN_BYTES 32

#define GPIO_IRQ 80

#define UART_OFS_DATA             0
#define UART_OFS_STATUS           1
#define UART_OFS_CONTROL          2
#define UART_OFS_BRD              3

#endif /* UART_REGS_H_ */
