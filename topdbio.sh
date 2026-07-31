#!/bin/bash
echo "if it fails set the ORACLE_HOME properly"
echo "wait for 60 seconds"

# Step 1: Get baseline values
for i in `ps -ef | grep pmon | grep -v MGMTDB | grep -v ASM | grep -v grep | cut -d"_" -f3`
do
  export ORACLE_SID=$i
  export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
  sqlplus -s "/ as sysdba" <<EOF
set lines 300 pages 0
set heading off
set feedback off
SELECT '$i' AS DB, SUM(VALUE) AS TOTAL_IO
FROM gv\$sysstat
WHERE NAME IN ('physical reads', 'physical writes');
EOF
done > 1.txt


# Step 2: Wait 1 minute
sleep 60

# Step 3: Get new values
for i in `ps -ef | grep pmon | grep -v MGMTDB | grep -v ASM | grep -v grep | cut -d"_" -f3`
do
  export ORACLE_SID=$i
  export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
  sqlplus -s "/ as sysdba" <<EOF
set lines 300 pages 0
set heading off
set feedback off
SELECT '$i' AS DB, SUM(VALUE) AS TOTAL_IO
FROM gv\$sysstat
WHERE NAME IN ('physical reads', 'physical writes');
EOF
done > 2.txt

echo "TOP i/o databases for past 1 minute"

# Step 4 : calculating difference
paste 1.txt 2.txt | awk '{print $1, $4 - $2}'
