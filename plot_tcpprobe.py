from helper import *
from collections import defaultdict
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--sport', help="Enable the source port filter (Default is dest port)", action='store_true', dest="sport", default=False)
parser.add_argument('-p', '--port', dest="port", default='5001')
parser.add_argument('-f', dest="files", nargs='+', required=True)
parser.add_argument('-o', '--out', dest="out", default=None)
parser.add_argument('-H', '--histogram', dest="histogram",
                    help="Plot histogram of sum(cwnd_i)",
                    action="store_true",
                    default=False)

args = parser.parse_args()

def first(lst):
    return map(lambda e: e[0], lst)

def second(lst):
    return map(lambda e: e[1], lst)

"""
Sample line:
0.028963522 10.0.0.1:5001 10.0.0.2:45460 2928 0xde003c0d 0xde003c0d 10 2147483647 29696 0 16776192
0.029436422 10.0.0.2:45460 10.0.0.1:5001 32 0xb2db77c7 0xb2da2fb7 59 43 16776192 69600 29696
Where fields are -
1) time
2) source ip:port
3) dest ip:port
4) packet lenth
5) Next send seq #
6) Unacked seq #
7) cwnd
8) ssthresh
9) send window
10) smoothed rtt
11) rcv window
"""
def parse_file(f):
    times = defaultdict(list)
    cwnd = defaultdict(list)
    snd_wnd = defaultdict(list)
    srtt = []
    for l in open(f).xreadlines():
        fields = l.strip().split(' ')
        if len(fields) != 11:
            break
        if not args.sport:
            if fields[2].split(':')[1] != args.port:
                continue
        else:
#            print "using sport %s (compare with %s)" % (args.port, fields[1].split(':')[1])
            if fields[1].split(':')[1] != args.port:
                continue
        sport = int(fields[1].split(':')[1])
        times[sport].append(float(fields[0]))

        c = int(fields[6])
        cwnd[sport].append(c * 1480 / 1024.0)
        srtt.append(int(fields[9]))
	swnd = int(fields[8])
	snd_wnd[sport].append(swnd / 1024.0)
    return times, cwnd, snd_wnd

added = defaultdict(int)
events = []

def plot_snd_wnd(ax):
    global events
    for f in args.files:
        times, cwnds, swnds = parse_file(f)
        for port in sorted(swnds.keys()):
            t = times[port]
            swnd = swnds[port]

            events += zip(t, [port]*len(t), swnd)
            ax.plot(t, swnd)

    events.sort()

def plot_cwnds(ax):
    global events
    for f in args.files:
        times, cwnds, swnds = parse_file(f)
        for port in sorted(cwnds.keys()):
            t = times[port]
            cwnd = cwnds[port]

            events += zip(t, [port]*len(t), cwnd)
            ax.plot(t, cwnd)

    events.sort()
total_cwnd = 0
cwnd_time = []

min_total_cwnd = 10**10
max_total_cwnd = 0
totalcwnds = []

m.rc('figure', figsize=(16, 12))
fig = plt.figure()
plots = 1
if args.histogram:
    plots = 2

axPlot = fig.add_subplot(2, plots, 1)
plot_cwnds(axPlot)

for (t,p,c) in events:
    if added[p]:
        total_cwnd -= added[p]
    total_cwnd += c
    cwnd_time.append((t, total_cwnd))
    added[p] = c
    totalcwnds.append(total_cwnd)

axPlot.plot(first(cwnd_time), second(cwnd_time), lw=2, label="$\sum_i W_i$")
axPlot.grid(True)
#axPlot.legend()
#axPlot.set_xlabel("seconds")
axPlot.set_ylabel("cwnd KB")
axPlot.set_title("TCP congestion window (cwnd) and Send Window timeseries")

axSWnd = fig.add_subplot(2,1,2)
plot_snd_wnd(axSWnd)
axSWnd.grid(True)
axSWnd.set_xlabel("seconds")
axSWnd.set_ylabel("Send Window (KB)")
#axSWnd.set_title("TCP Send Window")


if args.histogram:
    axHist = fig.add_subplot(2, 2, 2)
    n, bins, patches = axHist.hist(totalcwnds, 50, normed=1, facecolor='green', alpha=0.75)

    axHist.set_xlabel("bins (KB)")
    axHist.set_ylabel("Fraction")
    axHist.set_title("Histogram of sum(cwnd_i)")

if args.out:
    print 'saving to', args.out
    plt.savefig(args.out)
else:
    plt.show()
