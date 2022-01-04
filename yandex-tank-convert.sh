#!/bin/bash
host=$1
cookie_name=$2
kubectl=$3
namespase=$4
deployments-name-ingress-nginx-controller=$5
proxy_upstream_name=$6
sessionid_old=
while read ip uri sessionid
do
	if [[ ${sessionid_old} != ${sessionid} ]]
	then
		echo -e "[Host: $host]\n[Connection: close]\n[CF-Connecting-IP: $ip]"
		if [[ "$sessionid" != "-" ]]
		then
			echo "[Cookie: $cookie_name=$sessionid]"
		fi
		sessionid_old=$sessionid
	fi
	echo $uri
done < <($kubectl -n $namespase logs `$kubectl -n $namespase get pod | grep -E "$deployments-name-ingress-nginx-controller-.+1/1     Running" | awk '{print $1}'` | grep -E "\] \"GET /.+ \[$proxy_upstream_name\] " | cut -d '"' -f1,2,8 | tr '"' ' ' | awk '{print $1,$7,$9}')
