#!/bin/bash

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

LOW=10 
MEDIUM=100
HIGH=500

echo "##########################################"
echo "# AEROSPIKE"
echo "##########################################"

/etc/init.d/citrusleaf start
sleep 10

export THREADS=$LOW
./runtest.sh aerospike

/etc/init.d/citrusleaf stop
sleep 10
ipcs -m|grep root |grep -v "0x6c6c6536"| while read a b c; do ipcrm -m $b; done
/etc/init.d/citrusleaf start
sleep 10

export THREADS=$MEDIUM
./runtest.sh aerospike

/etc/init.d/citrusleaf stop
sleep 10
ipcs -m|grep root |grep -v "0x6c6c6536"| while read a b c; do ipcrm -m $b; done
/etc/init.d/citrusleaf start
sleep 10

export THREADS=$HIGH
./runtest.sh aerospike

/etc/init.d/citrusleaf stop
sleep 10

echo "##########################################"
echo "# REDIS"
echo "##########################################"

service redis_6379 start
sleep 10

export THREADS=$LOW
./runtest.sh redis -p redis.host=localhost

service redis_6379 stop
sleep 10
service redis_6379 start
sleep 10

export THREADS=$MEDIUM
./runtest.sh redis -p redis.host=localhost

service redis_6379 stop
sleep 10
service redis_6379 start
sleep 10

export THREADS=$HIGH
./runtest.sh redis -p redis.host=localhost

service redis_6379 stop
sleep 10

echo "##########################################"
echo "# MONGODB"
echo "##########################################"

service mongod start
sleep 10

export THREADS=$LOW
./runtest.sh mongodb
./cleandb_mongodb.sh

#service mongod stop
#sleep 10
#service mongod start
#sleep 10

export THREADS=$MEDIUM
./runtest.sh mongodb
./cleandb_mongodb.sh

#service mongod stop
#sleep 10
#service mongod start
#sleep 10

export THREADS=$HIGH
./runtest.sh mongodb
./cleandb_mongodb.sh

service mongod stop
sleep 10

#echo "##########################################"
#echo "# HBASE"
#echo "##########################################"
#
#export THREADS=$LOW
#./runtest.sh hbase
#
#export THREADS=$MEDIUM
#./runtest.sh hbase
#
#export THREADS=$HIGH
#./runtest.sh hbase

#echo "##########################################"
#echo "# MEMCACHED"
#echo "##########################################"
#
#service memcached start
#sleep 10
#
#export THREADS=$LOW
#./runtest.sh memcached -p memcached.hosts=localhost:11211 -p memcached.checkOperationStatus=true
#
#export THREADS=$MEDIUM
#./runtest.sh memcached -p memcached.hosts=localhost:11211 -p memcached.checkOperationStatus=true
#
#export THREADS=$HIGH
#./runtest.sh memcached -p memcached.hosts=localhost:11211 -p memcached.checkOperationStatus=true
#
#service memcached stop
#sleep 10

echo "##########################################"
echo "# ORION"
echo "##########################################"

rm -rf /opt/orion/Redologs/*

nohup /opt/orion/ORION &
sleep 10

export THREADS=$LOW
./runtest.sh orion -p hosts=orion:localhost:9001,9002:DEFAULT

ps -ef|grep ORION|grep -v grep|while read a b c; do  kill -9 $b; done
sleep 10
rm -rf /opt/orion/Redologs/*
nohup /opt/orion/ORION &
sleep 10

export THREADS=$MEDIUM
./runtest.sh orion -p hosts=orion:localhost:9001,9002:DEFAULT

ps -ef|grep ORION|grep -v grep|while read a b c; do  kill -9 $b; done
sleep 10
rm -rf /opt/orion/Redologs/*
nohup /opt/orion/ORION &
sleep 10

export THREADS=$HIGH
./runtest.sh orion -p hosts=orion:localhost:9001,9002:DEFAULT

ps -ef|grep ORION|grep -v grep|while read a b c; do  kill -9 $b; done
sleep 10

#####################################à####
# COLLECT
##########################################
now=$(date +"%Y%m%d_%H_%M_%S")
zip collect_$now.zip orion.* redis.* aerospike.* mongodb.* hbase.* memcached.*
mv collect_$now.zip /var/www/html/test

#####################################à####
# CLEANUP
##########################################
./cleanup.sh aerospike
./cleanup.sh redis
./cleanup.sh mongodb
./cleanup.sh orion
./cleanup.sh hbase
./cleanup.sh memcached

