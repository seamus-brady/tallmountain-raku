# convenience make class to run the Raku application and tests

.PHONY: all run test clean

all: run

# Run the Raku application
run:
	raku ./bin/app

# Run the tests using prove6
test:
	prove6 --lib t/

# Clean up temporary or compiled files
clean:
	rm -rf .precomp
