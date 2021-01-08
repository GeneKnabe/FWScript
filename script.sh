#!/bin/bash

echo "Checking the permission level"
if [ "$EUID" -ne 0 ]
  then echo "Please this script with su/root permissions"
  exit
fi

echo "Setup variables"

#Pfade
IPTABLES=/usr/sbin/iptables
#Router Interfaces und Addressen
ROUTEREXT=192.168.0.53/24
ROUTERINT=10.10.0.1/24
INTERFACEEXT=ens18
INTERFACEINT=ens19
#Subnetze
NETEXT=192.168.0.0/24
NETINT=10.10.0.0/24
NETALL=0.0.0.0/0
#Internal IPs welche via SSH von außen erreichbar sein sollten
SSHFORWARDIP=('10.10.0.15')
SSHFORWARDPORTFROMEXT=('8022')
#Internal IPs welche via RDP von außen erreichbar sein sollten
RDPFORWARDIP=('10.10.0.15')
RDPFORWARDPORTFROMEXT=('8023')
#TCP-Ports Welche freigegeben werden sollen (für das ganze netz)
TCPFORWARDPORTS=('80' '443')
#Ports Welche freigegeben werden sollen (für den Router)
INPUTPORTS=('22')
#Server für DNS ACCESS nach draußen
DNSSERVERS=('10.10.0.15')
#Server für Zeit-Server Zugriff
NTPSERVERS=('10.10.0.15')

case "$1" in 

#Start Parameter Start
start)

#Flush$IPTABLES
$IPTABLES -F
$IPTABLES -F -t nat

#NAT+FORWARDING
$IPTABLES -t nat -A POSTROUTING -o $INTERFACEEXT -j MASQUERADE

#SSH ACCESS to Internal Clients from external
j=0
for i in $SSHFORWARDIP; do
    $IPTABLES -t nat -A PREROUTING -p tcp -m tcp -i $INTERFACEEXT --dport ${SSHFORWARDPORTFROMEXT[$j]} -j DNAT --to-destination $i:22 
    j=$((j + 1))
done

#SSH for Router
$IPTABLES --insert INPUT -p tcp -i $INTERFACEEXT --dport 22 -j ACCEPT
$IPTABLES --insert INPUT -p tcp -i $INTERFACEEXT --sport 22 -j ACCEPT
$IPTABLES --insert OUTPUT -p tcp -o $INTERFACEEXT --sport 22  -j ACCEPT
$IPTABLES --insert OUTPUT -p tcp -o $INTERFACEEXT --dport 22  -j ACCEPT

#DNS
for i in $DNSSERVERS; do
    $IPTABLES --insert FORWARD -p tcp -s $i --dport 53 -j ACCEPT
    $IPTABLES --insert FORWARD -p tcp -d $i --sport 53 -j ACCEPT
    $IPTABLES --insert FORWARD -p udp -d $i --sport 53 -j ACCEPT
    $IPTABLES --insert FORWARD -p udp -s $i --dport 53 -j ACCEPT
done

#NTP
for i in $NTPSERVERS; do
    $IPTABLES --insert FORWARD -p UDP -i $INTERFACEINT -s $i --sport 123 -o $INTERFACEEXT --dport 123 -j ACCEPT
    $IPTABLES --insert FORWARD -p UDP -i $INTERFACEEXT --sport 123 -o $INTERFACEINT -d $i --dport 123 -j ACCEPT
done

#Internal Networkwide TCP Rules
for i in $TCPFORWARDPORTS; do
    $IPTABLES --insert FORWARD -p TCP -i $INTERFACEINT -s $NETINT --dport $i -j ACCEPT
    $IPTABLES --insert FORWARD -p TCP -i $INTERFACEEXT --sport $i -d $NETINT -j ACCEPT
done

#RDP ACCESS
j=0
for i in $RDPFORWARDIP; do
    $IPTABLES -t nat -A PREROUTING -p tcp -m tcp -i $INTERFACEEXT --dport ${RDPFORWARDPORTFROMEXT[$j]} -j DNAT --to-destination $i:3389
    j=$((j + 1))
done

$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT DROP

#Save Rules
/usr/sbin/iptables-save > /etc/iptables/rules.v4

#Display set rules
$IPTABLES -L -v -n


echo "Firewall on fire"

;;

#Start Parameter Stop
stop)

#Flush Tables which were modified
$IPTABLES -F
$IPTABLES -F -t nat

#NAT+FORWARDING
$IPTABLES -t nat -A POSTROUTING -o $INTERFACEEXT -j MASQUERADE

#Set everything to Accept
$IPTABLES -P INPUT ACCEPT
$IPTABLES -P FORWARD ACCEPT
$IPTABLES -P OUTPUT ACCEPT

#Save Rules
/usr/sbin/iptables-save > /etc/iptables/rules.v4

$IPTABLES -L -v -n


echo "Firewall off (HE DED)"

;;

fullblock)

echo "Wenn die SSH Verbindung abbricht hast du erfolgreich deinen eigenen Ast abgesägt"

$IPTABLES -P INPUT DROP
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT DROP

#Save Rules
/usr/sbin/iptables-save > /etc/iptables/rules.v4

echo "Everything blocked"

;;

esac
