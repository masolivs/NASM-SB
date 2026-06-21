extern _printf

; %define: substitui um nome por texto em tempo de montagem, com ou sem parametros.
; soma(6,7) e quadrado(5) serao substituidos por ((6)+(7)) e ((5)*(5)) antes de gerar qualquer opcode.
%define NEWLINE     10
%define SYS_OK      0
%define soma(a,b)   ((a)+(b))
%define quadrado(x) ((x)*(x))


; %idefine: funciona como %define, mas ignora maiusculas e minusculas no nome.
; qualquer variacao de "gato" (Gato, GATO, GaTo) expande para 1.
%idefine gato 1

; %define vs %xdefine: diferenca entre expansao tardia e congelada.
; %define armazena o texto "BASE" e so expande quando TARD for usado;
; %xdefine expande BASE imediatamente e congela o valor no momento da definicao.
; ao redefinir BASE para 99, TARD passa a valer 99 e IMEDI continua valendo 10.
%define  BASE       10
%define  TARD       BASE        ; armazena o texto "BASE", expande na invocacao
%xdefine IMEDI      BASE        ; congela BASE=10 agora
%define  BASE       99          ; TARD->99, IMEDI permanece 10

; %assign: define macro numerica avaliando a expressao imediatamente.
; diferente do %define, permite redefinicao; cada linha recalcula CONT.
; ao final das tres reatribuicoes, CONT vale 3.
%assign CONT 0
%assign CONT CONT+1
%assign CONT CONT+1
%assign CONT CONT+1             ; CONT = 3

; %strlen: conta os caracteres de uma string em tempo de montagem e atribui o resultado a uma macro.
; TAM_TEXTO recebe 15, que e o comprimento de 'Software Basico'.
%define TEXTO 'Software Basico'
%strlen TAM_TEXTO TEXTO         ; TAM_TEXTO = 15

; %substr: extrai um caractere de uma string pelo indice (base 1) em tempo de montagem.
; CHAR_1 recebe 'N' e CHAR_3 recebe 'S'; os valores ja sao codigos ASCII no objeto gerado.
%substr CHAR_1 'NASM' 1         ; CHAR_1 = 'N' (0x4E)
%substr CHAR_3 'NASM' 3         ; CHAR_3 = 'S' (0x53)

; %+: concatena dois tokens em tempo de montagem formando um novo identificador.
; reg_%+ax une "reg_" (definido como "e") com "ax", resultando em "eax".
%define reg_ e

; %undef: remove uma macro do escopo a partir desta linha.
; qualquer referencia a REMOVIDA apos o %undef causa erro de montagem.
%define REMOVIDA 777
%undef  REMOVIDA

section .data
    fmt_str     db  '%s', NEWLINE, 0
    fmt_int     db  '%s %d', NEWLINE, 0
    fmt_char    db  '%s %c', NEWLINE, 0

    hdr         db  '=== Macros de Unica Linha - NASM ===', 0
    msg_def1    db  '[%define] soma(6,7)    =', 0
    msg_def2    db  '[%define] quadrado(5)  =', 0
    msg_idef    db  '[%idefine] GaTo =', 0
    msg_tard    db  '[%define]  TARD (BASE=99) =', 0
    msg_imedi   db  '[%xdefine] IMEDI (congelado em 10) =', 0
    msg_cont    db  '[%assign] CONT apos 3 incrementos =', 0
    msg_strlen  db  '[%strlen] len("Software Basico") =', 0
    msg_sub1    db  "[%substr] 'NASM'[1] =", 0
    msg_sub3    db  "[%substr] 'NASM'[3] =", 0
    msg_concat  db  '[%+] reg_%+ax -> eax; valor =', 0
    msg_undef   db  '[%undef] REMOVIDA destruida (referencia causaria erro de montagem)', 0
    footer      db  '=====================================', 0

section .bss

section .text
global _main

_main:
    push ebp
    mov  ebp, esp

    push hdr
    push fmt_str
    call _printf
    add  esp, 8

    ; soma(6,7) expande para ((6)+(7)); o montador resolve para 13 antes de gerar o opcode
    push soma(6,7)
    push msg_def1
    push fmt_int
    call _printf
    add  esp, 12

    ; quadrado(5) expande para ((5)*(5)) = 25
    push quadrado(5)
    push msg_def2
    push fmt_int
    call _printf
    add  esp, 12

    ; GaTo e reconhecido como "gato" pelo %idefine e expande para 1
    mov  eax, GaTo
    push eax
    push msg_idef
    push fmt_int
    call _printf
    add  esp, 12

    ; TARD expande BASE agora, quando BASE ja vale 99
    push TARD
    push msg_tard
    push fmt_int
    call _printf
    add  esp, 12

    ; IMEDI foi congelado em 10 pelo %xdefine; redefinir BASE nao o afeta
    push IMEDI
    push msg_imedi
    push fmt_int
    call _printf
    add  esp, 12

    ; CONT vale 3; o montador ja calculou os tres incrementos, push gera "push 3"
    push CONT
    push msg_cont
    push fmt_int
    call _printf
    add  esp, 12

    ; TAM_TEXTO vale 15; mov eax, TAM_TEXTO vira "mov eax, 15" no objeto
    mov  eax, TAM_TEXTO
    push eax
    push msg_strlen
    push fmt_int
    call _printf
    add  esp, 12

    ; CHAR_1 vale 0x4E ('N'); movzx estende o byte para 32 bits sem sinal antes do push
    mov  al, CHAR_1
    movzx eax, al
    push eax
    push msg_sub1
    push fmt_char
    call _printf
    add  esp, 12

    ; CHAR_3 vale 0x53 ('S')
    mov  al, CHAR_3
    movzx eax, al
    push eax
    push msg_sub3
    push fmt_char
    call _printf
    add  esp, 12

    ; reg_%+ax e concatenado para "eax" antes da montagem; as duas linhas viram mov eax e push eax
    mov  reg_%+ax, 2024
    push reg_%+ax
    push msg_concat
    push fmt_int
    call _printf
    add  esp, 12

    ; REMOVIDA foi destruida pelo %undef; descomente a linha abaixo para ver o erro de montagem:
    ; mov eax, REMOVIDA
    push msg_undef
    push fmt_str
    call _printf
    add  esp, 8

    push footer
    push fmt_str
    call _printf
    add  esp, 8

    mov  eax, SYS_OK
    pop  ebp
    ret