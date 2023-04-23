/* 
 * File:   USARTmodl.h
 * Author: Diego
 *
 * Created on 17 de abril de 2023, 08:46 PM
 */

#ifndef USARTMODL_H
#define	USARTMODL_H
#include <xc.h>
#include <stdint.h>
#include <stdio.h>         // for sprintf
#define _XTAL_FREQ 8000000
const char message[] = "2.Enviar Ascii" ;
void UART_Init(const uint32_t baud_rate);
__bit UART_Data_Ready();
uint8_t UART_GetC();
void UART_PutC(const char data);
void UART_Print(const char *data);
void UART_maininit ();

#endif	/* USARTMODL_H */

