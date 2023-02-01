


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
  cont_big: DS 1
  cont_small: DS 1
    
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
    call cont_8b
    call cont_4b

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
   bsf TRISB,2
   bsf TRISB,3
     bcf TRISC,0
   bcf TRISC,1
   bcf TRISC,2
   bcf TRISC,3
   
   
    bcf STATUS,5
    bcf STATUS,6
    clrf  PORTA
    clrf PORTC
  
    
   cont_8b:
     btfsc PORTB,0
    call inc_porta
    btfsc PORTB,1
    call dec_porta
    return
   cont_4b:
    btfsc PORTB,2
    call inc_portc
    btfsc PORTB,3
    call dec_portc
    return
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
   
   inc_portc:
     call delay_small
    btfsc PORTB, 2
    goto $-1
    incf PORTC
    return
  dec_portc:
     call delay_small
      btfsc PORTB, 3
    goto $-1
    decf PORTC
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








