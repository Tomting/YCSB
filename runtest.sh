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
bin/ycsb load $1 -P workloads/workloada $2 $3 $4 $5 $6 $7 $8 $9 > load_$1.$THREADS.workloada.$now

# 2. run workload A
bin/ycsb run $1 -P workloads/workloada $2 $3 $4 $5 $6 $7 $8 $9 -threads $THREADS -p measurementtype=timeseries -p timeseries.granularity=$GRANULARITY > $1.$THREADS.workloada.$now

# 3. run workload B
bin/ycsb run $1 -P workloads/workloadb $2 $3 $4 $5 $6 $7 $8 $9 -threads $THREADS -p measurementtype=timeseries -p timeseries.granularity=$GRANULARITY > $1.$THREADS.workloadb.$now

# 4. run workload C
bin/ycsb run $1 -P workloads/workloadc $2 $3 $4 $5 $6 $7 $8 $9 -threads $THREADS -p measurementtype=timeseries -p timeseries.granularity=$GRANULARITY > $1.$THREADS.workloadc.$now

# 5. run workload F
bin/ycsb run $1 -P workloads/workloadf $2 $3 $4 $5 $6 $7 $8 $9 -threads $THREADS -p measurementtype=timeseries -p timeseries.granularity=$GRANULARITY > $1.$THREADS.workloadf.$now

# 6. run workload D
bin/ycsb run $1 -P workloads/workloadd $2 $3 $4 $5 $6 $7 $8 $9 -threads $THREADS -p measurementtype=timeseries -p timeseries.granularity=$GRANULARITY > $1.$THREADS.workloadd.$now

# 7. delete data in the database
if [ "$1" == "orion" ]; then
	ps -ef|grep ORION|grep -v grep|while read a b c; do  kill -9 $b; done
	sleep 10
	nohup /opt/orion/ORION &
	sleep 10
fi
if [ "$1" == "redis" ]; then
	service redis_6379 stop
	sleep 10
	service redis_6379 start
	sleep 10
fi
if [ "$1" == "aerospike" ]; then
	/etc/init.d/aerospike stop
	sleep 10
	/etc/init.d/aerospike start
	sleep 10
fi
if [ "$1" == "mongodb" ]; then
	./cleandb_mongodb.sh
fi
if [ "$1" == "memcached" ]; then
	echo "not yet implemented"
	exit 0
fi

# 8. load workload E
bin/ycsb load $1 -P workloads/workloade $2 $3 $4 $5 $6 $7 $8 $9 > load_$1.$THREADS.workloade.$now

# 9. run workload E
bin/ycsb run $1 -P workloads/workloade $2 $3 $4 $5 $6 $7 $8 $9 -threads $THREADS -p measurementtype=timeseries -p timeseries.granularity=$GRANULARITY > $1.$THREADS.workloade.$now

