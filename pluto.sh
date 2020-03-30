#!/bin/bash

init()
{
	if [ $# -lt 1 ]
	then
		echo -e '\e[96mUsage: pluto <ip address>'
		exit 1
	fi
	ip=$1
	if ! [[ $ip =~ ^([0-9]{1,3}[\.]){3}[0-9]{1,3} ]]
	then
		echo -e '\e[96m|ERROR| Ip was not inputted in a correct IPv4 format'
		exit 1
	fi
}

initial_portscan()
{
	echo -e '\e[94m[*]\e[39m Running initial port scan'
	openPorts=$(nmap -T4 -p- $ip | grep open | awk -F/ '{print $1}')
	echo -e '\e[32m[+]\e[39m Found open ports'
	for port in $openPorts
	do
		echo '	'$port
	done
}

version_scan()
{
	echo -e '\e[94m[*]\e[39m Running version scan on found ports'
	nmap -sV -p$(echo $openPorts | tr ' ' ',') $ip | grep -E '*STATE*|*open*' | sed "s/^/\t/"
}

main()
{
	init $1
	initial_portscan
	version_scan

}

main $1
