[BITS 16]       ;Tells the assembler that its a 16 bit code
[ORG 0x0F00]     ;Origin, tell the assembler that where t

section .data
        
        finger db "pimmmiiimimriirppiriiirrip"
        hand db "lllllllrrrrrrrrrllllrlllrl"
        mat db "___________________________________________________________________________",10,"|                                                                       __|",10,"|                                                                      ]__ ",10,"|    __     __     __     __     __     __     __     __     __     __    |",10,"|   |  |   |  |   |  |   |  |   |  |   |  |   |  |   |  |   |  |   |  |   |",10,"|   |  |   |  |   |  |   |  |   |  |   |  |   |  |   |  |   |  |   |  |   |",10,"|   |  |   |  |   |  |   |  |   |  |   |  |   |  |   |  |   |  |   |  |   |",10,"|   |  |   |  |   |  |   |  |   |  |   |  |   |  |   |  |   |  |   |  |   |",10,"iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii",10,10
        mat_size equ $ - mat
        line_size equ 75
        initial_pos equ 225 - 5
        score_msg db "Score = "
        score_msg_size equ $ - score_msg
        right db "Right hand with "
        right_size equ $ - right
        left db "Left hand with "
        left_size equ $ - left
        pinky db "pinky finger" , 10
        pinky_size equ $ - pinky
        ring db "ring finger" , 10
        ring_size equ $ - ring
        middle db "middle finger" , 10
        middle_size equ $ - middle
        index db "index finger" , 10
        index_size equ $ - index
        thumb db "thumb finger" , 10
        thumb_size equ $ - thumb

        

section .bss
        
        ij resb 2
        score resb 4
        buffer resb 2
        buffer_size equ $ - buffer
        time resb 4
        time_size equ $ - time
        letter resb 1
        falling resb 1
        

section .text
global main
main:
        mov byte[letter],120
        mov dword[time],99999999 ;max size
        mov word[ij], initial_pos
        mov esi, 0
        mov word[score],0
        mov byte[falling], 0

restartletter:
        mov AH, 00h
        INT 1Ah
        
        mov al,dh
        mov bl,26
        div bl
        add ah, 97


        mov byte[letter], ah
        mov dword[ij], initial_pos

paintletter:
                
        mov bx, word[ij]
        mov cl, byte[letter]
        mov byte[mat + ebx], cl        ; write into memory ; + i * line_size + j

loop: 
        mov si,0
        mov si, [time]
        mov di,0
        mov di, 9999
        push si
        push di

        ;mov al, [falling]
        cmp al, 1
        ;je moveletterdown
        ;mov byte[falling], 0

        mov ah, 02h
        mov bh, 0x00
        mov dl, 0x00
        mov dh, 0x00
        int 10h

        call clearScreen


        mov ah, 01h ; checks if a key is pressed
        int 16h
        jz end_pressed ; zero = no pressed

        mov ah, 00h ; get the keystroke
        int 16h
        end_pressed:

            


comparekey:
        mov si, word[ij]  
        mov bx, mat 
        mov cl, byte[bx + si]
        cmp cl,al
        je moveletterdown
        jmp moveletterleft


moveletterleft:
 
        mov si, word[ij]   
        mov al, byte[mat + si]
        mov cl, 0x20 
        mov byte[mat + si], cl ;escribo espacio en posicion anterior
        sub si,1   
        mov [ij],si 
        mov al,[letter]
        mov [mat + si], al ;escribo letra en posicion nueva
        jmp paintmat


moveletterdown:
        mov si, word[ij]  
        mov al, byte[mat + si]
        mov cl, 0x20 
        mov byte[mat + si], cl ;escribo espacio en posicion anterior
        add si,line_size
        mov word[ij],si
        mov byte[mat + si], al ;escribo letra en posicion nueva
        jmp paintmat


paintmat:
        mov ah, 02h
        mov bh, 0x00
        mov dl, 0x00
        mov dh, 0x00
        int 10h

        mov ebx,mat
        mov esi, mat_size
        CALL PrintString        ;Call print string procedure


printhand:
        mov ecx,0
        mov cl,byte[letter]
        sub cl,97
        add ecx, hand
        mov al, byte[ecx]
        call PrintCharacter
        mov al,20h
        call PrintCharacter

printfinger:
        mov ecx,0
        mov cl,byte[letter]
        sub cl,97
        add ecx, finger
        mov al, byte[ecx]
        call PrintCharacter
        mov al,10
        call PrintCharacter

printscore:
        mov ebx, score_msg
        mov esi, score_msg_size
        CALL PrintString        ;Call print string procedure

        pop di
        pop si


endloop:
        nop
        sub si,1
        cmp si,0
        jne endloop
        sub di,1
        mov si, [time]
        cmp di,0
        je loop
        jmp endloop












PrintCharacter: ;Procedure to print character on screen
        ;Assume that ASCII value is in register AL
        MOV AH, 0x0E    ;Tell BIOS that we need to print one charater on screen.
        MOV BH, 0x00    ;Page no.
        MOV BL, 0x07    ;Text attribute 0x07 is lightgrey font on black background

        INT 0x10        ;Call video interrupt

        CMP AL, 10

        JNE continue

        mov ah, 03h
        mov bh, 0x00

        int 10h

        mov ah, 02h
        mov bh, 0x00
        mov dl, 0x00

        int 10h

continue:
        ret

PrintString:    ;Procedure to print string on screen
        ;Assume that string starting pointer is in register SI

next_character: ;Lable to fetch next character from string
        MOV AL, byte[ebx]    ;Get a byte from string and store in AL register
        inc ebx
        dec eSI          ;Increment SI pointer
        cmp esi, 0       ;Check if value in AL is zero (end of string)
        Je exit_function ;If end then return
        push ebx
        push esi
        CALL PrintCharacter ;Else print the character which is in AL register
        pop esi
        pop ebx
        JMP next_character      ;Fetch next character from string
        exit_function:  ;End label
        RET             ;Return from procedure

;------------------------------------------------------------------------------

clearScreen:
    ;pusha

    mov ax, 0x0600  ; function 07, AL=0 means scroll whole window
    mov bh, 0x07    ; character attribute = white on black
    mov cx, 0x0000  ; row = 0, col = 0
    mov dx, 0x0A3F  ; row = 24 (0x18), col = 79 (0x4f)
    int 0x10        ; call BIOS video interrupt

    ;popa
    ret
;------------------------------------------------------------------------------