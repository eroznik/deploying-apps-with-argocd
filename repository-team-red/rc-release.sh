#!/bin/zsh

appName=$1
if [ -z "$appName" ]
then
  echo "app name missing(arg 1)"
  exit
fi

export RELEASE_TAG=$2
if [ -z "$RELEASE_TAG" ]
then
  echo "release tag missing(arg 2)"
  exit
fi

echo "Initiating $appName RC release"

echo "$appName preview is being updated to '$RELEASE_TAG'"
yq -i '.app.image.tag = env(RELEASE_TAG)' $appName/image-preview.yaml

git add $appName/image-preview.yaml
git commit -m "[rc] $appName - $RELEASE_TAG"

echo "Release complete!"
