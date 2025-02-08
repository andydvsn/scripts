#!/usr/bin/env bash

## unsplash.sh v0.01 (31st January 2025) by Andrew Davison
##  Mucking about with FBI.

wget -q -O /tmp/unsplash.jpg https://unsplash.it/800/480/?random
display -window root /tmp/unsplash.jpg
exit 0
