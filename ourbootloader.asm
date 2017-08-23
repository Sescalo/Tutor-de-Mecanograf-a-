[ORG  0x7C00] ;para saber donde comieza
bits    16 

BootLoader:
    ;Resetea el disco
    mov ah, 0x00
    mov dl, 0x80
    int 0x13
    jc BootLoader ;si por algo falla se intenta de nuevo

    ;Lee el segundo sector del disco
    mov ah, 0x02
    mov al, 0x03 ;sector a leer
    mov ch, 0x00 
    mov cl, 0x02 ;sector en el que se inicia
    mov dh, 0x00 ;numero cabeza(para la llave)
    mov dl, 0x80 
    mov bx, 0x0F00 ;direccion donde esta el programa
    int 0x13

    jmp 0x0F00  ;salta a esa etiqueta
                        
 times 510 - ($ - $$) db 0 ;llena el resto con 0
 dw 0xAA55 ;firma de arranque para saber que es bootable