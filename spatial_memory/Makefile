GNAT    := gnatmake
FLAGS   := -gnatwa -gnat2022
OBJ_DIR := obj
BIN_DIR := bin

.PHONY: all test play clean

all: $(BIN_DIR)/tests $(BIN_DIR)/play

$(BIN_DIR)/tests $(BIN_DIR)/play: *.ads *.adb *.gpr
	mkdir -p $(OBJ_DIR) $(BIN_DIR)
	$(GNAT) $(FLAGS) -Pspatial_memory.gpr

test: all
	@echo "Running tests..."
	@$(BIN_DIR)/tests

play: all
	@$(BIN_DIR)/play

clean:
	rm -rf $(OBJ_DIR) $(BIN_DIR)
