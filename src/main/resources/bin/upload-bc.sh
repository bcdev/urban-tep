#!/bin/bash
#set -x

rootdir=$(dirname $(dirname $0))
descriptor=$1

function error_exit
{
        echo
        echo "${1:-"Unknown Error"}" 1>&2
        echo
        exit 1
}

if [ "$descriptor" = "" ] ; then
        echo "invalid descriptor file"
        error_exit "usage : $(basename $0) <descriptor file>"
fi

packagedir=$(dirname $descriptor)

packagename=$(xmlstarlet sel -t -v "/utep:descriptor/utep:processor/utep:packaging/utep:name" $descriptor)
packageversion=$(xmlstarlet sel -t -v "/utep:descriptor/utep:processor/utep:packaging/utep:version" $descriptor)

# This is a script to send initial request to upload a custom software to calvalus

SOFTWARE_PATH=urbantep-${packagename}-${packageversion}.zip
FILE_NAME=`echo $SOFTWARE_PATH | awk -F'[/\\\\\\\\]' '{print $NF}'`

# Server configuration
# =========================
SERVER_NAME="www.brockmann-consult.de"
SERVER_PORT="80"

read -p "Enter User Name: " BC_USER
read -s -p "Enter Password: " PASSWORD
printf "\n"

curlOutput=$(curl -s -F file=@$SOFTWARE_PATH --user $BC_USER:$PASSWORD "http://${SERVER_NAME}/bc-wps/upload?dir=software&bundle=true")

curlResponse=$(echo "$?")

if [[ $curlOutput == *"$SOFTWARE_PATH"*  ]]; then
	echo
	echo "Successful upload"
	echo
elif [[ $curlResponse == 6 ]]; then
	error_exit "Could not resolve host ${SERVER_NAME}"
elif [[ $curlOutput == *"Bad Gateway"*  ]]; then
	error_exit "Invalid user/password"
else
	error_exit
fi

