#!/bin/bash

for i in test_*; do
    sed -i '1s/^/`include "defines.vh"\n/' "$i"
done
