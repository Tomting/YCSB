#!/bin/bash
BIN_HOME=./../../bin

. $BIN_HOME/utils.sh
. ./workload-env.sh

workloads=("profile=mysql-cluster-${MYSQL_CLUSTER_VERSION}-c.workload target=100 operationcount=10000"
           "profile=mysql-cluster-${MYSQL_CLUSTER_VERSION}-c.workload target=500 operationcount=50000"
           "profile=mysql-cluster-${MYSQL_CLUSTER_VERSION}-c.workload target=800 operationcount=80000"
           "profile=mysql-cluster-${MYSQL_CLUSTER_VERSION}-c.workload target=1000 operationcount=100000"
           "profile=mysql-cluster-${MYSQL_CLUSTER_VERSION}-c.workload target=1200 operationcount=100000"
           "profile=mysql-cluster-${MYSQL_CLUSTER_VERSION}-c.workload target=1500 operationcount=100000"
           "profile=mysql-cluster-${MYSQL_CLUSTER_VERSION}-c.workload target=2000 operationcount=200000")

workloads=$(array_join "${workloads[@]}")

$BIN_HOME/run-workload.sh -w "$workloads"