/*
 * File:   lab8prueba.c
 * Author: Diego
 *
 * Created on 17 de abril de 2023, 10:49 PM
 */


// set configuration words
#pragma config CONFIG1 = 0x2CD4
#pragma config CONFIG2 = 0x0700
 
 
#include <xc.h>
#define _XTAL_FREQ 8000000
#include <stdio.h>         // for sprintf
#include <stdint.h>        // include stdint header
 
 
/********************** UART functions **************************/
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
/********************** end UART functions **************************/
 
const char message[] = "PIC16F887 microcontroller UART example" ;
 
// main function
void main(void)
{
  OSCCON = 0x70;    // set internal oscillator to 8MHz
 
  UART_Init(9600);  // initialize UART module with 9600 baud
 
  __delay_ms(2000);  // wait 2 seconds
 
  UART_Print("Hello world!\r\n");  // UART print
 
  __delay_ms(1000);  // wait 1 second
 
  UART_Print(message);  // UART print message
 
  __delay_ms(1000);  // wait 1 second
 
  UART_Print("\r\n");  // start new line
 
  char text[5];
  for (uint8_t i = 0; i < 21; i++)
  {
    sprintf(text, "%02u\r\n", i);
    UART_Print(text);
    __delay_ms(500);
  }
 
  while(1)
  {
    if ( UART_Data_Ready() )  // if a character available
    {
      uint8_t c = UART_GetC();  // read from UART and store in 'c'
      UART_PutC(c);  // send 'c' via UART (return the received character back)
    }
 
  }
 
}
// end of code.