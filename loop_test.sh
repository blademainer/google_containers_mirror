#!/bin/bash

index=1
maxCount=10
cat git_push.sh | while read f; do
  echo "$index======$f";
  index=$((index+1))
  if [ $index -gt $maxCount ]; then
    echo "greater max size: $index";break;
  fi
done
echo "past.."

