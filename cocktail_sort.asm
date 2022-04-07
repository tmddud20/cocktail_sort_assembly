.data
	array: .space 256	# Researve a space in RAM for up to 64 integers (64 x 4 bytes = 256)
	msg1: .asciiz ".....Bubble Sort....."
	msg2: .asciiz "\nEnter Input Length: "
	msg3: .asciiz "\nEnter Input Values: "
	msg4: .asciiz "\nSorted Output Values: "
	newl: .asciiz "\n"
	
.text
	main:
		li $v0, 4		# system call to print string
		la $a0, msg1		# load [msg1] addresss to the argument register
		syscall			# execute system call
		
		la $a0, msg2		# load [msg2] address to the argument register
		syscall			# execute system call
		
		li $v0, 5		# system call to get integer from input (inputs length)
		syscall			# execute system call
		move $t0, $v0		# move the input to $t0 (holds value of inputs length)
		
		li $v0, 4		# system call to print string
		la $a0, msg3		# load [msg3] address to argment register
		syscall			# execute system call
		jal newline		# call to new line (save pointer to next instruction)
		
		addi $t1, $zero, 0	# init counter for getting all inputs
		addi $t2, $zero, 0	# init offset address for saving inputs to RAM
		
	inputs:
		beq $t0, $t1, initsort	# start sorting when the counter reaches the total number of desired inputs length
		li $v0, 5		# system call to get input integers
		syscall			# execute system call
		sw $v0, array($t2)	# save the integer to the RAM @ current offset address
		
		addi $t2, $t2, 4	# update offset address counter (add 4 since an integer is 4 bytes)
		addi $t1, $t1, 1	# update input counter
		
		j inputs		# repeat
		
	initsort:
		subi $t0, $t0, 1	# init bubble sort max count (number of adjacent comparisons)
		addi $t1, $zero, 1	# temp value to proceed to next instruction
		addi $t6, $zero, 0		# init variable to division forwoard and backword
	
	reset:				# start of the pass
		beq $t1, 0, innitdisp	# done sorting (no swaps), prep to display
		addi $t1, $zero, 0	# init FLAG for indicating we finished sorting
		addi $t2, $zero, 0	# init offset address counter
		addi $t3, $zero, 0	# init counter [i] for each pass
		
		beq $t6, $zero, initfor		# if $t6 == 0, do forward
		bne $t6, $zero, initback	# if $t6 != 0, do forward
		
	initfor:
		sll $t6, $t0, 2			# get last index of array($t0 = length - 1)
		j forword			# do forward sort
		
	initback:
		addi $t2, $t6, 0		# get first index of array
		addi $t6, $zero, 0		# get first index of array
		j backword			# do forward sort
		
	forword:				# one pass(forward)
		beq $t0, $t3, reset	# if one pass is done, reset
		
		lw $t4, array($t2)	# load left integer
		addi $t2, $t2, 4	# increment offset address
		lw $t5, array($t2)	# load right integer
	
		bgt $t4, $t5, swap1	# check if correct order, if not swap
		
	nexti1:
		addi $t3, $t3, 1	# increment counter [i]
		j forword			# continue forword
		
			
	backword:				# one pass(backword)
		beq $t0, $t3, reset		# if one pass is done, reset
		
		lw $t5, array($t2)		#
		subi $t2, $t2, 4		#
		lw $t4, array($t2)		#
	
		bgt $t4, $t5, swap2		# check if correct order, if not swap
		
	nexti2:
		addi $t3, $t3, 1	# increment counter [i]
		j backword			# continue forword
				
	swap1:					# swap elements
		subi $t2, $t2, 4	# decrement address offset
		sw $t5, array($t2)	# store integer to lower address
		addi $t2, $t2, 4	# increment address offset
		sw $t4, array($t2)	# store integer to higher address
		addi $t1, $t1, 1	# indicate swap
		j nexti1
		
	swap2:					# swap elements
		addi $t2, $t2, 4		#
		sw $t4, array($t2)	#
		subi $t2, $t2, 4	#
		sw $t5, array($t2)	#
		addi $t1, $t1, 1	#
		j nexti2
		
	innitdisp:
		addi $t0, $t0, 1	# init display max count (back to length of inputs)
		addi $t1, $zero, 0	# init display counter
		addi $t2, $zero, 0	# init address offset
		
		li $v0, 4		# system call to print string
		la $a0, msg4		# load [msg4] address to argument register
		syscall			# execute system call
		jal newline		# call newline	
		
	display:
		beq $t0, $t1, end
		
		li $v0, 1
		lw $a0, array($t2)
		syscall
		jal newline
		addi $t2, $t2, 4
		addi $t1, $t1, 1
		
		j display
		
	newline:
		li $v0, 4
		la $a0, newl
		syscall
		jr $ra
		
	end:
		li $v0, 10
		syscall
