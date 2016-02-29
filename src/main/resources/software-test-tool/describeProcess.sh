#!/bin/sh

# This is a script to send a DescribeProcess request to Calvalus WPS. It uses describeProcess.xsl to control which information is outputted
# to stdout. This script takes 1 parameter : the processor ID. For including all parameters, use 'all' as the processor ID.

PROCESSOR_ID=$1

read -p "Enter User Name: " USER

wget --user=$USER --ask-password -q -O - "urbantep-test:9080/bc-wps/wps/calvalus?Service=WPS&Request=DescribeProcess&Version=1.0.0&Identifier=$PROCESSOR_ID" | xsltproc describeProcess.xsl -
