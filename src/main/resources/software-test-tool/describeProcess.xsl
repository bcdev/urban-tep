<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:wps="http://www.opengis.net/wps/1.0.0"
                xmlns:ows="http://www.opengis.net/ows/1.1">
<xsl:output method="text"/>

<xsl:template match="/wps:ProcessDescriptions/wps:ProcessDescription/ows:Identifier">
processorId: <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="/wps:ProcessDescriptions/wps:ProcessDescription/wps:DataInputs/wps:Input[ows:Identifier='inputDataSetName']">
inputDataSet: <xsl:for-each select="wps:LiteralData/ows:AllowedValues/wps:Range">
<xsl:value-of select="."/>
<xsl:choose>
    <xsl:when test="position() != last()">,</xsl:when>
</xsl:choose>
</xsl:for-each>
<xsl:text>
</xsl:text>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:apply-templates select="@*|node()"/>
    </xsl:template>

</xsl:stylesheet>
