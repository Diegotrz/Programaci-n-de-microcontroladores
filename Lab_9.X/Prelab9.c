/*
 * File:   Prelab9.c
 * Author: Diego
 *
 * Created on 22 de abril de 2023, 11:27 PM
 */
// PIC16F887 Configuration Bit Settings

// 'C' source line config statements

// CONFIG1
#pragma config FOSC = INTRC_CLKOUT// Oscillator Selection bits (INTOSC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF      // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF      // RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF      // Brown Out Reset Selection bits (BOR disabled)
#pragma config IESO = OFF       // Internal External Switchover bit (Internal/External Switchover mode is disabled)
#pragma config FCMEN = ON       // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)
#pragma config LVP = ON         // Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.
#include <xc.h>
#include <stdint.h>
#include <stdio.h>         // for sprintf
#define _XTAL_FREQ 4000000



/*
 *Constantes
 */

/*
 *Variables
 */

/*
 * Prototipos de funciones
 */



void setup(void);

/*
 *Interrupción
 */
void __interrupt() isr (void)
{
    if(PIR1bits.ADIF){
        //Interrupción
        if (ADCON0bits.CHS ==1){
            NOP();
        
      
        }
        else if (ADCON0bits.CHS ==0)
            PORTC = ADRESH;
         PIR1bits.ADIF =0;
        
     
        
    }
    
    if (INTCONbits.RBIF ){
       
        //INTCONbits.RBIF = 0;
        if (!PORTBbits.RB0){
            while (!RB0);
            SLEEP();
        }
        if (!PORTBbits.RB1){
            while (!RB1){
             INTCONbits.RBIF = 0;
             PORTD --;
                         }
        }
    if (!PORTBbits.RB2){
            while (!RB1){
                EEPROM_Write();
            
                         }
        }
    
    }
    
}
/*
 *---------------Main-------------
 */
void main (void)
{
    setup();
    ADCON0bits.GO =1;
    while(1)
    {
        if (ADCON0bits.GO ==0){
            __delay_us(50);
            if (ADCON0bits.CHS == 0)
                ADCON0bits.CHS = 1;
            else 
                ADCON0bits.CHS = 0;
            __delay_us(50);
         
            
            ADCON0bits.GO =1;
        }
        /*
        if (!PORTBbits.RB0){
            while (!RB0);
            PORTD ++;
        }
    if (!PORTBbits.RB1){
            while (!RB1);
            PORTD --;
        }
    */
        
        
        
    }
    
}
/*
 * Funciones
 */
void setup(void){
    ANSEL = 0b00000011;
    ANSELH = 0;
    
    TRISC = 0;
    TRISB = 0b1111;
    TRISD = 0;
    OPTION_REGbits.nRBPU =  0;
    WPUB = 0b0111;
    IOCB = 0b1111;
    PORTB = 0;
    PORTC = 0;
    PORTD = 0;
    
   
    // Configuración del oscilador
    OSCCONbits.IRCF =   0b0111; //8MHz
    OSCCONbits.SCS = 1;
    
    // Configuración del ADC
    ADCON1bits.ADFM = 0; //Justificado a la izquierda
    ADCON1bits.VCFG0 = 0;
    ADCON1bits.VCFG1 = 0;
    
    ADCON0bits.ADCS = 0b01; //FOSC/32
    ADCON0bits.CHS = 1;
    ADCON0bits.ADON= 1;
    __delay_us(50);
    


    PIR1bits.TMR2IF =0; //Apagamos la bandera
    T2CONbits.T2CKPS = 0b11; //Prescaler 1:16
    T2CONbits.TMR2ON = 1;
   
    
    //Configuración de las interrupciones
    //Configuración para la interrupción del ADC
    PIR1bits.ADIF = 0;
    PIE1bits.ADIE = 1;
    //Configuración para la interrupción de los botones
    INTCONbits.RBIE = 0;
    INTCONbits.RBIF = 1;
    //Configuración para las interrupciones globales
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;
    
}
unsigned char readEEPROM(unsigned char  address)
{
  EEADR = address; //Address to be read
  EECON1bits.EEPGD = 0;//Selecting EEPROM Data Memory
  EECON1bits.RD = 1; //Initialise read cycle
  return EEDATA; //Returning data
}

void writeEEPROM(unsigned char  address, unsigned char  dataEE)
{ 
  unsigned char INTCON_SAVE;//To save INTCON register value
  EEADR = address; //Address to write
  EEDATA = dataEE; //Data to write
  EECON1bits.EEPGD = 0; //Selecting EEPROM Data Memory
  EECON1bits.WREN = 1; //Enable writing of EEPROM
  INTCON_SAVE=INTCON;//Backup INCON interupt register
  INTCON=0; //Diables the interrupt
  EECON2=0x55; //Required sequence for write to internal EEPROM
  EECON2=0xAA; //Required sequence for write to internal EEPROM
  EECON1bits.WR = 1; //Initialise write cycle
  INTCON = INTCON_SAVE;//Enables Interrupt
  EECON1bits.WREN = 0; //To disable write
  while(PIR2bits.EEIF == 0)//Checking for complition of write operation
  {
    NOP(); //do nothing
  }
  PIR2bits.EEIF = 0; //Clearing EEIF bit
}