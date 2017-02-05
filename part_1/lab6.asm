.model small
.stack 900
.data
    old dw 0
    old_es dw 0

	msg_invalid_command db "Error: invalid command [may be -d?]", 13, 10, "$"
	msg_already_installed db "Handler is already installed.", 13, 10, "$"
	msg_handler_removed db "Handler was successfully removed.", 13, 10, "$"
    msg_handler_installed db "Handler was successfully installed.", 13, 10, "$"
    msg_not_installed db "Handler was not installed yet.", 13, 10, "$"
    buf db 256 dup ('$')
.code
.486
new_handler proc far
        cmp ax, 0BEEFh
        je mybeef
        cmp ax, 0DEADh
        je mydead
        cmp ah, 09h
        jne non9h
        call convert_case
        jmp end_of_work

        non9h:
            jmp dword ptr cs:old

        mybeef:
            mov bx, 0DEADh
            retf

        mydead:
            push ds
            mov dx, cs:old_es
            mov ds, dx
            mov dx, cs:old
            mov ax, 2521h
            int 21h
            pop ds
            push cs
            pop es
            mov ax, 4900h 
            int 21h
            retf

    end_of_work:
    jmp dword ptr cs:old
    retf
new_handler endp
convert_case proc near
    push si
    mov si, dx
    dec si
    convert:
        inc si
        cmp byte ptr [si], 'Z'
        jg not_upper
        cmp byte ptr [si], 'A'
        jl not_upper
        add byte ptr [si], 32
        jmp convert

        not_upper:
        cmp byte ptr [si], 'z'
        jg not_lower
        cmp byte ptr [si], 'a'
        jl not_lower
        sub byte ptr [si], 32
        jmp convert

        not_lower:
        cmp byte ptr [si], '$'
        jne convert
    endconvert:
    pop si
    ret
convert_case endp
new_end: 
start:
	mov ax, @data
    mov ds, ax

	mov bx, 82h
	mov al, es:[bx]
    cmp al, ''
	je install_new_handler
	cmp al, '-'
	jne invalid_command
	inc bx 
	mov al, es:[bx]
	cmp al, 'd'
	jne invalid_command

    mov ax, 0BEEFh
    int 21h
    cmp bx, 0DEADh
    jne handler_not_installed

	remove_installed_handler:
        push es
        mov ax, 0DEADh
        int 21h
        pop es
        lea dx, msg_handler_removed
		mov ah, 09h
		int 21h
		jmp terminate

	handler_not_installed:
		lea dx, msg_not_installed
		mov ah, 09h
		int 21h
		jmp terminate
		
	install_new_handler:
        mov ax, 0BEEFh
        int 21h
        cmp bx, 0DEADh
        je handler_already_installed

        mov ax,3521h
        int 21h        
        
        mov word ptr old, bx
        mov word ptr old_es, es
        
        push ds
        mov ax,2521h
        mov dx,seg new_handler
        mov ds,dx
       	mov dx,offset new_handler
        int 21h
        pop ds

        mov ax, 0900h
        lea dx, msg_handler_installed
        int 21h

		jmp do_tsr

	invalid_command:
		lea dx, msg_invalid_command
		mov ah, 09h
		int 21h
		jmp terminate

	handler_already_installed:
    	lea dx, msg_already_installed
		mov ah, 09h
		int 21h
		jmp terminate
		
	do_tsr:
        xor ax, ax
        mov ah, 31h
        mov al, 1
        mov dx, (new_end - @code + 10FH + 20) / 16 ;вычисление размера резидентной части в параграфах(16 байт)
        int 21h
        jmp quit

	terminate:
		mov ax, 4c00h 
		int 21h

	quit:

end start