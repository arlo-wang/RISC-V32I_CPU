#!/bin/bash

# This script runs the testbench
# Usage: ./doit.sh <file1.cpp> <file2.cpp>

# Constants
SCRIPT_DIR="/root/Documents/Group-9-RISC-V/repo"
# TEST_FOLDER="/root/Documents/Group-9-RISC-V/repo/tb/tests"
# RTL_FOLDER="/root/Documents/Group-9-RISC-V/repo/rtl"
# SCRIPT_DIR=$(dirname "$(realpath "$0")")
TEST_FOLDER=$(realpath "$SCRIPT_DIR/tb/tests")
RTL_FOLDER=$(realpath "$SCRIPT_DIR/rtl")
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)
# echo "SCRIPT_DIR: $SCRIPT_DIR"
# echo "TEST_FOLDER: $TEST_FOLDER"
# echo "RTL_FOLDER: $RTL_FOLDER"
# Variables
passes=0
fails=0

# Handle terminal arguments
if [[ $# -eq 0 ]]; then
    # If no arguments provided, run all tests
    files=(${TEST_FOLDER}/*.cpp)
else
    # If arguments provided, use them as input files
    files=("$@")
fi

# Cleanup
rm -rf obj_dir

cd $TEST_FOLDER

# Iterate through files
for file in "${files[@]}"; do
    name=$(basename "$file" _tb.cpp | cut -f1 -d\-)
    
    # If verify.cpp -> we are testing the top module
    if [ $name == "verify.cpp" ]; then
        name="top"
    fi

    # Translate Verilog -> C++ including testbench
    verilator   -Wall --trace \
                -cc ${RTL_FOLDER}/${name}.sv \
                --exe ${file} \
                -y ${RTL_FOLDER} \
                --prefix "Vdut" \
                -o Vdut \
                -LDFLAGS "-lgtest -lgtest_main -lpthread" \

    # Build C++ project with automatically generated Makefile
    make -j -C obj_dir/ -f Vdut.mk

    # Run executable simulation file
    ./obj_dir/Vdut
    
    # Check if the test succeeded or not
    if [ $? -eq 0 ]; then
        ((passes++))
    else
        ((fails++))
    fi
    
done

# Exit as a pass or fail (for CI purposes)
if [ $fails -eq 0 ]; then
    echo "${GREEN}Success! All ${passes} test(s) passed!"
    #exit 0
else
    total=$((passes + fails))
    echo "${RED}Failure! Only ${passes} test(s) passed out of ${total}."
    #exit 0
fi