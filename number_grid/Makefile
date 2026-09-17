GNAT := gnatmake
FLAGS := -gnatwa -gnat2022 -gnata
OBJ_DIR := obj

.PHONY: all test clean

all:
	mkdir -p $(OBJ_DIR)
	$(GNAT) $(FLAGS) -Pnumber_grid.gpr

test: all
	@$(OBJ_DIR)/tests 2>/dev/null || ./tests

clean:
	rm -rf $(OBJ_DIR) tests *.ali *.o
