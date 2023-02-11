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
 CONFIG PWRTE=OFF
 CONFIG MCLRE=OFF
 CONFIG CP=OFF
 CONFIG CPD=OFF
 
 CONFIG BOREN=OFF
 CONFIG IESO=OFF
 CONFIG FCMEN=OFF
 CONFIG LVP=OFF
 
 CONFIG WRT= OFF
 CONFIG BOR4V=BOR40V
 ;------------------------Variables------------------
 PSECT udata_bank0
  cont_big: DS 1
  cont_small: DS 1
  cont_1s: DS 1
  comp: DS 1
  comp2: DS 1
  comp3: DS 1
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
    ;------------Binarios catodo comun------
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
    ;-----------------Binarios anodo comun--------
    ;retlw 11000000B	    ;0
    ;retlw 11111001B	    ;1
    ;retlw 10100100B	    ;2
    ;retlw 10110000B	    ;3
    ;retlw 10011001B	    ;4
    ;retlw 10010010B	    ;5
    ;retlw 10000010B	    ;6
    ;retlw 11111000B	    ;7
    ;retlw 10000000B	    ;8
    ;retlw 10010000B	    ;9
    ;retlw 10001000B	    ;A
    ;retlw 10000011B	    ;B
    ;retlw 11000110B	    ;C
    ;retlw 10100001B	    ;D
    ;retlw 10000110B	    ;E
    ;retlw 10001110B	    ;F
 ;----------------------Configuracion---------------
 main: 
   call config_io
   call config_reloj
   call config_tmr0
   banksel PORTA
    
    loop:
    call primer_contador
    call contador_display
    call comparador
    call reinicio_contsec
    movf PORTC,w
    call tabla
    movwf PORTD
    
    call delay_big  

    goto loop
    ;---------------------------Subrutinas----------------------
    reinicio_contsec:
    incf PORTE
    clrf PORTA
    return
    comparador:
    movf PORTC, w
    movwf comp
    movf PORTA,w
    subwf comp
    movwf comp3
    movlw 1
    btfss comp3,0
    sublw 1
    btfss comp3,1
    nop
    btfss comp3,2
    addlw 1
    btfss comp3,3
    sublw 1
    movwf comp2
    btfss comp2,0
    call reinicio_contsec
    return
    primer_contador:
    movlw 10
    movwf cont_1s
    
    decf cont_1s
    call reiniciar_tmr0
    btfsc cont_1s,0
    goto $-3
    
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
    movlw   12
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
    ;Establecemos los pines del puerto E como salida
    bcf TRISE,0
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









