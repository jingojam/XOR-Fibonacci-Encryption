%include "io64.inc"

section .data
STRING times 21 db 0        ; input string (assuming maximum is 20 characters)
KEY times 21 db 0           ; encryption/decryption key (fibonacci sequence starting from N0 and N1)assuming maximum input is 20 characters
N0 db 25                    ; first initial number in the sequence          
N1 db 138                   ; second initial number in the sequence

section .text
global main
main:
    GET_STRING STRING, 21   ; get input string
    PRINT_STRING "Input Text (ASCII): "
    PRINT_STRING STRING     ; display input string
    NEWLINE

    lea rsi, [STRING]       ; store memory STRING into rsi
    xor rcx, rcx            ; initialize rcx counter to 0

STR:                        ; STR: label used for pre-processing (counting input string length)
    cmp byte [rsi+rcx], 0   ; traverse the string until 0 is encountered    
    je FIB                  ; if 0 is found, jump to FIB label
    inc rcx                 ; increment rcx
    jmp STR                 ; do this process again

FIB:                        ; FIB: label used for pre-processing (loading initial fibonacci sequence values into memory)
    mov r8b, [N0]           ; store 1st initial number in the sequence into r8b
    mov r9b, [N1]           ; store 2nd initial number in the sequence into r9b
    mov [KEY], r8b          ; load r8b into 1st index (0) in the KEY memory location
    mov [KEY+1], r9b        ; load r9b into 2nd index (1) in the KEY memory location   

    mov rbx, rcx            ; store the length of the string (stored in rcx) into rbx     
    mov rcx, 2              ; initialize rcx with 2 (1 for the two initial fibonacci sequence value) 

NEXT_FIB:                   ; NEXT_FIB: used for the generation of the fibonacci sequence after initial processing
    cmp rcx, rbx            ; compare rcx and rbx
    jge PROCESS_STRING      ; if rcx is equal to rbx, jump to PROCESS_STRING label    

    mov al, r8b             ; load r8b into al (r8b initially contains n0)
    add al, r9b             ; add into al sum of r8b and r9b (r9b initially contains n1)     
    and al, 0xFF            ; since key needs to be truncated to a byte (8 bits)
                            ; simply AND-ing the register with 0xFF (0d255) should truncate the value to 8 bits (1 byte)

    mov [KEY+rcx], al       ; store value of al into KEY memory location starting from the index 2 (3rd element) onwards

    mov r8b, r9b            ; store r9b into r8b   
    mov r9b, al             ; store the value of al (currently holds the sum of previous 2 numbers) into r9b

    inc rcx                 ; increment rcx until equivalent to rbx (rbx holds the length of the input string)
    jmp NEXT_FIB            ; do this process again

PROCESS_STRING:        
    lea rsi, [STRING]       ; reset rsi again to the STRING memory
    lea rdi, [KEY]          ; reset rdi again to the KEY memory
    xor rcx, rcx            ; reset rcx counter back to 0
    NEWLINE
    PRINT_STRING "Input Text (Hex): "  

PRINT_HEX_INPUT:            ; PRINT_HEX_INPUT: display hex (ASCII) equivalent of characters in input string
    cmp byte [rsi+rcx], 0   ; check if at end of the string
    je ENCODE          

    PRINT_HEX 1, [rsi+rcx]    
    PRINT_STRING " "

    inc rcx                   
    jmp PRINT_HEX_INPUT

ENCODE:
    lea rsi, [STRING]            
    lea rdi, [KEY]            
    xor rcx, rcx 
    NEWLINE
    NEWLINE
    PRINT_STRING "Key (Hex): "                

ENCODE_LOOP:
    cmp byte [rsi+rcx], 0     
    je PROCESS_ENCODED                   

    mov al, [rsi+rcx]
    
    PRINT_HEX 1, [rdi+rcx]    
    PRINT_STRING " "
    
    xor al, [rdi+rcx]         
    mov [rsi + rcx], al

    inc rcx 
    jmp ENCODE_LOOP
    
PROCESS_ENCODED:
    lea rsi, [STRING]          ; reset rdi again to the KEY memory
    xor rcx, rcx            ; reset rcx counter back to 0
    NEWLINE
    NEWLINE
    PRINT_STRING "Encrypted Text (Hex): "
    
PRINT_HEX_ENCODED:
    cmp byte [rsi+rcx], 0   ; check if at end of the string
    je END          

    PRINT_HEX 1, [rsi+rcx]    
    PRINT_STRING " "

    inc rcx                   
    jmp PRINT_HEX_ENCODED

END:
    NEWLINE
    NEWLINE
    PRINT_STRING "Encrypted Text (ASCII): "
    PRINT_STRING STRING
    xor rax, rax              
    ret
