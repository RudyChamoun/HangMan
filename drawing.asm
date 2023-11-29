#{ Breaf explanation about the code: So the.macro gallowsdesign(%num) establishes the macro gallowsdesign,
# which takes only the number num as an input. This macro is used to generate code that draws a "gallows" graphic for our hangman game}.

# Ok so now we start by pushing registers onto the stack to save their values, and then it jumps to a label named DrawGallowsSC
.macro gallowsdesign(%num)
	pushStack($t0)
	pushStack($s0)
	pushStack($s1)
	pushStack($s2)
	pushStack($s3)
	pushStack($s4)
	pushStack($t9)
	
	# we initializs $t0 with the value of %num. 
	add $t0,$zero,%num 
	
	# it jumps to here depending on the value of $t0, it contains the code to draw the different parts of the gallow
	# e.g.s Drawing of the body,face,the tree,legs,hands and etc.
	DrawGallowsSC:
	
	beq $t0,1,gallowsdesign_1
	beq $t0,2,gallowsdesign_2
	beq $t0,3,gallowsdesign_3
	beq $t0,4,gallowsdesign_4
	beq $t0,5,gallowsdesign_5
	beq $t0,6,gallowsdesign_6
	beq $t0,7,gallowsdesign_7
	
	j EndDrawGallows # if it does not contain the value from 1 to 7 then the macro will jump here and stop
	
	# The first gallow
	gallowsdesign_1:
		# The tree (Gibbet)
		li $s0,10  # x
		li $s1,40  # y
		li $s2,120 # the length of the horizontal line
		li $t9, 0x893BFF # Here we are chosing the colour of the tree (the gibbet)
		horizontalLine($s0, $s2, $s1, $t9) # here we are creating the horizontal line
	
		li $s0,20 	
		li $s1,30	
		li $s2,20	
		li $s3,120	
		rectangle($s0,$s2,$s1,$s3,$t9) # here we are doing the rectangle form
		
		li $t9, 0xFFFF33 # here we are chosing the colour of the horizontal line
		li $s0,30	
		li $s1,80	
		li $s2,20
		horizontalLine($s0, $s2, $s1, $t9) # it calls the horizontalLine and draw it
		# the wood of my tree
		li $s0,65	
		li $s1,20	
		li $s2,30	
		verticalLine($s0,$s1,$s2,$t9) # it calls the vertical line and draw it
		j EndDrawGallows
	gallowsdesign_2:
		# Head of my stickman
		li $t9, 0xF70D1A # here we are choosing the color of the face
		li $s0,65	#x
		li $s1,40	#y
		li $s2,10	
		
		circle($s0,$s1,$s2,$t9) # calling the method circle to draw the circle
		
		li $t9, 0xF70D1A # here we are chosing the colour
		
		# The left eye
		li $s3,63	# x
		li $s4,38	# y
		
		drawPixel($s3,$s4,$t9) # here we are drawing the left eye
		
		# The right eye
		li $s3,67	# this is x
		li $s4,38	# this is y
		
		drawPixel($s3,$s4,$t9) # here we are drawing the right eye
		
		# The mouth of the man
		li $t9, 0x16F529 # here we are choosing the color of the mouth
		li $s0,62	# here the starting x
		li $s1,69	#y
		li $s2,43	# here the ending x
		
		horizontalLine($s0, $s2, $s1, $t9) # here we are calling the method to draw the horizontal line.
		
		j EndDrawGallows
	gallowsdesign_3:
		# The body of the stickman
		li $t9, 0xFFA500 # here we are choosing the color of the BODY
		li $s0,65	
		li $s1,50	
		li $s2,80	
		
		verticalLine($s0,$s1,$s2,$t9) # here we are calling the method to draw the vertical line.
		
		j EndDrawGallows
	gallowsdesign_4:
		# Right hand of the stickman 
		li $s0,65	
		li $s1,55	
		li $s2,13	
		li $t9, 0xE2F516 # the colour of the right hand
		
		lefttoright($s0,$s1,$s2,$t9)
		
		j EndDrawGallows
	gallowsdesign_5:
		# Left hand of the stickman
		li $s0,65	# here to explain: this numbers are used to adjust the hands in the right position
		li $s1,55	
		li $s2,13	
		li $t9, 0xE2F516 # the colour of the left hand
		
		righttoleft($s0,$s1,$s2,$t9) 
		
		j EndDrawGallows
	gallowsdesign_6:
		# Right leg of the stickman
		li $s0,65	
		li $s1,80	
		li $s2,15	#  this numbers are used to adjust the hands in the right position ,
		                 #we cannot chnage the values because it will affect the form
		li $t9, 0xFF0000  # the colour of the right leg
		
		lefttoright($s0,$s1,$s2,$t9)
		
		j EndDrawGallows
	gallowsdesign_7:
		# Left leg of the stickman
		li $s0,65	
		li $s1,80	#  this numbers are used to adjust the hands in the right position
		li $s2,15	
		li $t9, 0xFF0000 # the colour of the left leg
		
		righttoleft($s0,$s1,$s2,$t9)
		
		j EndDrawGallows
	
	EndDrawGallows:
	
	popStack($t9)
	popStack($s4)
	popStack($s3)
	popStack($s2)
	popStack($s1)
	popStack($s0)
	popStack($t0)
.end_macro

# The Drawing of a horizontal line; this method we used it up when we were creating the hangman
.macro horizontalLine(%xStart, %y, %xEnd, %color)
	pushStack($t0)
	pushStack($t1)
	
	add	$t0, $zero, %xStart
	
	LoopDrawHorizontalLine:
		# Here we are drawing the pixels to form the line.
		drawPixel($t0, %y, %color)
		
		# we increase x by one
		addi	$t0, $t0, 1
		
		# Loop on it
		blt	$t0, %xEnd, LoopDrawHorizontalLine
	
	popStack($t1)
	popStack($t0)
.end_macro

# The Drawing of a vertical line; this method we used it up when we were creating the hangman
.macro verticalLine(%x, %yStart, %yEnd, %color)
	pushStack($t0)
	pushStack($t1)
	
	add	$t1, $zero, %yStart
	
	LoopDVL:
		# Here we are drawing the pixels to form the line.
		drawPixel(%x,$t1, %color)
		#  Ok so we are increasing y by 1
		addi	$t1, $t1, 1
		blt	$t1, %yEnd, LoopDVL
	popStack($t1)
	popStack($t0)
.end_macro

# Ok so here this method is drawing the rectangle using the horizontal line function
.macro rectangle(%x1, %y1, %x2, %y2, %color)
	horizontalLine(%x1,%y1,%x2,%color)
	horizontalLine(%x1,%y2,%x2,%color)
	verticalLine(%x1, %y1, %y2, %color)
	verticalLine(%x2, %y1, %y2, %color)
.end_macro

# Ok here we are drawing the circle which is the face of the hangman
.macro circle(%x,%y,%radius,%color) # it takes as parameter x,y, radius and color
	
	pushStack($s0)
	pushStack($s1)
	pushStack($s2)
	pushStack($s3)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	pushStack($t4)
	pushStack($t5)
	pushStack($t6)
	pushStack($t7)
	pushStack($t8)
	pushStack($t9)
    
    	add $s0,$zero,%x # we store the x in the register $s0
	add $s1,$zero,%y # we store the y in the register $s1
	add $s3,$zero,%radius # we store the x in the register $s3
	
 
   	move $t0, $s0            # x0
   	move $t1, $s1            # y0
   	move $t2, $s3            
   	addi $t3, $t2, -1        
   	li   $t4, 0              
   	li   $t5, 1              
   	li   $t6, 1              
   	li   $t7, 0              


   	sll  $t8, $t2, 1         # we are shifting to the left
   	subu $t7, $t5, $t8         

   	# Ok so here While x >= y
    	circleLoop:
    	blt  $t3, $t4, skipCircleLoop    # Ok so If x < y, skip circleLoop

    	#  So here we draw pixels x0 + x, y0 + y
    	addu $s0, $t0, $t3
    	addu $s1, $t1, $t4
    	
	drawPixel($s0,$s1,%color)  # we are calling the method to draw it 

        # Ok so here we draw pixels x0 + y, y0 + x
        addu $s0, $t0, $t4
        addu $s1, $t1, $t3
       	
	drawPixel($s0,$s1,%color)            # we are calling the method to draw it 

        # Ok now we draw pixels x0 - y, y0 + x
        subu $s0, $t0, $t4
        addu $s1, $t1, $t3
        
	drawPixel($s0,$s1,%color)           # we are calling the method to draw it 

        # we are drawing here  pixels x0 - x, y0 + y
        subu $s0, $t0, $t3
        addu $s1, $t1, $t4
      
      	drawPixel($s0,$s1,%color)         # we are calling the method to draw it 

        # x0 - x, y0 - y
        subu $s0, $t0, $t3
        subu $s1, $t1, $t4
      	
	drawPixel($s0,$s1,%color)           # we are calling the method to draw it 

        # x0 - y, y0 - x
        subu $s0, $t0, $t4
        subu $s1, $t1, $t3
       
       	drawPixel($s0,$s1,%color)   # we are calling the method to draw the pixel        

        #  Now we draw the pixels x0 + y, y0 - x
        addu $s0, $t0, $t4
        subu $s1, $t1, $t3
      
      	drawPixel($s0,$s1,%color)          # we are calling the method to draw it 


        # we draw pixels x0 + x, y0 - y
        addu $s0, $t0, $t3   # storing it in $s0
        subu $s1, $t1, $t4   # storing it in $s1
       	
	drawPixel($s0,$s1,%color)          # we are calling the method to draw it  

    	# err <= 0 ise 
   	bgtz $t7, doElse
   	addi $t4, $t4, 1     # so here we are incrementing y
   	addu $t7, $t7, $t6      
    	addi $t6, $t6, 2     
    	j    circleContinue      

    	# err > 0 ise
    	doElse:
    	addi  $t3, $t3, -1        # so here we are decrementing x
    	addi  $t5, $t5, 2      
    	sll   $t8, $t2, 1     
    	subu  $t9, $t5, $t8       
    	addu  $t7, $t7, $t9      

    	circleContinue:
    	# loop
    	j   circleLoop

    	skipCircleLoop:     

    	popStack($t9)
	popStack($t8)
	popStack($t7)
	popStack($t6)
	popStack($t5)
	popStack($t4)
	popStack($t3)
	popStack($t2)
	popStack($t1)
	popStack($t0)
    	popStack($s3)
   	popStack($s2)
    	popStack($s1)
   	popStack($s0)
	
	
.end_macro

# we are drawing a cross from left to right
.macro lefttoright(%x,%y,%length,%color)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	
	add $t0,$zero,%x
	add $t1,$zero,%y
	
	li $t2,0
	looplDrawlrdia:
		drawPixel($t0,$t1,%color)
		# we are incrementing x by one
		addi $t0,$t0,1
		
		# we are incrementing y by one
		addi $t1,$t1,1
		
		addi $t2,$t2,1
		blt	$t2,%length,looplDrawlrdia
		
	popStack($t3)
	popStack($t2)
	popStack($t1)
	popStack($t0)
	
.end_macro

# So here we are drawing a cross from right to left
.macro righttoleft(%x,%y,%length,%color)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	
	add $t0,$zero,%x
	add $t1,$zero,%y
	
	li $t2,0
	looplDrawrldia:
		
		drawPixel($t0,$t1,%color)
		addi $t0,$t0,-1
		addi $t1,$t1,1
	
		addi $t2,$t2,1
		blt	$t2,%length,looplDrawrldia
	
	popStack($t3)
	popStack($t2)
	popStack($t1)
	popStack($t0)
	
.end_macro

.macro drawPixel(%x, %y, %color)
	pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($t3)
	
	add	$t0, $zero, %x
	add	$t1, $zero, %y

	li	$t2, 128
	mult	$t1, $t2
	mflo	$t1
	
	# we are adding x to the result
	add	$t1, $t1, $t0
	
	li	$t2, 4
	mult	$t1, $t2
	mflo	$t1
	
	# Ok in this step we are saving the colour of our pixels
	add	$t2, $zero, %color
	li	$t3, 0x10000000
	add	$t3, $t3, $t1
	sw	$t2, ($t3)
	sub	$t3, $t3, $t1
	
	popStack($t3)
	popStack($t2)
	popStack($t1)
	popStack($t0)
.end_macro