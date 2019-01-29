#!/bin/sh

setup_git() {
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

commit_website_files() {
#  git checkout -b gh-pages
#  git add ./ -A
  git add gcr-complete-tasks gcr-complete-images
  git commit --message "Travis build: $TRAVIS_BUILD_NUMBER"
}

upload_files() {
  git remote add origin https://${GH_TOKEN}@github.com/blademainer/google_containers_mirror.git > /dev/null 2>&1
  git push --quiet --set-upstream origin master
}

setup_git
commit_website_files
upload_files
