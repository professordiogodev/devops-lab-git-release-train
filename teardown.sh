#!/usr/bin/env bash
# Removes what this lab created. Run with: ./teardown.sh
rm -rf "${LAB_HOME:-$HOME/git-lab}"
echo "Lab environment removed."
