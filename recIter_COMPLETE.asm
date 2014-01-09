# A Program that takes does recursive and iterative addition
# @author: Monte Nichols
# CS 3340.501
# HW #5

.data 			# let processor know we will be submitting data to program now
input:    .word 4 	# make a 4 byte (32 bit) space in memory for a word with address: input
prompt:   .asciiz 	"\Please Enter a Series of numbers, without spaces, to be added:\n" 
outputI:  .asciiz 	"\Here is the interative sum of what you entered: " 
outputR:  .asciiz	"\Here is the recursive sum of what you entered:  "
NL:	  .asciiz 	"\ \n"
boop:     .asciiz 	"\Boop!\n"       	
.text 			# enables text input/output

main: 
        #-- Prompt the user "Please a Series of numbers, without spaces, to be added:" 
        la $a0, prompt 	# load address prompt from memory and store it into $a0
        jal cout  	# Output Prompt

	#-- Get their input
        la $a0, input 	# sets $a0 to point to the space allocated for writing a word
        la $a1, input 	# gets the length of the space in $a1 so we can't go over the memory limit
        jal cin       	# get input

	#-- Subroutine calls	
	la $a0, input		# load input
	jal sumItr		# calls our subroutine to turn a String into an Int
	add $s0, $v0, $zero 	#s0 gets out return value 	
	
	la $a0, input		# load input
	jal sumRec		# call function
	add $s1, $v0, $zero	# s1 gets our return value
	
	#-- Output to the user "Here is what you typed in, added iteratively: "
        la $a0, outputI	# load address output from memory and store it into $a0
        jal cout	# Output outputI      
	
	#-- Output the integer        
        add $a0, $s0, $zero
        jal coutInt	# output an int
        
        #-- Output to the user a new line
        la $a0, NL 	# load address output from memory and store it into $a0
        jal cout	# Output output
        
        #-- Output to the user "Here is what you typed in, added recursively: "
        la $a0, outputR	# load address output from memory and store it into $a0
        jal cout	# Output output
        
        #-- Output the integer        
        add $a0, $s1, $zero
        jal coutInt     # output an int   

	#-- Exit program
	jal exit        

###############################################################
#--- Subroutine to add numbers iteratively
sumItr: 
	#Setup
    	addi $sp, $sp, -8     	# Make more space on stack pointer    
    	sw   $ra, 4($sp)     	# Save the return Address    	
    	sw   $s1, 8($sp)    	# Save $s1 at first. this is important.     	     	
     	#Setup     	
	add  $s1, $zero, $zero 	# var sum($s1) = 0 and will eventually be returned	
nextCh: 
	lb   $t2, ($a0)		# load first character(byte) into ($t2) 
	beq  $t2, 0x0a, endSumItr # if loaded byte is a line break, end		
	#Caller Save
	addi $sp, $sp, -4  	# create space on the stack pointer
	sw  $ra, 4($sp)  	# save return address
	jal convToInt 		# convert ascii to int
	lw $ra, 4($sp) 	# restore $ra
     	addi $sp, $sp, 4  	# restore stack pointer	
	#Caller Clean		
	add  $s1, $s1, $v0	# Add the integer returned to our final value ($s1)	
	addi $a0, $a0, 1	# i++			
	j nextCh		# do it for the next value		
endSumItr:
	add  $v0, $s1, $zero	# var sum($s1) is returned
	#Cleanup
    	lw   $s1, 8($sp)    	# load back the next saved value    	   
    	lw   $ra, 4($sp)     	# load back the next saved register    
    	addi $sp, $sp, 8    	# load back the stack pointer to the next reference
    	#Cleanup		
	jr $ra			# Exit subroutine
#- End of subroutine strToInt
###############################################################
#--- Subroutine to add numbers recursively
sumRec: 
    	#Setup
    	addi $sp, $sp, -8     	# Make more space on stack pointer    
    	sw   $ra, 4($sp)     	# Save the return Address    	
    	sw   $s1, 8($sp)    	# Save $s1 at first. this is important.    
     	#Setup      	
    	lb   $t2, ($a0)        	# $t2 get's our current value
    	beq  $t2, 0x0a, sumRecEnd #if loaded byte is a line break, end	
    	#Caller Save
    	addi $sp, $sp, -4  	# create space on the stack pointer
	sw   $ra, 4($sp)  	# save return address	
	jal convToInt 		# convert ascii to int	
	lw   $ra, 4($sp) 	# restore $ra
     	addi $sp, $sp, 4  	# restore stack pointer        
        #Caller Clean
        add  $s1, $v0, $zero	# s1 gets a returned integer                                         
    	addi $a0, $a0, 1    	# next element in our array (array[i+1])
    	jal sumRec         	# jal back to sumRec
    	add  $v0, $v0, $s1     	# add $v0 to the next value in stack
recurse: 
    	#Cleanup
    	lw   $s1, 8($sp)    	# load back the next saved value    	   
    	lw   $ra, 4($sp)     	# load back the next saved register    
    	addi $sp, $sp, 8    	# load back the stack pointer to the next reference
    	#Cleanup
    	jr $ra            	# jump under jal sumRec or back to original call
sumRecEnd:            		# Here we start the process of ending things 
    	li   $v0, 0         	# reset $v0 so we can start filling it with values    
    	j recurse        	# jump, to recurse to end the program
#- End Subroutine
###############################################################
#---  Subroutine to convert a Char to Int
convToInt:	
	add $t9, $zero, 0x30 	# var count($t9) gets char 0
nextI:	
	beq $t2, $t9, getVal
	add $t9, $t9, 1	     	# var count($t9) gets char+1	
	j nextI
getVal:
	addi $t9, $t9, -48	# var count($t9) gets an int value (0-1)
	add  $v0, $t9, $zero	# return var num($v0) with the value of count	
	jr $ra
#- End convToInt
###############################################################
#--- Subroutine to output something
cout:	
 	li $v0, 4 	# loads the value 4 into $v0 which is the op-code for print string
        syscall 	# reads register $v0 for op-code, sees 4 and prints the string located in $a0
	jr $ra		# Exit subroutine
#- End of subroutine cout
##############################################################
#--- Subroutine to get input
cin:
	li $v0, 8	# load op-code for getting a string from the user into register $v0
        syscall		# reads register $v0 for op-code, sees 8 and asks user to input a string, places string in reference to $a0
	jr $ra		# Exit subroutine
#- End of subroutine cin
###############################################################
#--- Subroutine to exit
exit:	
 	li $v0, 10	# loads op-code into $v0 to exit program
        syscall 	# reads $v0 and exits program
	#jr $ra		# Exit subroutine
#- End of subroutine exit
##############################################################
#--- Subroutine to output an Int
coutInt:	
 	li $v0, 1	# loads op-code into $v0 to exit program
        syscall 	# reads $v0 and exits program
	jr $ra		# Exit subroutine
#- End of subroutine exit
##############################################################
