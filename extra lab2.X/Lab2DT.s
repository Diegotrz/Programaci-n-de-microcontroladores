;  Archivo: main.s
; Dispositivo: PIC16F887
; Autor: Diego Terraza
; Compilador: pic-as
; Programa: Contador en el puerto A de 8 bits, de 4 bits en el puerto C y sumador de ambos en el puerto D.
; Hardware: LEDS en el puerto A,C y D
;
; Creado: 31 feb ,2023
; Última modificación: 03 fb,2023
    
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
 ;Configuration word 2
 CONFIG WRT= OFF
 CONFIG BOR4V=BOR40V
 ;------------------------Variables------------------
 PSECT udata_bank0
  cont_big: DS 1
  cont_small: DS 1
   carry: DS 1
  ;-----------Vector reset--------------
    PSECT resVect, class=CODE,abs, delta=2
    ORG 00h
    resetVec: 
    PAGESEL main
    goto main
    
    PSECT code,delta=2,abs
 ORG 100h   ;Posición del código
 ;------------------Configuración-----------
 main: 
   call config_io
   call config_reloj
   banksel PORTA
    ;----------------------------Loop principal----------------------
    loop:
    call cont_8b
    call cont_4b
    call sumador
    goto loop
    ;-----------------------Subrutinas-------------------------
    config_io: ; Subrutina que contiene la configuración de pines
     bsf STATUS,5  ;Banco 11
    bsf STATUS,6
    clrf ANSEL ;Pines digitales
    clrf ANSELH
    
    bsf STATUS,5;Banco 01
    bcf STATUS,6
    clrf TRISA

   bsf TRISB,0 ;TRISB como entradas 
   bsf TRISB,1
   bsf TRISB,2
   bsf TRISB,3
   bsf TRISB,4

   bcf TRISC,0;TRISC,TRISD y TRISE como salidas
   bcf TRISC,1
   bcf TRISC,2
   bcf TRISC,3
   bcf TRISD,0
   bcf TRISD,1
   bcf TRISD,2
   bcf TRISD,3
   bcf TRISE,0
   
    bcf STATUS,5;Banco 00
    bcf STATUS,6
    ;Limpiamos los puertos para que inicien en 0 
    clrf  PORTA
    clrf PORTC
    clrf PORTD
    clrf PORTE
    return
  ;Subrutina de la configuración del reloj
  config_reloj:
   banksel OSCCON
   bcf IRCF0  ;Reloj en 100 correspondiente a 1Mhz
   bcf IRCF1
   bsf IRCF2
   return
  
   cont_8b:;Subrutina del contador de 8bits
     btfsc PORTB,0;Comprueba el estado de RB0,si es 0 realiza un salto 
    call inc_porta; Si el estado de RB0 es 1 se ejecuta el call del incrementador
    btfsc PORTB,1;Comprueba el estado de RB1,si es 0 realiza un salto 
    call dec_porta; Si el estado de RB1 es 1 se ejecuta el call para la función dec_porta
    return
   cont_4b:;Contador de 4bits que funciona igual al de 8 bits únicamente que se usan solo 4 salidas
    btfsc PORTB,2
    call inc_portc
    btfsc PORTB,3
    call dec_portc
    return
    sumador:;Subrutina del sumador
     btfsc PORTB, 4;Comprueba el estado de RB4,si es 0 realiza un salto 
     call suma
    return
    carry_bit:;Subrutina del bit carry para encender su led correspondiente
    bsf PORTE,0
    return
    suma:;Subrutina de ambos contadores en el puerto D
    call delay_small
    btfsc PORTB,4
    goto $-1
    movf PORTA,w;Movilizamos el valor del puerto A hacia W
    addwf PORTC,0;Suma del valor de W con el puerto C
    movwf PORTD;Movilizamos W al puerto D
    movwf carry;Movilizamos W también a la variable carry
    btfss carry,4 ;Evaluamos en 5to bit de la variable,correspondiente al carry, si es 1 salta
    bcf PORTE,0;Si el carry es 0 establece el TRISE0 en cero
    btfsc carry,4;Evaluamos en 5to bit de la variable,correspondiente al carry, si es 0 salta
    call carry_bit;Si el carry es 1 establece el TRISE0 en cero
    return
 inc_porta:;Subrutina para realizar el incremento del puerto A
    call delay_small
    btfsc PORTB, 0
    goto $-1
    incf PORTA
    return
  dec_porta:;Subrutina para decrementar el puerto A
    call delay_small
    btfsc PORTB, 1
    goto $-1
    decf PORTA
    return
   
   inc_portc:;Subrutina para realizar el incremento del puerto C
     call delay_small
    btfsc PORTB, 2
    goto $-1
    incf PORTC
    return
  dec_portc:;Subrutina para decrementar el puerto C
     call delay_small
      btfsc PORTB, 3
    goto $-1
    decf PORTC
    return 
    
 delay_big: ;Subrutina del delay grande
    movlw 200
    movwf cont_big
    call delay_small
    decfsz cont_big,1
    goto $-2
    return
    
    delay_small:;Subrutina del delay pequeño
    movlw 165
    movwf cont_small
    decfsz cont_small,1
    goto $-1
    return
    
    END



