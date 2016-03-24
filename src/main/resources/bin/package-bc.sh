#!/bin/bash
set -x

rootdir=$(dirname $(dirname $0))
descriptor=$1

if [ "$descriptor" = "" ] ; then
    echo "usage : $(basename $0) <descriptor file>"
    exit 1
fi

packagedir=$(dirname $descriptor)

processorname=$(xmlstarlet sel -t -v "/utep:descriptor/utep:processor/utep:name" $descriptor)
packagename=$(xmlstarlet sel -t -v "/utep:descriptor/utep:processor/utep:packaging/utep:name" $descriptor)
packageversion=$(xmlstarlet sel -t -v "/utep:descriptor/utep:processor/utep:packaging/utep:version" $descriptor)

cd $packagedir/${packagename}-${packageversion}

tar cf ../urbantep-${packagename}-${packageversion}.tar.gz *

cd ..

tar cf urbantep-${packagename}-package-info.tar.gz Dockerfile

xsltproc $rootdir/etc/urban-tep-bc-descriptor-to-bundle-descriptor.xsl $descriptor > bundle-descriptor.xml
xsltproc $rootdir/etc/urban-tep-bc-descriptor-to-process-script.xsl $descriptor > ${processorname}-process

zip urbantep-${packagename}-${packageversion}.zip urbantep-${packagename}-${packageversion}.tar.gz urbantep-${packagename}-package-info.tar.gz bundle-descriptor.xml ${processorname}-process

rm urbantep-${packagename}-${packageversion}.tar.gz urbantep-${packagename}-package-info.tar.gz bundle-descriptor.xml ${processorname}-process
