#!/bin/bash -xv

# Exit script if you try to use an uninitialized variable.
set -o nounset

# Exit script if a statement returns a non-true return value.
set -o errexit

# Use the error status of the first failure, rather than that of the last item in a pipeline.
set -o pipefail

VERSION=$1
DIRECTORY=$2

echo "bumping version in $DIRECTORY"

# Update version in pyproject.toml and lisette/__init__.py
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^version = \".*\"/version = \"$VERSION\"/" "$DIRECTORY/pyproject.toml"
    sed -i '' "s/^__version__ = \".*\"/__version__ = \"$VERSION\"/" "$DIRECTORY/lisette/__init__.py"
else
    # Linux
    sed -i "s/^version = \".*\"/version = \"$VERSION\"/" "$DIRECTORY/pyproject.toml"
    sed -i "s/^__version__ = \".*\"/__version__ = \"$VERSION\"/" "$DIRECTORY/lisette/__init__.py"
fi
