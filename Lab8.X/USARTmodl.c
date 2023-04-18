/*
 * File:   USARTmod.c
 * Author: Diego
 *
 * Created on 17 de abril de 2023, 08:43 PM
 */


#include <xc.h>
#include <stdint.h>
#include <stdio.h>         // for sprintf
#include "USARTmodl.h"
//----------------------Función de inicio para el calculo de los baudios y activación de RX y TX.----------------------
void UART_Init(const uint32_t baud_rate)
{
  int16_t n = ( _XTAL_FREQ / (16 * baud_rate) ) - 1;
  
  if (n < 0)
    n = 0;
 
  if (n > 255)  // low speed
  {
    n = ( _XTAL_FREQ / (64 * baud_rate) ) - 1;
    if (n > 255)
      n = 255;
    SPBRG = n;
    TXSTA = 0x20;  // transmit enabled, low speed mode
  }
 
  else   // high speed
  {
    SPBRG = n;
    TXSTA = 0x24;  // transmit enabled, high speed mode
  }
 
  RCSTA = 0x90;  // serial port enabled, continues receive enabled
 
}
 
// ---------------------------------Funciòn para retornar el bit colocado en el RCIF----------------------------
__bit UART_Data_Ready()
{
  return RCIF;  // return RCIF bit (register PIR1, bit 5)
}
 
uint8_t UART_GetC()
{
  while (RCIF == 0) ;  // wait for data receive
  if (OERR)  // if there is overrun error
  {  // clear overrun error bit
    CREN = 0;
    CREN = 1;
  }
  return RCREG;        // read from EUSART receive data register
}
 
 //-------------------Funciòn para actualizar eel dato en el txreg-----------------------------
 
void UART_PutC(const char data)
{
  while (TRMT == 0);  // wait for transmit shift register to be empty
  TXREG = data;       // update EUSART transmit data register
}
 
void UART_Print(const char *data)
{
  uint8_t i = 0;
  while (data[i] != '\0')
    UART_PutC (data[i++]);
}