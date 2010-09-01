<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" omit-xml-declaration="yes" version="1.0" encoding="UTF-8" indent="no"/>
	<xsl:variable name="GDDStringDefn" select="document('enp2dd.xml')//String"/>
	<xsl:variable name="FDMStringDefn" select="//String"/>
	<xsl:variable name="GDDSNMPPoint" select="document('SNMP.xml')//GDD_POINT"/>
	<xsl:variable name="deviceName">XP/XDP</xsl:variable>
	<xsl:variable name="tabName">Monitor</xsl:variable>
	<xsl:variable name="idPrefix">812.40.</xsl:variable>
	<xsl:template match="LocalStringDefinitions|LocalEnumDefinitions|LocalUnitOfMeasures|LocalSpecialValueDefinitions|LocalEventMappings"/>
	<xsl:template match="/">Test Suite,ID,Title
	<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="ReportDescriptor">
		<xsl:if test="@id > 256">
			<xsl:call-template name="dataPoint">
			<xsl:with-param name="reportName" select="$FDMStringDefn[@Id=current()/@labelId]"></xsl:with-param>
			<xsl:with-param name="reportIdx" select="position() - 6"></xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<xsl:template name="dataPoint">
		<xsl:param name="reportName"></xsl:param>
		<xsl:param name="reportIdx"></xsl:param>
		<xsl:for-each select="dataPoint">
			<xsl:value-of select="$deviceName"></xsl:value-of>/_<xsl:value-of select="$tabName"></xsl:value-of>/<xsl:value-of select="$reportIdx"></xsl:value-of>_<xsl:value-of select="$reportName"></xsl:value-of>,<xsl:value-of select="$idPrefix"></xsl:value-of><xsl:value-of select="$reportIdx"></xsl:value-of>0.<xsl:value-of select="position()*10 + 100"></xsl:value-of>,WB - <xsl:value-of select="@id"></xsl:value-of> - <xsl:value-of select="$GDDStringDefn[@Id=current()/*/DataLabel/TextID]"></xsl:value-of><xsl:value-of select="$FDMStringDefn[@Id=current()/*/DataLabel/TextID]"></xsl:value-of>
			<xsl:if test="$GDDSNMPPoint[@name=current()/*/ProgrammaticName]">
			<xsl:text> 
			</xsl:text>
			<xsl:value-of select="$deviceName"></xsl:value-of>/_<xsl:value-of select="$tabName"></xsl:value-of>/<xsl:value-of select="$reportIdx"></xsl:value-of>_<xsl:value-of select="$reportName"></xsl:value-of>,<xsl:value-of select="$idPrefix"></xsl:value-of><xsl:value-of select="$reportIdx"></xsl:value-of>0.<xsl:value-of select="position()*10 + 105"></xsl:value-of>,SP - <xsl:value-of select="@id"></xsl:value-of> - <xsl:value-of select="$GDDSNMPPoint[@name=current()/*/ProgrammaticName]/SNMP_OID[1]/@OID"></xsl:value-of>
			</xsl:if>
			<xsl:text> 
			</xsl:text>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
