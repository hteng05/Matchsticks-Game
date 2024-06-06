Game:
    BL AskInput
Game_loop:
    BL Player
    BL Computer
    B Game_loop

;---------------->Function 1: Asking for the player's name and number of matchsticks<-------------
AskInput:
    PUSH {R0, LR}
AskName:
    MOV R0, #ask_name //ask for player's name
    STR R0, .WriteString
    MOV R5, #player_name
    STR R5, .ReadString //store player's actual name in R5 for future use
    STR R5, .WriteString

AskMatchsticks:
    MOV R0, #ask1_matchsticks //ask for the number of matchsticks
    STR R0, .WriteString
    LDR R4, .InputNum 
    STR R4, .WriteUnsignedNum //store the number of matchsticks in R4
    CMP R4, #10 //compare the input matchsticks with 10 and 100
    BLT Error1  //if not between 10 and 100, go to error1   
    CMP R4, #100
    BGT Error1 //if not between 10 and 100, go to error1         
    B Done1
Error1:
    MOV R0, #errormsg1 //print error message to announce the invalid input
    STR R0, .WriteString
    B AskMatchsticks
Done1:
    MOV R0, #result_name //print out the player's name
    STR R0, .WriteString 
    STR R5, .WriteString
    MOV R0, #result_matchsticks //print out the matchsticks number
    STR R0, .WriteString
    STR R4, .WriteUnsignedNum
    STR R9, .ClearScreen
    BL DrawMatchsticks //draw matchstciks on screen
    POP {R0, LR}
    RET
;------------------------------->Function 2: Printing out the game status<---------------------------
GameStatus:
    PUSH {R0}
    MOV R0, #status //update the remaining matchsticks
    STR R0, .WriteString
    MOV R0, #remain4
    STR R0, .WriteString
    STR R4, .WriteUnsignedNum  
    MOV R0, #remain3
    STR R0, .WriteString
    CMP R4, #2 //R4 = remaining matchsticks, if equal or greater than 2, game continue
    PUSH {LR}
    BLT End //Otherwise, decide win or lose or draw
    POP {LR}
    POP {R0}
    RET
;--------------------------------------->Function 3: Player Turn<-----------------------------------
Player:
    MOV R6, #0 //define 0 is player turn
PlayerTurn:
    PUSH {R0}
    MOV R0, #player_turn1 //print the player's turn label
    STR R0, .WriteString
    STR R5, .WriteString
    MOV R0, #player_turn2
    STR R0, .WriteString
    MOV R0, #remain1 //print the remaining matchsticks number
    STR R0, .WriteString
    STR R5, .WriteString
    MOV R0, #remain2
    STR R0, .WriteString
    STR R4, .WriteUnsignedNum
    MOV R0, #remain3
    STR R0, .WriteString
PlayerRemove:
    MOV R0, #remain1
    STR R0, .WriteString
    STR R5, .WriteString
    MOV R0, #ask2_matchsticks
    STR R0, .WriteString
    LDR R1, .InputNum
    CMP R1, #1 //compare input matchsticks with 1 and 7
    BLT Error2 //if not between 1 and 7, go to error2   
    CMP R1, #7
    BGT Error2//if not between 1 and 7, go to error2   
    CMP R1, R4 //compare the removal matchsticks with remaining matchsticks
    BGT Error2 //if not lower than remaining matchsticks, go to error2    
    SUB R4, R4, R1 //Subtraction between initial matchstick number and removal matchstick number
    MOV R0, #user_remove //print out the number of matchsticks player removed
    STR R0, .WriteString
    STR R1, .WriteUnsignedNum
    MOV R0, #matchsticks
    STR R0, .WriteString
    STR R9, .ClearScreen
    PUSH {LR}
    BL DrawMatchsticks //draw matchstciks on screen
    POP {LR}
    CMP R4, #2 //R4 = remaining matchsticks, if equal or greater than 2, game continue
    BLT GameStatus //if less than 2, go to game status to update remaining matchsticks
    B Done2
Error2:
    MOV R0, #user_remove //print error message to announce the invalid input
    STR R0, .WriteString
    STR R1, .WriteUnsignedNum
    MOV R0, #matchsticks
    STR R0, .WriteString
    MOV R0, #errormsg2
    STR R0, .WriteString
    B PlayerRemove
Done2:
    POP {R0}
    RET
;--------------------------------------->Function 4: Computer Turn<-----------------------------------
Computer:
    MOV R6, #1 //define 1 is computer turn
ComputerTurn:
    PUSH {R0}
    MOV R0, #computer_turn
    STR R0, .WriteString
ComputerRandom:
    LDR R1, .Random //generate random number 
    AND R1, R1, #7 //make it becomes a random number from 0 to 7
    CMP R1, #0
    BEQ ComputerRandom //redo the generating process if random number is 0
    CMP R1, R4 //redo the generating process if random number is higher than the actual number of matchsticks.
    BGT ComputerRandom
    SUB R4, R4, R1 //Subtraction between initial matchstick number and removal matchstick number
    MOV R0, #computer_remove //print out the number of matchsticks computer removed
    STR R0, .WriteString
    STR R1, .WriteUnsignedNum
    MOV R0, #matchsticks
    STR R0, .WriteString
    STR R9, .ClearScreen
    PUSH {LR}
    BL DrawMatchsticks //draw matchsticks on screen
    BL GameStatus //go to game status to update remaining matchsticks
    POP {LR}
    POP {R0}
    RET
;--------------------------------------->Function 5: Analysis of who's the winner<-----------------------------------
End:
    CMP R4, #1 //if remaining matchstick = 1, go to win
    BEQ Win
    CMP R4, #0 //if remaining matchstick = 1, go to draw
    BEQ Draw
    B Over
Win:
    CMP R6, #0 //0 = player turn
    BEQ PlayerWin 
    CMP R6, #1 //1 = computer turn
    BEQ ComputerWin
PlayerWin: 
    MOV R0, #overmsg //print out the message which announces the player win the game
    STR R0, .WriteString
    MOV R0, #remain1
    STR R0, .WriteString
    STR R5, .WriteString
    MOV R0, #winmsg
    STR R0, .WriteString
    STR R9, .ClearScreen
    B Over
ComputerWin:
    MOV R0, #overmsg //print out the message which announces the player lose the game
    STR R0, .WriteString
    MOV R0, #remain1
    STR R0, .WriteString
    STR R5, .WriteString
    MOV R0, #losemsg
    STR R0, .WriteString
    STR R9, .ClearScreen
    B Over

Draw: 
    MOV R0, #overmsg //print out the message which announces draw game
    STR R0, .WriteString
    MOV R0, #drawmsg
    STR R0, .WriteString
    STR R9, .ClearScreen
    B Over

;--------------------------------------->Function 6: Visualize the matchsticks<-----------------------------------
DrawMatchsticks:
    Push {R1, R2, R3, R5, R7, R8, R11, R12}
    MOV R0, #4        //Set initial X coordinate
    MOV R2, #4        //Set initial Y coordinate
    MOV R1, #0        //Number of matchsticks drawn
    MOV R11, #0       //Line counter
    MOV R12, #0       //Matchsticks in the current line

drawMatchStick:
    MOV R9, #.PixelScreen
    MOV R7, #.red //Set color red for the matchstick head
    LSL R3, R0, #2    //Calculate X coordinate offset (multiply by 4)
    LSL R5, R2, #8    //Calculate Y coordinate offset (multiply by 256)
    ADD R5, R5, R3    //Get the pixel index
    STR R7, [R9+R5]   //Draw the head of the matchstick
    MOV R7, #.orange ////Set color orange for the matchstick body
    MOV R8, #0        //The number of pixels for the body

body_loop:
    ADD R2, R2, #1  //Increment Y coordinate by 1 pixel
    LSL R3, R0, #2  //Calculate X coordinate offset (multiply by 4)
    LSL R5, R2, #8  //Calculate Y coordinate offset (multiply by 256)
    ADD R5, R5, R3  //Get the pixel index
    STR R7, [R9+R5] //Draw the body pixel
    ADD R8, R8, #1  //increment the pixel count 
    CMP R8, #2      //check if it's less than 2 pixels
    BLT body_loop
    ADD R2, R2, #2 //Move to the next matchstick (add a 2-pixel distance)
    ADD R1, R1, #1 //Increment the number of matchsticks drawn
    ADD R12, R12, #1 // Increment the matchsticks in the current line counter
    CMP R1, R4 //Check if we've drawn the desired number of matchsticks
    BEQ EndDraw
    CMP R12, #10 //Check if we need to start a new line
    BEQ newLine
    B drawMatchStick //If not, continue on the same line

newLine:
    ADD R0, R0, #6 //Move to the next line (X coordinate + 6)
    MOV R2, #4  //Reset Y coordinate to 4
    ADD R11, R11, #1 //Increment the line counter
    MOV R12, #0       //Reset matchsticks in the current line
    CMP R11, #10 //Check if we've drawn all lines (up to 10)
    BLT drawMatchStick

EndDraw:
    Pop {R1, R2, R3, R5, R7, R8, R11, R12}
    RET
;--------------------------------------->Function 7: Asking the player if they want to play again<-----------------------------------
Over:
    MOV R0, #over
    STR R0, .WriteString
    MOV R0, #decision
    STR R0, .ReadString
    LDRB R7, [R0] //Load the first byte (character) of the input string
    CMP R7, #121 //ASCII 'y'
    BEQ Game
    CMP R7, #110 //ASCII 'n'
    BEQ Exit
    B Over //if not "y" or "n", ask again
Exit:
    MOV R0, #seeya
    STR R0, .WriteString
    HALT

;--------------------------------------->Messages<--------------------------------------------
//Stage 1
ask_name: .asciz "Please enter your name: "
player_name: .block 128
ask1_matchsticks: .asciz "\nHow many matchsticks (10-100)?\n"
errormsg1: .asciz "\nInput must be from 10 to 100!!! Please try again."
result_name: .asciz "\nPlayer 1 is "
result_matchsticks: .asciz "\nMatchsticks: "
//Stage 2
errormsg2: .asciz "\nInput must be from 1 to 7 and not be larger than current matchsticks number!!! Please try again."
remain1: .asciz "\nPlayer "
remain2: .asciz ", there are "
remain3: .asciz "matchstick(s) remaining."
remain4: .asciz "\nThere are "
ask2_matchsticks: .asciz ", how many do you want to remove (1-7)?\n"
user_remove: .asciz "You chose to remove "
matchsticks: .asciz "matchstick(s)."
//Stage 3
status: .asciz "\n-----> Remaining Matchsticks <-----"
player_turn1: .asciz "\n\n-----> Player "
player_turn2: .asciz "'s turn <-----"
computer_turn: .asciz "\n-----> Computer Player's turn <-----"
computer_remove: .asciz "\nComputer chose to remove "
overmsg: .asciz "\n-----> Game Over <-----"
winmsg: .asciz ", YOU WIN!"
losemsg: .asciz ", YOU LOSE!"
drawmsg: .asciz "\nIt's a draw!"
over:  .asciz "\nPlay again (y/n)?\n"
seeya: .asciz "See you again!"
decision: .block 128