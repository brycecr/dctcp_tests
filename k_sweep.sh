#!/bin/bash

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

time=30
bwnet=100
delay=1 #1

# Red settings (for DCTCP)
dctcp_red_limit=1000000
dctcp_red_avpkt=1000
dctcp_red_burst=100
dctcp_red_prob=1.0
iperf_port=5001
iperf=~/iperf-patched/src/iperf
#qsize=200
for qsize in 200; do
    dirf=dctcpgraphs-q$qsize
    rm -rf dctcpbb-q$qsize
    mkdir dctcpbb-q$qsize
    dir1=dctcpbb-q$qsize
    for k in 3 5 9 15 20 30 40 60 80 100; do
        dctcp_red_min=`expr $k \\* $dctcp_red_avpkt`
        dctcp_red_max=`expr $dctcp_red_min + 15`
        python dctcp.py --delay $delay -b $bwnet -B $bwnet -k $k -d $dir1 --maxq $qsize -t $time \
        --red_limit $dctcp_red_limit \
        --red_min $dctcp_red_min \
        --red_max $dctcp_red_max \
        --red_avpkt $dctcp_red_avpkt \
        --red_burst $dctcp_red_burst \
        --red_prob $dctcp_red_prob \
        --dctcp 1 \
	--red 0\
        --iperf $iperf -n 3
    done
done

python plot_k_sweep.py -f $dir1/k.txt -l Ksweep -o $dirf/k_sweep.png
rm -rf $dir1
