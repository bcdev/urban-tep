<?xml version="1.0" encoding="UTF-8"?>

<!-- use xsltproc urban-tep-bc-descriptor-to-bundle-descriptor.xsl descriptor.xml to generate the Fmask8-process script -->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:utep="http://urban-tep.eo.esa.int/schema/urban-tep-schema.xsd">
  <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <xsl:param name="snap.version">3.0.1</xsl:param>
  <xsl:param name="mcr_root.version">v81</xsl:param>

  <xsl:template match="utep:parameter">
    <parameterDescriptor>
      <name><xsl:value-of select="utep:name"/></name>
      <type><xsl:value-of select="utep:type"/></type>
      <description><xsl:value-of select="utep:description"/></description>
      <defaultValue><xsl:value-of select="utep:default"/></defaultValue>
    </parameterDescriptor>
  </xsl:template>

  <xsl:template match="utep:resource[utep:name='memory']">
    <jobParameter>
      <name>calvalus.hadoop.mapreduce.map.memory.mb</name>
      <value><xsl:value-of select="utep:value"/></value>
    </jobParameter>
  </xsl:template>
  <xsl:template match="utep:resource[utep:name='timelimit']">
    <jobParameter>
      <name>calvalus.hadoop.mapreduce.task.timeout</name>
      <value><xsl:value-of select="utep:value"/>000</value>
    </jobParameter>
  </xsl:template>

  <xsl:template match="/utep:descriptor/utep:processor">
    <bundleDescriptor>
      <bundleName>urbantep-<xsl:value-of select="utep:packaging/utep:name"/></bundleName>
      <bundleVersion><xsl:value-of select="utep:packaging/utep:version"/></bundleVersion>
      <includeBundle>urbantep-base-1.0</includeBundle>
      <processorDescriptors>
        <processorDescriptor>
          <processorName><xsl:value-of select="utep:title"/></processorName>
          <processorVersion><xsl:value-of select="utep:packaging/utep:version"/></processorVersion>
          <parameterDescriptors>
            <xsl:apply-templates select="utep:parameters" />
          </parameterDescriptors>
          <executableName><xsl:value-of select="utep:name"/></executableName>
          <outputFormats>NetCDF,GeoTIFF,BEAM-DIMAP</outputFormats>
          <inputProductTypes><xsl:value-of select="utep:inputTypes"/></inputProductTypes>
          <formatting>IMPLICIT</formatting>
          <descriptionHtml><xsl:value-of select="utep:description"/></descriptionHtml>
          <jobConfig>
            <xsl:apply-templates select="utep:packaging/utep:resources"/>
          </jobConfig>
        </processorDescriptor>
      </processorDescriptors>
    </bundleDescriptor>
  </xsl:template>

  <!-- catches all other stuff -->

  <xsl:template match="@*|node()" >
    <xsl:apply-templates select="@*|node()"/>
  </xsl:template>

</xsl:stylesheet>
