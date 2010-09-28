<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="text" omit-xml-declaration="yes" version="1.0" encoding="UTF-8" indent="yes"/>
<xsl:variable name="GDDEnumDefn" select="document('enp2dd.xml')//EnumStateDefn"/>
<xsl:variable name="GDDStringDefn" select="document('enp2dd.xml')//String"/>
<xsl:variable name="FDMEnumDefn" select="//EnumStateDefn"/>
<xsl:variable name="FDMStringDefn" select="//String"/>

<xsl:template match="/">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="ReportDescriptor">
    <!-- This will match only the 'folder links' in the navigation pane-->
    <xsl:if test="@id > 256 and @privateReport = 'False'">
        <xsl:value-of select="@ProgrammaticName"/>,
    </xsl:if>
</xsl:template>

</xsl:stylesheet>

