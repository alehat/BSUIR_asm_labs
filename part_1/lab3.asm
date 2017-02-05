model small
.data
	divisor dw 10000
	diget dw 10
	a dw 300;
	b dw 10;
.stack 
	db 256 dup ('?')
.code
	output_value PROC
    	;save number in ax;
    	push ax 
    	push bx
    	push cx
    	push dx
    	push si

    	xor si, si
    	xor dx, dx
    	mov bx, divisor

    	;here we save '-' numbers;
    	cmp di, 1
    	jne output_cycle
    	push ax
    	;output '-';
    	mov ax, 45
    	int 29h
    	pop ax

    	;if output value is 0;
    	cmp ax, 0 
    	jne output_cycle

    	;symbol code that starts from zero;
    	add ax, 30h
    	int 29h
    	jmp output_end

    	output_cycle:

    		div bx
    		;there are no zeroes before the number (like 00032 (just 32))
    		cmp ax, si 
      		je output_next
    		;symbol code that starts from zero;
    		add ax, 30h
    		;fast console output (value in al);
    		int 29h
    		;must be > 10 (not zero value);
    		mov si, 15 
    	
    	output_next:
    		mov cx, dx
         	xor dx, dx
    		mov ax, bx
    		div diget
    		mov bx, ax
    		cmp bx, 0 
    		mov ax, cx
    		jne output_cycle

    	output_end:
        	;save all register value;
        	pop si
        	pop dx
        	pop cx
        	pop bx
        	pop ax
        	ret
    output_value ENDP

    
    input_value PROC
    	push bx
    	push cx
    	push dx
    	;number(kol-vo) of digits, that the user input ;
    	push si 

    	;here save value digits;
    	xor si, si
    	xor di, di

    	input_cycle:
           	xor ax, ax
        	mov ah, 01h
        	int 21h
               	

        	cmp al, 0dh
        	je input_handle

        	;check '-' in al;
        	cmp al, 45
        	jne not_a_minus
        	cmp di, 0
        	jne invalid_input
        	inc di
        	jmp input_cycle

		not_a_minus:
        	;<0;
        	cmp al, 30h
        	jc invalid_input

        	;>9;
        	cmp al, 40h
        	jnc invalid_input 

        	;check that input less than 5 digits;
        	cmp si, 5 
        	jnc invalid_input
        	

        	sub al, 30h
        	xor ah, ah 
        	push ax
        	inc si
        	jmp input_cycle

        input_handle:
        	xor bx, bx
        	xor cx, cx
        	xor dx, dx
        	mov bx, 1 
        	;tnen increase to 10, 100, 1000... (to 5 digits);

        handle_cycle:
        	xor ax, ax
        	;the last digit number;
        	pop ax 
        	dec si
        	
        	;input number, then multiplication 1 (then 10 100);
        	mul bx 
        	;if input digit 70000 (for ex.);
        	cmp dx, 0 
        	jne invalid_input
        	;cx = cx + al*bx;
        	add cx, ax 
        	;переход через разряд;
        	jc invalid_input 
        	
        	mov ax, bx
        	mul diget
        	mov bx, ax
        	xor dx, dx
        	cmp si, 0
        	jne handle_cycle
        	mov ax, cx
        	cmp di, 1
        	jne input_end
        	jmp input_end

        invalid_input:
        	pop ax 
        	dec si
        	
        	cmp si, 0
        	jne invalid_input

        	mov ax, 69
        	int 29h
        	mov ax, 82
        	int 29h
        	mov ax, 82
        	int 29h
        	mov ax, 79
        	int 29h
        	mov ax, 82
        	int 29h
        	mov ax, 33
          	int 29h
        	jmp terminate

        	mov ax, 0
        	jmp input_end
        

    	input_end:
    		;pop all to avoid values changes;
    		pop si
    		pop dx
       	 	pop cx
        	pop bx
        ret
    input_value ENDP
	
	main:
		mov ax, @data    
        mov ds, ax

		xor si, si     
        call input_value
        mov bx, ax
        add si, di
        call input_value
        mov cx, ax
        add si, di
        mov ax, bx
        xor dx, dx
        cmp cx, 0
        je divide_by_zero
        div cx
        mov di, si
        call output_value
        ;remainder' output;
        mov ax, 32
        int 29h
        mov ax, 114
        int 29h
        mov ax, 101
        int 29h
        mov ax, 109
        int 29h
        mov ax, 32
        int 29h
        mov ax, 40
        int 29h
        xor di, di
        mov ax, dx
        call output_value
        mov ax, 41
        int 29h
        jmp terminate

		divide_by_zero:
        	mov ax, 69
        	int 29h
        	mov ax, 82
        	int 29h
        	mov ax, 82
        	int 29h
        	mov ax, 79
        	int 29h
        	mov ax, 82
        	int 29h
        	mov ax, 33
          	int 29h
        	jmp terminate
         
        terminate:
        mov ax,4c00h    
        int 21h
 
	end main