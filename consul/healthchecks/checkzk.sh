#!/bin/bash

if [ $1 == "zk1" ]
then
  #host='zookeeper1.ciscozeus.io'
  host='alerts.zk1.ciscozeus.io'
elif [ $1 == "zk2" ]
then
  #host='zookeeper2.ciscozeus.io'
  host='alerts.zk2.ciscozeus.io'
elif [ $1 == "zk3" ]
then
  #host='zookeeper3.ciscozeus.io'
  host='alerts.zk3.ciscozeus.io'
elif [ $1 == "hangbo_zk" ]
then 
  host='10.10.10.10'
else
  echo "illegal argument, need to specify zk1,zk2,zk3 for node testing"
  exit 1
fi


function init() {
        touch /tmp/$1err_count
}

#The function will only send success message if there has been failure
function send_success_message() {
        count=`cat /tmp/$1err_count`
        if [[ "$count" != 0 ]]
                then
                echo 0 > /tmp/$1err_count
                #payload='payload={"channel": "#virginia1_monitoring", "username": "webhookbot", "text":'echo $host '"port 2181 is ok. . .", "icon_emoji": ":green_heart:"}'
                action=`curl -silent -X POST --data-urlencode 'payload={"channel": "#virginia1_monitoring", "username": "webhookbot", "text":"'$host'port 2181 is ok. . .", "icon_emoji": ":green_heart:"}' https://hooks.slack.com/services/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`
        fi
}

#No of times, the check has failed status
function send_error_message() {
        count=`cat /tmp/$1err_count`
        if [[ "$count" == 0 ]]
                then
                count=$((count+1))
                echo $count > /tmp/$1err_count
                action=`curl -silent -X POST --data-urlencode 'payload={"channel": "#virginia1_monitoring", "username": "webhookbot", "text": "MayDay! MayDay!'"$host"'2181 is not ok! Cross-Check using --> echo ruok | nc $host 2181 ", "icon_emoji": ":skull:"}' https://hooks.slack.com/services/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`
        fi
}


#Main program starts from here

init $1
result=`echo ruok | nc $host 2181 `
status=`echo $result | grep 'imok'`

echo "=========="
echo $result
echo "=========="


if [ ! -z $status ]
then
  #send_success_message $1
  exit 0
else
  #send_error_message $1
  exit -1
fi
