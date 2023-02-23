#!/bin/bash

set -e

# borrowed filepath from
# https://github.com/apple/swift-markdown/blob/main/bin/update-gh-pages-documentation-site

filepath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

ROOT_DIR="$(dirname $(filepath $0))"
#echo "filepath is $(filepath $0)"
#echo "ROOT_DIR is ${ROOT_DIR}"

# Enables deterministic output
# - useful when you're committing the results to host on github pages
export DOCC_JSON_PRETTYPRINT=YES

# Swift package plugin for hosted content:
#
$(xcrun --find swift) package \
    --allow-writing-to-directory ./docs \
    generate-documentation \
    --fallback-bundle-identifier com.github.ordo-one.package-benchmark \
    --target Benchmark \
    --output-path ./docs \
    --emit-digest \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path 'package-benchmark' \
    --source-service github \
    --source-service-base-url https://github.com/ordo-one/package-benchmark/blob/main \
    --checkout-path ${ROOT_DIR}

# -skip-synthesized-members

# Generate a list of all the identifiers to assist in DocC curation
#

cat docs/linkable-entities.json | jq '.[].referenceURL' -r | sort > all_identifiers.txt
sort all_identifiers.txt \
    | sed -e 's/doc:\/\/com\.github\.ordo-one\.package-benchmark\/documentation\///g' \
    | sed -e 's/^/- ``/g' \
    | sed -e 's/$/``/g' | sort > all_symbols.txt


echo "preview this stuff by running"
echo "swift package --disable-sandbox preview-documentation --target Benchmark"

echo "github pages docs available at https://heckj.github.io/package-benchmark/documentation/benchmark/"
