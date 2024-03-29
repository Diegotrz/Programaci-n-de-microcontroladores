/* 
 * File:   Prelab_9.c
 * Author: Luis Antunez
 *
 * Created on 23 de abril de 2023, 05:53 PM
 */

// CONFIG1
#pragma config FOSC = INTRC_CLKOUT// Oscillator Selection bits (RC oscillator: CLKOUT function on RA6/OSC2/CLKOUT pin, RC on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF       // Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = OFF      // RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF      // Brown Out Reset Selection bits (BOR disabled)
#pragma config IESO = OFF       // Internal External Switchover bit (Internal/External Switchover mode is disabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
#pragma config LVP = OFF        // Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)

// Librerias 
#include <xc.h>
#include <pic16f887.h>
#include <stdint.h>

// Constantes 
#define _XTAL_FREQ 8000000 // Valor del ciclo de reloj



// Prototipos
void setup(void);
// Interrupcion
void __interrupt() isr(void)
{
    if (INTCONbits.RBIF)
    {
        if (PORTBbits.RB0 == 0) // Si el pin RB0 ha cambiado a bajo, entrar en modo de suspensión
        {
            SLEEP();
            INTCONbits.RBIF = 0; // Borrar la bandera de interrupción por cambio de estado del puerto B
        }
        else if (PORTBbits.RB1 == 0 || INTCONbits.RBIF == 0)
        {
            INTCONbits.RBIF = 0; // Borrar la bandera de interrupción por cambio de estado del puerto B
        
        }
    }
}

// Codigo principal 
void main (void){
    
    setup();
    while (1) 
    {
        ADCON0bits.CHS = 0; // Seleccion del canal AN1
        ADCON0bits.GO =1;  // Habilita las conversiones de analogico a digital
        __delay_ms(10);
        while (ADCON0bits.GO_DONE); // Verificacion del canal AN1
        int adc = ADRESH;           // Mueve el valor almacenado en ADRESH a adc
        PORTC = (char) adc;         // Mueve el valor de adc al puerto C
        __delay_ms(10);
    }
        
        
        
}
    
void setup(void)
{
    ANSEL = 0b00000011;
    ANSELH=0; 
    //Configuracion de entradas y salidas
    TRISB = 0b00000111;
    TRISC = 0;
    // Limpiamos los puertos
    PORTA=0;
    PORTB=0;
    PORTC=0;
    
    OSCCONbits.IRCF =0b0110; // Oscilador de de 4MHz
    OSCCONbits.SCS = 1;      // Oscilador interno
    
    OPTION_REGbits.nRBPU = 0;
    WPUBbits.WPUB0 = 1;
    WPUBbits.WPUB1 = 1;
    WPUBbits.WPUB2 = 1;
    IOCB= 0b01111111;
    
    // Interrupcion del purto B
    INTCONbits.RBIF = 0; // Borrar la bandera de interrupción por cambio de estado del puerto B
    INTCONbits.RBIE = 1; // Habilitar la interrupción por cambio de estado del puerto B
    INTCONbits.GIE = 1; // Habilitar la interrupción global
    
    // Configuracion del ADC
    ADCON0bits.ADCS = 0b01; // divisor de reloj de 32
    __delay_ms(10);
    ADCON1bits.ADFM = 0;    // Justificado a la izquierda 
    ADCON1bits.VCFG0 = 0;
    ADCON1bits.VCFG1 = 0;    // Referencia de voltaje 0
    ADCON0bits.ADON = 1;   // habilitar el adc
    ADIF =0;
    return;
}
