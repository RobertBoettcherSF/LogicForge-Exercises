GNAT := gnatmake
FLAGS := -gnatwa -gnat2022 -gnata
OBJ_DIR := obj

.PHONY: all test play clean

all:
	mkdir -p $(OBJ_DIR)
	$(GNAT) $(FLAGS) -Psequence_match.gpr

test: all
	@$(OBJ_DIR)/tests

play: all
	@$(OBJ_DIR)/play

clean:
	rm -rf $(OBJ_DIR) tests play *.ali *.o
