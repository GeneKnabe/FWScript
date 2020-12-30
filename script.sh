#!/bin/bash
#/usr/sbin/iptables -t nat -A POSTROUTING -o ens18 -j MASQUERADE
#!/bin/bash

echo "Checking the permission level"
if [ "$EUID" -ne 0 ]
  then echo "Please this script with su/root permissions"
  exit
fi

echo "Setup variables"

#Pfade
IPTABLES=/usr/sbin/iptables
#Router
ROUTEREXT=192.168.200.213/24
ROUTERINT=172.16.13.1/24
INTERFACEEXT=ens33
INTERFACEINT=ens37
#Subnetze
NETEXT=172.16.13.0
NETINT=10.0.13.0
NETALL=0.0.0.0
#Internal IPs for SSH (EXT -> INT Network)
SSHFORWARDIP=('' '' '' '')
SSHFORWARDPORTFROMEXT=('8022' '9023' '9024' '9025')
#Ports 
FORWARDPORTS=('123' '37' '53' '80' '' '' '' '' '')
INPUTPORTS=('22' '' '' '' '')

case "$1" in 

#Start Parameter Start
start)

$IPTABLES -F
$IPTABLES -F -t nat
#NAT+FORWARDING
$IPTABLES -t nat -A POSTROUTING -o $INTERFACEEXT -j MASQUERADE
#$IPTABLES -A PREROUTING -t nat -i ens33 -p tcp --dport 80 -j DNAT --to 172.16.13.2:80
#$IPTABLES -A FORWARD -p tcp -d $IPADMINDMZ --dport 80 -j ACCEPT
#SSH ACCESS
for i in SSHFORWARDIP; do
    for j in SSHFORWARDPORTFROMEXT; do
        $IPTABLES -t NAT -A prerouting -p tcp -m tcp -i $INTERFACEEXT --dport $j DNAT --to-destination $i:22 
    done
done
$IPTABLES --insert INPUT 1 -p tcp -s $NETALL -i $INTERFACEEXT --dport 22 -i $INTERFACEINT -j ACCEPT
$IPTABLES --insert INPUT 1 -p tcp -s $IPADMINDMZ --dport 22 -i ens37 -j ACCEPT
$IPTABLES --insert OUTPUT 1 -p tcp --sport 22 -o ens37 -j ACCEPT
$IPTABLES --insert FORWARD 1 -p tcp -m tcp --sport 22 -o ens37 -j ACCEPT
$IPTABLES --insert FORWARD 1 -p tcp -m tcp --sport 22 -o ens37 -j ACCEPT
#ICMP ACCESS
#$IPTABLES --insert INPUT 1 -p ICMP -j ACCEPT
#$IPTABLES --insert OUTPUT 1 -p ICMP -j ACCEPT
#$IPTABLES --insert FORWARD 1 -p ICMP -j ACCEPT
#NTP
#$IPTABLES --insert FORWARD 1 -p UDP -o ens37 --dport 123 -j ACCEPT
#$IPTABLES --insert FORWARD 1 -p UDP -o ens33 --sport 123 -j ACCEPT
#Webserver
#$IPTABLES --insert FORWARD 1 -p tcp -d 172.16.13.3 --dport 80 -j ACCEPT
#User WebACCESS
#$IPTABLES --insert FORWARD 1 -p tcp -s 10.0.13.0 --dport 80 -j ACCEPT
#$IPTABLES --insert FORWARD 1 -p tcp -d 10.0.13.0 --sport 80 -j ACCEPT
#
#$IPTABLES --insert FORWARD 1 -p tcp -s $IPADMINDMZ --dport 37 -j ACCEPT
#$IPTABLES --insert FORWARD 1 -p UDP -s $IPADMINDMZ --dport 37 -j ACCEPT
#$IPTABLES --insert INPUT 1 -p tcp -s $IPADMINDMZ --dport 37 -j ACCEPT
#$IPTABLES --insert INPUT 1 -p UDP -s $IPADMINDMZ --dport 37 -j ACCEPT

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
$IPTABLES -P INPUT ACCEPT
$IPTABLES -P FORWARD ACCEPT
$IPTABLES -P OUTPUT ACCEPT
#NAT+FORWARDING
#$IPTABLES -t nat -A POSTROUTING -o ens33 -j MASQUERADE
#$IPTABLES -A PREROUTING -t nat -i ens33 -p tcp --dport 80 -j DNAT --to 172.16.13.2:80
#$IPTABLES -A FORWARD -p tcp -d $IPADMINDMZ --dport 80 -j ACCEPT
#Set Default



$IPTABLES -L -v -n


echo "Firewall off (HE DED)"

;;
esac

#echo -ne '#####                     (33%)\r'
#sleep 1
#echo -ne '#############             (66%)\r'
#sleep 1
#echo -ne '#######################   (100%)\r'
#echo -ne '\n'
