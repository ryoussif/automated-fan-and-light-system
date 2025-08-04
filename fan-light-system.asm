;---------------------------------------------------- 
; Variable/Data Section
;----------------------------------------------------  
            ORG RAMStart   ; loc $1000  (RAMEnd = $3FFF)
; Insert your data definitions here
;Light Sensor variables 
LAST2DIGITS DC.W 1

SAVE_LED   DS.B 1

SAVE_TEMP  DS.B 1

Lights   DS.B 2
;Potentiometer variables 
SAVE_Potentiometer   DS.B 1

FAN_ON_TIME     DC.B 1

FAN_OFF_TIME     DC.B 1

First_Digit      DS    1		       ;First digit of voltage
Second_Digit      DS    1          ;Second digit of voltage
Volts           DC.B  " Volts",0   ;To Display Voltage

;printing

OFF      FCC  "OFF   "
         dc.b  0
         
ON       FCC  "ON   "
         dc.b  0
         
FAN      FCC  "FAN:"
         dc.b 0
         
LED      FCC  "LED:"         
         dc.b  0
—-------------------------------------------------------------------------------------------------------------------   
;---------------------------------------------------- 
; Insert your code here
;---------------------------------------------------- 
         LDS    #ROMStart ; load stack pointer
         JSR   TermInit    ; initialize Terminal
         JSR    clear_lcd   ; clear LCD
         JSR    led_enable      ;init. PORTB for LED’s
         JSR    lcd_init        ; initialize LCD (must be done first)
         
         BCLR   PTP,  RED+GREEN+BLUE  ; clear all

;initialize the ATD0 converter -------------------------------------------
         movb    #$80,ATD0CTL2   ; set ADPU (%10000000)
         jsr     delay20us             ; wait for 20 us
         movb    #$20,ATD0CTL3   ; 4 conversions per sequence (default)- (%00100000)
         movb    #$A5,ATD0CTL4   ; 8-bit resolution 1010 0101
                                        ; 4 cycles sample time, prescaler set to 12
;Setting an interrupt for PORT H---------------------------------
          ;BSET DDRH, %11111111
         
          BCLR    PPSH, #$07  ; set Port H pins 0-1 for falling edge
          MOVB   #$07, PIFH    ; clear interrupt flags initially
          BSET     PIEH,  $07     ; enable interrupts on Port H  pins 0,1 and 2 PIEH = %00000111
          CLI                      ; enable interrupts


;Endless Loop-----------------------------------------          
LOOP   
   Check_Light: 
          MOVB     #$84,ATD0CTL5     ; start an A/D conversion sequence
          BRCLR    ATD0STAT0,SCF,*   ; wait for conversion sequence to complete            
          
          LDAA     ATD0DR0L          ; get the low byte of the conversion result
          STAA     SAVE_LED          ; Store the value of the brightness for the LED

          JSR    Print_LED_OnOff 
          JSR    Printing_LED_volt
              
  Get_Voltage_From_A_D:
          MOVB  #$87,ATD0CTL5         ; select channel 7 (pot)
          BRCLR ATD0STAT0,SCF,*       ; poll if conversion's finished
          
          LDAA ATD0DR0L               ; load register a with digital value
          STAA SAVE_Potentiometer
          STAA FAN_ON_TIME
          
          JSR  Extract_First_And_Second_Digit  ;calculate and prints the input in volts  
          JSR  Display_In_LCD
          JSR  ACTIVATE_FAN           
          
   Checking_Temp:
          MOVB     #$85,ATD0CTL5     ; start an A/D conversion sequence
          BRCLR    ATD0STAT0,SCF,*   ; wait for conversion sequence to complete      
          
          LDAA     ATD0DR0           ; get the low byte of the conversion result
          STAA     SAVE_TEMP   
              
          JSR Print_FAN
                     
    
   BRA LOOP                     ; endless loop waiting for reset (and for interrupts)

;----------------------------------------------------------------------------------------------        
; Function: Print_LED_OnOff
; Purpose: Prints to the LCD whether the LED is ON or OFF
; Inputs: Veriable SAVE_LED 
; Outputs: LED On or LED Off to the LCD
; Registers Modified: Registers A and B
; ===================================================          
Print_LED_OnOff:
        
        LDAB    #00       ;set print position in LCD
        JSR    set_lcd_addr  
        LDAA   SAVE_LED
        CMPA   #100 
        BHI    LED_OFF
        
  LED_ON:
         LDD #LED      ;Prints "LED:"         
         JSR lcd_prtstrg
         LDD #ON       ;prints  "ON"
         JSR lcd_prtstrg
         
         BSET PORTB, #$01
         LDD #$100
         JSR ms_delay
         RTS 
         
         
  LED_OFF: 
         LDD #LED      ;Prints "LED:"         
         JSR lcd_prtstrg
         LDD #OFF     ; printf "OFF"
         JSR lcd_prtstrg
         
         BCLR PORTB, #$FF
         LDD #$100
         JSR ms_delay
         
         RTS
;=====================================================================
; Function: ACTIVATE_FAN
; Purpose: Activates the output voltage of the fan depending on the value of potentiometer
; Inputs: Variables FAN_ON_TIME and FAN_OFF_TIME 
; Outputs: output voltage to port T
; Registers Modified: Registers D
; =================================================== 
ACTIVATE_FAN: 
     ;PSHD
       LDAA #0
       BSET PTH, #$FF

       LDAB FAN_ON_TIME             ;D = [A:B]
       JSR ms_delay
       
       LDAB FAN_ON_TIME
       EORB #$FF
       STAB FAN_OFF_TIME             ;D = [A:B]
       BCLR PTH, #$FF
       JSR ms_delay

      ;PULD
       RTS  
;**************************************************************
;*                 Interrupt Service Routine              *
;**************************************************************  

PORTH_I:  
         BRSET  PIFH, %00000001,PUSH0  
         BRSET  PIFH, %00000010,PUSH1  
         BRA  DONE1
PUSH0:
     LDAA PORTB
     CMPA #$02        ;Check is one bit on
     BLO  DONE1       ;End interrupt of only one LED is on 
     LSRA             ;Shift to the right
     STAA SAVE_LED    ;store the new value in memory 
     STAA PORTB       ;LOAD the new value to the LED
     LDD #$500        ;make a delay for 0.5 Seconds 
     JSR ms_delay
     BRA    DONE1     ;End interrupt
     
PUSH1:
     LDAA PORTB       ;
     CMPA #$FF        ;Checks if ALL LEDs are ON
     BHS DONE1        ;End subroutine if all ALL LEDs are ON 
     LSLA             ;Ex. 0000 0111 -> 0000 1110
     INCA             ;    0000 1110 -> 0000 1111
     STAA SAVE_LED    ;store the new value in memory 
     STAA PORTB       ;LOAD the new value to the LED
     LDD #$500        ;make a delay for 0.5 Seconds 
     JSR ms_delay
     BRA DONE1        ;End interrupt

DONE1: 
         MOVB  #$07, PIFH   ; clear Port H interrupt flags
         RTI

;***********************************************************
            ORG     Vporth     ; setup  Port H interrupt Vector
            DC.W    PORTH_I
