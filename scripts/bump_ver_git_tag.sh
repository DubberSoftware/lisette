#!/bin/bash -xv

# Exit script if you try to use an uninitialized variable.
set -o nounset

# Exit script if a statement returns a non-true return value.
set -o errexit

# Use the error status of the first failure, rather than that of the last item in a pipeline.
set -o pipefail

git config --global user.email "$CIRCLE_USERNAME""@dubber.net"
git config --global user.name "$CIRCLE_USERNAME"

if [[ "$NEW_TAG" ]]; then
    echo "Updating to $NEW_TAG"

    ./scripts/update_version.sh "${NEW_TAG}" ./

    git add .
    git diff-index --quiet HEAD || git commit -m "version bump by CircleCI ${NEW_TAG} [skip ci]"
    git push origin

    GIT_TAG="v${NEW_TAG}"
    DESCRIPTION=$CIRCLE_BUILD_URL
    git tag -a "$GIT_TAG" -m "$DESCRIPTION"
    echo "Tagged with $GIT_TAG"
    git push origin "$GIT_TAG"
else
    echo "no new tag version detected"
    exit 0
fi
