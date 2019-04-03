#!/bin/bash
dir=`pwd`
setup_git() {
  git config user.email "travis@travis-ci.org"
  git config user.name "TravisCI"
}

upload_files() {
#  git checkout -b gh-pages
#  git add ./ -A
  pwd
  git status
  git add ./
  git commit -m "Travis build: $TRAVIS_BUILD_NUMBER"
  REPO="https://${GH_TOKEN}@github.com/blademainer/google_containers_mirror_completed_list.git"
#  REMOTE_REF="tasks"
#  [ -n "`git remote | grep $REMOTE_REF`" ] && git remote remove ${REMOTE_REF}
#  git remote add ${REMOTE_REF} https://${GH_TOKEN}@github.com/blademainer/google_containers_mirror.git
#  git push --quiet --set-upstream tasks master
#  git pull ${REMOTE_REF} master && 
#  git push ${REMOTE_REF} master
  git pull "$REPO" master && git push "$REPO" master
}

cd google_containers_mirror_completed_list
setup_git
#commit_website_files
upload_files

cd "$dir"
