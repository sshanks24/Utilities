<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" encoding="UTF-8" indent="no"/>
	<xsl:variable name="GDDStringDefn" select="document('Common/enp2dd.xml')//String"/>
	<xsl:variable name="FDMStringDefn" select="//String"/>
	<xsl:variable name="GDDSNMPPoint" select="document(Device/XP_Bravo/SNMP.xml')//GDD_POINT"/>
	<xsl:variable name="HMI" select="document('Device/XP_Bravo/XP_HMI.xml')/Root"/>
	<xsl:variable name="deviceFamily" select="document('Common/Suite_Info.xml')//deviceFamily"/>
	<xsl:variable name="deviceType" select="document('Common/Suite_Info.xml')//deviceType"/>
	<xsl:variable name="deviceName"><xsl:value-of select="$deviceFamily"/>/<xsl:value-of select="$deviceType"/></xsl:variable>
	<xsl:variable name="tabName" select="document('Device/XP_Bravo/Suite_Info.xml')//tabName"/>
	<xsl:variable name="idPrefix" select="document('Device/XP_Bravo/Suite_Info.xml')//idPrefix"/>
	<xsl:variable name="WB_Monitor" select="document('TestCases/WB_Monitor.xml')/project_test_case"/>
	<xsl:variable name="SP_Monitor" select="document('TestCases/SP_Monitor.xml')/project_test_case"/>
	<xsl:template match="LocalStringDefinitions|LocalEnumDefinitions|LocalUnitOfMeasures|LocalSpecialValueDefinitions|LocalEventMappings"/>
	<xsl:template match="/">Type, Test Suite, ID,Title,Hours Expected,Type,Phase,Configurations,Resources,Status,Attempts,Last Attempt Date,Last Attempt Time,Actual Hours,Testers,Faults,CR ID,Results,Version,Build,Link2,Result Notes,Requirements,Created Date,Created Time,Updated Date,Updated Time,Author,Update By,Prerequisites,Description,Results,Notes Field 1,Revision History,Link,Priority
<xsl:for-each select="//ReportDescriptor[@id > 256]">
			<xsl:call-template name="getReport">
				<xsl:with-param name="reportName" select="$FDMStringDefn[@Id=current()/@labelId]"/>
				<xsl:with-param name="reportIdx" select="count(ancestor-or-self::ReportDescriptor[@id > 256]) + count(preceding::ReportDescriptor[@id > 256])"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="getDataPoint">
		<xsl:param name="pointName"/>
		<xsl:param name="reportName"/>
		<xsl:param name="reportIdx"/>
		<xsl:param name="mmIdx"/>
		<xsl:param name="testLogFile"/>
		<xsl:param name="protocolTitle"/>
		<xsl:param name="idOffset"/>
		<xsl:param name="HMICode"/>case,<xsl:value-of select="$deviceName"/>/_<xsl:value-of select="$tabName"/>/<xsl:value-of select="$reportIdx"/>_<xsl:value-of select="$reportName"/>,<xsl:value-of select="$idPrefix"/>
		<xsl:value-of select="$reportIdx"/>0.<xsl:value-of select="position()*10 + $idOffset"/>
		<xsl:if test="current()/../@index">.<xsl:value-of select="$mmIdx"/>
		</xsl:if>,<xsl:value-of select="$protocolTitle"/> - <xsl:value-of select="@id"/> - <xsl:value-of select="$pointName"/>
		<xsl:value-of select="$FDMStringDefn[@Id=current()/*/DataLabel/TextID]"/>
		<xsl:if test="current()/../@index">[<xsl:value-of select="$mmIdx"/>]</xsl:if> - HMI - <xsl:value-of select="$HMICode"/>,<xsl:value-of select="$testLogFile/test_duration"/>,Functionality,System test,,,Not Yet Attempted,0,N/A,N/A,0:00,,,,,,,<xsl:value-of select="$testLogFile/external_link2"/>,<xsl:value-of select="$testLogFile/result_obtained"/>,<xsl:value-of select="$testLogFile/requirement"/>,<xsl:value-of select="$testLogFile/create_date"/>,<xsl:value-of select="$testLogFile/create_time"/>,<xsl:value-of select="$testLogFile/update_date"/>,<xsl:value-of select="$testLogFile/update_time"/>,<xsl:value-of select="$testLogFile/create_user_id"/>,<xsl:value-of select="$testLogFile/update_user_id"/>,<xsl:value-of select="$testLogFile/prerequisites"/>,"<xsl:value-of select="replace($testLogFile/test_description,'&quot;','&quot;&quot;')"/>",<xsl:value-of select="$testLogFile/test_result"/>,<xsl:value-of select="$testLogFile/notes1"/>,<xsl:value-of select="$testLogFile/notes2"/>,<xsl:value-of select="$testLogFile/external_link"/>,<xsl:value-of select="$testLogFile/priority"/>
		<xsl:if test="$mmIdx = 1 and current()/../@index > 0">
			<xsl:text>
</xsl:text>
			<xsl:call-template name="getDataPoint">
				<xsl:with-param name="pointName" select="$pointName"/>
				<xsl:with-param name="reportName" select="$reportName"/>
				<xsl:with-param name="reportIdx" select="$reportIdx"/>
				<xsl:with-param name="mmIdx">
					<xsl:value-of select="floor(current()/../@index div 2) + 1"/>
				</xsl:with-param>
				<xsl:with-param name="testLogFile" select="$testLogFile"/>
				<xsl:with-param name="protocolTitle" select="$protocolTitle"/>
				<xsl:with-param name="idOffset" select="$idOffset"/>
				<xsl:with-param name="HMICode" select="$HMICode"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$mmIdx != current()/../@index and $mmIdx > 1 and current()/../@index > 0">
			<xsl:text>
</xsl:text>
			<xsl:call-template name="getDataPoint">
				<xsl:with-param name="pointName" select="$pointName"/>
				<xsl:with-param name="reportName" select="$reportName"/>
				<xsl:with-param name="reportIdx" select="$reportIdx"/>
				<xsl:with-param name="mmIdx">
					<xsl:value-of select="current()/../@index"/>
				</xsl:with-param>
				<xsl:with-param name="testLogFile" select="$testLogFile"/>
				<xsl:with-param name="protocolTitle" select="$protocolTitle"/>
				<xsl:with-param name="idOffset" select="$idOffset"/>
				<xsl:with-param name="HMICode" select="$HMICode"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<xsl:template name="getReport">
		<xsl:param name="reportName"/>
		<xsl:param name="reportIdx"/>suite,<xsl:value-of select="$deviceName"/>/_<xsl:value-of select="$tabName"/>,<xsl:value-of select="$reportIdx"/>_<xsl:value-of select="$reportName"/>,<xsl:value-of select="$reportName"/>,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
<xsl:for-each select="dataPoint">
			<xsl:call-template name="getDataPoint">
				<xsl:with-param name="pointName" select="$GDDStringDefn[@Id=current()/*/DataLabel/TextID]"/>
				<xsl:with-param name="reportName" select="$reportName"/>
				<xsl:with-param name="reportIdx" select="$reportIdx"/>
				<xsl:with-param name="mmIdx">1</xsl:with-param>
				<xsl:with-param name="testLogFile" select="$WB_Monitor"/>
				<xsl:with-param name="protocolTitle">WB</xsl:with-param>
				<xsl:with-param name="idOffset">100</xsl:with-param>
				<xsl:with-param name="HMICode">
					<xsl:choose>
						<xsl:when test="$HMI/dataPoint/DataIdentifier[.=current()/@id]">
							<xsl:value-of select="$HMI/dataPoint/DataIdentifier[.=current()/@id]/../HMI"/>
						</xsl:when>
						<xsl:otherwise>N/A</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="$GDDSNMPPoint[@name=current()/*/ProgrammaticName]">
				<xsl:text>
</xsl:text>
				<xsl:call-template name="getDataPoint">
					<xsl:with-param name="pointName" select="concat(replace(replace($GDDSNMPPoint[@name=current()/*/ProgrammaticName]/SNMP_OID[1]/@OID,'.1.3.6.1.4.1.476.1.42.3.9.20.1.20.',''),'.hierarchy',' - '),$GDDStringDefn[@Id=current()/*/DataLabel/TextID])"/>
					<xsl:with-param name="reportName" select="$reportName"/>
					<xsl:with-param name="reportIdx" select="$reportIdx"/>
					<xsl:with-param name="mmIdx">1</xsl:with-param>
					<xsl:with-param name="testLogFile" select="$SP_Monitor"/>
					<xsl:with-param name="protocolTitle">SP</xsl:with-param>
					<xsl:with-param name="idOffset">105</xsl:with-param>
					<xsl:with-param name="HMICode">
						<xsl:choose>
							<xsl:when test="$HMI/dataPoint/DataIdentifier[.=current()/@id]">
								<xsl:value-of select="$HMI/dataPoint/DataIdentifier[.=current()/@id]/../HMI"/>
							</xsl:when>
							<xsl:otherwise>N/A</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
			<xsl:text> 
</xsl:text>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
