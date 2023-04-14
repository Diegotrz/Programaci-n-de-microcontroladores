/*
 * File:   Lab_7.c
 * Author: Diego
 *
 * Created on 13 de abril de 2023, 11:47 PM
 */


// PIC16F887 Configuration Bit Settings

// 'C' source line config statements

// CONFIG1
#pragma config FOSC = INTRC_CLKOUT// Oscillator Selection bits (INTOSC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
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
             CCPR1L = (ADRESH>>1)+128; 
        
      
        }
        else if (ADCON0bits.CHS ==0)
            CCPR2L = (ADRESH>>1)+128; 
         PIR1bits.ADIF =0;
        
     
        
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
    }
    
    
    
}
/*
 * Funciones
 */
void setup(void){
    ANSEL = 0b00000011;
    ANSELH = 0;
    
    TRISA = 0xFF;
    
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
    
    // Configuración del PWM
    TRISCbits.TRISC1 = 1; //RC1/CCP2 como entrada
    TRISCbits.TRISC2 = 1;    //RC2/CCP1 como entrada
    
    PR2 = 255;              // Config del periodo
    CCP1CONbits.P1M =0;     // Config modo PWM
    CCP1CONbits.CCP1M =0b1100; 
    
    CCPR1L = 0x0f; //Ciclo de trabajo inicial
    CCP1CONbits.DC1B= 0;    
    
    PIR1bits.TMR2IF =0; //Apagamos la bandera
    T2CONbits.T2CKPS = 0b11; //Prescaler 1:16
    T2CONbits.TMR2ON = 1;
    //PWM EN CP2
    CCP2CONbits.CCP2M = 0;    //PWM mode
    CCP2CONbits.CCP2M = 0b1100; 
    CCPR2L = 0x0f;          //inicio de ciclo de trabajo
    CCP2CONbits.DC2B0 = 0;
    CCP2CONbits.DC2B1 = 0;
    
    
    while (PIR1bits.TMR2IF == 0); // Esperamos un ciclo del TMR2
    PIR1bits.TMR2IF = 0;
    
    TRISCbits.TRISC2 = 0; //Salida del PWM
    
    
    
    
    //Configuración de las interrupciones
    PIR1bits.ADIF = 0;
    PIE1bits.ADIE = 1;
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;
    
}