# Macro that reads a string from a file up to a delimiter and stores it in a destination string
# Parameters:
#   %wordPos: the position of the word in the file (starting from pos 0)
#   %dstStr: the destination string
#   %delim: the delimiter character
#   %path: the path to the file
.macro getline(%wordPos, %dstStr, %delim, %path)
.data
    buff: .space 1   # temporary buffer to read characters from the file
.text
    pushStack($t0)    # save registers that will be used
    pushStack($t1)
    pushStack($t2)
    pushStack($t3)
    pushStack($t4)
    pushStack($s7)
    pushStack($a0)	
    pushStack($a1)	
    pushStack($a2)
	
    move $t4, %dstStr   # initialize destination string pointer
    move $t1, %wordPos  # initialize word position in $t1
	
    # open file for reading
    li $v0, 13
    la $a0, %path
    li $a1, 0
    li $a2, 0
    syscall
    move $s7, $v0    
	
    li $t2, 0        # initialize delimiter count to 0
	
    FindWord:
        # read one character from the file
        li $v0, 14
        move $a0, $s7
        la $a1, buff
        la $a2, 1
        syscall
	
        lb $t3, buff   # get the character from the buffer
	
        beqz $v0, Error  # end of file reached, word not found
        beqz $t1, getWord  # found first word, read it
        beq $t3, %delim, count  # found delimiter character, increment delimiter count
        beq $t1, $t2, getWord  # found word at the desired position, read it

        j FindWord
	
    count:
        addi $t2, $t2, 1   # increment delimiter count
        j FindWord
		
    getWord:
        lb $t3, buff   # get the character from the buffer
        sb $t3, ($t4)  # store the character in the destination string
		
        addi $t4, $t4, 1   # increment destination string pointer
    Loop:
        li $v0, 14
        move $a0, $s7
        la $a1, buff
        la $a2, 1
        syscall
	
        lb $t3, buff
		
        beq $t3, %delim, getWordExit   # found delimiter character, end of word
        beqz $v0, getWordExit  # end of file reached, end of word

        sb $t3, ($t4)   # store the character in the destination string
        addi $t4, $t4, 1   # increment destination string pointer
        j Loop
		
    getWordExit:
        li $t3, 0x00
        sb $t3, ($t4)   # null-terminate the destination string
        li $t0, 0   # return 0 
        j end
		
    Error:
        li $t0, -1   # return '-'

		li $t3, 0x00
		sb $t3, ($t4)
	
	end:
	# We use the system call to close the file and store the file descriptor in $s7.
	li   $v0, 16       
	move $a0, $s7      
	syscall           
	move $v0, $t0
	
	# We pop the stack to clean up the registers used in the function
	popStack($a2)	
	popStack($a1)	
	popStack($a0)
	popStack($s7)		
	popStack($t4)
	popStack($t3)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro


# The following macro saves a character to a file
# The file will be reduced if flag is set to 0. The file will be inserted if flag is set to 1.


.macro saveChar(%char, %flag, %path)
.data
	storeSaveChar: .byte
.text
	pushStack($s7)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)	
	pushStack($t4)
	pushStack($a0)	
	pushStack($a1)	
	pushStack($a2)	
	
	li $t0, 1  # We load the value 1 into register $t0
	
	la $t1, %flag  # We load the address of the variable %flag into register $t1

	
	add $t3, $zero, %char # We load the value of %char into register $t3 and the address of storeSaveChar into register $t4
	la $t4, storeSaveChar
	sb $t3, ($t4)  # We store the value of $t3 (which is %char) into the memory address pointed to by $t4 (which is storeSaveChar)
	
	beqz $t1, trunc  # If the value of $t1 is equal to the value stored in $t0 (which is 1), thus we jump  to label app

	beq $t1, $t0, app
	
	trunc:
		li $v0, 13  # loads the system call number 13 into register $v0
		la $a0, %path # loads the address of the file path string into register $a0
		li $a1, 1  # sets the value of $a1 to 1, indicating that the file should be opened in write mode
		li $a2, 0  # sets the value of $a2 to 0, which specifies the default file permissions
		syscall    # return $vo
		move $s7, $v0 # Here we move $vo to the register $s7 to use it later

		li $v0, 15 # loads the system call number 15 into $v0
		move $a0, $s7 # moves the file descriptor value in $s7(from the instruction before) to $a0 
		# the address of the character to write to the file in $a1, and the number of bytes to write in $a2
		move $a1, $t4 
		li $a2, 1
		syscall  # we call it here by using the syscall 
		
		j exit # here it jumps to the exit
	
	app:
		li $v0, 13  # value 13 is loaded into register $v0, which is the system call code for opening a file in append mode
		la $a0, %path # here the address of the file path string is loaded into register $a0
		li $a1, 9  # the value 9 is loaded into register $a1, which means the file will be opened
		# with write permission and the file pointer is set to the end of the file
		
		li $a2, 0 # value 0 is loaded into register $a2
		syscall # syscall instruction is executed to open the file in append mode
		move $s7, $v0 # we move the file from $v0 to $s7

		li $v0, 15 # the value 15 is loaded in $v0
		move $a0, $s7 # the file descriptor is loaded into $a0 from $s7
		move $a1, $t4 # the address of the character to be written is loaded into $a1 from $t4
		li $a2, 1 # the value 1 is loaded into $a2, which means only one character will be written to the file
		syscall # syscall instruction is executed to write the character to the file
	exit:

	# closing the file
	li   $v0, 16       # we close our file with system call
	move $a0, $s7      # we also grab the file descriptor
	syscall            #  Ok so now we closed the file
	
	popStack($a2)	
	popStack($a1)	
	popStack($a0)	
	popStack($t4)	
	popStack($t3)
	popStack($t2)	
	popStack($t1)
	popStack($t0)
	popStack($s7)

.end_macro

# saving the string in the file
# If the flag value is 0, the macro branches to the trunc label. If the flag value is 1, it branches to the app label.
.macro saveString(%string, %flag, %path)
.data 
	storeSaveChar: .byte
.text
	pushStack($s7)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	pushStack($t4)
	pushStack($t5)	
	pushStack($a0)	
	pushStack($a1)	
	pushStack($a2)	
	
	li $t0, 1
	
	la $t1, %flag
	
	li $t2, 0x00
	add $t3, $zero, %string
	
	beqz $t1, trunc
	beq $t1, $t0, app
	
	trunc:
		la $t4, storeSaveChar	
		
		# we open the file
		li $v0, 13
		la $a0, %path
		li $a1, 1
		li $a2, 0
		syscall
		move $s7, $v0 # we save the file descriptor
		
		loopTrunc:
			# we start writting
			lb $t5, ($t3)
			sb $t5, ($t4)
			beq $t5, $t2, loopTruncExit
			
			li $v0, 15
			move $a0, $s7
			move $a1, $t4
			li $a2, 1
			syscall	
			
			addi $t3, $t3, 1
			j loopTrunc
		loopTruncExit:
		
		j exit
	app:
		loopApp:
			lb $t4, ($t3)
			beq $t4, $t2, loopAppExit
			saveChar($t4, 1, %path)
			add $t3, $t3, 1
			j loopApp
		loopAppExit:
	exit:

	# we close the file
	li   $v0, 16       # we close our file 
	move $a0, $s7      # we also grab the file descriptor
	syscall            # Ok we close it using the syscall instruction
	
	popStack($a2)	
	popStack($a1)	
	popStack($a0)	
	popStack($t5)	
	popStack($t4)	
	popStack($t3)
	popStack($t2)	
	popStack($t1)
	popStack($t0)
	popStack($s7)
.end_macro