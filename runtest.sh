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
#FILES=workloads/*
#for f in $FILES
#do
#	now=$(date +"%Y%m%d_%H_%M_%S")
#	bin/ycsb load $1 -P $f $2 $3 $4 $5 $6 $7 $8 $9 -p table=$(basename $f) > load_$1.$THREADS.$(basename $f).$now
#	bin/ycsb run $1 -P $f $2 $3 $4 $5 $6 $7 $8 $9 -threads $THREADS -p table=$(basename $f) -p measurementtype=timeseries -p timeseries.granularity=$GRANULARITY > $1.$THREADS.$(basename $f).$now
#done

# execute the sequence as reported here 
# https://github.com/Tomting/YCSB/wiki/Core-Workloads

# 1. load workload A 
now=$(date +"%Y%m%d_%H_%M_%S")
bin/ycsb load workloads/workloada -P $f $2 $3 $4 $5 $6 $7 $8 $9 > load_$1.$THREADS.$(basename $f).$now

# 2. run workload A
bin/ycsb run workloads/workloada -P $f $2 $3 $4 $5 $6 $7 $8 $9 -threads $THREADS -p measurementtype=timeseries -p timeseries.granularity=$GRANULARITY > $1.$THREADS.$(basename $f).$now

# 3. run workload B
bin/ycsb run workloads/workloadb -P $f $2 $3 $4 $5 $6 $7 $8 $9 -threads $THREADS -p measurementtype=timeseries -p timeseries.granularity=$GRANULARITY > $1.$THREADS.$(basename $f).$now

# 4. run workload C
bin/ycsb run workloads/workloadc -P $f $2 $3 $4 $5 $6 $7 $8 $9 -threads $THREADS -p measurementtype=timeseries -p timeseries.granularity=$GRANULARITY > $1.$THREADS.$(basename $f).$now

# 5. run workload F
bin/ycsb run workloads/workloadf -P $f $2 $3 $4 $5 $6 $7 $8 $9 -threads $THREADS -p measurementtype=timeseries -p timeseries.granularity=$GRANULARITY > $1.$THREADS.$(basename $f).$now

# 6. run workload D
bin/ycsb run workloads/workloadd -P $f $2 $3 $4 $5 $6 $7 $8 $9 -threads $THREADS -p measurementtype=timeseries -p timeseries.granularity=$GRANULARITY > $1.$THREADS.$(basename $f).$now

# 7. delete data in the database
#
#

# 8. load workload E
bin/ycsb load workloads/workloade -P $f $2 $3 $4 $5 $6 $7 $8 $9 > load_$1.$THREADS.$(basename $f).$now

# 9. run workload E
bin/ycsb run workloads/workloade -P $f $2 $3 $4 $5 $6 $7 $8 $9 -threads $THREADS -p measurementtype=timeseries -p timeseries.granularity=$GRANULARITY > $1.$THREADS.$(basename $f).$now

