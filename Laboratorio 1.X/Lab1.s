;  Archivo: main.s
; Dispositivo: PIC16F887
; Autor: Diego Terraza
; Compilador: pic-as
; Programa: Contador en el puerto A
; Hardware: LEDS en el puerto A
;
; Creado: 31 jan ,2023
; Última modificación: 31 jan,2023
    
PROCESSOR 16F887
#include <xc.inc>
    
 ;configuration word 1
 CONFIG FOSC=INTRC_NOCLKOUT
 CONFIG WDTE=OFF 
 CONFIG PWRTE=ON
 CONFIG MCLRE=OFF
 CONFIG CP=OFF
 CONFIG CPD=OFF
 
 CONFIG BOREN=OFF
 CONFIG IESO=OFF
 CONFIG FCMEN=OFF
 CONFIG LVP=ON
 
 CONFIG WRT= OFF
 CONFIG BOR4V=BOR40V
 
 PSECT udata_bank0
    cont_small: DS 1
    cont_big:   DS 1
    
    PSECT resVect, class=CODE,abs, delta=2
    ORG 00h
    resetVec: 
    PAGESEL main
    goto main
    
    PSECT code,delta=2,abs
 ORG 100h   
 main: 
    bsf STATUS,5
    bsf STATUS,6
    clrf ANSEL
    clrf ANSELH
    
    bsf STATUS,5
    bcf STATUS,6
    clrf TRISA
     
    bcf STATUS,5
    bcf STATUS,6
    
    loop:
    incf PORTA,1
    call delay_big
    goto loop
    
    delay_big: 
    movlw 200
    movwf cont_big
    call delay_small
    decfsz cont_big,1
    goto $-2
    return
    
    delay_small:
    movlw 165
    movwf cont_small
    decfsz cont_small,1
    goto $-1
    return
    
    END


