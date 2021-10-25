#!/bin/bash
set -x
hugo -D
git add -A
git commit -m "$1"
git push

# copy and push to ChaoChunHsu.github.io
cp -a docs/* ../ChaoChunHsu.github.io/
cd ../ChaoChunHsu.github.io/
git add -A
git commit -m "$1"
git push
