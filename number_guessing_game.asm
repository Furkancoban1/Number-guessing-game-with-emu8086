org 100h
; Establishes the starting point in memory for this .COM program, commonly used in DOS applications. 


#start=led_display.exe#
; Directive indicating the name for the compiled executable,
; typically used in assembly language development tools.


mov al,0
out 199,al
; Resets the LED display to a blank state by clearing all lights, addressing port 199h.


mov ah, 09h
mov dx, offset attempts_prompt
int 21h
; Invokes DOS's service to print a prompt on the screen, querying users for their desired number of guesses.

putdifferentnumber: 

call getNumber
; Executes a subroutine that captures a single character input from the keyboard.

cmp al, '9'
ja invalid_input 
cmp al, '1'
jb invalid_input
; Validates the captured input to ensure it's a digit between 1 and 9, redirects to error handling if not.

 
sub al, '0'      
mov bh, al
; Transforms the ASCII character to its numerical equivalent for further processing, storing it in BH.       

mov ah,09h
mov dx, offset new_line
int 21h
int 21h
; Outputs two line breaks for better readability in the interface.

  

mov dx, offset game_intro
int 21h
; Presents an introductory message to the player, setting the stage for the game.


call random_number
mov bl, al
; Fetches a pseudo-random number for the session, which the player will aim to guess. 

putdifferentnumber1: 

start:

call getGuess

cmp al, '9'
ja invalid_input1 
cmp al, '1'
jb invalid_input1
; Rechecks guess input validity, ensuring it falls within acceptable bounds.

sub al, '0'      
out 199, al
; Converts the guess to a numerical value and updates the LED display accordingly.

     
cmp al, bl
; Compares player's guess against the target number.
      

mov ah,09h
mov dx, offset new_line
int 21h
int 21h
; Inserts a double line break for visual spacing after each guess.


je correct_guess
; Directs flow to a victory message if the guess matches the target number.

 
dec bh
cmp bh,0
je game_over
; Reduces the number of remaining guesses and checks if they've run out.



mov dx, offset try_again_msg
int 21h
jmp start
; Encourages the player to attempt another guess if the previous one was incorrect and chances remain.


correct_guess:
; Marks the flow's arrival at a successful guess.

mov al,bl 
out 199, al
; Lights up the LED display with the successfully guessed number.


mov dx, offset win_msg
int 21h
; Celebrates the player's victory with a congratulatory message.


jmp game_end
; Bypasses the game over logic, concluding the session.


game_over:
; Engages when the player has exhausted all attempts without success.


  mov dx, offset new_line
  int 21h


mov al,bl 
out 199, al
; Reveals the correct number on the LED display as a part of game closure.



mov dx, offset failed_msg
int 21h
; Offers words of consolation and encourages reflection or another try.


jmp game_end
; Concludes the game session, readying for termination or a new game.

invalid_input:
; Catches and handles inputs that don't comply with the expected range for attempt setting.
 
mov ah,09h
mov dx, offset new_line
int 21h  
int 21h


mov dx, offset invalid_attempt_msg
int 21h
; Advises the player of the input mistake and prompts for a correct value.

jmp putdifferentnumber
  
invalid_input1:
; Deals with out-of-bound inputs during the guessing phase.
 
mov ah,09h
mov dx, offset new_line
int 21h  
int 21h


mov dx, offset invalid_guess_msg
int 21h
; Informs the player about the invalid guess and requests a new input within the valid range.

jmp putdifferentnumber1

game_end:
mov ah, 4Ch     
int 21h
; Requests DOS to terminate the program, handing control back to the operating system.

; The program also includes several subroutines and data strings that facilitate input collection,
; display messaging, and random number generation, supporting the game's core mechanics and user interaction.

getNumber:
mov ah, 01h 
int 21h     
ret

random_number:
    mov ah, 2Ch   ; Function to get system time
    int 21h       ; Call interrupt to get time
    and dl, 0Fh   ; Keep only the last 4 bits
    add dl, 1     ; Add 1 to ensure the range is 1-8
    cmp dl, 9     ; Check if the number is greater than 9
    jle random_ok ; If not, it's within range, jump to random_ok
    sub dl, 7     ; If greater than 9, sub it with 7 to make sure it is less than 10
random_ok:
    mov al, dl    ; Move the random number to AL
    ret   ;Return

getGuess:
mov ah, 01h 
int 21h     
ret

; These subroutines handle input and random number generation.
; getNumber and getGuess read a single character from the user.
; random_number generates a random number between 1 and 8 (inclusive).

game_intro db 'Guess the number between 1 and 9 (inclusive)', 0Dh, 0Ah, '$'
attempts_prompt db 'How many attempts do you want (1-9)?', 0Dh, 0Ah, '$'
try_again_msg db 'Incorrect, try again:', 0Dh, 0Ah, '$'
win_msg db 'Correct! You guessed the number correctly!', 0Dh, 0Ah, '$'
failed_msg db 'You failed! The correct answer is written on the led ', '$'
invalid_attempt_msg db 'Invalid number of attempts. Please enter a value between 1 and 9.', 0Dh, 0Ah, '$'
invalid_guess_msg db 'Any input other than a digit (not 0) you enter will prevent you from continuing.', 0Dh, 0Ah, '$'
new_line db 0Dh,0Ah,'$'
; These are data strings used for display messages throughout the game. 