[BITS    16]
[ORG 0x7C00]

%define WSCREEN 320
%define HSCREEN 200

BootMain:
        mov     ax, 0x13
        int     0x10

        mov     si, buffer

        fninit

;-------------------------------------------------

DrawReset:
        ;Print shell
        mov     ah, 0x0E
        mov     al, '>'
        mov     bl, 0x47
        int     0x10

        call    EnterInput

        mov     ah, 0x0C

        mov     cx, 0x00
        mov     dx, 0x0F

        jmp     Effect

        Draw:
                cmp     cx, WSCREEN
                jae     NextLine

                cmp     dx, HSCREEN
                jae     Restart
                
                int     0x10

                inc     cx

                jmp     Effect

        NextLine:
                xor     cx, cx
                inc     dx 
                
                jmp     Effect

Restart:
        xor     ax, ax
        int     0x16

        mov     ax, 0x03
        int     0x19

;-------------------------------------------------

Effect:
        mov     word [x], cx
        mov     word [y], dx

        mov     si, buffer
        call    ParseCommand

        mov     al, [calc]

        jmp     Draw

;-------------------------------------------------

EnterInput:
        mov     ax, 0x00
        int     0x16

        mov     ah, 0x0E
        mov     bl, 0x0F
        int     0x10

        mov     [si], al
        inc     si

        cmp     al, 0x0D
        jne     EnterInput

        mov     al, 0x00
        mov     [si], al

        ret

ParseCommand:
        mov     al, [si]

        cmp     al, 0x00
        je      parseEnd

        cmp     al, 'x'
        je      xCalc

        cmp     al, 'y'
        je      yCalc

        cmp     al, '+'
        je      addCalc

        cmp     al, '-'
        je      subCalc

        cmp     al, '^'
        je      xorCalc

        cmp     al, '*'
        je      mulCalc

        cmp     al, '/'
        je      divCalc

        cmp     al, '>'
        je      shrCalc

        cmp     al, '<'
        je      shlCalc

nextCalc:
        inc     si

        jmp     ParseCommand
        
parseEnd:
        ret

;-------------------------------------------------

xCalc:
        mov     word [calc], cx

        jmp     nextCalc

yCalc:
        mov     word [calc], dx

        jmp     nextCalc

addCalc:
        inc     si

        mov     al, [si]

        cmp     al, 'x'
        je      .addXpos

        cmp     al, 'y'
        je      .addYpos

        .addXpos:
                add     word [calc], cx

                jmp     nextCalc

        .addYpos:
                add     word [calc], dx

                jmp     nextCalc

subCalc:
        inc     si

        mov     al, [si]

        cmp     al, 'x'
        je      .subXpos

        cmp     al, 'y'
        je      .subYpos

        .subXpos:
                sub     word [calc], cx

                jmp     nextCalc

        .subYpos:
                sub     word [calc], dx

                jmp     nextCalc

mulCalc:
        inc     si

        mov     al, [si]

        cmp     al, 'x'
        je      .mulXpos

        cmp     al, 'y'
        je      .mulYpos

        .mulXpos:
                fild    dword [calc]
                fmul    dword [x]
                fstp    dword [calc]

                jmp     nextCalc

        .mulYpos:
                fild    dword [calc]
                fmul    dword [y]
                fstp    dword [calc]

                jmp     nextCalc

divCalc:
        inc     si

        mov     al, [si]

        cmp     al, 'x'
        je      .divXpos

        cmp     al, 'y'
        je      .divYpos

        .divXpos:
                fild    dword [calc]
                fild    dword [x]
                fdiv
                fstp    dword [calc]

                jmp     nextCalc

        .divYpos:
                fild    dword [calc]
                fild    dword [y]
                fdiv
                fstp    dword [calc]

                jmp     nextCalc

xorCalc:
        inc     si

        mov     al, [si]

        cmp     al, 'x'
        je      .xorXpos

        cmp     al, 'y'
        je      .xorYpos

        .xorXpos:
                xor     word [calc], cx

                jmp     nextCalc

        .xorYpos:
                xor     word [calc], dx

                jmp     nextCalc

shrCalc:
        shr     dword [calc], 1

        jmp     nextCalc

shlCalc:
        shl     dword [calc], 1

        jmp     nextCalc

;-------------------------------------------------

x: dd 0.0
y: dd 0.0
calc: dd 0.0

buffer: times 15 db 0x00

times 510 - ($ - $$) db 0x00
dw 0xAA55
