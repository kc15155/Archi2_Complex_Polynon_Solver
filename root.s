%macro before 0
	push		rbp
	mov		rbp, rsp
	finit
%endmacro

%macro after 0
	mov		rsp, rbp
	pop		rbp
	ret
%endmacro

section .data       
        temp1:	DQ 0.0
        temp2:	DQ 0.0
        length: DQ 0.0
        normal: DQ 0.0
        formalloc: DQ 0.0
        squared: DQ 0.0
        degree: DQ 0.0
        temp:   DQ 0.0
        tmp: DQ 0.0
        guessR: DQ 0.0
        guessI: DQ 0.0
        output: db "root = %.17g %.17g" , 10, 0
        epsilonInput: db "epsilon = %lf ", 0
        orderInput: db "order = %d ", 0
        coeffInput: db "coeff %d ", 0
        coeffValueInput: db "= %lf %lf ", 0
        initialI: db "initial = %lf %lf", 0
        
section .bss
        
        epsilon: resq 1  
        order: resq 1
        index: resq 1
        polynom: resq 1
        
section .text                    	
        global main
        extern malloc
	extern free
        extern printf
        extern __isoc99_scanf
        
    main:
        before
        mov rdi, epsilonInput  
        mov rsi, epsilon    
        mov rax, 0
        call __isoc99_scanf
        
        mov rdi, orderInput 
        mov rsi, order   
        mov rax, 0
        call __isoc99_scanf
        mov rax, qword [order]
        mov qword[degree], rax
        
        mov rax, 16
        mul qword[degree]        
        add rax, 16   
        mov rdi, rax
        call malloc
        mov qword[polynom], rax
        mov r11, qword[degree] 
        inc r11     
    
        .loop:
        mov rdi, coeffInput    
        mov rsi, index     
        mov rax, 0
        call __isoc99_scanf
        mov rsi, qword[polynom]  
        mov rax, 16  
        mov r12, qword [order]
        sub r12, qword [index]
        mul r12
        add rsi, rax         
        mov rdi, coeffValueInput
        lea rsi, [rsi] 
        lea rdx, [rsi + 8]   
        mov rax, 0
        call __isoc99_scanf
        
        dec r11
        cmp r11, 0
        jg .loop
        
        mov rdi, initialI
        lea rsi, [guessR]     
        lea rdx, [guessI]     
        mov rax, 0
        call __isoc99_scanf
        
        mov r14, qword [order]
        cmp r14, 0
        je badFinish
        
        mov rdi, qword [polynom]
        mov rsi, guessR
        mov rdx, guessI
        mov rcx, qword [degree]
        mov r8, epsilon
        call newtonAlgo
        after
        
    badFinish:
    
        mov r14, guessR
        mov r15, guessI
        jmp foundRoot
        
    addCom:
        before
        mov qword [r8], 0
        mov qword [r9], 0
	fld qword [rdi]		
	fst st1			
	fld qword [rdx]		
	fadd			
	fst qword [r8]		
	fld qword [rsi]		
	fst st1			
	fld qword [rcx]		
	fadd			
	fst qword [r9]	
	after

	
    mulCom:
        before
        mov qword [r8], 0
        mov qword [r9], 0
        fld qword [rdi]	
        fst st1			
	fld qword [rdx]		
	fmul
	fst qword [r8]
	fld qword [rsi]	
        fst st1			
	fld qword [rcx]		
	fmul
	fst st1
	fld qword [r8]
	fsub st1
	fst qword [r8]
	
	fld qword [rsi]	
        fst st1			
	fld qword [rdx]		
	fmul
	fst qword [r9]
	fld qword [rdi]	
        fst st1			
	fld qword [rcx]		
	fmul
	fst st1
	fld qword [r9]
	fadd
	fst qword [r9]
	after
	
    divCom:
        before
        mov qword [r8], 0
        mov qword [r9], 0
        fld qword [rdi]	
        fst st1			
	fld qword [rdx]		
	fmul
	fst qword [r8]
	fld qword [rsi]	
        fst st1			
	fld qword [rcx]		
	fmul
	fst st1
	fld qword [r8]
	fadd
	fst qword [r8]
	fld qword [rdx]
	fst st1
	fmul
	fst qword [temp1]
	fld qword [rcx]
	fst st1
	fmul
	fst st1
	fld qword [temp1]
	fadd
	fst st1
	fld qword [r8]
	fdiv st1
	fst qword [r8]
	
	fld qword [rsi]
	fst st1
	fld qword [rdx]
	fmul
	fst qword [temp1]
	fld qword [rdi]
	fst st1
	fld qword [rcx]
	fmul
	fst st1
	fld qword [temp1]
	fsub st1
	fst qword [r9]
	fld qword [rdx]
	fst st1
	fmul
	fst qword [temp1]
	fld qword [rcx]
	fst st1
	fmul
	fst st1
	fld qword [temp1]
	fadd
	fst st1
	fld qword [r9]
	fdiv st1
	fst qword [r9]
	after
	
    derivative:
    ;;  rdi - input((rdx+1)*2), rsi - output (rdx * 2),  rdx - degree of highest in input 
        before
        mov r14,0 ;j
        mov r15, rdx ;order (for loop)
        push rdx ;for backup
        push rdi
        mov rax, 2 
        mul rdx
        mov rdi, 8
        mul rdi
        mov rdi, rax ;real
        mov r12, rdi
        call malloc
        mov qword [temp2], rax
        mov rsi, qword [temp2]
        pop rdi
        pop rdx
        loop:
            cmp r15, 0
            je finishLoop
            
            mov r13, rdx ;length
            sub r13, r14
            
            mov [temp], r13
            fild qword [temp]
            fst st1
            fld qword [rdi]
            fmul
            fst qword [rsi]
        
            add rsi,8
            add rdi,8
            
            fild qword [temp]
            fst st1
            fld qword [rdi]
            fmul
            fst qword [rsi]
            
            add rdi, 8
            add rsi, 8
            inc r14
            dec r15
            jmp loop
            
        finishLoop:
            sub rsi, r12
            sub rdi, r12
            after
            
    evaluate:
    ;; rdi - guess (r),  rsi - guess(i),  rdx - result (r),  rcx - result (i),  r8 - degree of highest in rdi, r9 - input
     ;; we switch rdi/rsi and rdx/rcx in the beginning       
            before
            mov r14, rdi; backup guessR
            mov r15, rsi ;backup guessI
            mov r12, r8 ; INDEX
            mov r11, r8 ; backup for degree permanent
            mov r13, r9 ; input for later use
            mov r10, r9 ; backup input permanent
            push rdi
            push rsi
            mov rdi, rdx ; resR
            mov rsi, rcx ; resI
            pop rcx ; guessI
            pop rdx ; guessR
            add r13,8
            fld qword [r9] ;;
            fst qword [rdi]
            fld qword [r9+8] ;;
            fst qword [rsi]
            
        
            mov r8, qword [formalloc]
            add r8, 8
            mov r9, r8
            sub r8, 8
                loop2:
                push rdi
                push rsi
                cmp r12,0
                je finishEv
                call mulCom ;rdi/rsi - res, rdx/rcx - guess, r8/r9 - temp
                mov rdi, r8 ;rdi/rsi - temp
                mov rsi, r9
                add r13, 8
                mov rdx, r13  ; rdx/rcx - input
                add r13, 8
                mov rcx, r13
                pop r9 ;r8/r9 - res
                pop r8
                
                call addCom ; rdi/rsi - temp, rdx/rcx - input, r8/r9 - res
                ; r8,r9 -> rdi, rsi
                ; r14,r15 -> rdx,rcx
                ; rdi, rsi -> r8, r9
                mov rdx, r14 ;retrieve guess to rdx/rcx
                mov rcx, r15
                push r8
                push r9
                mov r8, rdi ; r8/r9 - temp
                mov r9, rsi
                pop rsi ; rdi/rsi - res
                pop rdi
                
                dec r12
                jmp loop2
            
                finishEv: ; rdi/rsi - res, rdx/rcx - guess, r8/r9 - temp
                ; we want rdi/rsi - guess, rdx/rcx - res, r8 - degree, r9 - input
                push rdi
                push rsi
                mov rdi, r14
                mov rsi, r15
                pop rcx
                pop rdx
                mov r8, r11
                mov r9, r10
                after
        newtonAlgo:
        ;; rdi -  input, rsi - guessR,  rdx - guessI, rcx - degree, r8 - epsilon (DOUBLE)
                before
                fld qword [r8]
                fst st1
                fmul st1
                fst qword [squared] ;squared now holds epsilon ^ 2
                mov qword [degree], rcx
                mov r14,rsi ; backup for guessR
                mov r15,rdx ; backup for guessI
                push r14
                push r15
                mov rdx, rcx
                call derivative
                ; rdi - input (unchanged), rsi - deriv of input, rdx - degree
                push rdi
                push rsi
                mov rdi, 64 ; 0-16 - polr,poli  16-32 - derr,deri  32-48 - divr,divi  
                call malloc
                mov qword [tmp], rax
                add rax, 48
                mov qword [formalloc], rax
                sub rax, 48
                pop rsi
                pop rdi
                pop r15
                pop r14
                mov r13, rsi ;backup for deriv
                push r13
                mov r9, rdi
                mov rdi, r14
                mov rsi, r15
                mov r8, qword [degree]
                mov rdx, qword [tmp]
                mov rcx, qword [tmp]
                add rcx, 8
                push r15
                call evaluate
                ; rdi/rsi - guess, rdx/rcx - result, r8 - degree, r9 - input
                pop r15
                add rcx,16
                add rdx,16
                pop r13
                push r9
                mov r9, r13
                mov r8, qword [degree]
                dec r8
                mov rdi, r14
                mov rsi, r15
                push r13
                push r15
                call evaluate
                ; rdi/rsi - guess, rdx/rcx - result (der), r8 - degree-1, r9 - deriv
                pop r15
                pop r13
                pop r9 ; r9 - input (deriv is in r13)
                sub rdx, 16
                push rdi
                push rsi
                push rdx
                push rcx
                push r8
                push r9
                push r13
                
                mov rdi,rdx
                add rdx, 8
                mov rsi, rdx
                add rdx, 8
                add rcx, 8
                mov r8, rcx
                add rcx, 8
                mov r9, rcx
                sub rcx, 16
                call divCom
                
                pop r13
                pop r9
                pop r8
                pop rcx
                pop rdx
                pop rsi
                pop rdi
                sub rcx, 16
                
                
                finit
                fld qword [rdx]
                fst st1
                fmul
                fst qword [temp1]
                fld qword [rcx]
                fst st1
                fmul
                fld qword [temp1]
                fadd
                fst qword [normal]
                fld qword [normal]
                fcomp qword [squared]
                fstsw ax
                sahf 
                jbe foundRoot
                
                checkIfFinished:
                finit
                fld qword [rdx+32]
                fst st1
                fld qword [r14]
                fsub st0, st1
                fst qword [r14]
                fld qword [rdx+40]
                fst st1
                fld qword [r15]
                fsub st0, st1
                fst qword [r15]

                finit
                mov rdi, r14
                mov rsi, r15
                mov r8, qword [degree]
                push r13
                call evaluate
                pop r13
                push r15
                ; rdi/rsi - guess, rdx/rcx - result, r8 - degree, r9 - input
                pop r15
                add rcx,16
                add rdx,16
                push r9
                mov r9, r13
                mov r8, qword [degree]
                dec r8
                mov rdi, r14
                mov rsi, r15
                push r13
                push r15
                call evaluate
                pop r15
                pop r13
                ; rdi/rsi - guess, rdx/rcx - result (der), r8 - degree-1, r9 - deriv
                pop r9 ; r9 - input (deriv is in r13)
                sub rdx, 16
                sub rcx, 16
                push rdi
                push rsi
                push rdx
                push rcx
                push r8
                push r9
                push r13
                mov rdi,rdx
                add rdx, 8
                mov rsi, rdx
                add rdx, 8
                add rcx, 16
                mov r8, rcx
                add r8, 8
                mov r9, rcx
                add r9,16
                call divCom
                pop r13
                pop r9
                pop r8
                pop rcx
                pop rdx
                pop rsi
                pop rdi
                
                finit
                fld qword [rdx]
                fst st1
                fmul
                fst qword [temp1]
                fld qword [rcx]
                fst st1
                fmul
                fld qword [temp1]
                fadd
                fst qword [normal]
                fld qword [normal]
                fcomp qword [squared]
                fstsw ax
                sahf 
                jbe foundRoot
                jmp checkIfFinished
                
                foundRoot:
                
                movsd xmm0, qword[r14]
                movsd xmm1, qword[r15]
                mov rdi, output
                mov rax, 2
                call printf 
                after
                
	
	
	
	
