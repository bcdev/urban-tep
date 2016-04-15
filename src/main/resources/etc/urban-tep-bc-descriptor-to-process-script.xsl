<?xml version="1.0" encoding="UTF-8"?>

<!-- use xsltproc urban-tep-bc-descriptor-to-process-script.xsl descriptor.xml to generate the Fmask8-process script -->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:utep="http://urban-tep.eo.esa.int/schema/urban-tep-schema.xsd"
                xmlns:wps="http://www.opengis.net/wps/1.0.0"
                xmlns:ows="http://www.opengis.net/ows/1.1"
                xmlns:xlink="http://www.w3.org/1999/xlink">
  <xsl:output method="text"/>

  <xsl:param name="snap.version">2.0.2</xsl:param>
  <xsl:param name="mcr_root.version">v81</xsl:param>

  <xsl:template match="utep:dependency[utep:name='snap']"> -v $(pwd)/snap-2.0.2:/urbantep/software/snap-2.0.2</xsl:template>
  <xsl:template match="utep:dependency[utep:name='mcr_root']"> -v $(pwd)/mcr_root-v81:/urbantep/software/mcr_root-v81</xsl:template>

  <xsl:template match="/utep:descriptor/utep:processor">#!/bin/bash
set -e

#foreach($key in $parameters.keySet() )
echo "$key=$parameters.get($key)" >> parameters
#end

#[[
docker build -t urbancentos <xsl:value-of select="utep:packaging/utep:name"/>-package-info

docker run -i -t --rm=true<xsl:apply-templates select="utep:packaging/utep:dependencies"/> -w /wd -v $(pwd):/wd -v $(pwd)/urbantep-<xsl:value-of select="utep:packaging/utep:name"/>-<xsl:value-of select="utep:packaging/utep:version"/>:/urbantep-<xsl:value-of select="utep:packaging/utep:name"/>-<xsl:value-of select="utep:packaging/utep:version"/> urbancentos /urbantep-<xsl:value-of select="utep:packaging/utep:name"/>-<xsl:value-of select="utep:packaging/utep:version"/>/<xsl:value-of select="utep:executable"/> /wd/$(basename $1) /wd/parameters
]]#
</xsl:template>

  <!-- catches all other stuff -->

  <xsl:template match="@*|node()" >
    <xsl:apply-templates select="@*|node()"/>
  </xsl:template>

</xsl:stylesheet>
