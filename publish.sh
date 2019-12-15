#!/bin/bash
set -x
hugo -D
git add -A
git commit -m "$1"
git push
cp -a docs/* ../joe32140.github.io/
cp -a docs/* ../ChaoChunHsu.github.io/
cd ../joe32140.github.io/
git add -A
git commit -m "$1"
git push
cd ../ChaoChunHsu.github.io/
git add -A
git commit -m "$1"
git push
