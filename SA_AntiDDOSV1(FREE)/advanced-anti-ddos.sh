IPT="/sbin/iptables"
WAN="eth0"
LAN="xenbr0"
$IPT -F
$IPT -F INPUT
$IPT -F OUTPUT
$IPT -F FORWARD
$IPT -F -t mangle
$IPT -F -t nat
$IPT -X
$IPT -P INPUT DROP
$IPT -P OUTPUT ACCEPT
$IPT -P FORWARD ACCEPT
echo 1 > /proc/sys/net/ipv4/ip_forward
$IPT -t nat -A POSTROUTING -o $WAN -j MASQUERADE
$IPT -A FORWARD -i $WAN -m state --state NEW,INVALID -j DROP
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A INPUT -i $LAN -j ACCEPT
$IPT -N Firewall
$IPT -A Firewall -m limit --limit 10/minute -j LOG --log-prefix "Firewall: "
$IPT -A Firewall -j DROP
$IPT -N Rejectwall
$IPT -A Rejectwall -m limit --limit 10/minute -j LOG --log-prefix "Rejectwall: "
$IPT -A Rejectwall -j REJECT
$IPT -N Badflags
$IPT -A Badflags -m limit --limit 10/minute -j LOG --log-prefix "Badflags: "
$IPT -A Badflags -j DROP
$IPT -A INPUT -p tcp --tcp-flags ACK,FIN FIN -j Badflags
$IPT -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j Badflags
$IPT -A INPUT -p tcp --tcp-flags ACK,URG URG -j Badflags
$IPT -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j Badflags
$IPT -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j Badflags
$IPT -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j Badflags
$IPT -A INPUT -p tcp --tcp-flags ALL ALL -j Badflags
$IPT -A INPUT -p tcp --tcp-flags ALL NONE -j Badflags
$IPT -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j Badflags
$IPT -A INPUT -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j Badflags
$IPT -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j Badflags
$IPT -A INPUT -p icmp --icmp-type 0 -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type 11 -j ACCEPT
$IPT -A INPUT -p icmp --icmp-type 8 -m limit --limit 1/second -j ACCEPT
$IPT -A INPUT -p icmp -j Firewall
$IPT -A INPUT -i $WAN -p tcp --dport 94 -j ACCEPT
$IPT -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPT -A INPUT -p udp --sport 137 --dport 137 -j DROP
$IPT -A INPUT -j Rejectwall
