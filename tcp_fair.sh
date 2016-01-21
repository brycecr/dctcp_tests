#!/bin/bash

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

time=60
bwnet=10
bwhost=10
delay=0.25

# Red settings (for DCTCP)
dctcp_red_limit=1000000
dctcp_red_min=90000
dctcp_red_max=90001
dctcp_red_avpkt=1500
dctcp_red_burst=61
dctcp_red_prob=1
iperf_port=5001
iperf=~/iperf-patched/src/iperf
for qsize in 200; do
    dirf=tcpfairgraphs-q$qsize
    dir1=tcpfairbb-q$qsize
    rm -rf $dirf
    mkdir $dirf
    rm -rf $dir1
    ./bin/python tcpfair.py --cong reno --cong1 reno --congrest reno --delay $delay -b $bwnet -B $bwhost -d $dir1 --maxq $qsize -t $time \
    --red_limit $dctcp_red_limit \
    --red_min $dctcp_red_min \
    --red_max $dctcp_red_max \
    --red_avpkt $dctcp_red_avpkt \
    --red_burst $dctcp_red_burst \
    --red_prob $dctcp_red_prob \
    --ecn 1 --ecnrest 1 --vtcp 0 --vtcprest 1 --split 10 \
    --red 1 \
    --iperf $iperf -k 0 -n 12
    ./bin/python plot_tcpprobe.py -f $dir1/cwnd.txt -o $dir1/cwnd-iperf.png -p $iperf_port
    ./bin/python plot_queue.py -f $dir1/q.txt --legend "tcp-w/ecn"  -o \
    $dirf/tcp_ecn_queue.png
    #rm -rf $dir1 $dir2
    #python plot_ping.py -f $dir/ping.txt -o $dir/rtt.png
done
