#!/bin/bash

function incr(){
    echo "1" >> counter.tmp
}

function reached(){
    cat counter.tmp | wc -l
}

maxCount=10
cat git_push.sh | while read f; do
  cat gcr.sh | while read g; do
      incr
      [ $(reached) -gt $maxCount ] && echo "inner reach max: 10" && break 2
  done
  [ $(reached) -gt $maxCount ] && echo "out reach max: 10" && break
done
echo "done."

