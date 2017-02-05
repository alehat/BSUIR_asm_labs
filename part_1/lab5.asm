model small
.data
	 max_size db 255
	 ;count of read symbol;
	 char_read db 0
	 inp_str db	256 dup (0)
	 input_N db "Input N: $" ;rows count
	 input_M db "Input M: $" ;cols count
	 input_A db "Input A: $"
	 input_matrix db "Input matrix NxM: ", 0dh, 0ah, '$'
	 input_less_than_expected db 0dh, 0ah, "Input contains less amount of numbers than it was expected!", 0dh, 0ah, '$'
     input_error_str db 0dh, 0ah, "Input error!", 0dh, 0ah, '$'
     input_error_empty db "N or M cannot be 0!", 0dh, 0ah, '$'
     num_read db 0
     ;count of symbol in one read number;
	 num_chars db 0
	 step dw 1
	 input_number db 0
	 ;bx value;
	 inp_expected db 0
	 outp_expected db 0
	 N dw 0
	 M dw 0
	 A dw 0
	 matrix dw 200 dup(0)
.stack 
	db 512 dup ('?')
.code

	string_input PROC
		push ax
		push bx
		push cx
		push dx
		push si
		push di
		push bp
		;count of read numbers;
		mov num_read, 0

		mov inp_expected, bl
		mov di, ax

		mov ah, 0ah
		lea dx, max_size
		int 21h

		xor ax, ax
		mov al, char_read
		mov si, ax
		mov inp_str[si], ' '
		inc char_read

		xor cx, cx
		mov cl, char_read
		lea si, inp_str

		xor ax, ax
		char_loop:
			lodsb
			cmp al, ' '
			jne next
			inc num_read
			mov step, 1

			cmp num_chars, 0
			jne inner_loop
			loop char_loop
			jmp after_error

			inner_loop:
				pop ax
				sub ax, '0'
				mul step
				add [di], ax
				mov ax, step
				mov dx, 10
				mul dx
				mov step, ax
				dec num_chars
				cmp num_chars, 0
				jne inner_loop
			;адрес по которому мы пишем числа
			add di, 2
			mov dl, num_read
			cmp dl, inp_expected
			je string_input_end
			loop char_loop
			jmp input_error

			next:
				cmp al, '0'
				jl input_error
				cmp al, '9'
				jg input_error
				push ax
				inc num_chars
				loop char_loop

	jmp string_input_end
	
	input_error:
		mov ah, 09h
		lea dx, input_error_str
		int 21h

	after_error:
		mov al, num_read
		cmp al, inp_expected
		je string_input_end
		mov ah, 09h
		lea dx, input_less_than_expected
		int 21h

	string_input_end:
		mov ax, 0dh
		int 29h
		mov ax, 0ah
		int 29h
		pop bp
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret

	string_input ENDP

	string_output PROC
		push ax
		push bx
		push cx
		push dx
		push si
		push di
		push bp

		mov cx, bx
		mov si, ax

		number_loop:
			; bx - колічество ціфр в числе
			xor bx, bx

			lodsw 
			cmp ax, 0
			je inner_out_end
			inner_out_loop:
				xor dx, dx
				mov di, 10
				div di
				add dx, '0'
				push dx
				inc bx
				cmp ax, 0
				jne inner_out_loop

			inner_out_end:
				;end of inner output loop;
				cmp bx, 0
				jne out_one_char
				mov ax, '0'
				int 29h
				jmp out_tab

				out_one_char:
					pop ax
					int 29h
					dec bx
					cmp bx, 0
					jne out_one_char
				out_tab:
					mov ax, 09h
					int 29h
					loop number_loop

		mov ax, 0dh
		int 29h
		mov ax, 0ah
		int 29h

		pop bp
		pop di
		pop si
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	string_output ENDP

	main:
		mov ax, @data    
        mov ds, ax
        mov es, ax

        mov ah, 09h
		lea dx, input_N
		int 21h

		lea ax, N
		mov bx, 1
		call string_input

		mov ax, N
		cmp ax, 0
		je empty_lbl

		mov ah, 09h
		lea dx, input_M
		int 21h

		lea ax, M
		mov bx, 1
		call string_input

		mov ax, M
		cmp ax, 0
		je empty_lbl
		jmp after_empty

		empty_lbl:
			mov ah, 09h
			lea dx, input_error_empty
			int 21h
			jmp terminate

		after_empty:
		mov ah, 09h
		lea dx, input_A
		int 21h

		lea ax, A
		mov bx, 1
		call string_input

		mov ah, 09h
		lea dx, input_matrix
		int 21h

		mov cx, N
		lea ax, matrix
		xor dx, dx
		xor si, si

		row_input_loop:
			mov bx, M
			call string_input
			push cx
			mov cx, M

			mov dx, A
			do_null_loop:
				cmp dx, matrix[si]
				jge do_not_touch
				mov matrix[si], 0

				do_not_touch:
					add si, 2
					loop do_null_loop

			pop cx
			add ax, M
			add ax, M
			loop row_input_loop

		mov cx, N
		lea ax, matrix
		row_output_loop:
			mov bx, M
			call string_output
			add ax, M
			add ax, M
			loop row_output_loop
		jmp terminate


	    terminate:
	        mov ax,4c00h    
	        int 21h
	end main