#!/bin/bash

setup_git() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

commit_website_files() {
#  git checkout -b gh-pages
#  git add ./ -A
  git status
  git add ./ -A
  git commit --message "Travis build: $TRAVIS_BUILD_NUMBER"
}

upload_files() {
  git remote add tasks https://${GH_TOKEN}@github.com/blademainer/google_containers_mirror.git
#  git push --quiet --set-upstream tasks master
  git push --set-upstream tasks master
}

setup_git
commit_website_files
upload_files
