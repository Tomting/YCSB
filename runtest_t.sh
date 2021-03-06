#!/bin/bash

# if not set THREADS use default
if [ -z "$THREADS" ]; then
  THREADS=1
fi

# if not set GRANULARITY use default (1sec)
if [ -z "$GRANULARITY" ]; then
  GRANULARITY=1000
fi


# clean up 
CLEANUP=$1.$THREADS.* 
for f0 in $CLEANUP
do
  echo "delete $f0"
	rm $f0
done

# execute test
FILES=workload.1/w*
for f in $FILES
do
	now=$(date +"%Y%m%d_%H_%M_%S")
	echo -n "$THREADS" >$(basename $f).$THREADS.$now.dat
	bin/ycsb load $1 -P $f $2 $3 $4 $5 $6 $7 $8 $9 -p table=$(basename $f) > load_$1.$THREADS.$(basename $f).$now
	bin/ycsb run $1 -P $f $2 $3 $4 $5 $6 $7 $8 $9 -threads $THREADS -p table=$(basename $f) -p measurementtype=timeseries -p timeseries.granularity=$GRANULARITY > $1.$THREADS.$(basename $f).$now
	VAL=`grep "Throughput(ops/sec)" $1.$THREADS.$(basename $f).$now|cut -f3 -d","`
done
