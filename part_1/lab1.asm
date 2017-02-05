model small
.stack 100h
.data
	a dw 2;
	b dw 4;
	c dw 30;
	d dw 20;
.code
	main:
		mov ax,@data    
        mov ds,ax

        ;a*a;
        mov ax, a 
        mul a
        ;if (a*a == b);
        mov bx, b
        cmp ax, bx
        jnz a_a_equal_b
        jmp a_a_not_equal_b

        a_a_not_equal_b:
        	;computing c*b;
        	mov cx, c  
  			mov ax, bx
        	mul c ;result in ax:dx;
        	mov cx,ax
        	;result in cx;

        	;computing d/b;
        	xor dx, dx 
        	mov ax, d
        	cmp bx, 0
        	jz divide_by_zero
        	div bx
        	mov bx,ax
        	;result in bx;

        	;if (c*b > d/b);
        	cmp cx, bx
        	jz c_b_equal_d_b;
        	cmp cx, bx
          	jnc c_b_grater_d_b ;> true;
           
           	;if false;
	        c_b_equal_d_b:
	          	mov ax, c
	          	jmp terminate
          	
          	;if true;
        	c_b_grater_d_b:
        		xor ax, ax
        		mov ax, a
        		xor bx, bx
        		mov bx, b;
        		or ax, bx
        		jmp terminate

        a_a_equal_b:
        	mov ax, a
        	mul c ;result in аx:dx;
        	sub ax, b
        	jmp terminate

        divide_by_zero:
        	;division by zero;
        	nop
        	nop
        	nop
        	nop
        	nop

        terminate:
        	xor cx, cx
        	mov cx, ax
        	mov ax,4c00h    
        	int 21h
 
	end main

	