#!/bin/bash

EXT=enp0s3
INT=enp0s8


case "$1" in
	start)
		echo 1 > /proc/sys/net/ipv4/ip_forward

		iptables -F
		iptables -X
		iptables -t nat -F
		iptables -t nat -X

		iptables -P INPUT DROP
		iptables -P FORWARD DROP
		iptables -P OUTPUT ACCEPT

		iptables -A INPUT -i lo -j ACCEPT

		iptables -A INPUT -p tcp --dport 22 -j ACCEPT # SSH
		
		iptables -A INPUT -m multiport -p tcp --port 53,67,80,443,20000 -j ACCEPT
                iptables -A INPUT -m multiport -p udp --port 53,67,80,443,20000 -j ACCEPT

		iptables -A INPUT -p icmp -j ACCEPT
		iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

		iptables -A FORWARD -m multiport -p tcp --port 53,67,80,443,20000 -j ACCEPT
		iptables -A FORWARD -m multiport -p udp --port 53,67,80,443,20000 -j ACCEPT
		iptables -A FORWARD -p icmp -j ACCEPT
		iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
		
		iptables -t nat -A PREROUTING -p tcp --dport 80 -m mark ! --mark 0x1 -j REDIRECT --to-ports 20000
                iptables -t nat -A PREROUTING -p udp --dport 80 -m mark ! --mark 0x1 -j REDIRECT --to-ports 20000

                iptables -t nat -A PREROUTING -p tcp --dport 443 -m mark ! --mark 0x1 -j DNAT --to-destination 192.168.0.128:443
                iptables -t nat -A PREROUTING -p udp --dport 443 -m mark ! --mark 0x1 -j DNAT --to-destination 192.168.0.128:443


		iptables -t nat -A POSTROUTING -o $EXT -j MASQUERADE
		echo "Firewall Habilitado"
		;;

	stop)
		echo 1 > /proc/sys/net/ipv4/ip_forward

		iptables -F
		iptables -X
		iptables -t nat -F
		iptables -t nat -X
		
		iptables -P INPUT DROP
		iptables -P FORWARD ACCEPT
		iptables -P OUTPUT ACCEPT

		iptables -A INPUT -i lo -j ACCEPT

		iptables -A INPUT -p tcp --dport 22 -j ACCEPT
		iptables -A INPUT -m multiport -p tcp --port 53,67,80,443,20000 -j ACCEPT
		iptables -A INPUT -m multiport -p udp --port 53,67,80,443,20000 -j ACCEPT
		iptables -A INPUT -p icmp -j ACCEPT
		iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

		#iptables -t nat -A PREROUTING -p tcp --dport 80 -m mark ! --mark 0x1 -j DNAT --to-destination 192.168.0.128:20000
		#iptables -t nat -A PREROUTING -p udp --dport 80 -m mark ! --mark 0x1 -j DNAT --to-destination 192.168.0.128:20000
		
		iptables -t nat -A PREROUTING -p tcp --dport 80 -m mark ! --mark 0x1 -j REDIRECT --to-ports 20000
		iptables -t nat -A PREROUTING -p udp --dport 80 -m mark ! --mark 0x1 -j REDIRECT --to-ports 20000
		
		iptables -t nat -A PREROUTING -p tcp --dport 443 -m mark ! --mark 0x1 -j DNAT --to-destination 192.168.0.128:443
		iptables -t nat -A PREROUTING -p udp --dport 443 -m mark ! --mark 0x1 -j DNAT --to-destination 192.168.0.128:443
		
		#iptables -t nat -A PREROUTING -p tcp --dport 443 -m mark ! --mark 0x1 -j REDIRECT --to-ports 20001
		#iptables -t nat -A PREROUTING -p udp --dport 443 -m mark ! --mark 0x1 -j REDIRECT --to-ports 20001
		
		
		iptables -t nat -A POSTROUTING -o $EXT -j MASQUERADE
		;;
	*)
		echo "Use: "$0" {start|stop}"
		exit 1
esac

exit 0

