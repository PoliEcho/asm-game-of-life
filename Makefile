NASM = nasm
LD = ld

NASM_FLAGS := -felf64
LD_FLAGS := --strip-all 

SRC_PATH := src
OBJ_PATH := build/obj
BIN_PATH := build/bin

SRC_FILES := $(wildcard $(SRC_PATH)/*.asm)
OBJ_FILES := $(patsubst $(SRC_PATH)/%.asm,$(OBJ_PATH)/%.o,$(SRC_FILES))

all: make-build-dir $(BIN_PATH)/asm-game-of-life

make-build-dir:
	mkdir -p $(OBJ_PATH)
	mkdir -p $(BIN_PATH)


$(BIN_PATH)/asm-game-of-life: $(OBJ_FILES)
	$(LD) $(LD_FLAGS) $^ -o $@


$(OBJ_PATH)/%.o: $(SRC_PATH)/%.asm
	$(NASM) $(NASM_FLAGS) $< -o $@

clean:
	rm -fr build
