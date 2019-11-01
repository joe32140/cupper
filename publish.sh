#!/bin/bash
set -x
git add -A
git commit -m "$1"
git push
cp -a docs/* ../joe32140.github.io/
cd ../joe32140.github.io/
git add -A
git commit -m "$1"
git push
