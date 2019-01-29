#!/bin/bash

setup_git() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

commit_website_files() {
#  git checkout -b gh-pages
#  git add ./ -A
  git status
  git add gcr-complete-images gcr-complete-images & git add ./ -A
  git commit -a --message "Travis build: $TRAVIS_BUILD_NUMBER"
}

upload_files() {
  REMOTE_REF="tasks"
  [ -n "`git remote | grep $REMOTE_REF`" ] && git remote remove ${REMOTE_REF}
  git remote add ${REMOTE_REF} https://${GH_TOKEN}@github.com/blademainer/google_containers_mirror.git
#  git push --quiet --set-upstream tasks master
    git pull && git push --set-upstream ${REMOTE_REF} master
}

setup_git
commit_website_files
upload_files
