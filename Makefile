# convenience make class to run the Raku application and tests

# get the current directory
ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

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
