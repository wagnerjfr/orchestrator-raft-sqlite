#!/bin/bash

set -x;

LEADER=0

for N in 1 2 3
do
  RESULT=$(curl --write-out " %{http_code}" "http://localhost:300$N/api/leader-check" 2> /dev/null)
  echo "Health check result: $RESULT"

  REGEX=" 200$"
  if [[ "$RESULT" =~ $REGEX ]]; then
      echo "Health check passed, is leader"
      LEADER=1
  else
      REGEX="Not leader"
      if [[ "$RESULT" =~ $REGEX ]]; then
          echo "Health check passed, not leader"
      else
          echo "Health check failed (didn't return HTTP 200 or 'Not leader')"
          exit 1
      fi
  fi
done
if  [[ $LEADER == 1 ]]
    echo "Test check passed"
    exit 0
else
    echo "Test check failed"
    exit 1
fi
