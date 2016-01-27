for x in (seq 4)
	sudo ./tcp_fair.sh 
	for file in /tmp/wireshark*
		sudo tshark -r $file -qz "io,stat,0,tcp&&ip.src==10.0.0.2&&frame.time_relative>10.0,tcp&&ip.src==10.0.0.3&&frame.time_relative>10.0,tcp&&ip.src==10.0.0.4&&frame.time_relative>10.0,tcp&&ip.src==10.0.0.5&&frame.time_relative>10.0,tcp&&ip.src==10.0.0.6&&frame.time_relative>10.0,tcp&&ip.src==10.0.0.7&&frame.time_relative>10.0,tcp&&ip.src==10.0.0.8&&frame.time_relative>10.0,tcp&&ip.src==10.0.0.9&&frame.time_relative>10.0,tcp&&ip.src==10.0.0.10&&frame.time_relative>10.0,tcp&&ip.src==10.0.0.11&&frame.time_relative>10.0,tcp&&ip.src==10.0.0.12&&frame.time_relative>10.0,tcp&&ip.src==10.0.0.13&&frame.time_relative>10.0,tcp&&ip.src==10.0.0.13" > throughput_output
		sed -f ./script/pass1.sed throughput_output | sed -f ./script/pass2.sed | tr '\n' ' ' > script/data/$x.txt
		sudo rm $file
	end
end
