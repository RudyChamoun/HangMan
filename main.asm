# Computer Organisation Final Project
# Lebanese American University
# Developers : Roudy Chamoun, Karim Chalabi
# Game Description(line 5 to 8)  : Hangman Simulator 
# A random word is selected from our text file (every run of the game a different word is chosen)
# The user tries to guess the word after entering their name. (he can either choose to guess the entire word at once or letter by letter)
# The user has 7 allowed wrong guesses before the man HANGS !!
# The man hangs on the 7th wrong and it's game over.

# In order to visualise the man hanging, you'll need to use the Bitmap Display 

# Settings in Bitmap Display (line 13 to 17)
# unit width : 2
# unit height: 2
# display width: 256
# display height: 256
# base address: $gp (10000000)
# One last step is to connect the Bitmap Display to MIPS and run the code
# IMPORTANT NOTICE : check line 587 and adjust the path for the game to run on your computer

# Good Luck Dr :)


# These files should be on your device in order to run it

.include "method.asm"
.include "track_record.asm"
.include "drawing.asm"
.include "choose_word.asm"



	
.text
main:
	# The part where the game will greet you.
	la	$a0, helloGame
	messagebox($a0, 1)
	
	# The part where the player enters their name
	InputPlayerName:
		la	$a0, askPlayerName
		la	$a1, playerName
		# we store the name given by the user in $a1
		inputmessagebox($a0, $a1, 20)
		num($a1)
		beq	$v0, 0, InputPlayerName
	
	# we count the words present in the text file from wich to the word will be chosen
	li	$s0, 0
	la	$a0, tempStr
	
	Dictionary:
		
		getline($s0, $a0, ',', wordbox)
		beq	$v0, -1, EndDictionary
		addi	$s0, $s0, 1
		j	Dictionary
		
	EndDictionary:
	sw	$s0, numWordDictionary

Hangman:
	# We are clearing the screen
	li	$a0, 0
	li	$a1, 0
	
	LoopYClearScreen:
		LoopXClearScreen:
			drawPixel($a0, $a1, 0x00000000)
			addi	$a0, $a0, 1
			blt	$a0, 128, LoopXClearScreen
			
		li	$a0, 0
		addi	$a1, $a1, 1
		blt	$a1, 128, LoopYClearScreen
	
	# Here we are taking the "secret" word that will be unkown to the user (represented in xxx)
	la	$a0, hiddenWord
	lw	$a1, numWordDictionary
	
	choose($a1)
	move	$s0, $v0
	getline($s0, $a0, ',', wordbox)
	
	# We're making a guess
	length($a0)
	move	$t0, $v0
	la	$a0, guessWord 
	
	string($a0, 'x', $t0)
	# At every iteration the user is given a choice to either guess a letter or the entire word at once		
	LoopGuessOneWord:
		# This is where the choice is given to the user
		la	$a0, guessWord
		messagebox($a0, 1)
		
		# We are making a choice
		la	$a0, chooseGuessWord
		confirmbox($a0)
		move	$a0, $v0
		# According to the choice, we follow a path to guess a character or word
		beq	$a0, 0, InputGuessOneWord
		beq	$a0, 1, InputGuessOneChar
		
		j	InputGuessOneChar
		
		# the below code is in case the user chooses to guess a word deghre
		InputGuessOneWord:
			la	$a0, askInputWord
			la	$a1, guessWord
			inputmessagebox($a0, $a1, 10)
			# We are checking whether it is correct or not (for the word)
		j	_CheckGuessWord
		
		# the below code is the other case where the user chooses to guess a letter
		InputGuessOneChar:
			la	$a0, askInputChar
			la	$a1, tempStr
			inputmessagebox($a0, $a1, 5)
			lb	$a0, 0($a1)
			sb	$a0, guessChar
			# We are checking whether it is correct or not (for the letter)
			#If the letter is in the secret word, it is indicated by writing it down(it appears instead of xxx)
		j	_CheckGuessChar
			
# This is the part where we check for the word		
_CheckGuessWord:
	la	$a0, hiddenWord # The secret word (the answer)
	la	$a1, guessWord #the user's guess
	
	# First of all, I am thinking of two values ??to evaluate whether they are equal or not
	# Compare (the secret word and the guessed word).
	
	compare($a0, $a1)
	beq	$v0, 1, GuessWordRight 
	j 	GuessWordWrong
	
	#The below code is for when the user guesses the entire word correct at once	
	GuessWordRight:
		
		# Note : right word
		la	$a0, notiRightWord
		messagebox($a0, 1)
		
		# we reset to 0
		sb	$zero, playerStatus
		
		# score
		lw	$a0, playerScore
		la	$a1, hiddenWord
		length($a1)
		add	$a0, $a0, $v0
		sw	$a0, playerScore
		
		#  Count : right word
		lw	$a0, playerWord
		addi	$a0, $a0, 1
		sb	$a0, playerWord
		
		# We continue the game and allow the user to play again
		j Hangman
		
	# When we follow the wrong word, unfortunately, our man is hanged directly (no 7 guesses in this case)		
	GuessWordWrong:
	
		# We are saving the player
		la	$a0, playerName
		saveString($a0, 1, dataPlayer)
		saveChar('-', 1, dataPlayer)
		
		lw	$a0, playerScore
		la	$a1, tempStr
		toString($a1, $a0)
		saveString($a1, 1, dataPlayer)
		saveChar('-', 1, dataPlayer)
		
		lw	$a0, playerWord
		toString($a1, $a0)
		saveString($a1, 1, dataPlayer)
		saveChar('*', 1, dataPlayer)
		
		# status player = 7
		li	$a0, 7
		sb	$a0, playerStatus
		
		# We are displaying on the screen
		j	_Lose
		
#The part where we check if the letter guessed by the user exists in our word or not	
_CheckGuessChar:

	# We are checking whether the full character is filled or not and comparing it with the secret word
	
	la	$a0, hiddenWord
	la	$a1, guessWord

	find($a1, 0, 'x')  #I am getting a letter from the user where every x represents a letter in the guide you see
	beq	$v0, -1, _CheckGuessWord
	  
	# The part where we check the secret word containing the guessed character.
	lb	$a0, guessChar
	la	$a1, hiddenWord
	
	find($a1, 0, $a0)
	
	beq	$v0, -1, Nothidden 
	j	hidden
	
	Nothidden:
		lb	$a0, playerStatus
		addi	$a0, $a0, 1
		sb	$a0, playerStatus
		
		beq	$a0, 7, GuessWordWrong
		
		# Show the wrong answer
		la	$a0, notiWrongChar
		messagebox($a0, 0)
		
		# The mistakes I make here will affect me in hanging the man
		
		jal	_DrawPlayerStatus
	
		# Jumping back to Loop Guess One word to guess the word
		j	LoopGuessOneWord
		
	hidden:
		# My total values are a guessable word, a correct letter, and a hidden word. We will proceed with these
		la	$a0, guessWord
		lb	$a1, guessChar
		la	$a2, hiddenWord
		
		li	$t0, -1
		
		LoopFillChar:
			# prevPos + 1 = posStartFind 
			addi	$t0, $t0, 1
			
			# We are finding a positive character in the secret word
			find($a2, $t0, $a1)
			move	$t0, $v0
			
			# We are saving the guessed one
			add	$a0, $a0, $t0
			sb	$a1, ($a0)
			sub	$a0, $a0, $t0
				
			bne	$t0, -1, LoopFillChar
			
		compare($a0, $a2)
		beq	$v0, 1, GuessWordRight
		# I am going back to guessing the word
		j	LoopGuessOneWord

# Here, we will draw the man according to the user's wrong guesses
_Lose:
		
		# I am drawing the man
		jal 	_DrawPlayerStatus
		
		la	$a0, notiLostGame
		messagebox($a0, 0)
		
		# We are showing the player their score
		la	$a0, notiInfor
		printString($a0)
		la	$a0, notiName   #We assign the name to a0
		la	$a1, notiScore  #We assign the score they have won to a1
		la	$a2, notiWord   #We assign the words they have guessed correctly to a2 
		#We print a0,a1,a2
		printString($a0)
		printString($a1)
		printString($a2)
		
		la	$a0, playerName
		lw	$a1, playerScore
		lw	$a2, playerWord
		printString($a0)
		printChar('\t')
		printInt($a1)
		printChar('\t')
		printInt($a2)
		printChar('\n')
		
		# reset 
		sb	$zero, playerStatus
		sw	$zero, playerScore
		sw	$zero, playerWord
		
		# Here we are asking the user if they want to quit the game
		la	$a0, askStatusGame
		confirmbox($a0)
		
		# If they want to quit, we show the scores, names, and number of words guessed of the top 10 players
		beq	$v0, 0, Hangman
		
		j	_BestPlayer	
									
_DrawPlayerStatus:
	pushStack($ra)
	pushStack($t0)
	#Our man consists of 7 parts, the hanging parts
	lb	$t0, playerStatus
	
	#Based on the status, we start the hanging process
	beq	$t0, 1, draw1
	beq	$t0, 2, draw2
	beq	$t0, 3, draw3
	beq	$t0, 4, draw4
	beq	$t0, 5, draw5
	beq	$t0, 6, draw6
	beq	$t0, 7, draw7
	j 	EndDraw
	
	draw7:  gallowsdesign(7)
	draw6:  gallowsdesign(6)
	draw5:  gallowsdesign(5)
	draw4:  gallowsdesign(4)
	draw3:  gallowsdesign(3)
	draw2:  gallowsdesign(2)
	draw1:  gallowsdesign(1)
	
	EndDraw:
	
	popStack($t0)
	popStack($ra)
	
	jr	$ra
	
_BestPlayer:
	# Number the players
	li	$s0, 0
	la	$a0, tempStr
	
	LoopCountPlayer:
		# Separate the players with an asterisk (*)
		getline($s0, $a0, '*', dataPlayer)
		beq	$v0, -1, EndLoopCountPlayer
		addi	$s0, $s0, 1
		j	LoopCountPlayer
		
	EndLoopCountPlayer:
	sw	$s0, numPlayer
	
	# dynamic allocation
	li	$gp, 0x10040000 # heap
	lw	$s0, numPlayer
	
	# player name
	mul	$t0, $s0, 24   # Each name has a length of 20 and one empty space
	sw	$gp, allPlayerNameBuffPtr
	add	$gp, $gp, $t0

	# score
	mul	$t0, $s0, 4   # 1 score = 1 word = 4 bytes
	sw	$gp, allPlayerScorePtr
	add	$gp, $gp, $t0
	
	# ptr name
	sw	$gp, allPlayerNamePtr
	add	$gp, $gp, $t0

	# number word
	sw	$gp, allPlayerWordPtr
	add	$gp, $gp, $t0

	# Loading my data
	li	$s1, 0
	la	$a0, tempStr
	lw	$a1, allPlayerNamePtr
	lw	$a2, allPlayerScorePtr
	lw	$a3, allPlayerWordPtr
	lw	$s0, allPlayerNameBuffPtr
	
	# Reading from file since I was keeping players and their scores in a file
	LoopReadDataPlayer:
		# Each player is separated by *
		getline($s1, $a0, '*', dataPlayer)
		beq	$v0, -1, EndLoopReadDataPlayer
		
		# Getting the player's name
		getstr($s0, $a0, '-', 0)
		sw	$s0, ($a1)
		addi	$s0, $s0, 24
		addi	$a1, $a1, 4
		
		# Getting their score
		getstr($a2, $a0, '-', 1)
		int($a2)
		sw	$v0, ($a2)
		lw	$s3, ($a2)
		addi	$a2, $a2, 4
		
		# I am getting the number of words the player guessed correctly.
		getstr($a3, $a0, '-', 2)
		int($a3)
		sw	$v0, ($a3)
		addi	$a3, $a3, 4
		
		addi	$s1, $s1, 1
		# I am repeating this for each player
		j	LoopReadDataPlayer
		
	EndLoopReadDataPlayer:
	
	# This is the part where I will sort the players in order
	lw	$a0, allPlayerNamePtr
	lw	$a1, allPlayerScorePtr
	lw	$a2, allPlayerWordPtr


	li	$t0, 0 # i
	li	$t1, 0 # j
	li	$t2, 0 # max_index
	lw	$t3, numPlayer
	li	$t4, 0 # address arr[j]
	li	$t5, 0 # address arr[min_index]
	li	$t6, 4
	li	$s0, 0
	li	$s1, 0
	li	$s2, 0
	
	LoopForI:
		move	$t2, $t0
		bge	$t0, $t3, EndLoopForI
		
		move	$t1, $t0
		LoopForJ:
			
			bge	$t1, $t3, EndLoopForJ 
			
			# Calculate the elements of the address array
			mult	$t1, $t6
			mflo	$t4
			
			mult	$t2, $t6
			mflo	$t5
			
			# Compare and modify (max_index).
			add	$a1, $a1, $t4
			lw	$s0, ($a1)
			sub	$a1, $a1, $t4
			
			add	$a1, $a1, $t5
			lw	$s1, ($a1)
			sub 	$a1, $a1, $t5
		
			bgt 	$s0, $s1, ChangeMaxIndex 
			j 	IncreaseJ
			
			ChangeMaxIndex:
				move	$t2, $t1
				
			IncreaseJ:
				addi	$t1, $t1, 1
				
			beq	$zero, $zero, LoopForJ
		EndLoopForJ:
		
		# change
		mul	$t4, $t2, 4
		mul	$t5, $t0, 4
		
		# the part where i change the name
		add	$a0, $a0, $t4
		lw	$s0, ($a0)
		sub	$a0, $a0, $t4
	
		add	$a0, $a0, $t5
		lw	$s1, ($a0)
		sub	$a0, $a0, $t5
		
		swap($s0, $s1)
		
		add	$a0, $a0, $t4
		sw	$s0, ($a0)
		sub	$a0, $a0, $t4
		
		add	$a0, $a0, $t5
		sw	$s1, ($a0)
		sub	$a0, $a0, $t5
		
		#the part where I change the score
		add	$a1, $a1, $t4
		lw	$s0, ($a1)
		sub	$a1, $a1, $t4
		
		add	$a1, $a1, $t5
		lw	$s1, ($a1)
		sub	$a1, $a1, $t5
		
		swap($s0, $s1)
		
		add	$a1, $a1, $t4
		sw	$s0, ($a1)
		sub	$a1, $a1, $t4
		
		add	$a1, $a1, $t5
		sw	$s1, ($a1)
		sub	$a1, $a1, $t5
		
		# the part I changed according to the words they guessed
		add	$a2, $a2, $t4
		lw	$s0, ($a2)
		sub	$a2, $a2, $t4
		
		add	$a2, $a2, $t5
		lw	$s1, ($a2)
		sub	$a2, $a2, $t5
		
		swap($s0, $s1)
		
		add	$a2, $a2, $t4
		sw	$s0, ($a2)
		sub	$a2, $a2, $t4
		
		add	$a2, $a2, $t5
		sw	$s1, ($a2)
		sub	$a2, $a2, $t5
		
		
		addi	$t0, $t0, 1
		
		beq	$zero, $zero, LoopForI
	EndLoopForI:		
	
	# print header
	printConstString("\n BEST PLAYERS ! \n")
	la	$a0, notiName
	la	$a1, notiScore
	la	$a2, notiWord

	printString($a0)
	printString($a1)
	printString($a2)
	
	# print best players
	li	$t0, 0
	lw	$t1, numPlayer
	lw	$a0, allPlayerNamePtr
	lw	$a1, allPlayerScorePtr
	lw	$a2, allPlayerWordPtr
	bgt	$t1, 10, Assign10
	j 	LoopPrintBest
	
	Assign10:
		li	$t1, 10

	LoopPrintBest:
		# load data
		lw	$s0, ($a0)
		lw	$s1, ($a1)
		lw	$s2, ($a2)
		
		# print data
		printString($s0)
		printChar('\t')
		printInt($s1)
		printChar('\t')
		printInt($s2)
		printChar('\n')
		
		# I am increasing the address
		addi	$a0, $a0, 4
		addi	$a1, $a1, 4
		addi	$a2, $a2, 4
		
		
		addi 	$t0, $t0, 1
		
		
		blt	$t0, $t1, LoopPrintBest
	# reset	
	li	$sp, 0x10040000 
.data
#We are directing questions to our user here. If the user wants, they can choose to receive a letter or take the risk and try to guess the whole word, but remember, if they make a wrong guess, our hangman will be completely hanged!
	helloGame:		.asciiz 	"Welcome to the game Hangman"
	askPlayerName:		.asciiz		"Please enter your name"
	askInputChar:		.asciiz		"Please enter the letter"
	askInputWord:		.asciiz		"What is the word??"
	askStatusGame:		.asciiz 	"Do you want to play again ?"
	chooseGuessWord:	.asciiz		"Do you want to enter words?"
	notiLostGame:		.asciiz		"Incorrect Guess ! Game Over "
	notiRightWord:		.asciiz 	"That's right, well done !!"
	notiWrongChar:		.asciiz		"Wrong guess ;)"
	#keep in mind that the path of wordbox.txt in the below line may differ once you open it on your computer !!!
	wordbox:		.asciiz 	"C:/Users/user/Desktop/Spring23/Computer Organization/Final project/Hangman Game Submission/words.txt"
	dataPlayer:		.asciiz		"playerinfo.txt"                     # We will keep the information of the players who play our game here
	
	notiInfor:		.asciiz		"Player's infor\n"
	notiName:		.asciiz		"Player Name\t"
	notiScore:		.asciiz		"Player Score\t"
	notiWord:		.asciiz		"Number of word\n"
	
	allPlayerNameBuffPtr:	.word		0
	allPlayerNamePtr:	.word		0	
	allPlayerScorePtr:	.word		0	
	allPlayerWordPtr:	.word		0	
	numWordDictionary:	.word		0
	numPlayer:		.word		0
	
	hiddenWord:		.space		12
	guessWord:		.space		12
	guessChar:		.space		4
	tempStr:		.space		48
	playerName:		.space		24
	playerScore:		.word		0
	playerWord:		.word		0
	playerStatus:		.word		0
