# Starting: Here we are pushing the content register to the stack
.macro pushStack(%regIn)
	addi	$sp, $sp, -4
	sw	%regIn, ($sp)
.end_macro

# We are removing  the top value from the stack, it does so by loading the value at the top of the stack
# into a specified register using the "lw" instruction, and then adjusting the stack pointer by adding 4 to it.
.macro popStack(%regOut)
	lw	%regOut, ($sp)
	addi	$sp, $sp, 4
.end_macro

# # This method is used to  swap 2 registers(%a, %b)
.macro swap(%a, %b)
	pushStack($t0)
	move	$t0, %a
	move 	%a, %b
	move	%b, $t0
	popStack($t0)
.end_macro

# This method converts integer to String
.macro toString(%regStr, %int)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($s0)
	
	# initialization 
	add	$t0, $zero, %int  
	move 	$s0, %regStr
	li	$t1, 10  #This line loads the integer value 10 into register $t1.
	abs	$t0, $t0 #This line takes the absolute value of the integer stored in register $t0.
	
	LoopIntToString:
		# Here, we are performing integer division of the value in $t0 by the value in $t1; 
		# the quotient is stored in register $t0.
		div 	$t0, $t1 
			
		mflo	$t0 # is used to move the quotient of the division operation stored in $LO by the div instruction .
		# into register $t0
		
		mfhi	$t2  # it moves the remainder into the register $t2
		
		addi	$t2, $t2, 48 #Ok here we add the immediate value 48 to the value in register $t2, 
		# which represents the ASCII code of a digit.This is done to convert the digit value into its corresponding ASCII character.
		
		sb	$t2, ($s0) #This method store the instruction $t2 in the memory.
			
		addi	$s0, $s0, 1 #Here this instruction is used to increment the memory address stored in $s0 by 1
		#                   in order to prepare it for storing the ASCII code of the next digit.
		
		#checks whether the integer value in register $t0 has been completely converted to a string representation or not.
		bne	$t0, $zero, LoopIntToString
	
        # Initialize register $t0 with the value stored in register $zero (which is 0).		
	add	$t0, $zero, %int
	
	# Check whether the value stored in register $t0 is less than 0. If so, branch to the AddMinusAfterString label.
	blt 	$t0, $zero, AddMinusAfterString
	
	# Store the value 0 in the memory
	sb	$zero, ($s0) 
	
	# Jump to the EndCheckNegative label.
	j 	EndCheckNegative
	
	AddMinusAfterString:
		# if branch in the second step is taken then we set the value of $to to '-'.
		li	$t0, '-'
		
		# We are storing the value of $t0 at the memory location pointed to by $s0.
		sb	$t0, ($s0)
		
		# Increment the value stored in $s0 by 1, to the next memory location.
		addi	$s0, $s0, 1
	
	# if the integer is neg we add a minus sign to the beginning of a string representation of that integer.
	EndCheckNegative:
		
	# reversing the string by popping the elements.
	strReverse(%regStr)
	
	popStack($s0)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro

# specifies the register containing the address of the string.
.macro length(%regStr)
	pushStack($t0)
	pushStack($t1)
	pushStack($s0)
	
	
	li	$t0, -1  #   sets the value of the $t0 register to -1
	move	$s0, %regStr #  loads the address of the string into the $s0 register.
	lb	$t1, ($s0) #    loads the first byte of the string (at the address stored in $s0) into the $t1 register.
	
	# we check length=0
	li	$v0, 0	   # Set the initial value of the length to 0
	beq	$t1, 0, EndStrlen  # Check if the input string pointer is null, if so, jump to the end

	
	LoopStrlen:
		addi	$t0, $t0, 1 # Increment the length counter
		lb 	$t1, ($s0)  # Load the byte at the current string position into t1
		addi	$s0, $s0, 1  # Increment the string pointer to point to the next byte
		
		bne	$t1, $zero, LoopStrlen # If the byte is not null, continue looping
	move	$v0, $t0
	
	EndStrlen:
	
	popStack($s0)
	popStack($t1)  # Restore the original values of the registers from the stack
	popStack($t0)
.end_macro

# str we check all alpha numbers
.macro num(%regStr)
	pushStack($t0)
	pushStack($s0)
	
	# we calculate the number of loops
	li	$t0, 0
	move	$s0, %regStr
	
	LoopCheckAlnum:
		# break
		lb	$t0, ($s0)
		
		# we check that it is smaller than zero
		blt	$t0, 48, alnumFalse
		
		# we check > '9' & < 'A' 
		bgt	$t0, 57, CheckSmallerA
		j CheckNext1
		CheckSmallerA:
			blt	$t0, 65, alnumFalse
		
		CheckNext1:
		# we check > 'Z' & < 'a'	
		bgt	$t0, 90, CheckSmallera
		j CheckNext2
		CheckSmallera:
			blt	$t0, 97, alnumFalse
			
		# we check > 'z'
		CheckNext2:	
		bgt	$t0, 122, alnumFalse
			
		# address
		addi	$s0, $s0, 1
		lb	$t0, ($s0)
		
		# loop
		bne	$t0, $zero, LoopCheckAlnum
	
	alnumTrue:
		li	$v0, 1
		j EndCheckAlnum
	
	alnumFalse:
		li	$v0, 0
		j EndCheckAlnum
		
	EndCheckAlnum:
	
	popStack($s0)
	popStack($t0)
.end_macro

# all elements in the array are equal to char
.macro string(%regStr, %char, %len)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($s0)
	
	add	$t0, $zero, %len
	beq	$t0, $zero, EndInitString
	
	li	$t2, 0
	add	$t1, $zero, %char
	move	$s0, %regStr
	
	LoopInitString:
		#  we save the character here
		sb	$t1, ($s0)
		
		# we are increasing the count by 1
		addi	$t2, $t2, 1
		
		# We are incrementing the address by 1
		addi	$s0, $s0, 1
		
		# looping through
		blt	$t2, $t0, LoopInitString

	sb	$zero, ($s0)
	
	EndInitString:
	
	popStack($s0)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro

# Now: here we are comparing strings regStr1 is the 1st string rand egStr2 is the 2nd string 
#  Ok so if it is not equal; if v0 = 0 Equal if v0=1  we return
.macro compare(%regStr1, %regStr2)
	pushStack($t0)
	pushStack($t1)
	pushStack($s0)
	pushStack($s1)
	
	# ilk
	move	$s0, %regStr1
	move	$s1, %regStr2
	
	# we check length
	length($s0)
	move	$t0, $v0
	
	length($s1)
	move	$t1, $v0
	bne 	$t0, $t1, StrNotEqual

	LoopStrCmp:
		# here we are loading
		lb	$t0, ($s0)
		lb	$t1, ($s1)
		
		# addresses
		addi	$s0, $s0, 1
		addi 	$s1, $s1, 1
		
		bne	$t0, $t1, StrNotEqual
		
		bne	$t0, $zero, LoopStrCmp
	
	StrEqual:	
		li	$v0, 1
		j EndStrCmp
		
	StrNotEqual:	
		li	$v0, 0
		j EndStrCmp
		
	EndStrCmp:
	
	popStack($s1)
	popStack($s0)
	popStack($t1)
	popStack($t0)
.end_macro

# we find the first character to appear
# Ok so  we start from the position of our input
.macro find(%regStr, %posStart, %char)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($s0)
	
	add	$t0, $zero, %posStart
	add	$t1, $zero, %char
	move	$s0, %regStr
	add	$s0, $s0, %posStart
	
	addi	$t0, $t0, -1
	lb	$t2, ($s0)
		
	#  we check if  null
	li	$v0, -1
	beq	$t2, $zero, EndStrFind
	LoopStrFind:
		# loading a character
		lb	$t2, ($s0)
		
		# increasing the count
		addi	$t0, $t0, 1
		
		# we are increasing the address
		addi 	$s0, $s0, 1
		
		# Condition break
		beq	$t2, $t1, CharFound
	
		# looping condition
		bne	$t2, $zero, LoopStrFind
	
	beq	$t2, $zero, CharNotFound
	
	CharFound:
		move	$v0, $t0
		j EndStrFind
		
	CharNotFound:
		li	$v0, -1
		j EndStrFind
		
	EndStrFind:
	
	popStack($s0)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro

# here I am copying string from posStart to posend
.macro substr(%dstStr, %srcStr, %posStart, %num)
	pushStack($t0)
	pushStack($t1)
	pushStack($s0)
	pushStack($s1)
	
	move	$s0, %dstStr
	# address of dstStr destional string
	move	$s1, %srcStr
	# srcStr source string's address
	add	$s1, $s1, %posStart
	li	$t0, 0
	
	# i'm copying my loop
	LoopSubstr:
		#  saving the character
		lb	$t1, ($s1)
		sb	$t1, ($s0)
		
		# the number of my saved characters
		addi	$t0, $t0, 1
		
		# addresses
		addi	$s0, $s0, 1
		addi	$s1, $s1, 1
		
		# looping through
		bne	$t0, %num, LoopSubstr
	
	sb	$zero, ($s0)	
	
	popStack($s1)
	popStack($s0)
	popStack($t1)
	popStack($t0)
.end_macro

# I'm reversing my strings
.macro strReverse(%regStr)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	pushStack($s0)
	pushStack($s1)
	
	move	$s0, %regStr
	move	$s1, %regStr
	
	# the length of my string
	length(%regStr)
	move	$t1, $v0
	
	# end of my address
	add	$s1, $s1, $t1
	addi	$s1, $s1, -1
	
	# cycle count
	addi 	$t1, $t1, -1
	srl	$t1, $t1, 1

	li	$t0, -1
	
	LoopStrReverse:
		# I am uploading
		lb	$t2, ($s0)
		lb	$t3, ($s1)
		
		# I swap
		swap($t2, $t3)
		
		# I am recording
		sb	$t2, ($s0)
		sb	$t3, ($s1)
		
		# incrementing
		addi	$t0, $t0, 1
		
		# I reduce my address by 1
		addi	$s0, $s0, 1
		addi 	$s1, $s1, -1
		
		#  looping through
		bne	$t0, $t1, LoopStrReverse
		
	popStack($s1)
	popStack($s0)
	popStack($t3)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro

# I am getting array from the string
.macro getstr(%dstString, %srcString, %delim, %num)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($s0)
	pushStack($s1)
	pushStack($s2)
	pushStack($s3)
	
	move	$s0, %dstString
	move	$s1, %srcString
	add	$s2, $zero, %delim
	add	$s3, $zero %num
	
	li	$t0, -1 
	li	$t1, 0 
	li	$t2, 0 
	LoopGetStr:
		addi	$t0, $t0, 1
		find($s1, $t0, $s2)
		move	$t1, $v0
		
		beq	$t1, -1, NotFoundDelim
		beq	$t2, $s3, FoundDelim
		
		move	$t0, $t1
		addi	$t2, $t2, 1
		
		beq	$zero, $zero, LoopGetStr
		
	NotFoundDelim:
		length($s1)
		move	$t1, $v0
		li	$v0, -1
		j 	EndLoopGetStr
		
	FoundDelim:
		li	$v0, 1	
		
	EndLoopGetStr:
		sub	$t2, $t1, $t0
		substr($s0, $s1, $t0, $t2)
	
	popStack($s3)
	popStack($s2)
	popStack($s1)
	popStack($s0)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro

# Here we are showing  the user the message box when running the game
.macro messagebox(%msgIn, %typeMsg)
	pushStack($a0)
	pushStack($a1)
	
	li	$v0, 55
	move	$a0, %msgIn
	add	$a1, $zero, %typeMsg
	syscall
	
	popStack($a1)
	popStack($a0)
.end_macro


# I am getting the input from the user
.macro inputmessagebox(%msgIn, %msgOut, %maxNum)
	pushStack($a0)
	pushStack($a1)
	pushStack($a2)
	
	li	$v0, 54
	move	$a0, %msgIn
	# msgIn is the address of the message to be displayed on the screen
	move	$a1, %msgOut
	# msgOut my address buffer
	add	$a2, $zero, %maxNum
	# maxNum the maximum number of characters I can read
	syscall
	move	$v0, $a1
		
	popStack($a2)
	popStack($a1)
	popStack($a0)
	
	pushStack($s0)
	pushStack($t0)
	
	move	$s0, %msgOut
	LoopCheckNewLine:
		#  breaking 
		lb	$t0, ($s0)
		beq	$t0, 10, EndCheckNewLine
		
		# adding 1 to the address
		addi	$s0, $s0, 1
		
		bne	$t0, $zero, LoopCheckNewLine
	
	EndCheckNewLine:
		sb	$zero, ($s0)
		
	popStack($t0)	
	popStack($s0)
	
.end_macro

# I show the user my checkbox
.macro confirmbox(%msgIn)
	pushStack($a0)
	
	li	$v0, 50
	move	$a0, %msgIn
	syscall
	move 	$v0, $a0
	
	popStack($a0)
.end_macro

# Converting str int to Integer
.macro int(%intStr)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($s0)
	
	move	$s0, %intStr
	li	$t0, 0
	li	$t1, 10
	li	$t2, 0
	
	LoopConvertStrToInt:
		lb	$t0, ($s0)
		beq	$t0, $zero, EndLoopConvertStrToInt
		
		subi	$t0, $t0, 48
		mult	$t2, $t1
		mflo	$t2
		add	$t2, $t2, $t0 
		
		addi	$s0, $s0, 1
		beq	$zero, $zero, LoopConvertStrToInt
	
	EndLoopConvertStrToInt:
	
	move	$v0, $t2
	
	popStack($s0)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro

# Printing the character
.macro printChar(%char)
	pushStack($a0)
	
	li	$v0, 11
	add	$a0, $zero, %char
	syscall
	
	popStack($a0)
.end_macro

# I am printing the string
.macro printString(%string)
	pushStack($a0)
	
	li	$v0, 4
	move	$a0, %string
	syscall
	
	popStack($a0)
.end_macro

# Printing the integer
.macro printInt(%int)
	pushStack($a0)
	
	li	$v0, 1
	add	$a0, $zero, %int
	syscall
	
	popStack($a0)
.end_macro

# I am printing my const string
.macro printConstString(%string)
	.data
		str:	.asciiz		%string
	.text
		pushStack($a0)
	
		li	$v0, 4
		la	$a0, str
		syscall
	
		popStack($a0)
.end_macro