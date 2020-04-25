 ;-------------------------------------------------------------------
;                           lcd16x2
;-------------------------------------------------------------------
;AUTHOR: LUAN FERREIRA REIS DE JESUS       LAST REVISION: 20/04/2020
;V 1.0.0
;-------------------------------------------------------------------
;                        DESCRIPTION
;-------------------------------------------------------------------
; Code to control and send data to 16x2 LCD
;-------------------------------------------------------------------
;                     DEFINITION FILES
;-------------------------------------------------------------------
#include <p16f15376.inc>

#define LCD_RS  PORTC, 0x00
#define LCD_RW  PORTC, 0x01
#define LCD_ENA PORTC, 0x02


;-------------------------------------------------------------------
;                   DEVICE CONFIGURATION
;-------------------------------------------------------------------
    __CONFIG _CONFIG1, _FEXTOSC_OFF & _RSTOSC_HFINT32   ; Turn off external oscilator and set internal oscilator to 32 MHz
    __CONFIG _CONFIG2, _MCLRE_ON & _PWRTE_ON            ; Enable Master Clear and Powerup Timer
    __CONFIG _CONFIG3, _WDTE_OFF                        ; Turn off the watchdog timmer
    __CONFIG _CONFIG4, _LVP_ON                          ; Low voltage programming on

;-------------------------------------------------------------------
;                        VARIABLES
;-------------------------------------------------------------------
    CBLOCK 0X20
        DELAYTEMP2
        DELAYTEMP
        SysWaitTempMS
        SysWaitTempMS_H
        SysWaitTempUS
        SysWaitTempUS_H
        DATA_BYTE
        PTRH
        PTRL
    ENDC
;-------------------------------------------------------------------
;                        RESET VECTOR
;-------------------------------------------------------------------
    ORG     0x0000          ; Initial Address
    GOTO    INICIO
;-------------------------------------------------------------------
;                        SUBSOUTINES
;-------------------------------------------------------------------
;                        Delay ms
;-------------------------------------------------------------------
DELAY_MS
    INCF    SysWaitTempMS_H, 1
DMS_START
    MOVLW   D'14'
    MOVWF   DELAYTEMP2
DMS_OUTER
    MOVLW   D'189'
    MOVWF   DELAYTEMP
DMS_INNER
    DECFSZ  DELAYTEMP, 1
    GOTO    DMS_INNER
    DECFSZ  DELAYTEMP2, 1
    GOTO    DMS_OUTER
    DECFSZ  SysWaitTempMS, 1
    GOTO    DMS_START
    DECFSZ  SysWaitTempMS_H, 1
    GOTO    DMS_START
    RETURN

;-------------------------------------------------------------------
;                        Delay us
;-------------------------------------------------------------------
DELAY_US
    INCF    SysWaitTempUS_H, 1
DUS_START
    MOVLW   D'8'
    MOVWF   DELAYTEMP
DUS_INNER
    DECFSZ  DELAYTEMP, 1
    GOTO    DUS_INNER
    DECFSZ  SysWaitTempUS, 1
    GOTO    DUS_START
    DECFSZ  SysWaitTempUS_H, 1
    GOTO    DUS_START
    RETURN

DELAY_200US
    MOVLW   D'0'
    MOVWF   SysWaitTempUS_H
    MOVLW   D'200'
    MOVWF   SysWaitTempUS
    CALL    DELAY_US
    RETURN

DELAY_100MS
    MOVLW   D'0'
    MOVWF   SysWaitTempMS_H
    MOVLW   D'100'
    MOVWF   SysWaitTempMS
    CALL    DELAY_MS
    RETURN

DELAY_5MS
    MOVLW   D'0'
    MOVWF   SysWaitTempMS_H
    MOVLW   D'5'
    MOVWF   SysWaitTempMS
    CALL    DELAY_MS
    RETURN
;-------------------------------------------------------------------
;                        Display Initialization
;-------------------------------------------------------------------    
DISPLAY_INIT
    CALL    DELAY_100MS
    BCF     LCD_RS
    BCF     LCD_ENA
    BCF     LCD_RW

    MOVLW   0x03
    CALL    SEND_NIBBLE
    CALL    DELAY_5MS

    MOVLW   0x03
    CALL    SEND_NIBBLE
    CALL    DELAY_200US

    MOVLW   0x03
    CALL    SEND_NIBBLE
    CALL    DELAY_200US

    MOVLW   0x02
    CALL    SEND_NIBBLE
    CALL    DELAY_200US

    MOVLW   0x28
    CALL    SEND_COMMAND
    CALL    DELAY_200US

    MOVLW   0x0F
    CALL    SEND_COMMAND
    CALL    DELAY_200US

    MOVLW   0x01
    CALL    SEND_COMMAND
    CALL    DELAY_5MS

    MOVLW   0x06
    CALL    SEND_COMMAND
    CALL    DELAY_200US

    MOVLW   0x80
    CALL    SEND_COMMAND

    CALL    DELAY_100MS

    RETURN
    
;-------------------------------------------------------------------
; Routine to send a command to display
;-------------------------------------------------------------------
SEND_COMMAND
    BCF     LCD_RS
    MOVWF   DATA_BYTE
    SWAPF   DATA_BYTE, W
    CALL    SEND_NIBBLE
    MOVF    DATA_BYTE, W
    CALL    SEND_NIBBLE
    RETURN

SEND_DATA
    BSF     LCD_RS
    MOVWF   DATA_BYTE
    SWAPF   DATA_BYTE, W
    CALL    SEND_NIBBLE
    MOVF    DATA_BYTE, W
    CALL    SEND_NIBBLE
    RETURN

SEND_NIBBLE
    ANDLW   0x0F
    MOVWF   PORTA
    BSF     LCD_ENA
    CALL    DELAY_200US
    BCF     LCD_ENA
    RETURN

 ;
 ; print string subroutine
 ;
PRTSTR
    CALL    GETSTR        ;                  |B0   
    ANDLW    b'01111111'    ;                  |B0
    BTFSC    STATUS,Z    ;end of string (00)?          |B0
    RETURN                ;yes, return              |B0
    CALL    SEND_DATA    ;else, send character          |B0
    INCF    PTRL,f        ;increment pointer lo          |B0
    BTFSC    STATUS,Z    ;FF to 00 transition?          |B0
    INCF    PTRH,f        ;yes, bump PTRH              |B0
    GOTO    PRTSTR        ;
 
GETSTR
    MOVF    PTRH,W        ;                  |B0
    MOVWF    PCLATH        ;                  |B0
    MOVF    PTRL,W        ;                  |B0
    MOVWF    PCL            ;this causes the jump into table  |B0
    RETURN

;-------------------------------------------------------------------
;                        Clock Initialization
;-------------------------------------------------------------------   
CLOCK_INIT
    BANKSEL OSCCON1         ; Go to bank 17
    MOVLW   B'01100000'     ; HFINTOSC and NDIV = 1
    MOVWF   OSCCON1
    CLRF    OSCCON3         ; Enable
    CLRF    OSCEN
    CLRF    OSCTUNE
    MOVLW   B'00000110'     ; 32MHz
    MOVWF   OSCFRQ
    RETURN

;-------------------------------------------------------------------
;                        Disable AD
;------------------------------------------------------------------- 
DISABLE_AD
    BCF     ADCON0, ADON 
    BANKSEL ANSELA
    CLRF    ANSELB
    CLRF    ANSELC
    CLRF    ANSELD
    CLRF    ANSELE
    RETURN
;-------------------------------------------------------------------
;                           MAIN ROUTINE
;-------------------------------------------------------------------
INICIO:
    CALL    CLOCK_INIT
    CALL    DISABLE_AD

    MOVLB   0x00            ; Go to Bank 0
    
    MOVLW   B'11110000'     ; Define pins 3:0
    MOVWF   TRISA           ; As output

    MOVLW   B'11111000'     ; Define pins 2:0
    MOVWF   TRISC           ; As output

    CLRF    PORTA           ; Turn off all leds 

    CALL    DISPLAY_INIT

    MOVLW    HIGH STRING1    ;print string2 string          |B0
    MOVWF    PTRH            ;                  |B0
    MOVLW    LOW STRING1        ;                  |B0
    MOVWF    PTRL            ;                  |B0
    CALL    PRTSTR            ;print the string          |B0

    MOVLW   0xC0
    CALL    SEND_COMMAND

    MOVLW    HIGH STRING2        ;print string2 string          |B0
    MOVWF    PTRH            ;                  |B0
    MOVLW    LOW STRING2        ;                  |B0
    MOVWF    PTRL            ;                  |B0
    CALL    PRTSTR            ;print the string          |B0
R3:
    NOP
    GOTO    R3

STRING1    
    dt        "BRASIL 2020"
    dt        0x00            ;end-of-string
STRING2    
    dt        "0123456789ABCDEF"
    dt        0x00            ;end-of-string

;-------------------------------------------------------------------
;                           END OF PROGRAM
;-------------------------------------------------------------------
    END
