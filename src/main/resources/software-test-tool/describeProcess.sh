#!/bin/sh

# This is a script to send a DescribeProcess request to Calvalus WPS

read -p "Enter User Name: " USER

wget --user=$USER --ask-password -O - "urbantep-test:9080/bc-wps/wps/calvalus?Service=WPS&Request=DescribeProcess&Version=1.0.0&Identifier=$1" | xsltproc describeProcess.xsl -
