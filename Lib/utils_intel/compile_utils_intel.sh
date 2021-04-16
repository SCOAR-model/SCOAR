#!/bin/sh
set -ax

echo "inchour.f"
ifort inchour.f -o inchour.x
echo "incdte.f"
ifort incdte.f -o incdte.x
