#!/bin/sh

check()
{
  if [ $? -ne 0 ]; then
    exit 1
  fi
}
IP="10.22.13.17" 
file="/home/ye.cai/NAT_UAT_SAVE.txt"
d=`date +%T%t%D`

travePort()
{
  while [ -n "$*" ]; do
    iptables -t nat -A POSTROUTING -p tcp -m tcp --dport $1 -j MASQUERADE
    check
    iptables -t nat -A PREROUTING -p tcp -m tcp --dport $1 -j DNAT --to-destination $IP:$1
    check
    iptables-save > /etc/iptables.save
    check
    #[ -e "$file" ] || touch $file
    #echo "$d port $1 " >> $file

    echo "$1 is translated to $IP"
    shift
  done
}

paramPort()
{
  startPt=-1
  endPt=-1
  while getopts "s:e:" opt; do
    case $opt in
      s) startPt=$OPTARG;;
      e) endPt=$OPTARG;;
      ?) echo "invalid param $opt";;
    esac
  done
  echo "$startPt to $endPt"
  if [ "$startPt" -gt 0 ] && [ "$endPt" -ge "$startPt"  ]; then
    while [ "$endPt" -ge "$startPt" ]; do
      iptables -t nat -A POSTROUTING -p tcp -m tcp --dport $startPt -j MASQUERADE
      check
      iptables -t nat -A PREROUTING -p tcp -m tcp --dport $startPt -j DNAT --to-destination $IP:$startPt
      check
      iptables-save > /etc/iptables.save
      check
      #[ -e "$file" ] || touch $file
      #echo "$d port $startPt " >> $file

      echo "$startPt is translated to $IP"
      let startPt+=1;
    done
  fi
}

if [ "$#" -lt 1 ]; then
  echo "USAGE: sudo $0 port0 port1 ... or suod $0 -s port0 -e port1"
elif [ "$1" != "-s" ] && [ "$1" != "-e" ]; then
  echo "traveport"
  travePort $*
else
  echo "paramport"
  paramPort $*
fi
