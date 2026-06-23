extern _printf ; função printf da libc

; %define: substitui um nome por um valor. nenhuma operação ocorre em tempo de execução
%define NEWLINE     10 
%define SYS_OK      0
%define soma(a,b)   ((a)+(b))
%define quadrado(x) ((x)*(x))

; %idefine: parecida com a %define, mas não é case sensitive (gato, gaTo, GATO expandem para 1) 
%idefine gato 1

; %define (expansão tardia) x %xdefine (expansão congelada) 
%define  BASE       10
%define  TARD       BASE    ; TARD guarda o nome "BASE", não o valor  
%xdefine IMEDI      BASE    ; IMEDI lê BASE agora e guarda 10    
%define  BASE       99      ; BASE vale 99, TARD passa a valer 99, IMEDI continua 10 (expansão congelada)   

; %assign: funciona como um contador, seu valor pode ser atualizado
%assign CONT 0
%assign CONT CONT+1
%assign CONT CONT+1
%assign CONT CONT+1      ; no final CONT = 3       

; %strlen:  conta os caracteres da string e armazena em TAM_TEXTO (é só uma constante)
%define TEXTO 'Software Basico'
%strlen TAM_TEXTO TEXTO  ; TAM_TEXTO = 15       

; %substr: pega um caractere pelo índice, começa pelo 1, resultado em ASCII
%substr CHAR_1 'NASM' 1         ; CHAR_1 = 'N' (0x4E)
%substr CHAR_3 'NASM' 3         ; CHAR_3 = 'S' (0x53)

; %+: guarda "e" e cola com "ax" na main, formando "eax"
%define reg_ e

; %undef: remove macro a partir da linha dele, o que está abaixo causa erro de montagem
%define REMOVIDA 777
%undef  REMOVIDA

section .data
    fmt_str     db  '%s', NEWLINE, 0  ; imprime texto
    fmt_int     db  '%s %d', NEWLINE, 0  ; imprime texto + número
    fmt_char    db  '%s %c', NEWLINE, 0  ; imprime texto + um caractere

    cabecalho   db  '== Macros de Linha - Nasm ==', 0
    msg_def1    db  '[%define] soma(6,7)    =', 0
    msg_def2    db  '[%define] quadrado(5)  =', 0
    msg_idef    db  '[%idefine] GaTo =', 0
    msg_tard    db  '[%define]  TARD (BASE=99) =', 0
    msg_imedi   db  '[%xdefine] IMEDI (congelado em 10) =', 0
    msg_cont    db  '[%assign] CONT apos 3 incrementos =', 0
    msg_strlen  db  '[%strlen] len("Software Basico") =', 0
    msg_sub1    db  "[%substr] 'NASM'[1] =", 0
    msg_sub3    db  "[%substr] 'NASM'[3] =", 0
    msg_concat  db  '[%+] eax = ', 0
    msg_undef   db  '[%undef] REMOVIDA foi destruida', 0
    footer      db  '============================', 0

section .text
global _main

_main:
    push ebp   ; salva o ebp de quem chamou a função
    mov  ebp, esp    ; ebp aponta para o topo da pilha 

    ; começo da pilha, arguemntos de trás pra frente
    push cabecalho
    push fmt_str
    call _printf
    add  esp, 8  ; 2 pushs do formato x 4 bytes

    push soma(6,7) ; expande para 13 em tempo de montagem
    push msg_def1
    push fmt_int
    call _printf
    add  esp, 12 ; 3 pushes x 4 bytes

    push quadrado(5) ; expande para 25 em tempo de montagem
    push msg_def2
    push fmt_int
    call _printf
    add  esp, 12 ; 3 pushes x 4 bytes

    mov  eax, GaTo ; GaTo é reconhecido pelo %idefine, logo vale 1. uso de eax pois é uma constante, não ee
    push eax
    push msg_idef
    push fmt_int
    call _printf
    add  esp, 12

    push TARD ; TARD guarda BASE, agora vale 99
    push msg_tard
    push fmt_int
    call _printf
    add  esp, 12

    push IMEDI ; IMEDI continua 10 por causa do %xdefine
    push msg_imedi
    push fmt_int
    call _printf
    add  esp, 12

    push CONT  ; CONT = 3 pelos incrementos em tempo de montagem
    push msg_cont
    push fmt_int
    call _printf
    add  esp, 12

    mov  eax, TAM_TEXTO ; TAM_TEXTO = 15 pelo %strlen
    push eax
    push msg_strlen
    push fmt_int
    call _printf
    add  esp, 12

    ; CHAR_1 e CHAR_3 são um byte ASCII ('N' de CHAR_1 e 'S' de CHAR_3)
    mov  al, CHAR_1
    movzx eax, al ; estende para 32 bits zerando os bits altos
    push eax
    push msg_sub1
    push fmt_char
    call _printf
    add  esp, 12
    mov  al, CHAR_3
    movzx eax, al
    push eax
    push msg_sub3
    push fmt_char
    call _printf
    add  esp, 12

    mov  reg_%+ax, 2024 ; reg_%+ax vira eax em tempo de montagem
    push reg_%+ax
    push msg_concat
    push fmt_int
    call _printf
    add  esp, 12

    ; mov eax, REMOVIDA - DESCOMENTE PARA ERRO NA MONTAGEM
    push msg_undef
    push fmt_str
    call _printf
    add  esp, 8

    push footer
    push fmt_str
    call _printf
    add  esp, 8

    ; restaura ebp e retorna código com 0
    mov  eax, SYS_OK
    pop  ebp 
    ret  