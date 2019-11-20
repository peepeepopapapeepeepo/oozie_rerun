#!/bin/bash

#-----------------------------------------------------------#
#   Author Name : Sawit Meekwamdee                          #
#   Program     : oozie_rerun                               #
#   Description : To rerun oozie job that failed for        #
#                 for a specific coordinator                #
#-----------------------------------------------------------#
#
# Change History
#   v1.0    2019/11/19 Sawit M. - First draft
#
# Usage
#   ./oozie_rerun "<Coordinator Name>" "<since datetime in format yyyy-MM-dd'T'HH:mm'Z' e.g. 2019-01-01T00:00Z>"

SCRIPTNAME=${0##*/}

if [ "${1}" != "" -a "${2}" != "" -a "${3}" != "" ]
then
    if [[ ${1} =~ ^rerun$|^list$ ]]
    then
        ACTION="${1}"
    else
        echo "ERROR: Invalid arguments \$1 = <rerun|list>"
        exit 99
    fi
    COOR="${2}"
    QTIME="${3}"
else
    echo "ERROR: Insufficient arguments"
    exit 99
fi

oozie jobs -jobtype coordinator -filter "name=${COOR};status=RUNNING;status=SUCCEEDED" | grep '[0-9][0-9][0-9][0-9]' | awk '{print $1}' | \
while read coor
do
    oozie job -info ${coor} -filter "status!=SUCCEEDED;status!=WAITING;status!=RUNNING;status!=READY;nominaltime>=${QTIME}" | grep '^[0-9][0-9][0-9][0-9]' | awk '{print $1,$2}' | \
    while read job status
    do
        wf=`oozie job -info ${job} | grep '^External ID' | awk -F': ' '{print $2}'`
        if [ "${ACTION}" == "rerun" ]
        then
            if [ "${status}" == "SUSPENDED" ]
            then
                oozie job -kill ${wf}
            fi
            tmpfile=$(mktemp /tmp/${SCRIPTNAME}_XXXXXX.xml)
            trap "rm -rf $tmpfile" EXIT
            oozie job -configcontent ${wf} > ${tmpfile}
            oozie job \
                -doas "admin" \
                -config ${tmpfile} \
                -Doozie.coord.application.path="" \
                -Doozie.wf.rerun.skip.nodes="," \
                -Duser.name="admin" \
                -Dmapreduce.job.user.name="admin" \
                -rerun ${wf}
            if [ $? -ne 0 ]
            then
                oozie job \
                    -config ${tmpfile} \
                    -Doozie.coord.application.path="" \
                    -Doozie.wf.rerun.skip.nodes="," \
                    -Duser.name="admin" \
                    -Dmapreduce.job.user.name="admin" \
                    -rerun ${wf}
            fi
            rm -f $tmpfile
            sleep 1
            after_status=`oozie job -info ${wf} | grep '^Status' | awk -F': ' '{print $2}'`
            echo "`date +'%Y-%m-%dT%T'`|job=${job}|wf=${wf}|before=${status}|after=${after_status}"
        elif [ "${ACTION}" == "list" ]
        then
            echo "`date +'%Y-%m-%dT%T'`|job=${job}|wf=${wf}|status=${status}"
        fi
    done
done