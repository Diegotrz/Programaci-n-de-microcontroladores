;  Archivo: Prelab 5
; Dispositivo: PIC16F887
; Autor: Diego Terraza
; Compilador: pic-as
; Programa: Contador de 8 bits que aumenta y decrementa mediante el uso de de botones utilizando
;la interrupcion
; Hardware: LEDS en el puerto A y botones en el puerto B.
;
; Creado: 17 feb ,2023
; Última modificación: 17 feb,2023
    
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
 
 ;-----Macros---------------
 restart_tmr0 macro
 banksel PORTA 
 movlw   100
    movwf   TMR0
    bcf	    T0IF
    endm
 ;------------------------Variables------------------
 PSECT udata_bank0
  cont_1s: DS 1
  cont: DS 1
  var: DS 1
  banderas: DS 1
    nibble:  DS 2
    display_var: DS 2
  PSECT udata_shr
 W_TEMP: DS 1
 STATUS_TEMP: DS 1
    
    PSECT resVect, class=CODE,abs, delta=2
    ORG 00h
    resetVec: 
    PAGESEL main
    goto main
    
 PSECT intVect, class=CODE,abs, delta=2   
    ORG 04h
    push:
    movwf W_TEMP
    swapf STATUS,W
    movwf STATUS_TEMP
    
    isr:    
    btfsc T0IF
    call cont_tmr0
    call int_t0
    btfsc RBIF
    call int_iocb
    pop:
    swapf STATUS_TEMP,W 
    movwf STATUS
    swapf W_TEMP,F
    swapf W_TEMP,W
    retfie
    ;------Subrutinas de interrupcion-----
     int_iocb:
    banksel PORTA
    btfss PORTB,1
    decf PORTA
    btfss PORTB,0
    incf PORTA	
    bcf RBIF
    return
    cont_tmr0:
    restart_tmr0
    incf cont
    movf cont,W
    sublw 50
    btfss ZERO
    goto return_t0  
    clrf cont
  
    return_t0:
    return
    int_t0:
    restart_tmr0
    clrf PORTD
    btfsc banderas,0
    goto display_1
    display_0:
    movf display_var,W
    movwf PORTC
    bsf PORTD,0
    goto siguiente_display

    display_1:
    movf display_var+1,W
    movwf PORTC
    bsf PORTD,1


    siguiente_display:
    movlw 1
    xorwf banderas,F
    
    return
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
     retlw 01110111B ;A
    retlw 01111100B ;B
    retlw 00111001B ;C
    retlw 01011110B ;D
    retlw 01111001B ;E
    retlw 01110001B ;F
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
   call  config_int_enable
   call config_ioc
   banksel PORTA
  ;-----------------------------Loop------------------------	 
    loop:
    movlw 0x1
    movwf var
    call separar_nibbles
    call preparar_displays
    goto loop
    ;---------------------------Subrutinas----------------------
     config_ioc:
    banksel TRISA
    bsf IOCB,0
    bsf IOCB,1
    banksel PORTA
    movf PORTB,W
    bcf RBIF 
    
    return 
   separar_nibbles:
    movf var,w
    andlw 0x0f
    movwf nibble
    swapf var,W
    andlw  0x0f
    movwf nibble+1
    return
    preparar_displays:
    movf  nibble,w
    call tabla
    movwf display_var
    movf  nibble+1,w
    call tabla
    movwf display_var+1
    return
    config_int_enable:
    bsf GIE
    bsf T0IE
    bcf T0IF
    bsf RBIE
    bcf RBIF
    return
    config_tmr0:
    banksel TRISA
    bcf T0CS
    bcf PSA ;Establecido en 101, 1:64
    bsf PS2
    bcf PS1
    bsf PS0
    banksel PORTA
    restart_tmr0
    return
    config_io:
     bsf STATUS,5  ;Banco 11
    bsf STATUS,6
    clrf ANSEL ;Pines digitales
    clrf ANSELH
    
    banksel TRISA
    clrf TRISA
   
    ;Establecemos los puertos de B como entradas
    bsf TRISB,0
    bsf TRISB,1
     bcf OPTION_REG,7
    bsf WPUB, 0
    bsf WPUB,1
    ;Establecemos los pines del puerto C como salidas
    clrf TRISC
    ;Establecemos los dos pines del puerto E como salidas
    bcf TRISD,0
    bcf TRISD,1
    bcf TRISD,2
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
 
 
    
    END



