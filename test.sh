#!/usr/bin/env bash
# Test Docker files
set -e

main() {
    for dockerfile in docker/*; do
        for profile in min dev; do
            sudo docker build --build-arg="PROFILE=${profile}" -f "${dockerfile}" .
        done
    done
}

main "${@}"
