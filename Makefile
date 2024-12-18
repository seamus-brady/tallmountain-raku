# convenience make class to run the Raku application and tests

# get the current directory
ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: all run test clean

all: run

# Run the TallMountain web application
run:
	raku ./bin/tm_webapp

# Run the TallMountain repl
repl:
	raku ./bin/tm_repl


# Run the tests using prove6
test:
	prove6 --lib t/

# Clean up temporary or compiled files
clean:
	rm -rf .precomp
