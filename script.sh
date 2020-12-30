#!/bin/bash
#/usr/sbin/iptables -t nat -A POSTROUTING -o ens18 -j MASQUERADE
#!/bin/bash

echo "Setup variables"

#Router1
ROUTER1EXT=192.168.200.213/24
ROUTER1DMZT=172.16.13.1/24
#Router2
Router2DMZ=172.16.13.2/24
Router2INT=10.0.13.1/24
#AdminRechner
IPADMINDMZ=172.16.13.3/24
IPADMININT=10.0.13.2/24
#Subnetze
NETDMZ=172.16.13.0
NETINT=10.0.13.0
NETEXT=0.0.0.0
#Pfade
IPTABLES=/usr/sbin/iptables
#Ports
FORWARDPORTS=('123' '37' '53' '80' '' '' '' '' '')
INPUTPORTS=('22' '' '' '' '')

case "$1" in 

#Start Parameter Start
start)

$IPTABLES -F
$IPTABLES -F -t nat
#NAT+FORWARDING
$IPTABLES -t nat -A POSTROUTING -o ens33 -j MASQUERADE
$IPTABLES -A PREROUTING -t nat -i ens33 -p tcp --dport 80 -j DNAT --to 172.16.13.2:80
$IPTABLES -A FORWARD -p tcp -d $IPADMINDMZ --dport 80 -j ACCEPT
#SSH ACCESS
$IPTABLES --insert INPUT 1 -p tcp -s $IPADMINDMZ --dport 22 -i ens37 -j ACCEPT
$IPTABLES --insert INPUT 1 -p tcp -s $IPADMINDMZ --dport 22 -i ens37 -j ACCEPT
$IPTABLES --insert OUTPUT 1 -p tcp --sport 22 -o ens37 -j ACCEPT
#ICMP ACCESS
$IPTABLES --insert INPUT 1 -p ICMP -j ACCEPT
$IPTABLES --insert OUTPUT 1 -p ICMP -j ACCEPT
$IPTABLES --insert FORWARD 1 -p ICMP -j ACCEPT
#NTP
$IPTABLES --insert FORWARD 1 -p UDP -o ens37 --dport 123 -j ACCEPT
$IPTABLES --insert FORWARD 1 -p UDP -o ens33 --sport 123 -j ACCEPT
#Webserver
$IPTABLES --insert FORWARD 1 -p tcp -d 172.16.13.3 --dport 80 -j ACCEPT
#User WebACCESS
$IPTABLES --insert FORWARD 1 -p tcp -s 10.0.13.0 --dport 80 -j ACCEPT
$IPTABLES --insert FORWARD 1 -p tcp -d 10.0.13.0 --sport 80 -j ACCEPT

$IPTABLES --insert FORWARD 1 -p tcp -s $IPADMINDMZ --dport 37 -j ACCEPT
$IPTABLES --insert FORWARD 1 -p UDP -s $IPADMINDMZ --dport 37 -j ACCEPT
$IPTABLES --insert INPUT 1 -p tcp -s $IPADMINDMZ --dport 37 -j ACCEPT
$IPTABLES --insert INPUT 1 -p UDP -s $IPADMINDMZ --dport 37 -j ACCEPT

$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT DROP



$IPTABLES -L -v -n


echo "Firewall on fire"

;;

#Start Parameter Stop
stop)

$IPTABLES -F
$IPTABLES -F -t nat
#NAT+FORWARDING
$IPTABLES -t nat -A POSTROUTING -o ens33 -j MASQUERADE
$IPTABLES -A PREROUTING -t nat -i ens33 -p tcp --dport 80 -j DNAT --to 172.16.13.2:80
$IPTABLES -A FORWARD -p tcp -d $IPADMINDMZ --dport 80 -j ACCEPT
#Set Default
$IPTABLES -P INPUT ACCEPT
$IPTABLES -P FORWARD ACCEPT
$IPTABLES -P OUTPUT ACCEPT



$IPTABLES -L -v -n


echo "Firewall off"

;;
esac

#echo -ne '#####                     (33%)\r'
#sleep 1
#echo -ne '#############             (66%)\r'
#sleep 1
#echo -ne '#######################   (100%)\r'
#echo -ne '\n'
