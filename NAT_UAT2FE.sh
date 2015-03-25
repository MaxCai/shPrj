#!/bin/sh
check()
{
  if [ $? -ne 0 ]; then 
    exit 1
  fi
}

uatip="10.22.13.17"
feip="10.22.13.12"
file="/home/ye.cai/NAT_UAT2FE_SAVE.txt"
d=`date +%T%t%D`

if [ "$#" -lt 1 ]; then
  echo "USAGE: sudo $0 port0 port1 ... or sudo $0 -s port0 -e port1"
elif [ "$1" != "-s" ] && [ "$1" != "-e" ]; then
  while [ -n "$*" ]; do
    iptables -t nat -D PREROUTING -p tcp -m tcp --dport $1 -j DNAT --to-destination $uatip:$1
    check
    iptables -t nat -A PREROUTING -p tcp -m tcp --dport $1 -j DNAT --to-destination $feip:$1
    check
    iptables-save > /etc/iptables.save
    check
    #[ -e "$file" ] || touch $file
    #echo "$d port $1 " >> $file
    echo "$1 is translated from $uatip to $feip"
    shift
  done
else
  startPt=-1
  endPt=-1
  while getopts "s:e:" opt; do
    case $opt in
      s) startPt=$OPTARG;;
      e) endPt=$OPTARG;;
      ?) echo "invalid param $opt";;
    esac
  done
  if [ "$startPt" -gt 0 ] && [ "$endPt" -ge "$startPt" ]; then
    while [ "$endPt" -ge "$startPt" ]; do
      iptables -t nat -D PREROUTING -p tcp -m tcp --dport $startPt -j DNAT --to-destination $uatip:$startPt
      check
      iptables -t nat -A PREROUTING -p tcp -m tcp --dport $startPt -j DNAT --to-destination $feip:$startPt
      check
      iptables-save > /etc/iptables.save
      check
      #[ -e "$file" ] || touch $file
      #echo "$d port $startPt " >> $file
      echo "$startPt is translated from $uatip to $feip"
      let startPt+=1;
    done
  fi
fi
