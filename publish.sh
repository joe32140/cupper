#!/bin/bash
set -x
git add -A
git commit -m "$1"
git push
cd ~/joe32140.github.io/
git add -A
git commit -m "$1"
git push
