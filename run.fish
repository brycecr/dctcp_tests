for x in (seq 2)
	sudo ./tcp_fair.sh 
	for file in /tmp/wireshark*
		sudo tshark -r $file -qz "io,stat,0,tcp&&ip.src==10.0.0.2,tcp&&ip.src==10.0.0.3,tcp&&ip.src==10.0.0.4,tcp&&ip.src==10.0.0.5,tcp&&ip.src==10.0.0.6,tcp&&ip.src==10.0.0.7,tcp&&ip.src==10.0.0.8,tcp&&ip.src==10.0.0.9,tcp&&ip.src==10.0.0.10,tcp&&ip.src==10.0.0.11,tcp&&ip.src==10.0.0.12" > throughput_output
		sed -f ./script/pass1.sed throughput_output | sed -f ./script/pass2.sed | tr '\n' ' ' > script/data/$x.txt
		sudo rm $file
	end
end
