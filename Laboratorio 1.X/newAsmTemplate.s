;  Archivo: main.s
; Dispositivo: PIC16F887
; Autor: Diego Terraza
; Compilador: pic-as
; Programa: Contador en el puerto A
; Hardware: LEDS en el puerto A
;
; Creado: 24 jan ,2023
; Última modificación: 24 jan,2023
    
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
 ;------------------------Variables------------------
 PSECT udata_bank0
  cont_8b: DS 1
    
    
    PSECT resVect, class=CODE,abs, delta=2
    ORG 00h
    resetVec: 
    PAGESEL main
    goto main
    
    PSECT code,delta=2,abs
 ORG 100h   
 main: 
   call config_io
   banksel PORTA
    
    loop:
    btfsc PORTB,0
    call inc_porta
    btfsc PORTB,1
    call dec_porta

    goto loop
    config_io:
     bsf STATUS,5  ;Banco 11
    bsf STATUS,6
    clrf ANSEL ;Pines digitales
    clrf ANSELH
    
    bsf STATUS,5
    bcf STATUS,6
    clrf TRISA
     
   bsf TRISB,0 ;TRISB como entradas 
   bsf TRISB,1
    
    bcf STATUS,5
    bcf STATUS,6
    clrf  PORTA
 inc_porta:
     call delay_small
    btfsc PORTB, 0
    goto $-1
    incf PORTA
    return
  dec_porta:
     call delay_small
      btfsc PORTB, 1
    goto $-1
    decf PORTA
    return
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








