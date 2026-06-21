# Makefile - macros_linha (MSYS2 UCRT32)
# Uso:
#   make        -> monta e linka
#   make lst    -> exibe expansoes do listing
#   make clean  -> remove arquivos gerados

ASM    = nasm
CC     = gcc
TARGET = macros_linha.exe
SRC    = macros_linha.asm
OBJ    = macros_linha.obj
LST    = macros_linha.lst

.PHONY: all lst clean

all: $(TARGET)

$(OBJ): $(SRC)
	$(ASM) -f win32 -l $(LST) $(SRC)

$(TARGET): $(OBJ)
	$(CC) -m32 -o $@ $<

lst: $(LST)
	@echo "=== Expansoes no listing ==="
	@grep -E "define|idefine|xdefine|undef|assign|strlen|substr|soma|quadrado|TARD|IMEDI|CONT|TAM|CHAR_|reg_" $(LST) | head -60

clean:
	rm -f $(OBJ) $(LST) $(TARGET)
