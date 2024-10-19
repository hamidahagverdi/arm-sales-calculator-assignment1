.text
    .global _start

/*
 * This is where the program starts.
 * First, it sets up important variables like the total sales for all 5 days,
 * as well as the highest (max) and lowest (min) sales recorded.
 * The program then processes sales data for each of the 5 days.
 * After that, it calculates the total sales, finds the average sales per day, 
 * and identifies the highest and lowest sales amounts across all days.
 */

_start:
    @ Set total sales to 0. This variable will keep track of the total amount of sales made over all 5 days.

    LDR R0, =total_sales      @ Get the memory address where the total sales will be stored and put it into register R0
    MOV R1, #0                @ Put the number 0 into register R1, so we can use it to start total sales at 0
    STR R1, [R0]              @ Store the value 0 from R1 into the memory location for total_sales

    @ Set max sales to 0. This will keep track of the highest sales amount, starting at 0 since all sales are positive.
    LDR R0, =max_value        @ Get the memory address where the max sales will be stored and put it into register R0
    STR R1, [R0]              @ Store the value 0 from R1 into the memory location for max_value, so the max sales start at 0

    @ Set min sales to 0xFFFFFFFF. This will keep track of the lowest sales amount, starting at the largest possible number.
    LDR R0, =min_value        @ Get the memory address where the min sales will be stored and put it into register R0
    MVN R1, #0                @ MVN means move NOT, so this sets R1 to all 1's (0xFFFFFFFF, the highest possible value)
    STR R1, [R0]              @ Store this very large number (0xFFFFFFFF) into the memory location for min sales, so any actual sales will be lower

    @ Now we will process the sales data for each day, starting with day 1
    LDR R0, =day1             @ Get the memory address of day 1’s sales data and put it into register R0
    BL process_day            @ Branch with link to the process_day function to handle the sales data for day1

    @ Now do the same for day 2
    LDR R0, =day2             @ Get the memory address of day 2’s sales data and put it into register R0
    BL process_day            @ Call process_day to process day2 sales data

    @ Now do the same for day 3
    LDR R0, =day3             @ Get the memory address of day 3’s sales data and put it into register R0
    BL process_day            @ Call process_day to process day3

    @ Now do the same for day 4
    LDR R0, =day4             @ Get the memory address of day4's sales data and put it into register R0
    BL process_day            @ Call process_day to process day4

    @ Now do the same for day 5
    LDR R0, =day5             @ Get the memory address of day5's sales data and put it into register R0
    BL process_day            @ Call process_day to process day5

    @ After processing all 5 days, we calculate the average sales using repeated subtraction
    LDR R1, =total_sales      @ Load the address of total_sales into R1
    LDR R2, [R1]              @ Load the actual total sales value into R2
    MOV R3, #5                @ Set R3 to 5 because there are 5 days, which is the divisor
    MOV R4, #0                @ Initialize R4 to 0. This will hold the result of the division (the average)
    MOV R5, R2                @ Copy the total sales value into R5, so we can subtract from it

    @ Now we perform repeated subtraction to calculate the integer division (average sales)
div_loop:
    CMP R5, R3                @ Compare the total sales left in R5 to 5 (the divisor)
    BLO div_end               @ If R5 is less than 5, we’re done with the division, so branch to div_end
    SUB R5, R5, R3            @ Subtract 5 from R5 (the total sales) to simulate division
    ADD R4, R4, #1            @ Increment R4, which is counting how many times we can subtract 5 (this is the quotient)
    B div_loop                @ Branch back to the top of the loop to repeat until R5 < 5

div_end:
    LDR R6, =average_sales    @ Load the address of average_sales into R6
    STR R4, [R6]              @ Store the quotient (R4) into the average_sales memory location

    @ Load the final min and max sales values into registers (for future use or output)
    LDR R7, =min_value        @ Load the address of min_value into R7
    LDR R7, [R7]              @ Load the actual min_value into R7
    LDR R8, =max_value        @ Load the address of max_value into R8
    LDR R8, [R8]              @ Load the actual max_value into R8

    B end_program             @ Jump to end_program (infinite loop) to finish the program

/*
 * process_day: This subroutine processes the sales data for a single day.
 * It reads sales data (terminated by a 0), updates the total sales, and checks if each value is a new max or min.
 * Input: R0 - The pointer to the current day's sales data (array of numbers ending with 0)
 */
process_day:
    PUSH {R4-R7, LR}          @ Save registers R4 to R7 and the return address (LR) on the stack for use in the subroutine

process_day_loop:
    LDR R1, [R0], #4          @ Load the next sales value from memory into R1, then increment R0 to point to the next value
    CMP R1, #0                @ Check if the loaded value is 0 (0 indicates the end of the sales data)
    BEQ process_day_end       @ If the value is 0, we are done processing this day's data, so branch to process_day_end

    @ Update the total sales with the current sales value (R1)
    LDR R2, =total_sales      @ Load the address of total_sales into R2
    LDR R3, [R2]              @ Load the current total_sales value into R3
    ADD R3, R3, R1            @ Add the current sales value (R1) to the total sales (R3)
    STR R3, [R2]              @ Store the updated total_sales value back into memory

    @ Check if the current sales value (R1) is greater than the current max sales value
    LDR R4, =max_value        @ Load the address of max_value into R4
    LDR R5, [R4]              @ Load the current max_value into R5
    CMP R1, R5                @ Compare the current sales value (R1) with the max_value
    BHI update_max            @ If the current sales value is higher, branch to update_max to update max_value
    B skip_max_update         @ Otherwise, skip to skip_max_update

update_max:
    STR R1, [R4]              @ Store the new maximum sales value (R1) into max_value

skip_max_update:
    @ Check if the current sales value (R1) is smaller than the current min sales value
    LDR R6, =min_value        @ Load the address of min_value into R6
    LDR R5, [R6]              @ Load the current min_value into R5
    CMP R1, R5                @ Compare the current sales value (R1) with the min_value
    BLO update_min            @ If the current sales value is lower, branch to update_min to update min_value
    B skip_min_update         @ Otherwise, skip to skip_min_update

update_min:
    STR R1, [R6]              @ Store the new minimum sales value (R1) into min_value

skip_min_update:
    B process_day_loop        @ Loop back to process the next sales value for the day

process_day_end:
    POP {R4-R7, PC}           @ Restore the saved registers and return from the subroutine

end_program:
    B end_program             @ Infinite loop to mark the end of the program (can replace with exit logic)

.data
    .align 4

@ Data section where we define the sales data for each day, with a 0 at the end of each day’s data to show it's finished
day1:
    .word 5, 10, 15, 0        @ This is the sales data for day 1, with a 0 at the end to indicate that there are no more sales for this day

day2:
    .word 8, 12, 0            @ This is the sales data for day 1, with a 0 at the end to indicate that there are no more sales for this day

day3:
    .word 6, 9, 11, 0         @ This is the sales data for day 3, with a 0 at the end to indicate that there are no more sales for this day

day4:
    .word 7, 13, 0            @ This is the sales data for day 4, with a 0 at the end to indicate that there are no more sales for this day

day5:
    .word 14, 16, 0           @ This is the sales data for day 5, with a 0 at the end to indicate that there are no more sales for this day

@ These are the variables where we will store the results of our calculations
total_sales:
    .word 0                   @ This is where we will store the total_sales, starting at 0

max_value:
    .word 0                   @ This is where we will store the max_value, starting at 0

min_value:
    .word 0xFFFFFFFF          @ This is where we will store the min_value, starting at 0

average_sales:
    .word 0                   @ This is where we will store the average_sales, starting at 0
