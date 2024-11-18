; Arano, Christian Timothy Z. LBYARCH - S14
; XOR Fibonacci Encryption/Decryption
%include "io64.inc"

section .data
STRING times 21 db 0              ; input string (assuming maximum is 20 characters)
KEY times 21 db 0                 ; encryption/decryption key (fibonacci sequence starting from N0 and N1)
ENCRYPTED_STRING times 21 db 0    ; for storing encrypted output
N0 db 3                          ; first initial number in the sequence          
N1 db 7                       ; second initial number in the sequence

section .text   
global main
main:
    GET_STRING STRING, 21         ; get input string
    PRINT_STRING "Input Text (ASCII): "
    PRINT_STRING STRING           ; display input string
    NEWLINE
    
    lea rsi, [STRING]             ; store memory STRING into rsi
    xor rcx, rcx                  ; initialize rcx counter to 0

STR:                              ; used for counting input string length
    cmp byte [rsi+rcx], 0         ; traverse the string until 0 is encountered    
    je FIB                        ; if 0 is found, jump to FIB label
    inc rcx                       ; increment rcx
    jmp STR                       ; repeat the process

FIB:                              ; used for loading initial Fibonacci values
    mov r8b, [N0]                 ; store 1st initial number in r8b
    mov r9b, [N1]                 ; store 2nd initial number in r9b
    mov [KEY], r8b                ; load r8b into 1st index (0) in KEY
    mov [KEY+1], r9b              ; load r9b into 2nd index (1) in KEY   

    mov rbx, rcx                  ; store length of the input string into rbx     
    mov rcx, 2                    ; start generating Fibonacci sequence at index 2

NEXT_FIB:                         ; Label for generating the Fibonacci sequence
    cmp rcx, rbx                  ; compare rcx and rbx
    jge PROCESS_STRING            ; if rcx reaches rbx, jump to PROCESS_STRING    

    mov al, r8b                   ; load r8b into al
    add al, r9b                   ; add r8b and r9b   
    and al, 0xFF                  ; truncate to 8 bits by AND-ing with 0xFF

    mov [KEY+rcx], al             ; store result in KEY at current index
    mov r8b, r9b                  ; update r8b to previous r9b   
    mov r9b, al                   ; update r9b to current sum

    inc rcx                       ; increment rcx
    jmp NEXT_FIB                  ; repeat until Fibonacci sequence is complete

PROCESS_STRING:                   ; start processing the input string
    lea rsi, [STRING]             ; reset rsi to STRING memory
    lea rdi, [KEY]                ; reset rdi to KEY memory
    xor rcx, rcx                  ; reset rcx counter
    NEWLINE
    PRINT_STRING "Input Text (Hex): "  

PRINT_HEX_INPUT:                  ; display input string in hex
    cmp rcx, rbx                  ; check if at end of the string length
    jge ENCODE                    ; if rcx equals rbx, jump to ENCODE

    PRINT_HEX 1, [rsi+rcx]        ; display character in hex  
    PRINT_STRING " "

    inc rcx                       ; increment rcx
    jmp PRINT_HEX_INPUT           ; repeat until end of string

ENCODE:                           ; start XOR encryption
    lea rsi, [STRING]             ; reset rsi to STRING
    lea rdi, [KEY]                ; reset rdi to KEY
    lea rdx, [ENCRYPTED_STRING]     ; point rdx to ENCODED_STRING
    xor rcx, rcx                  ; reset rcx counter
    NEWLINE
    NEWLINE
    PRINT_STRING "Key (Hex): "                

ENCODE_LOOP:                      ; display key in hex and perform XOR operation
    cmp rcx, rbx                  ; check if end of the string length
    jge PROCESS_ENCODED           ; if rcx equals rbx, jump to display encrypted text              

    mov al, [rsi+rcx]             ; load current character into al
    PRINT_HEX 1, [rdi+rcx]        ; display key byte in hex
    PRINT_STRING " "
    
    xor al, [rdi+rcx]             ; XOR character with key
    mov [rdx+rcx], al             ; store encrypted result in ENCODED_STRING

    inc rcx                       ; increment rcx
    jmp ENCODE_LOOP               ; repeat for each character

PROCESS_ENCODED:                  ; display the encrypted string in hex and ASCII
    lea rsi, [ENCRYPTED_STRING]   ; point rsi to ENCRYPTED_STRING
    xor rcx, rcx                  ; reset rcx counter
    NEWLINE
    NEWLINE
    PRINT_STRING "Encrypted Text (Hex): "
    
PRINT_HEX_ENCODED:                ; display encrypted string in hex
    cmp rcx, rbx                  ; check if end of the encrypted string length
    jge DISPLAY_ASCII             ; if rcx equals rbx, jump to ASCII output

    PRINT_HEX 1, [rsi+rcx]        ; display encrypted byte in hex
    PRINT_STRING " "

    inc rcx                       ; increment rcx
    jmp PRINT_HEX_ENCODED         ; repeat for all encrypted bytes

DISPLAY_ASCII:                    ; display encrypted string in ASCII
    NEWLINE
    NEWLINE
    PRINT_STRING "Encrypted Text (ASCII): "
    PRINT_STRING ENCRYPTED_STRING           ; display STRING as ASCII

END:                              
    xor rax, rax
    ret
