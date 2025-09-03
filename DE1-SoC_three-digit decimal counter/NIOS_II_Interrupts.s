/*****************************************************************************
* DEFINITIONS SECTION
*/
.equ IOBASE,		0xFF200000
.equ ADDR_LED,		0xFF200000
.equ ADDR_SWITCH,	0xFF200040
.equ ADDR_TIMER,	0xFF202000

.equ LED,		(ADDR_LED - IOBASE)
.equ SWITCH,		(ADDR_SWITCH - IOBASE)
.equ TIMER_STATUS,	(ADDR_TIMER - IOBASE + 0)
.equ TIMER_CONTROL,	(ADDR_TIMER - IOBASE + 4)
.equ TIMER_START_LOW,	(ADDR_TIMER - IOBASE + 8)
.equ TIMER_START_HIGH,	(ADDR_TIMER - IOBASE + 12)
.equ TIMER_VALUE_LOW,	(ADDR_TIMER - IOBASE + 16)
.equ TIMER_VALUE_HIGH,	(ADDR_TIMER - IOBASE + 20)

.equ STACK_END,		0x0080000

/*****************************************************************************
* RESET SECTION
* The Nios II assembler/linker places this section at address 0x00000000.
* It must be <= 8 real NiosII instructions. This is where the CPU starts
* at "powerup" and on "reset".
*
/.section .reset, "ax"
	movia	sp, STACK_END	/* initialize stack */
	movia	ra, _start
	ret			/* jump to _start */

/*****************************************************************************
* EXCEPTIONS SECTION
* The Nios II assembler/linker places this section at addresss 0x00000020.
*/
.section .exceptions, "ax"

exception_handler:
	addi	sp, sp, -12	/* save used regs on stack */
	stw		r8, 0(sp)
	stw		r9, 4(sp)
	stw		ra, 8(sp)

/* Check if interrupts were enabled by examining the EPIE bit. */
/* EPIE is bit0 of estatus, a copy of PIE before the exception */
	rdctl	et, estatus
	andi	et, et, 1
	beq		et, r0, check_software_exceptions
	/* interruptsare enabled, check if any are pending */
	rdctl	et, ipending
	beq		et, r0, check_software_exceptions

check_hardware_interrupts:
	/* upon return, execute the interrupted instruction */
	subi	ea, ea, 4
	/* should check interrupts one-at-a-time, from irq0 to irq31 */
	/* each time the ipending bit is set, we should call the proper ISR */
	/* since we are only expecting irq0, we will only check for it */
	andi	et, et, 0x1
	beq		et, r0, check_next_interrupt

	call	timer_isr	/* ISR uses r8, r9, and ‘call’ uses ra */

check_next_interrupt:
	/* no more interrupts to check */

check_software_exceptions:
	/* no software exceptions supported */
	/* they should be checked in priority order (trap, break, unimplemented) */

done_exceptions:
	ldw		ra, 8(sp)	/* restore used regs from stack */
	ldw		r9, 4(sp)
	ldw		r8, 0(sp)
	addi	sp, sp, 12
	eret

/* Nios II exception prioritiesare defined as follows:
*	1) hardware interrupt exceptions
*		a) irq 0 (highest interrupt priority)
*		b) irq 1, ..., irq30 (again, listed higher to lower priority)
*		c) irq 31 (lowest interrupt priority)
*	2) software exceptions
*		a) trap exception
*		b) break exception
*		c) unimplemented instruction
* We implement these priorities by checking the cause of the exception
* in the same order in the exception handler above.
*/

/*****************************************************************************
* TEXT SECTION
* The Nios II assembler/linker should put the .text section after the .exceptions.
* You may need to configure the Altera Monitor Program to locate it at address 0x400.
*/
.text	
.global _start

_start:
	movia	r23, IOBASE
	movia	sp, STACK_END	/* make sure stack is initialized */
	movia	r4, interrupt_counts
	stw		r0, 0(r4)

	movia	r4, 100*50000	/* # of timer cycles in 100ms */
	call	setup_timer_interrupts
	call	setup_cpu_interrupts

loop:
	br		loop

timer_isr:
	/* every interval, increment 'interrupt_counts' and display on LED */
	/* clear source of interrupt by writing 0 to TO bit */
	stwio	r0, TIMER_STATUS(r23)

	/* process the interrupt, change state of system */
	movia	r9, interrupt_counts
	ldw		r8, 0(r9)
	addi	r8, r8, 1
	stw		r8, 0(r9)
	stwio	r8, LED(r23)	/* show count on LED */

	/* return from ISR */
	ret

setup_timer_interrupts:
	/* set up timer to send interrupts */
	/* parameter r4 holds the # cycles for the timer interval */

	/* set the timer period */
	andi	r2, r4, 0xffff	/* extract low halfword */
	stwio	r2, TIMER_START_LOW(r23)
	srli	r2, r4, 16	/* extract high halfword */
	stwio	r2, TIMER_START_HIGH(r23)

	/* start timer (bit2), count continuously (bit1), enable irq (bit0) */
	movi	r2, 0b0111
	stwio	r2, TIMER_CONTROL(r23)

	ret

setup_cpu_interrupts:
	/* set up CPU to receive interrupts from timer */
	movi	r2, 0x01	/* bit0 = irq0 = countdown timer device */
	wrctl	ienable, r2
	movi	r2, 1		/* bit0 = PIE */
	wrctl	status, r2

	ret			/* first instr. that may be interrupted */

.data
interrupt_counts:	.word 0
.end