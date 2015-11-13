#!/bin/bash

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

time=12
bwnet=100
delay=0.25

# Red settings (for DCTCP)
dctcp_red_limit=1000000
dctcp_red_min=30000
dctcp_red_max=30001
dctcp_red_avpkt=1500
dctcp_red_burst=20
dctcp_red_prob=1
iperf_port=5001
iperf=~/iperf-patched/src/iperf
for qsize in 200; do
    rm -rf dctcpgraphs-q$qsize
    mkdir dctcpgraphs-q$qsize
    rm -rf dctcpbb-q$qsize
    rm -rf tcpbb-q$qsize
    dirf=dctcpgraphs-q$qsize
    dir1=dctcpbb-q$qsize
    python dctcp.py --delay $delay -b $bwnet -B $bwnet -d $dir1 --maxq $qsize -t $time \
    --red_limit $dctcp_red_limit \
    --red_min $dctcp_red_min \
    --red_max $dctcp_red_max \
    --red_avpkt $dctcp_red_avpkt \
    --red_burst $dctcp_red_burst \
    --red_prob $dctcp_red_prob \
    --dctcp 1 \
    --red 0 \
    --iperf $iperf -k 0 -n 3
    dir2=tcpbb-q$qsize
    python dctcp.py --delay $delay -b 100 -d $dir2 --maxq $qsize -t $time \
    --dctcp 0 --red 0 --iperf $iperf -k 0 -n 3
    #python plot_tcpprobe.py -f $dir1/cwnd.txt $dir2/cwnd.txt -o $dirf/cwnd-iperf.png -p $iperf_port
    python plot_queue.py -f $dir1/q.txt $dir2/q.txt --legend dctcp tcp -o \
    $dirf/dctcp_tcp_queue.png
    #rm -rf $dir1 $dir2
    #python plot_ping.py -f $dir/ping.txt -o $dir/rtt.png
done
