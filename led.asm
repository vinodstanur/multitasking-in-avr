;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;MULTITASKING IN AVR (atmega32) [A DEMO]
;------------------------------------------------------------------
;data: 19/03/2012
;by: VINOD.S <vinodstanur@gmail.com> <http://blog.vinu.co.in>
;------------------------------------------------------------------
;TASK:
;At present, there are 7 tasks in this program. Also we can add
;more by editing the TASKx_STACK_BEGIN, TOTAL_TASK and adding few 
;lines on the start_up code....
;Each task toggle a bit of PORTD with a constant delay, but the 
;delay for each task is different. Thus we could observe the LEDs
;at different port bits are toggling at different speed. 
;------------------------------------------------------------------
;assembler: gavrasm
;development platform: linux
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.INCLUDE "m32def.inc"
;
.EQU    TOTAL_TASK=7
.EQU    TASK_INDEX=(RAMEND)
.EQU    SP_BACKUP_BASE=(RAMEND-2)   ;stack pointer backup array base 
.EQU    TASK1_STACK_BEGIN=(RAMEND-50)   ;initial stack pointer for task1
.EQU    TASK2_STACK_BEGIN=(RAMEND-350)  ;initial stack pointer for task2
.EQU    TASK3_STACK_BEGIN=(RAMEND-650)  ;initial stack pointer for task3
.EQU    TASK4_STACK_BEGIN=(RAMEND-950)  ;initial stack pointer for task4
.EQU    TASK5_STACK_BEGIN=(RAMEND-1250) ;initial stack pointer for task5
.EQU    TASK6_STACK_BEGIN=(RAMEND-1550) ;initial stack pointer for task6
.EQU    TASK7_STACK_BEGIN=(RAMEND-1850) ;initial stack pointer for task7
;
.CSEG
.ORG 0x0000                            ;reset vector
    rjmp startup                    ;jump to startup code
.ORG 0x000e                            ;OCCR1B timer interrupt vector
    rjmp context_switch                ;jump to context_switching interrupt service routine
;   
startup:
;timer_init                            ;this code initialize the timer interrupt
    ldi r16, (1<<WGM12)+(1<<CS12)+(1<<CS10) ; timer increment on clk/1024
    out TCCR1B, r16
    ldi r16, (1<<OCIE1A)
    out TIMSK,r16
    ldi r16,0
    out OCR1AH,r16                    ;compare value , interrupt when timer matches this value
    ldi r16,1
    out OCR1AL, r16
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INITIAL SP BACKUP ON AN ARRAY:                
;this is an initial setup to fill the stack pointer backup
;array with initial stack pointers of each tasks....
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldi r31,HIGH(SP_BACKUP_BASE)        ;initializing Z register(pointer) SP_BACKUP_BASE (higher 8 bit) 
    ldi r30,LOW(SP_BACKUP_BASE)         ;initializing Z register(pointer) SP_BACKUP_BASE (lower 8 bit)
;
    ldi r16, HIGH(TASK1_STACK_BEGIN)  
    st z, r16                           
    out SPH, r16                         
    ldi r16, LOW(TASK1_STACK_BEGIN)         
    st -z, r16                         
    out SPL, r16                       
;---------------------------------------
    ldi r16, HIGH(TASK2_STACK_BEGIN-35)
    st -z, r16
    ldi r16, LOW(TASK2_STACK_BEGIN-35)
    st -z, r16
;---------------------------------------
    ldi r16, HIGH(TASK3_STACK_BEGIN-35)
    st -z, r16
    ldi r16, LOW(TASK3_STACK_BEGIN-35)
    st -z, r16
;---------------------------------------
    ldi r16, HIGH(TASK4_STACK_BEGIN-35)
    st -z, r16
    ldi r16, LOW(TASK4_STACK_BEGIN-35)
    st -z, r16
;---------------------------------------
    ldi r16, HIGH(TASK5_STACK_BEGIN-35)
    st -z, r16
    ldi r16, LOW(TASK5_STACK_BEGIN-35)
    st -z, r16
;---------------------------------------
    ldi r16, HIGH(TASK6_STACK_BEGIN-35)
    st -z, r16
    ldi r16, LOW(TASK6_STACK_BEGIN-35)
    st -z, r16
;--------------------------------------
    ldi r16, HIGH(TASK7_STACK_BEGIN-35)
    st -z, r16
    ldi r16, LOW(TASK7_STACK_BEGIN-35)
    st -z, r16
;--------------------------------------
;
;YOUR CODE HERE
;DO AS ABOVE IF YOU HAVE TO ADD EXTRA TASK :-)
;
;---------------------------------------
    clr r16
    sts TASK_INDEX, r16
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PROGRAM COUNTER INITIALIZATION:
;This is an initial setup to keep all the 
;task starting address for task2 to task 7 in
;the stack head so that the reti instruction at
;the end of context switching can load the PC with
;the task starting address for the first time..
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;program counter initialization for task2
    ldi r16, LOW(TASK2)
    sts TASK2_STACK_BEGIN, r16
    ldi r16, HIGH(TASK2)
    sts TASK2_STACK_BEGIN-1, r16
;
;program counter initialization for task3
    ldi r16, LOW(TASK3)
    sts TASK3_STACK_BEGIN, r16
    ldi r16, HIGH(TASK3)
    sts TASK3_STACK_BEGIN-1, r16
;
;program counter initialization for task4
    ldi r16, LOW(TASK4)
    sts TASK4_STACK_BEGIN, r16
    ldi r16, HIGH(TASK4)
    sts TASK4_STACK_BEGIN-1, r16
;
;program counter initialization for task6
    ldi r16, LOW(TASK5)
    sts TASK5_STACK_BEGIN, r16
    ldi r16, HIGH(TASK5)
    sts TASK5_STACK_BEGIN-1, r16
;
;program counter initialization for task6
    ldi r16, LOW(TASK6)
    sts TASK6_STACK_BEGIN, r16
    ldi r16, HIGH(TASK6)
    sts TASK6_STACK_BEGIN-1, r16
;
;program counter initialization for task7
    ldi r16, LOW(TASK7)
    sts TASK7_STACK_BEGIN, r16
    ldi r16, HIGH(TASK7)
    sts TASK7_STACK_BEGIN-1, r16
;    
;program counter initialization for ADDITIONAL TASK
;WANT TO ADD MORE TASKS? :-)
;
;  ADD THE CODE HERE ,AS ABOVE WITH NEW TASK ADDRESS
;  ALSO DON'T FORGET TO UPDATE THE TASKX_STACK_BEGIN & TASK NUMBER
;  Also don't forget about the RAM capacity.. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
;-------------STARTUP END-------------------------------------;
;THE ABOVE CODE WILL NOT REPEAT ANY MORE UNTIL A RESET HAPPENS
;-------------------------------------------------------------;
    sei                     ;ENABLE GLOBAL INTERUPT
    rjmp TASK1              ;JUMP TO FIRST TASK AND THE REAL GAME BEGINS ;-)
;
;
;---------------------------------------------------------------------
;TASK 1 TO 7    
;Pls read this:
;All the example tasks are almost similar. Each task is to control each 
;bit of PORTD, it toggle each bits and the delay of toggling is different 
;on each task. All the delay related registers are common to all tasks.
;This shows significance of the backup and restore of the cpu registers
;and status register while context switching.. We can see the LED 
;blinkings on each bit of PORTD is independent... Each one is 
;blinking at it's own delay and is not affected by any other, remember
;each one is an independent task and is continuously switching from 
;1 to 7 and the the cycle repeats...
;---------------------------------------------------------------------
;
;;;;;TASK -1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
TASK1:
    ldi r16, 255
    out DDRD, r16
    clr r23
while11:
    cpi r23,255
    brne increment
    dec r25
    rjmp skip_inc
increment:
    inc r25
skip_inc:
    cpi r25, 0
    brne next1
    com r23
next1:
    cpi r25, 255
    brne ll
    com r23
ll:
    rcall pwm
    dec r24
    lsr r24
    nop
    nop
    nop
    brne ll
    rjmp while11
pwm:
    push r25
    sbi PORTD, PD7
pwml1:
    dec r25
    brne pwml1
    pop r25
    push r25
    com r25
    cbi PORTD, PD7
pwml2:
    dec r25
    brne pwml2
    pop r25
    ret
;   
;;;;;TASK -2;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
TASK2:
    ldi r16, 255
    out DDRD, r16
while12:
    ldi R17,1<<PD6
    IN r16, PIND
    EOR r16,R17
    out PORTD,r16
    RCALL delay12
    rjmp while12    
;
delay12:
    ldi r25,25
l12:
    ldi r24,25
l22:
    ldi r23,20
l32:
    dec r23
    brne l32
    dec r24
    brne l22
    dec r25
    brne l12
    ret
;    
;;;;TASK -3;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
TASK3:
    ldi r16, 255
    out DDRD, r16
while13:
    ldi R17,1<<PD5
    IN r16, PIND
    EOR r16,R17
    out PORTD,r16
    RCALL delay13
    rjmp while13    
;
delay13:
    ldi r25,255
l13:
    ldi r24,255
l23:
    ldi r23,15
l33:
    dec r23
    brne l33
    dec r24
    brne l23
    dec r25
    brne l13
    ret
;    
;;;;TASK -4;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
TASK4:
    ldi r16, 255
    out DDRD, r16
while14:
    ldi R17,1<<PD4
    IN r16, PIND
    EOR r16,R17
    out PORTD,r16
    RCALL delay14
    rjmp while14    
;
delay14:
    ldi r25,255
l14:
    ldi r24,255
l24:
    ldi r23,10
l34:
    dec r23
    brne l34
    dec r24
    brne l24
    dec r25
    brne l14
    ret
;    
;;;;TASK -5;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
TASK5:
    ldi r16, 255
    out DDRD, r16
while15:
    ldi R17,1<<PD3
    IN r16, PIND
    EOR r16,R17
    out PORTD,r16
    RCALL delay15
    rjmp while15    
;
delay15:
    ldi r25,255
l15:
    ldi r24,255
l25:
    ldi r23,5
l35:
    dec r23
    brne l35
    dec r24
    brne l25
    dec r25
    brne l15
    ret
;            
;;;;TASK 6;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
TASK6:
    ldi r16, 255
    out DDRD, r16
while16:
    ldi R17,1<<PD2
    IN r16, PIND
    EOR r16,R17
    out PORTD,r16
    RCALL delay16
    rjmp while16    
;
delay16:
    ldi r25,255
l16:
    ldi r24,255
l26:
    ldi r23,1
l36:
    dec r23
    brne l36
    dec r24
    brne l26
    dec r25
    brne l16
    ret
;    
;;;;TASK 7;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
TASK7:
    ldi r16, 255
    out DDRD, r16
while17:
    ldi R17,1<<PD1
    IN r16, PIND
    EOR r16,R17
    out PORTD,r16
    RCALL delay17
    rjmp while17    
;
delay17:
    ldi r25,255
l17:
    ldi r24,100
l27:
    ldi r23,1
l37:
    dec r23
    brne l37
    dec r24
    brne l27
    dec r25
    brne l17
    ret
;--------------------------TASK END----------------------------------------;
;
;I S R
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;THIS IS THE MOST IMPORTANT PART OF THIS PROGRAM.      
;IT BACKUP THE CURRENT STACK POINTER IN THE PER-TASK
;SP BACKUP TABLE AND TAKES THE NEXT TASK'S STACKPOINTER
;FROM THE SAME TABLE AND LOAD IT TO THE STACK POINTER.
;ALSO IT BACKUP AND RESTORE ALL THE REGISTER STATUS AND
; THE STATUS REGISTER SO THAT THE PAUSED TASK COULD BE 
;RESUMED FROM IT'S PAUSED STATE WITHOUT ANY CHANGE IN
;THE CPU REGISTERS AND STATUS REGISTER...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
context_switch: ;pushing all registers
    push r31
    push r30
    push r29
    push r28
    push r27
    push r26
    push r25
    push r24
    push r23
    push r22
    push r21
    push r20
    push r19
    push r18
    push r17
    push r16
    push r15
    push r14
    push r13
    push r12
    push r11
    push r10
    push r9
    push r8
    push r7
    push r6
    push r5
    push r4
    push r3
    push r2
    push r1
    push r0   
    in r17, SREG
    push r17            ;pushing status register
;-------CONTEXT SWITCHING -------------------;
    lds r16, TASK_INDEX
    ldi r30, low(SP_BACKUP_BASE)
    ldi r31, high(SP_BACKUP_BASE)
    clr r0
    sub r30,r16
    sbc r31,r0
    sub r30,r16
    sbc r31,r0
    in r17, SPH
    st Z, r17
    in r17, SPL
    st -Z, r17
    inc r16
    cpi r16, TOTAL_TASK
    brne SKIP1
    ldi r30, low(SP_BACKUP_BASE)
    ldi r31, high(SP_BACKUP_BASE)
    clr r16
    sts TASK_INDEX, r16
    ld r17, Z
    rjmp SKIP2    
SKIP1:
    sts TASK_INDEX,r16
    ld r17, -Z
SKIP2:
    out SPH,r17
    ld r17, -Z
    out SPL,r17
;-----NOW I GOT THE NEW STACK POINTER, SO THE TASK IS SWITCHED!-------;
; 
;Now the next process is to restore the status register and 
;all the cpu registers as it's previous state for the selected
;task....
    pop r17
    out SREG, r17
    pop r0
    pop r1
    pop r2
    pop r3
    pop r4
    pop r5
    pop r6
    pop r7
    pop r8
    pop r9
    pop r10
    pop r11
    pop r12
    pop r13
    pop r14
    pop r15
    pop r16
    pop r17
    pop r18
    pop r19
    pop r20
    pop r21
    pop r22
    pop r23
    pop r24
    pop r25
    pop r26
    pop r27
    pop r28
    pop r29
    pop r30
    pop r31
    reti                     ;at last, returning to the task to continue it until
                             ;next interrupt occur
