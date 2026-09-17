GNAT := gnatmake
FLAGS := -gnatwa -gnat2022
.PHONY: all test play clean
all: bin/tests bin/play
bin/tests bin/play: *.ads *.adb *.gpr
	mkdir -p obj bin
	$(GNAT) $(FLAGS) -Pround_tens.gpr
test: all
	@echo "Running tests..."
	@bin/tests
play: all
	@bin/play
clean:
	rm -rf obj bin
