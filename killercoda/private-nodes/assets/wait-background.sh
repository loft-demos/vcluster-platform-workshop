#!/usr/bin/env bash
set -euo pipefail

# waits for background init to finish

rm $0

clear

echo -n "Initialising Docker..."
while [ ! -f /ks/.dockerfinished ]; do
    echo -n '.'
    sleep 1;
done;
echo " done"

echo -n "Initialising Scenario..."
while [ ! -f /ks/.initfinished ]; do
    echo -n '.'
    sleep 1;
done;
echo " done"

echo
