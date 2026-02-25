#!/bin/bash -xv

# Exit script if you try to use an uninitialized variable.
set -o nounset

# Exit script if a statement returns a non-true return value.
set -o errexit

# Use the error status of the first failure, rather than that of the last item in a pipeline.
set -o pipefail

DIRECTORY=$1

if [[ -z "$DIRECTORY" ]]; then
    echo "directory to pyproject.toml must be provided."
    exit 1
fi

VERSION=$(grep '^version = "' "$DIRECTORY/pyproject.toml" | sed 's/.*version = "\(.*\)"/\1/')
GIT_HASH=$(git rev-parse --short HEAD)
NEW_VERSION="${VERSION}.dev+${GIT_HASH}"

# Update version in pyproject.toml and lisette/__init__.py
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' 's|^version = ".*"|version = "'"$NEW_VERSION"'"|' "$DIRECTORY/pyproject.toml"
    sed -i '' 's|^__version__ = ".*"|__version__ = "'"$NEW_VERSION"'"|' "$DIRECTORY/lisette/__init__.py"
else
    # Linux
    sed -i 's|^version = ".*"|version = "'"$NEW_VERSION"'"|' "$DIRECTORY/pyproject.toml"
    sed -i 's|^__version__ = ".*"|__version__ = "'"$NEW_VERSION"'"|' "$DIRECTORY/lisette/__init__.py"
fi
