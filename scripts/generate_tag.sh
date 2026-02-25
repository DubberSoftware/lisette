#!/bin/bash

# In CircleCI, we can't set debug and verbose on the shebang line because it's ignored so set it here
set -xv

# Set Error flags: https://circleci.com/docs/using-shell-scripts/#set-error-flags

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
MAJOR="${VERSION%%.*}"; VERSION="${VERSION#*.}"
MINOR="${VERSION%%.*}"; VERSION="${VERSION#*.}"
PATCH="${VERSION%%.*}"; VERSION="${VERSION#*.}"

# Get current hash and see if it already has a tag
GIT_COMMIT=$(git rev-parse HEAD)
NEEDS_TAG=$(git describe --contains "$GIT_COMMIT" 2> /dev/null) && exit_status=0 || exit_status=$?
COMMIT_MESSAGE=$(git log --format=oneline -n 1 "$CIRCLE_SHA1")

echo "COMMIT_MESSAGE: $COMMIT_MESSAGE" 

COMMIT_MESSAGE_LOWER_CASE=${COMMIT_MESSAGE,,}

case $COMMIT_MESSAGE_LOWER_CASE in
    *"-no-tag"*)
        echo "Not tagging as the '-no-tag' flag was found in the commit message"
        exit 0
        ;;
    *"-major"*)
        echo "Tag flag '-major' found in commit message, bumping MAJOR version"
        MAJOR=$((MAJOR+1))
        MINOR=0
        PATCH=0
        ;;
    *"-minor"*)
        echo "Tag flag '-minor' found in commit message, bumping MINOR version"
        MINOR=$((MINOR+1))
        PATCH=0
        ;;
    *"-patch"*)
        echo "Tag flag '-patch' found in commit message, bumping PATCH version"
        PATCH=$((PATCH+1))
        ;;
    *)
        echo "No explicit tag flag found in commit message, defaulting to PATCH version bump"
        PATCH=$((PATCH+1))
        ;;
esac

if [[ -z "$NEEDS_TAG" && ! $exit_status -eq 0 ]]; then
    # Create new tag
    NEW_TAG="$MAJOR.$MINOR.$PATCH"

    # append an export command to CCI $BASH_ENV file to persist the NEW_TAG for subsequent CCI steps
    # shellcheck disable=SC2016
    echo 'export NEW_TAG='"$NEW_TAG" >> "$BASH_ENV"
else
    echo "Already has a tag on this commit"

    # Terminate this job early as we don't need to run the rest of the steps
    circleci-agent step halt
fi
