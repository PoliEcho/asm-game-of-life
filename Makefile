NASM = nasm
LD = ld

NASM_FLAGS := -felf64 -Isrc -Ox -Ov -w+all
LD_FLAGS := --strip-all 

DEBUG_LD_FLAGS := -g
DEBUG_NASM_FLAGS := -g -F dwarf

# check for avx2 support
ifeq ($(shell grep -o 'avx512[^ ]*' /proc/cpuinfo | head -n 1),avx512)
    NASM_FLAGS += -DAVX512
endif


SRC_PATH := src
OBJ_PATH := build/obj
BIN_PATH := build/bin

BIN_NAME := asm-game-of-life

SRC_FILES := $(wildcard $(SRC_PATH)/*.asm)
OBJ_FILES := $(patsubst $(SRC_PATH)/%.asm,$(OBJ_PATH)/%.o,$(SRC_FILES))

all: $(BIN_PATH)/$(BIN_NAME) | make-build-dir

debug: NASM_FLAGS += $(DEBUG_NASM_FLAGS)
debug: LD_FLAGS = $(DEBUG_LD_FLAGS)
debug: $(BIN_PATH)/$(BIN_NAME) | make-build-dir

make-build-dir:
	mkdir -p $(OBJ_PATH)
	mkdir -p $(BIN_PATH)


$(BIN_PATH)/$(BIN_NAME): $(OBJ_FILES) | make-build-dir
	$(LD) $(LD_FLAGS) $^ -o $@


$(OBJ_PATH)/%.o: $(SRC_PATH)/%.asm | make-build-dir
	$(NASM) $(NASM_FLAGS) $< -o $@

clean:
	rm -fr build
