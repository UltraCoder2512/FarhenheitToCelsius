bits 64
default rel

section .data
    mulFactor dq 5
    divFactor dq 9
    subAmt dq 32.0
    fmt db "%lf C", 0xd, 0xa, 0

    wrongNumOfArgsError db "Incorrect usage. Correct usage: ftoc <Your float value>", 0xd, 0xa, 0

section .text
    extern printf
    extern ExitProcess
    extern strtod
    global main

    main:
        ;Set up stack
        push rbp
        mov rbp, rsp
        sub rsp, 32

        ;Get cli args
        mov r8, rcx
        mov r9, rdx
        cmp rcx, 2
        jne .wrong_num_ofargs

        mov rax, 1
        imul rax, 8
        add rax, r9

        ;Prepare for strtod
        mov rcx, [rax]
        mov rdx, 0

        ;Call strtod
        call strtod

        movsd xmm1, xmm0 

        ;Set up for calling ftoc
        call ftoc

        ;Set up for printf
        mov rcx, fmt
        movq rdx, xmm1
        mov rax, 1
        call printf

        ;Exit the program
        xor rax, rax
        call ExitProcess

        .wrong_num_ofargs:
            mov rcx, wrongNumOfArgsError
            mov rax, 0
            call printf
            mov rax, 1
            call ExitProcess

    ftoc:
        ;*Args: temp in f (xmm1) Returns: temp in c (xmm1)
        ;Set up stack
        push rbp
        mov rbp, rsp
        sub rsp, 32

        ;apply formula: (f - 32)*5/9
        subsd xmm1, [subAmt]
        mulsd xmm1, [mulFactor]
        divsd xmm1, [divFactor]

        ;exit
        leave
        ret