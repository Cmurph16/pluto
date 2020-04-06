#!/bin/bash

init()
{
	if [ $# -lt 1 ]
	then
		echo -e '\e[96m[!]\e[39m Usage: pluto <ip address>'
		exit 1
	fi
	ip=$1
	if ! [[ $ip =~ ^([0-9]{1,3}[\.]){3}[0-9]{1,3} ]]
	then
		echo -e '\e[91m[ERROR]\e[39m Ip was not inputted in a correct IPv4 format'
		exit 1
	fi
}

initial_portscan()
{
	echo -e '\e[94m[*]\e[39m Running initial port scan'
	openPorts=$(nmap -T4 -p- $ip | grep open | awk -F/ '{print $1}')
	if [ -z "$openPorts" ];
	then
		echo -e '\e[96m[!]\e[39m No open ports found. Exiting...'
		exit 1
	fi
	echo -e '\e[32m[+]\e[39m Found open ports'
	for port in $openPorts
	do
		echo ' |	'$port
	done
}

version_scan()
{
	echo -e '\e[94m[*]\e[39m Running version scan on found ports'
	echo -e '\e[32m[+]\e[39m Version and service info'
	nmap -sV -p$(echo $openPorts | tr ' ' ',') $ip | grep -E '*STATE*|*open*' | sed "s/^/ |\t/"
}

http_enum()
{
	echo -e '\e[94m[*]\e[39m Detected http(s) service'
	nohup dirb 'http://'$ip -r > dirb.txt 2>&1 &
	echo -e ' |	Starting dirb in background [pid '$!']'
	nohup nikto -h 'http://'$ip > nikto.txt 2>&1 &
	echo -e ' |	Starting nikto in background [pid '$!']'
}

determine_additional_scans()
{
	for port in $openPorts
	do
		echo 'found' $port
		if [ $port -eq '80' ] || [ $port -eq '443' ]
		then
			http_enum
		fi
	done
}

main()
{
	init $1
	initial_portscan
	version_scan
	determine_additional_scans
}

main $1
