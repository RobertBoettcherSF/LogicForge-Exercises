GNAT := gnatmake
FLAGS := -gnatwa -gnat2022
.PHONY: all test play clean
all: bin/tests bin/play
bin/tests bin/play: *.ads *.adb *.gpr
	mkdir -p obj bin
	$(GNAT) $(FLAGS) -Pelement_pick.gpr
test: all
	@bin/tests
play: all
	@bin/play
clean:
	rm -rf obj bin
