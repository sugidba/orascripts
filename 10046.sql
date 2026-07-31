oradebug setospid &ospid
oradebug unlimit
oradebug event 10046 trace name context forever, level 12
oradebug dump processstate 10
oradebug event 10046 trace name context off
oradebug tracefile_name
