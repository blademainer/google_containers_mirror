#!/bin/bash

index=1
maxCount=10
cat git_push.sh | while read f; do
  cat git_push.sh | while read g; do
  index=$((index+1))
  echo "$index======$g";
  if [ $index -gt $maxCount ]; then
    echo "greater max size: $index";
    break 2;
  fi
  done
done
echo "done."

