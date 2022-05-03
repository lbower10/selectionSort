#
# Author: Logan Bowers
# Description: This program uses a mySort subroutine that uses
#   a mySwap subroutine to sort an array of values.
# Register Usage: 
# rax and rbx used for exit program system calls
# rsp is the stack pointer
# More register usage documented in subroutine headers below
#

.equ NUM_ELEMENTS, 10
.data
    myArray: .quad 5, -1, 4, 55, -30, 2, 1, 9, -55, 10
.text
.global main
main:
    pushq $myArray  # push address of myArray onto the stack
    pushq $NUM_ELEMENTS # push NUM_ELEMENTS onto stack
    call mySort # call function mySort
    addq $16, %rsp   # get $myArray and $NUM_ELEMENTS off stack
    # End program system calls
    movq $1, %rax
    movq $0, %rbx
    int $0x80
    retq

# mySort: Sorts values in an array
# Parameters
#   The memory address of an array and an int for 
#   the number of elements in that array
# Returns: Nothing
# Register usage:
#   rbp points to stack ptr rsp, 
#   rax holds current minimum, and then is used to get reference to myArray 
#       at index currentMin to push onto stack and call mySwap
#   rbx holds mem address for myArray
#   rdi is used as j in the inner loop
#   r8 is used as i in outer loop
#   r9 holds NUM_ELEMENTS - 1 value
#   r10 holds NUM_ELEMENTS value
#   r11 holds memory address of myArray[currentMin] (myArray at rax)
#   r12 used to get reference to myArray at index i, then pushed onto stack
#       for mySwap call 
#   
#
#
.type mySort, @function
mySort:
    pushq %rbp
    movq %rsp, %rbp # rbp -> rsp    # establish stack frame
    pushq %rax
    pushq %rbx
    pushq %rdi
    pushq %r8       # push used registers
    pushq %r9
    pushq %r10
    pushq %r11
    pushq %r12
    pushfq 
    
    movq $0, %r8    # r8 = 0 (outer for-loop counter)
    movq 16(%rbp), %r9  # r9 = NUM_ELEMENTS
    movq %r9, %r10  # inner loop control: r10 = NUM_ELEMENTS not decremented 
    decq %r9    # r9 = NUM_ELEMENTS - 1
    movq 24(%rbp), %rbx   # rbx points to myArray
    
outerLoop: cmp %r9, %r8     # i > NUM_ELEMENTS - 1? 
    jge sortDone    # sort is done, jump to end of subroutine 
    movq %r8, %rax    # rax = current min index
    movq %r8, %rdi   # rdi is our "j=i+1"
    incq %rdi
    
innerLoop: cmp %r10,%rdi # skipping loop if rdi > r10 = NUM_ELEMENTS - 1
    jge innerLoopDone # jump to innerLoopDone if rdi > r10
    movq (%rbx, %rax, 8), %r11  # r11 = myArray[currentMin] (currentMin = rax)
    cmp (%rbx, %rdi,8), %r11    # comparing myArray[currentMin] to myArray[j]
    jle nextIteration   # if a[currentMin] is less than a[j],jump to next loop nextIteration
    movq %rdi, %rax # currentMin = j
    
nextIteration: incq %rdi    # This is "j++"
    jmp innerLoop # Jump up to main loop for next nextIteration
    
innerLoopDone:
    movq %r8, %r12  # r12 = i 
    imulq $8, %r12 # r12 is now the offset
    addq %rbx, %r12 # get refernce to myArray at index i
    pushq %r12  
    imulq $8, %rax  
    addq %rbx, %rax # get reference to myArray at index currentMin
    pushq %rax
    call mySwap # call mySwap function
    addq $16, %rsp  # go back to stack pointer
    incq %r8    # i++
    jmp outerLoop   # jump back up to outerLoop label for next iteration 

sortDone:
    popfq
    popq %r12
    popq %r11
    popq %r10
    popq %r9            # pop used registers in rev. order
    popq %r8
    popq %rdi
    popq %rbx
    popq %rax
    popq %rbp
    retq

# mySwap: swaps values of two numbers
# Parameters
#   two memory addresses
# Postcondition: parameters values are swapped
# Register usage:
#   ** here, num1 and num2 are myArray[i] and myArray[currentMin]
#   rbp points to rsp, rax to hold first mem address, rcx to hold
#   second mem address, rbx to hold first value, rdx to hold second value,
#   rbp used to point to this subroutine's stack frame
.type myswap, @function
mySwap:
    pushq %rbp  # establish the stack frame
    movq %rsp, %rbp # rbp -> rsp
    pushq %rax
    pushq %rbx      # push used registers
    pushq %rcx
    pushq %rdx
    pushfq
    movq 24(%rbp), %rax # rax = num1 memory address
    movq (%rax), %rbx   # rbx = * rax = num1 actual value
    
    movq 16(%rbp), %rcx # rcx = num2 memory address
    movq (%rcx), %rdx   # rdx = * rcx = num2 actual value
    
    movq %rdx, (%rax)   # moving values into opposite address (num2 to num1)
    movq %rbx, (%rcx)   # num1 to num2 
    
    popfq       # pop used registers in reverse order
    popq %rdx
    popq %rcx
    popq %rbx
    popq %rax
    popq %rbp
    retq
