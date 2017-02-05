model small
.data
	 max_size db 255
	 ;number of read symbol;
	 char_read db 0
	 mas db	256 dup (0)
	 error_msg db '^', 0dh, 0ah, "error here!$"
	 correct_msg db 0dh, 0ah, "correct string!$"

.stack 
	db 512 dup ('?')
.code
	string_input PROC
		
		mov ah, 0ah
		lea dx, max_size
		int 21h
		mov ax, 0ah
		int 29h
		ret

	string_input ENDP

	get_label PROC
		cmp ax, '('
		jne lbl_1
		mov ax, 1
		mov si, 0
		ret

		lbl_1:
		cmp ax, ')'
		jne lbl_2
		mov ax, 1
		mov si, 1
		ret

		lbl_2:
		cmp ax, '{'
		jne lbl_3
		mov ax, 2
		mov si, 0
		ret

		lbl_3:
		cmp ax, '}'
		jne lbl_4
		mov ax, 2
		mov si, 1
		ret

		lbl_4:
		cmp ax, '['
		jne lbl_5
		mov ax, 3
		mov si, 0
		ret

		lbl_5:
		cmp ax, ']'
		jne lbl_6
		mov ax, 3
		mov si, 1
		ret

		lbl_6:
		mov ah, 09h
		lea dx, error_msg
		int 21h
		jmp terminate
		ret

	get_label ENDP

	out_space PROC
		push ax
		mov ax, ' '
		int 29h
		pop ax
		ret
	out_space ENDP

	validate PROC
		;stack beginning label;
		push 100
		mov cl, char_read
		mov di, 0
		xor ax, ax
		jcxz end_loop
		
		validation_loop:
			mov al, mas[di]
			call get_label
			cmp si, 0
			jne pop_from_stack
			push ax
			call out_space
			inc di
			loop validation_loop
			jmp end_loop

			pop_from_stack:
				pop bx
				cmp bl, al
				jne invalid_sequence
				call out_space
				inc di
				loop validation_loop
				jmp end_loop

				invalid_sequence:
					mov ah, 09h
					lea dx, error_msg
					int 21h
					jmp terminate
					ret
		end_loop:
			pop ax
			cmp ax, 100
			jne invalid_sequence
			mov ah, 09h
			lea dx, correct_msg
			int 21h
			jmp terminate
			ret

	validate ENDP

	main:
		mov ax, @data    
        mov ds, ax

        call string_input
        call validate

	    terminate:
        mov ax,4c00h    
        int 21h
	end main

