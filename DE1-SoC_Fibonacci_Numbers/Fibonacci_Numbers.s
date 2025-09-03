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
	mov r6 , #12
	
@ main loop	
main_loop:
    @ display '0'
    ldr r8 , =0x3F
    str r8 , [r5]
    str r3 , [r0, #4]
    bl display_1_second

    @ display '1'
    ldr r8 , =0x06
    str r8 , [r5]
	str r3 , [r0, #4]
    bl display_1_second

    @ display '1'
    ldr r8 , =0x06
    str r8 , [r5]
	str r3 , [r0, #4]
    bl display_1_second

    @ display '2'
    ldr r8 , =0x5B
    str r8 , [r5]
	str r3 , [r0, #4]
    bl display_1_second

    @ display '3'
    ldr r8 , =0x4F
    str r8 , [r5]
    str r3 , [r0, #4]
    bl display_1_second

    @ display '5'
    ldr r8 , =0x6D
    str r8 , [r5]
	str r3 , [r0, #4]
    bl display_1_second

    @ display '8'
    ldr r8 , =0x7F
    str r8 , [r5]
	str r3 , [r0, #4]
    bl display_1_second

    @ display '13'
    ldr r8 , =0x064F
    str r8 , [r5]
	str r3 , [r0, #4]
    bl display_1_second

    @ display '21'
    ldr r8 , =0x5B06
    str r8 , [r5]
	str r3 , [r0, #4]
    bl display_1_second

    @ display '34'
    ldr r8 , =0x4F66
    str r8 , [r5]
	str r3 , [r0, #4]
    bl display_1_second

    b main_loop

display_1_second:
     @ push r4, r6 for overwriting r4, r6
     push {r4, r6}	
	 @ check if it passed 1s
     ldr r4 , [r0]
     cmp r4 , #2
	 @ pop r4, r6 for overwriting r4, r6  
     pop {r4 , r6}
	 @ loop
     beq display_1_second
	 @ write anything to clear the timer
     str r6 , [r0]
	 @ branch back to main loop
     bx lr 
