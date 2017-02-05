
; Protected mode martix solve
; developed by Vera Myshelova, 453502
; BSUIR 2016
;
; uses CWSDPMI host installed as system service under DOS


format MZ

include 'macro/proc32.inc'   ; enable using proc syntax

heap 0	 ; no additional memory


segment loader use16

	push	cs
	pop	ds

	mov	ax,1687h
	int	2Fh
	or	ax,ax			;Does DPMI installed?
	jnz	error
	test	bl,1			;Does 32-bit programs supported?
	jz	error
	mov	word [pr_mode_switch],di
	mov	word [pr_mode_switch+2],es

	mov	bx,si			; allocate memory for DPMI data
	mov	ah,48h
	int	21h
	jc	error
	mov	es,ax
	mov	ax,1
	call	far [pr_mode_switch]	 ; switch to protected mode
	jc	error

	mov	cx,1
	xor	ax,ax
	int	31h			; allocate descriptor for code
	mov	si,ax
	xor	ax,ax
	int	31h			; allocate descriptor for data
	mov	di,ax
	mov	dx,cs
	lar	cx,dx
	shr	cx,8
	or	cx,0C000h
	mov	bx,si
	mov	ax,9
	int	31h			; set code descriptor access rights
	mov	dx,ds
	lar	cx,dx
	shr	cx,8
	or	cx,0C000h
	mov	bx,di
	int	31h			; set data descriptor access rights
	mov	ecx,main
	shl	ecx,4
	mov	dx,cx
	shr	ecx,16
	mov	ax,7			; set descriptor base address
	int	31h
	mov	bx,si
	int	31h
	mov	cx,0FFFFh
	mov	dx,0FFFFh
	mov	ax,8			; set segment limit to 4 GB
	int	31h
	mov	bx,di
	int	31h

	mov	ds,di
	mov	es,di
	mov	fs,di
	mov	gs,di
	push	si
	push	dword start
	retfd

    error:
	mov	ax,4CFFh
	int	21h

 pr_mode_switch dd ?

segment main use32
proc outpp
 push ax
 push dx
.loop1:
lodsb
or al,al
jz contin
mov dl,al
mov ah,2
int 21h
jmp .loop1
contin:
pop dx
pop ax
ret
endp

	proc string_input
		push ax
		push bx
		push cx
		push dx
		push si
		push di
		push bp
		;count of read numbers;
		mov [num_read], 0
		mov [inp_expected], bl
		mov di, dx
	       ; mov ah, 0ah
	       ; lea dx, [max_size]
	       ; int 21h
	       ;lea dx,[bys]
		push di
		push cx
	       ; push bx
		;xor dx,dx
		xor bx,bx
		mov bx,0
		xor ax,ax

		lea di,[inp_str]
		inpa:

		 mov ah,1
		 int 21h

		 stosb
		 inc bl
		 cmp al,0dh
		 jnz inpa

		 dec bl
		 mov [char_read],bl
		; pop bx
		 pop cx
		 pop di

		;mov dx,bys

		xor ax, ax
		mov al, [char_read]
		mov si,inp_str
		add si,ax
		mov byte[si],' '
		inc [char_read]

		xor cx, cx
		mov cl, [char_read]
		lea si, [inp_str]

		xor ax, ax
		char_loop:
			lodsb
			cmp al, ' '
			jne next
			inc [num_read]
			mov [step], 1

			cmp [num_chars], 0
			jne inner_loop
			loop char_loop
			jmp after_error

			inner_loop:
				pop ax
				sub ax, '0'
				mul [step]
				add [di], ax
				mov ax, [step]
				mov dx, 10
				mul dx
				mov [step], ax
				dec [num_chars]
				cmp [num_chars], 0
				jne inner_loop

			add di, 2
			mov dl, [num_read]
			cmp dl, [inp_expected]
			je string_input_end
			loop char_loop
			jmp input_error

			next:
				cmp al, '0'
				jl input_error
				cmp al, '9'
				jg input_error
				push ax
				inc [num_chars]
				loop char_loop

	jmp string_input_end
	
	input_error:
		mov si,input_error_str
		call outp

	after_error:
		mov al, [num_read]
		cmp al, [inp_expected]
		je string_input_end
		mov si, input_less_than_expected
		call outp

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
	endp

	proc string_output
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
	endp
  proc outp

	.loop2:
	lodsb
	or al,al
	jz continue
	mov dl,al
	mov ah,2
	int 21h
	jmp .loop2
	continue:
	ret
endp

	proc maina
	mov si,mesg1
	call outp
	xor si,si

	mov si,input_N
	call outp

		mov dx, N
		mov bx, 1
		call string_input

		mov ax, word[N]
		cmp ax, 0
		je empty_lbl

		mov si,input_M
		call outp


		mov dx, M
		mov bx, 1
		call string_input

		mov ax, word[M]
		cmp ax, 0
		je empty_lbl
		jmp after_empty

	       empty_lbl:

			mov si, input_error_empty
			call outp
			jmp terminate

		after_empty:
		mov si,input_A
		call outp

		mov dx, A
		mov bx, 1
		call string_input

		mov si,input_matrix
		call outp

		mov cx,[N]
		;mov dx,matrix
		xor si, si
		xor di,di
		lea si,[matrix]
		lea di,[matrix]

		row_input_loop:
			mov bx,[M]
			mov dx,di
			call string_input
			push cx
			mov cx,[M]


			mov dx,[A]
			do_null_loop:
				cmp dx,[si]
				jge do_not_touch
				mov word[si],0

				do_not_touch:
					add si, 2
					loop do_null_loop

			pop cx

		       ; mov ,[cter]
			add di,[M]
			add di,[M]
			;mov [cter],bx
			loop row_input_loop

	       mov cx,[N]
	       mov ax,matrix
		row_output_loop:
			mov bx,[M]
			call string_output
			add ax,[M]
			add ax,[M]
			loop row_output_loop
		jmp terminate


	    terminate:
		mov si,mesg2
		call outp; exit from protected mode to dos's real mode
		mov ax,4c00h	
		int 21h
	endp

     start:
     call maina

    ;data
   tab db ' '
   bys db '2',0
   cter dw 0
   offset rw 1
   dop rw 1

	 max_size db 255
	 ;count of read symbol;
	 char_read db 0
	 inp_str db	256 dup (0)

	 char_readw dw 0
	 mesg1 db ' V8086 mode is successfully installed',0dh, 0ah, 0
	 mesg2 db 0dh, 0ah,'Successfully returning in real mode',0dh, 0ah, 0

	 input_N db "Input N:",0 ;rows count
	 input_M db "Input M:",0 ;cols count
	 input_A db "Input A:",0
	 input_matrix db "Input matrix NxM: ", 0dh, 0ah, 0
	 input_less_than_expected db 0dh, 0ah, "Input contains less amount of numbers than it was expected!", 0dh, 0ah, 0
     input_error_str db 0dh, 0ah, "Input error!", 0dh, 0ah, 0
     input_error_empty db "N or M cannot be 0!", 0dh, 0ah, 0
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










