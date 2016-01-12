#!/bin/bash

function init() {
        touch /tmp/es_err_count
}

#The function will only send success message if there has been failure
function send_success_message() {
        count=`cat /tmp/es_err_count`
        if [[ "$count" != 0 ]]
                then
                echo 0 > /tmp/es_err_count
                action=`curl -silent -X POST --data-urlencode 'payload={"channel": "#my_monitoring_channel", "username": "robot", "text": "Elastic Search seems to be fine for now! :) . . . url: http://xx.xx.xx.xx:9200/_cluster/health ", "icon_emoji": ":green_heart:"}' https://hooks.slack.com/services/T10086UFO/654321XYZ/123456xyz`
        fi
}

#No of times, the check has failed status
function send_error_message() {
        count=`cat /tmp/es_err_count`
        if [[ "$count" == 0 ]]
                then
                count=$((count+1))
                echo $count > /tmp/es_err_count
                action=`curl -silent -X POST --data-urlencode 'payload={"channel": "#my_monitoring_channel", "username": "robot", "text": "Elastic Search xx.xx.xx.xx Port 9200 is NOT Green. url: http://xx.xx.xx.xx:9200/_cluster/health ", "icon_emoji": ":skull:"}' https://hooks.slack.com/services/T10086UFO/654321XYZ/123456xyz`
        fi
}


#Main program starts from here

init
elastic_ip='es.mychannel.io'
elastic_port='9200'
result=`curl -silent -XGET 'http://'$elastic_ip:$elastic_port/_cluster/health | awk '{split($0,a,","); print a[2] }'`
status=`echo $result | grep 'green'`

if [ ! -z $status ]
then
  send_success_message
  exit 0
else
  send_error_message
  exit -1
fi
