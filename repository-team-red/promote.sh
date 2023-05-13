#!/bin/zsh

appName=$1
if [ -z "$appName" ]
then
  echo "app name missing(arg 1)"
  exit
fi

echo "Initiating $appName promotion"

export PROMOTE_TAG=$(yq ".app.image.tag" $appName/image-preview.yaml)

echo "$appName is being promoted to '$PROMOTE_TAG'"
yq -i '.app.image.tag = env(PROMOTE_TAG)' $appName/image-production.yaml

git add $appName/image-production.yaml
git commit -m "[promote-production] $appName - $RELEASE_TAG"

echo "Promotion complete!"
