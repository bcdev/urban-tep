<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:wps="http://www.opengis.net/wps/1.0.0"
                xmlns:ows="http://www.opengis.net/ows/1.1">
<xsl:output method="text"/>

<xsl:template match="/wps:ProcessDescriptions/ProcessDescription/ows:Identifier">
processorId : <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="/wps:ProcessDescriptions/ProcessDescription/ows:Abstract">
description : <xsl:value-of select="."/><xsl:text>

Parameters
</xsl:text>
</xsl:template>

<xsl:template match="/wps:ProcessDescriptions/ProcessDescription/DataInputs/Input[ows:Identifier='inputDataSetName']">inputDataSet : <xsl:value-of select="ows:Title"/> [<xsl:for-each select="LiteralData/ows:AllowedValues/ows:Value">
<xsl:value-of select="."/>
<xsl:choose>
    <xsl:when test="position() != last()">,</xsl:when>
</xsl:choose>
</xsl:for-each>].
</xsl:template>

<xsl:template match="/wps:ProcessDescriptions/ProcessDescription/DataInputs/Input[ows:Identifier='outputFormat']">outputFormat : <xsl:value-of select="ows:Title"/> [<xsl:for-each select="LiteralData/ows:AllowedValues/ows:Value">
<xsl:value-of select="."/>
<xsl:choose>
    <xsl:when test="position() != last()">,</xsl:when>
</xsl:choose>
</xsl:for-each>].
</xsl:template>

<xsl:template match="/wps:ProcessDescriptions/ProcessDescription/DataInputs/Input[ows:Identifier!='inputDataSetName' and ows:Identifier!='outputFormat']">
<xsl:value-of select="ows:Identifier"/> : <xsl:value-of select="ows:Title"/>.
</xsl:template>

<xsl:template match="@*|node()">
    <xsl:apply-templates select="@*|node()"/>
</xsl:template>

</xsl:stylesheet>
