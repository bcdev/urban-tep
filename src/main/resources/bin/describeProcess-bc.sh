#!/bin/sh

# This is a script to send a DescribeProcess request to Calvalus WPS. It uses describeProcess.xsl to control which information is outputted
# to stdout. This script takes 1 parameter : the processor ID. For including all parameters, use 'all' as the processor ID.

rootdir=$(dirname $(dirname $0))
descriptor=$1

if [ "$descriptor" = "" ] ; then
    echo "usage : $(basename $0) <descriptor file>"
    exit 1
fi

packagedir=$(dirname $descriptor)

packagename=$(xmlstarlet sel -t -v "/utep:descriptor/utep:processor/utep:packaging/utep:name" $descriptor)
packageversion=$(xmlstarlet sel -t -v "/utep:descriptor/utep:processor/utep:packaging/utep:version" $descriptor)
processorname=$(xmlstarlet sel -t -v "/utep:descriptor/utep:processor/utep:name" $descriptor)

PROCESSOR_ID=urbantep-${packagename}~${packageversion}~${processorname}

read -p "Enter User Name: " WPS_USER
read -s -p "Enter Password: " PASSWORD

wget --user=$WPS_USER --password=$PASSWORD -q -O - "bc-wps:9080/bc-wps/wps/calvalus?Service=WPS&Request=DescribeProcess&Version=1.0.0&Identifier=$PROCESSOR_ID" | xsltproc $rootdir/etc/describeProcess.xsl -
