#!/bin/sh
set -e

INPUT_BRANCH=${INPUT_BRANCH:-master}
INPUT_FORCE=${INPUT_FORCE:-false}
INPUT_TAGS=${INPUT_TAGS:-false}
INPUT_DIRECTORY=${INPUT_DIRECTORY:-'.'}
_FORCE_OPTION=''
REPOSITORY=${INPUT_REPOSITORY:-$GITHUB_REPOSITORY}

echo "Push to branch $INPUT_BRANCH";
[ -z "${INPUT_GITHUB_TOKEN}" ] && {
    echo 'Missing input "github_token: ${{ secrets.GITHUB_TOKEN }}".';
    exit 1;
};

if ${INPUT_FORCE}; then
    _FORCE_OPTION='--force'
fi

if ${TAGS}; then
    _TAGS='--tags'
fi

cd ${INPUT_DIRECTORY}

remote_repo="https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${REPOSITORY}.git"

node_modules/gulp/bin/gulp.js

git push ${remote_repo} --delete gh-pages || echo Branch not found
git checkout -b gh-pages

ls -l

mkdir web
mv css web/
mv img web/
mv scss web/
mv index.html web/
mv vendor web

shopt -s extglob
rm -rf !(web)
mv web/* ./ && rm -rf web/

git config user.name ${GITHUB_ACTOR}
git config user.email ${GITHUB_ACTOR}@gmail.com
git add .
git commit -m "New site fixes - $(date)"
git push "${remote_repo}" HEAD:${INPUT_BRANCH} --follow-tags $_FORCE_OPTION $_TAGS;

exit

git add .
git commit -m "New deploy - $(date)"
git push "${remote_repo}" HEAD:${INPUT_BRANCH} --follow-tags $_FORCE_OPTION $_TAGS;

curl https://stefanos1316.github.io/programmers_blog/ || echo Failed to load
curl https://stefanos1316.github.io/programmers_blog/index.html || echo Failed to load
