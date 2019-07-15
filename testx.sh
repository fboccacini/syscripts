#!/bin/bash

echo "Value of \$0 is : $0"

echo "path to script : ${0%/*}"
echo $(dirname $0)
apath=$(cd "${0%/*}" 2>/dev/null; echo "$PWD"/"${0##*/}")
echo "absolutepath is : $apath"

dname=$(dirname $apath)
echo "directory name : $dname"


test=$(ls -l /proc/self/exe | sed 's/.*> //')
dirname /proc/self/exe
echo $test
set -u
if [[ -n boh ]]
then
  echo 'equal'
else
  echo 'not equal'
fi

read boh

if [[ -n boh ]]
then
  echo 'equal'
else
  echo 'not equal'
fi

if [[ $boh == '' ]]
then
  echo 'equal'
else
  echo 'not equal'
fi
