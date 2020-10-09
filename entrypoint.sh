#!/bin/bash

set -e

if [ -z "$GITHUB_TOKEN" ]; then
	echo "Set the GITHUB_TOKEN env variable."
	exit 1
fi

default_semvar_bump=${BUMP:-minor}
with_v=${WITH_V:-true}

repo_fullname=$(jq -r ".repository.full_name" "$GITHUB_EVENT_PATH")

git remote set-url origin https://x-access-token:$GITHUB_TOKEN@github.com/$repo_fullname.git
git config --global user.email "actions@github.com"
git config --global user.name "GitHub Merge Action"

set -o xtrace

git fetch origin $BRANCH
git checkout $BRANCH

# get latest tag
tag=$(git tag --sort=-creatordate | head -n 1)
echo "tag before latest check: $tag"
tag_commit=$(git rev-list -n 1 $tag)

# get current commit hash for tag
commit=$(git rev-parse HEAD)

if [ "$tag_commit" == "$commit" ]; then
    echo "No new commits since previous tag. Skipping..."
    exit 0
fi

if [ "$tag" == "latest" ]; then
    tag=$(git tag --sort=-creatordate | head -n 2 | tail -n 1)
fi

echo "tag before update: $tag"
# if there are none or it's still latest or v, start tags at 0.0.0
if [ -z "$tag" ] || [ "$tag" == "latest" ] || [ "$tag" == "v" ]; then
    echo "Tag does not mmatch semver scheme X.Y.Z(-PRERELEASE)(+BUILD). Changing to 0.0.0'"
    tag="0.0.0"
fi

new=$(semver bump $default_semvar_bump $tag);

if [ "$new" != "none" ]; then
    # prefix with 'v'
    if $with_v; then
        new="v$new"
    fi
    echo "new tag: $new"

    # push new tag ref to github
    dt=$(date '+%Y-%m-%dT%H:%M:%SZ')
    full_name=$GITHUB_REPOSITORY

    echo "$dt: **pushing tag $new to repo $full_name"

    git tag -a -m "release: ${new}" $new $commit
fi

git push origin :refs/tags/latest
git tag -fa -m "latest release" latest $commit
git push --follow-tag