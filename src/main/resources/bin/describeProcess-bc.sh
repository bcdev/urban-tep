#!/bin/sh

# This is a script to send a DescribeProcess request to Calvalus WPS. It uses describeProcess.xsl to control which information is outputted
# to stdout. This script takes 1 parameter : the processor ID. For including all parameters, use 'all' as the processor ID.

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

packagename=$(xmlstarlet sel -t -v "/utep:descriptor/utep:processor/utep:packaging/utep:name" $descriptor | tr ' ' '_')
packageversion=$(xmlstarlet sel -t -v "/utep:descriptor/utep:processor/utep:packaging/utep:version" $descriptor)
processorname=$(xmlstarlet sel -t -v "/utep:descriptor/utep:processor/utep:name" $descriptor)

PROCESSOR_ID=urbantep-${packagename}~${packageversion}~${processorname}

read -p "Enter User Name: " WPS_USER
read -s -p "Enter Password: " PASSWORD

describeProcessResponse=$(wget --user=$WPS_USER --password=$PASSWORD -q -O - "www.brockmann-consult.de/bc-wps/wps/calvalus?Service=WPS&Request=DescribeProcess&Version=1.0.0&Identifier=$PROCESSOR_ID")
commandResponse=$?
if [ $commandResponse -eq 0 ]; then
	if [[ $describeProcessResponse == *"<ows:Exception exceptionCode="*  ]]; then
		if [[ $describeProcessResponse == *"Unable to retrieve the selected process(es)"* ]] || [[ $describeProcessResponse == *"Unable to retrieve processor"* ]]; then
			error_exit "The processor is not available"
		elif [[ $describeProcessResponse == *"Unable to retrieve the selected process(es)"* ]]; then
			error_exit "No processor name is specified"
		else
			error_exit "An error is returned by the WPS"
		fi
	elif [[ $describeProcessResponse == "" ]]; then
		error_exit "Empty response from WPS"
	else
		continue
	fi
elif [ $commandResponse -eq 4 ]; then
	error_exit "Unable to connect to WPS server."
elif [ $commandResponse -eq 6 ]; then
	error_exit "Invalid username/password."
else
	error_exit
fi

echo "$describeProcessResponse" | xsltproc $rootdir/etc/describeProcess.xsl -

if [ "$?" != 0 ]; then
	error_exit "unable to parse the DescribeProcess response."
fi

