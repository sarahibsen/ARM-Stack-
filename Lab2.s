@ File: Arm program Quiz
@ Purpose: Creating a four function calculator 
@ we need to:
@	create a four function integer calculator (addition, sub, mul, div)
@	each function must be accessed as a subroutine function
@	operands are passed to the function via the stack.
@	function returns results on the top of the stack.
@	program prints welcome/instruction messages to the user.
@	user is prompted to enter zero and positive integers and the operation
@	to be performed.	
@
@	After the program provides the right result, as the user if they want to 
@	continue or quit the program.
@
@ Use these commands to assemble, link, run, and debug
@ the program.
@ as -o program1.o program1.s
@ gcc -o program1 program1.o
@ ./program1 ;echo $?
@ gdb --args ./program1

@.equ READERROR, #0 	@ used so that if the user enters an integer lower than 0, we will branch so that we can reprompt them

.global main


main:
  @ welcome message that explains what this program is
  @ after the instruction message we are going to go to the get_input

	
	ldr r0, =welcomeMessage 	@ asks the user to enter their first number
	bl printf

 	ldr r0, =instructionMessage 	@ instruction message displayed letting the user know 
	bl printf 
	
	ldr r0, =numInputPattern
	ldr r1, =intInput		@ asking the user for input 
	bl scanf
	ldr r1, =intInput
	ldr r5, [r1]			@ storing register in r5
	mov r1, r5
	ble readerror			@ checking if the input is less than 0

  @ prompting the user to choose one of the options of a four function cal

	ldr r0, =operation		@ the message, A = + , B = - , C = *, D = % 
	bl printf
	ldr r0, =charPattern
	ldr r1, =charInput
	bl scanf
	ldr r1, =charInput		@ loading r1 again
	ldr r6, [r1]			@ storing the register in r6	
	
	bl operationValid

	


  @ now we ask for the second integer after we have prompted for the desired operation

	ldr r0, =instructionMessage
	bl printf
	ldr r0, =numInputPattern
	ldr r1, =intInput
	bl scanf
	ldr r1, =intInput
	ldr r7, [r1]

	mov r1, r7
	ble readerror

	push {r5, r7}		@ we want to push the two inputs onto the stack so we can preform the operation 
	

	pop {r1, r2}
	push {r1, r2, lr}

	cmp r6, #'a'
	bleq addition	
	cmp r6, #'b'
	bleq subtraction
	cmp r6, #'c'
	bleq multiplication
	cmp r6, #'d'
	bleq division
@ just in case they enter an uppercase character
	cmp r6, #'A'
	bleq addition
	cmp r6, #'B'
	bleq subtraction
	cmp r6, #'C'
	bleq multiplication
	cmp r6, #'D'
	bleq division

	@bl operationChoice

	bl printCalc

	bl repeat

	ldr r0, =choiceExit 		@ if the user chooses to exit the program prompt this message
	bl printf
	b done 

printCalc:
	pop {r1}
	ldr r0, =printedMessage
	push {lr}
	bl printf
	pop {lr}
	mov pc, lr

operationValid:
	@ compare entered letter then branch to the desired operation to see if the operation is valid 
	cmp r6, #'a'
	moveq pc, lr	
	cmp r6, #'b'
	moveq pc, lr
	cmp r6, #'c'
	moveq pc, lr
	cmp r6, #'d'
	moveq pc, lr
@ just in case they enter an uppercase character
	cmp r6, #'A'
	moveq pc, lr
	cmp r6, #'B'
	moveq pc, lr
	cmp r6, #'C'
	moveq pc, lr
	cmp r6, #'D'
	moveq pc, lr
	b inValid		 

	
@ addition loop 
addition:
	@ we want to push the lr onto the stack to save it
	pop {r1, r2}
	adds r1, r1, r2
	bvs overflow
	push {r1}
	mov pc, lr


subtraction:
	pop {r1, r2}	@ we want to pop these onto the stack so that we can manipulate them
	sub r1, r1, r2
	bvs overflow
	push {r1}		@ pushing the values on to the stack so we can save the values
	mov pc, lr		@ in order to return to the main, we want to move the lr to pc

@ multiplication loop
multiplication:
	pop {r1, r2}
@ umull to check for overflow 
@ umull is set up with regL, regU, regA, regB where you are multiplying a and b

	umull r0, r4, r1, r2
	cmp r4, #0 			@ if it is anything other than 0 you have overflow
	bgt overflow
	push {r0}
	mov pc, lr

@division loop
division:
    pop {r1, r2}  @ Pop the inputs and lr

    mov r3, #0        @ Initialize quotient to 0
   

    cmp r2, #0        @ Check if divisor is zero
    beq division_error

division_loop:
    cmp r1, r2        @ Compare dividend and divisor
    blt division_exit  @ Exit loop if dividend < divisor

    sub r1, r1, r2    @ Subtract divisor from dividend
    add r3, r3, #1    @ Increment quotient
    b division_loop   @ Repeat until dividend < divisor

division_exit:
	mov r8, r1 @ remainder
	mov r9, r3 @ quotient
	b division_return

division_error:
    ldr r0, =errorMSG
    bl printf
    pop {r1, r2}
    b repeat

division_return:
	 @ Print quotient and remainder
    	ldr r0, =quotientRemainderMsg
	push {lr}
    	bl printf
    	pop {lr}
	push {r9}
	@ return to the main
	mov pc, lr

overflow:
    ldr r0, =overflowMsg    @ Loads r0 with the overflow string to be printed
    push {lr}
    bl printf                  @ Prints the string
    pop {lr}

    mov r0, #0                 @ Reinitializes r0 with 0
    mov pc, lr	                 @ Reprompts the user



repeat:
@ after the user recieves their result, then, they should be prompted to do another calculation

	ldr r0, =continuePrompt
	push {lr}
	bl printf
	pop {lr}

	ldr r0, =charPattern
	ldr r1, =charInput
	push {lr}
	bl scanf
	pop {lr}

	ldr r1, =charInput
	ldr r1, [r1]
	cmp r1, #'Y'
	beq main
	cmp r1, #'y'
	beq main
	
	mov pc, lr


inValid:
	ldr r0, =errorMSG
	bl printf
	b repeat
	
readerror:
	cmp r1, #0
	ble inValid
	mov pc, lr
done:
    mov r7, #0x01
    svc 0                     @ Exit the program

.data
.balign 4
welcomeMessage: .asciz "Welcome to the four function Calculator.\n"
.balign 4
instructionMessage: .asciz "Please enter a positive integer or zero \n"
.balign 4
invalidInputMessage: .asciz "Invalid input. Please enter a positive integer.\n"
.balign 4
operation: .asciz "Please select what operation you want to use: A (+), B (-), C(*), D(/)\n"
.balign 4
choiceExit: .asciz "Thank you for using the four function calculator!\n"
.balign 4
printedMessage: .asciz "Result:   %d\n"
.balign 4
continuePrompt:  .asciz "Would you like to perform another operation (y/n)?\n"
.balign 4
errorMSG: .asciz "You have entered an invalid input.\n"
.balign 4
numInputPattern: .asciz "%d"
.balign 4
intInput: .word 0 	@ location used to store the user input
.balign 4
charInput: .asciz "%c"
.balign 4
charPattern : .asciz "%s"
.balign 4
overflowMsg: .asciz "Overflow\n"
.balign 4
quotientRemainderMsg: .asciz "Remainder: %d, Divisor: %d\n"
.global printf
.global scanf

