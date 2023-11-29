.macro choose(%size)
        pushStack($t7)
        pushStack($t0)
	pushStack($t1)
	pushStack($t2)
	pushStack($a0)
	pushStack($a1)
	pushStack($a2)
	pushStack($a3)

   
        add $t7,$0,%size                 # I'm saving you to t7
        la $t1,sizecur
        lw $t1,sizecur
          #I'm checking if it satisfies the condition (size <= 100)
        li $t2,101                      
        slt $t2,$t7,$t2
        blez $t2,resize                #  $t2=0  size >100
 
         j RanDom
resize:                       # If your size is greater than 100, set your size to 100
         li $t7,100

RanDom:        
          la $a2,arr         
          move $a1,$t7       #The interval set from 0 to the size can have a maximum size of 100
          li $v0,42    
          # It generates a random number and puts it into $a0      
          syscall

          beq $t1,$t7,End           #We are checking it here
          li $t0,0 # count 0
        
       
control:                          
          beq $t0,$t1,Exit
          lw $a3,0($a2)
          bne $a0,$a3,incre
          j RanDom
         
          incre:
          addi $a2,$a2,4
          addi $t0,$t0,1
          j control

          #save the a1 random number
Exit:
        li $t2,4
        mult $t2,$t0
        mflo $t2
        sw $a0,($a2)   # save -> (a$2)
        sub $a2,$a2,$t2   # $a2 = $a2- 4*($t0)
  
         # we increase the index
         addi $t1,$t1,1
         sw $t1,sizecur
         
         move $v0,$a0  # i'm saving v0
         j end_marco
End:
         li $v0,10
          syscall
end_marco:
	popStack($a3)
	popStack($a2)
	popStack($a1)
	popStack($a0)
	popStack($t2)
	popStack($t1)
	popStack($t0)
        popStack($t7)	
.end_macro

.data 
# we are saving the selected random number
      arr: .word 0:100 
 # the array size of the selected random number
      sizecur:.word 0:100
