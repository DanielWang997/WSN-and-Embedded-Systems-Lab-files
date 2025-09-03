.global _start

.data
timer_T: .word 100000000  @ Timer interval for 1 second

.text
_start:
    @ get the addresses
    ldr r5 , =0xff200020  @ 7-segment display base address
    @ initialize the timer
	ldr r0 , =0xff202000 @ timer address
	ldr r1 , =timer_T
	ldr r2 , [r1]
	str r2 , [r0 , #8] @ write interval to timer
	@ low-period register
	@ only lowest-16 bits will be written
	@ shift right by 16 bits
	@ write rest of interval 
	@to timer high-period
	mov r2 , r2 , lsr #16 
	str r2 , [r0 , #12 ]
	@count down and repeat to achieve 1s display
	mov r3 , #0b0110 
	@write anything to r6 to clean timer status
	mov r10 , #12

@Thrid_Digit
Thrid_Digit:

	@ Preserve state by pushing remaining registers
    push {r8, r5, r0}
	
    @ display '0'
    ldr r8 , =0x3F0000 
    str r8 , [r5]
    bl Second_Digit

    @ display '1'
    ldr r8 , =0x060000
    str r8 , [r5]
    bl Second_Digit

    @ display '2'
    ldr r8 , =0x5B0000
    str r8 , [r5]
    bl Second_Digit

    @ display '3'
    ldr r8 , =0x4F0000
    str r8 , [r5]
    bl Second_Digit

    @ display '4'
    ldr r8 , =0x660000
    str r8 , [r5]
    bl Second_Digit
	
    @ display '5'
    ldr r8 , =0x6D0000
    str r8 , [r5]
    bl Second_Digit

    @ display '6'
    ldr r8 , =0x7D0000
    str r8 , [r5]
    bl Second_Digit

    @ display '7'
    ldr r8 , =0x070000
    str r8 , [r5]
    bl Second_Digit

    @ display '8'
    ldr r8 , =0x7F0000
    str r8 , [r5]
    bl Second_Digit

    @ display '9'
    ldr r8 , =0x6F0000
    str r8 , [r5]
    bl Second_Digit
	
	@ Restore state by popping registers
    pop {r8, r5, r0}
	
    @ Exit subroutine
    b Thrid_Digit

@Second_Digit	
Second_Digit:
    push {lr , r11, r7}
	
	@ Set up frame pointer and move stack pointer ahead
    mov r11, sp
    sub sp, sp, #32

    @ display '0'
    ldr r7 , =0x3F00 
	add r7, r7, r8
    str r7 , [r5]
    bl First_Digit

    @ display '1'
    ldr r7 , =0x0600
	add r7, r7, r8
    str r7 , [r5]
    bl First_Digit

    @ display '2'
    ldr r7 , =0x5B00
	add r7, r7, r8
    str r7 , [r5]
    bl First_Digit

    @ display '3'
    ldr r7 , =0x4F00
	add r7, r7, r8
    str r7 , [r5]
    bl First_Digit

    @ display '4'
    ldr r7 , =0x6600
	add r7, r7, r8
    str r7 , [r5]
    bl First_Digit
	
    @ display '5'
    ldr r7 , =0x6D00
	add r7, r7, r8
    str r7 , [r5]
    bl First_Digit

    @ display '6'
    ldr r7 , =0x7D00
	add r7, r7, r8
    str r7 , [r5]
    bl First_Digit

    @ display '7'
    ldr r7 , =0x0700
	add r7, r7, r8
    str r7 , [r5]
    bl First_Digit

    @ display '8'
    ldr r7 , =0x7F00
	add r7, r7, r8
    str r7 , [r5]
    bl First_Digit

    @ display '9'
    ldr r7 , =0x6F00
	add r7, r7, r8
    str r7 , [r5]
    bl First_Digit
	
    @ Rewind stack pointer over temporary storage
    mov sp, r11	
	
    @ Pop previous frame pointer and link register
    pop {lr, r11, r7}	
	
    @ Exit subroutine
    bx lr

@First_Digit	
First_Digit:
    push {lr , r11, r6 }
	@ Set up frame pointer and move stack pointer ahead
    mov r11, sp
    sub sp, sp, #64
	
    @ display '0'
    ldr r6 , =0x3F 
	add r6, r6, r7
    str r6 , [r5]
    str r3 , [r0, #4]	
    bl display_1_second

    @ display '1'
    ldr r6 , =0x06
	add r6, r6, r7
    str r6 , [r5]
    bl display_1_second

    @ display '2'
    ldr r6 , =0x5B
	add r6, r6, r7
    str r6 , [r5]
    bl display_1_second

    @ display '3'
    ldr r6 , =0x4F
	add r6, r6, r7
    str r6 , [r5]
    bl display_1_second

    @ display '4'
    ldr r6 , =0x66
	add r6, r6, r7
    str r6 , [r5]
    bl display_1_second
	
    @ display '5'
    ldr r6 , =0x6D
	add r6, r6, r7
    str r6 , [r5]
    bl display_1_second

    @ display '6'
    ldr r6 , =0x7D
	add r6, r6, r7
    str r6 , [r5]
    bl display_1_second
	
    @ display '7'
    ldr r6 , =0x07
	add r6, r6, r7
    str r6 , [r5]
    bl display_1_second

    @ display '8'
    ldr r6 , =0x7F
	add r6, r6, r7
    str r6 , [r5]
    bl display_1_second

    @ display '9'
    ldr r6 , =0x6F
	add r6, r6, r7
    str r6 , [r5]
    bl display_1_second
	
    @ Rewind stack pointer over temporary storage
    mov sp, r11	
    @ Pop previous frame pointer and link register
    pop {lr, r11, r6}	
	
    @ Exit subroutine
    bx lr

display_1_second:

     @ push r4, r6 for overwriting r4, r6
     push {r4, r10}	
	 @ check if it passed 1s
     ldr r4 , [r0]
     cmp r4 , #2
	 @ pop r4, r6 for overwriting r4, r6  
     pop {r4 , r10}
	 @ loop
     beq display_1_second
	 @ write anything to clear the timer
     str r10 , [r0]
	 @ branch back to main loop
     bx lr 
