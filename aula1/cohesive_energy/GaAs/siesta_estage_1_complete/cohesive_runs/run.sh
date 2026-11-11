#!/bin/bash
# Run SIESTA in every folder that contains a calc.fdf

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mapfile -t FDFS < <(find "$ROOT" -name calc.fdf | sort)

for fdf in "${FDFS[@]}"; do
    dir="$(dirname "$fdf")"
    echo ">>> Running in: ${dir#$ROOT/}"
    (cd "$dir" && mpirun -np 2 siesta calc.fdf --out calc.out < /dev/null) \
        || echo "!!! Failed in: ${dir#$ROOT/}"
done

echo "Done."
