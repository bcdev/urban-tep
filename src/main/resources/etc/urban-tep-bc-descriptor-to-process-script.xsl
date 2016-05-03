<?xml version="1.0" encoding="UTF-8"?>

<!-- use xsltproc urban-tep-bc-descriptor-to-process-script.xsl descriptor.xml to generate the Fmask8-process script -->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:utep="http://urban-tep.eo.esa.int/schema/urban-tep-schema.xsd"
                xmlns:wps="http://www.opengis.net/wps/1.0.0"
                xmlns:ows="http://www.opengis.net/ows/1.1"
                xmlns:xlink="http://www.w3.org/1999/xlink">
  <xsl:output method="text"/>
  <xsl:preserve-space elements="*"/>

  <xsl:param name="snap.version">3.0.1</xsl:param>
  <xsl:param name="mcr_root.version">v81</xsl:param>

  <xsl:template mode='mounts' match="utep:dependency[utep:name='snap']"> -v $SNAP_DIR:/urbantep/software/snap-3.0.1 \</xsl:template>
  <xsl:template mode='mounts' match="utep:dependency[utep:name='mcr_root']"> -v $MCR_DIR:/urbantep/software/mcr_root-v81 \</xsl:template>
  <xsl:template match="utep:dependency[utep:name='snap']">SNAP_DIR=$(ls -ld $(pwd)/snap-3.0.1|awk '{print $11}')
</xsl:template>
  <xsl:template match="utep:dependency[utep:name='mcr_root']">MCR_DIR=$(ls -ld $(pwd)/mcr_root-v81|awk '{print $11}')
</xsl:template>

  <xsl:template match="/utep:descriptor/utep:processor">#!/bin/bash
set -e
set -x

#foreach($key in $parameters.keySet() )
echo "$key=$parameters.get($key)" >> parameters
#end

#[[
DOCKERINFO_DIR=$(ls -ld $(pwd)/urbantep-<xsl:value-of select="utep:packaging/utep:name"/>-package-info|awk '{print $11}')
<xsl:apply-templates select="utep:packaging/utep:dependencies"/>
PROCESSOR_DIR=$(ls -ld $(pwd)/urbantep-<xsl:value-of select="utep:packaging/utep:name"/>-<xsl:value-of select="utep:packaging/utep:version"/>|awk '{print $11}')

rm $(find . -type l)

function handle_progress() {
  line=$1
  echo $line
  if [[ ${line} =~ OUTPUT_PRODUCT ]]; then
    echo CALVALUS_$line
  fi
}

docker build -t urbancentos $DOCKERINFO_DIR
docker run --rm=true \<xsl:apply-templates mode='mounts' select="utep:packaging/utep:dependencies"/> -w /wd -v $(pwd):/wd -v ${PROCESSOR_DIR}:/urbantep-<xsl:value-of select="utep:packaging/utep:name"/>-<xsl:value-of select="utep:packaging/utep:version"/> urbancentos /urbantep-<xsl:value-of select="utep:packaging/utep:name"/>-<xsl:value-of select="utep:packaging/utep:version"/>/<xsl:value-of select="utep:executable"/> /wd/$(basename $1) /wd/parameters | while read x ; do handle_progress "$x" ; done
]]#
</xsl:template>

  <!-- catches all other stuff -->

  <xsl:template match="@*|node()" >
    <xsl:apply-templates select="@*|node()"/>
  </xsl:template>

</xsl:stylesheet>
