;  Archivo: LAB3
; Dispositivo: PIC16F887
; Autor: Diego Terraza
; Compilador: pic-as
; Programa: Contador en el puerto A
; Hardware: LEDS en el puerto A
;
; Creado: 6 feb ,2023
; Última modificación: 6 feb,2023
    
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
 tabla:
    clrf PCLATH
    bsf PCLATH,0
    andlw 0x0f
    addwf PCL
    retlw 00111111B	    ;0
    retlw 00000110B	    ;1
    retlw 01011011B	    ;2
    retlw 01001111B	    ;3
    retlw 01100110B	    ;4
    retlw 01101101B	    ;5
    retlw 01111101B	    ;6
    retlw 00000111B	    ;7
    retlw 01111111B	    ;8
    retlw 01101111B	    ;9
    retlw 01110111B	    ;A
    retlw 01111100B	    ;B
    retlw 00111001B	    ;C
    retlw 01011110B	    ;D
    retlw 01111001B	    ;E
    retlw 01110001B	    ;F
    
 ;----------------------Configuracion---------------
 main: 
   call config_io
   call config_reloj
   call config_tmr0
   banksel PORTA
    
    loop:
    call primer_contador
    call contador_display
    
    movf PORTC,w
    call tabla
    movwf PORTD
    
    call delay_big  

    goto loop
    ;---------------------------Subrutinas----------------------
    primer_contador:
    btfss T0IF
    goto $-1
    call reiniciar_tmr0
    incf PORTA
    
    return
    contador_display:
    btfsc PORTB,0
    call inc_porta
    btfsc PORTB,1
    call dec_porta
    return
    config_tmr0:
    banksel TRISA
    bcf T0CS
    bcf PSA ;Establecido en 101, 1:64
    bsf PS2
    bcf PS1
    bsf PS0
    banksel PORTA
    call reiniciar_tmr0
    return
    reiniciar_tmr0:
    movlw   256
    movwf   TMR0
    bcf	    T0IF
    return
    config_io:
     bsf STATUS,5  ;Banco 11
    bsf STATUS,6
    clrf ANSEL ;Pines digitales
    clrf ANSELH
    
    banksel TRISA
    bcf TRISA,0
    bcf TRISA,1
    bcf TRISA,2
    bcf TRISA,3
    ;Establecemos con entradas los pines del puerto B
    bsf TRISB,0
    bsf TRISB,1
    ;Establecemos los pines del puerto C como salidas
    bcf TRISC,0
    bcf TRISC,1
    bcf TRISC,2
    bcf TRISC,3
    ;Establecemos los pines del puerto D como salidas
    clrf TRISD
   ;Limpiamos los pines al iniciar el programa
    bcf STATUS,5
    bcf STATUS,6
    clrf  PORTA
    clrf PORTB
    clrf PORTC
    clrf PORTD
  return
  config_reloj:
    banksel OSCCON
    bsf IRCF2
    bcf IRCF1
    bsf IRCF0
    bsf SCS
    return
    inc_porta:
    call delay_small
    btfsc PORTB, 0
    goto $-1
    incf PORTC
    return
    dec_porta:
     call delay_small
      btfsc PORTB, 1
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









