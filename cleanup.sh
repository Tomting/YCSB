#!/bin/bash

# clean up 
CLEANUP=$1.* 
for f0 in $CLEANUP
do
  echo "delete $f0"
	rm $f0
done

# clean up load_<database>_* 
CLEANUP=load_$1.*
for f0 in $CLEANUP
do
  echo "delete $f0"
  rm $f0
done

