rm -f index.html && grep Throughput *.html |while read a b c; do A=`echo $a|cut -f1 -d"."`; B=`echo $a|cut -f2 -d"."`; C=`echo $a|cut -f3 -d"."`; echo "Database <b> $A </b> ^Crformed with workload <b> $C </b> a Throughput of  <b>$c </b> <BR>" >>index.html; done