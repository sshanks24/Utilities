<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" omit-xml-declaration="yes" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:variable name="GDDEnumDefn" select="document('enp2dd.xml')//EnumStateDefn"/>
	<xsl:variable name="GDDStringDefn" select="document('enp2dd.xml')//String"/>
	<xsl:variable name="FDMEnumDefn" select="//EnumStateDefn"/>
	<xsl:variable name="FDMStringDefn" select="//String"/>
	<xsl:variable name="ip">http://126.4.202.95</xsl:variable>
	<xsl:variable name="DeltaMinus">-100</xsl:variable>
	<xsl:variable name="DeltaPlus">100</xsl:variable>
	<xsl:variable name="TextMin">a</xsl:variable>
	<xsl:template match="LocalStringDefinitions|LocalEnumDefinitions|LocalUnitOfMeasures|LocalSpecialValueDefinitions|LocalEventMappings"/>
	<xsl:template match="/">
		<WebATS>
			<Load>
				<xsl:value-of select="$ip"/>
			</Load>
			<Sleep>100</Sleep>
			<xsl:call-template name="configSetC"/>
			<Click type="Image">imgControl</Click>
			<xsl:apply-templates/>
		</WebATS>
	</xsl:template>
	<xsl:template match="ReportDescriptor">
		<xsl:if test="@index">  <!-- This handles multimodule indexes... --!>
			<Click type="Id">report<xsl:value-of select="@id"/>
			</Click>
		</xsl:if>
		<xsl:if test="@id > 256 and @privateReport = 'False' and dataPoint/*/AccessDefn='RW' and dataPoint/@type='DataEnum'">
			<Click type="Id">report<xsl:value-of select="@id"/>0</Click>
			<Field nametype="Name" type="Button">editButton</Field>
			<xsl:for-each select="dataPoint[*/AccessDefn='RW']">
				<xsl:if test="@type != 'DataEnum' and @type != 'DateTime32' and @type != 'DataText'">
					<xsl:call-template name="setLowBoundary"></xsl:call-template>
				</xsl:if>				
				<xsl:if test="@type = 'DataEnum'">
					<xsl:call-template name="setEnumFirst"></xsl:call-template>
				</xsl:if>
				<xsl:if test="@type = 'DataText'">
					<xsl:call-template name="setTextMin"></xsl:call-template>
				</xsl:if>
			</xsl:for-each>
			<Field nametype="Id" type="Button">submitButton</Field>
			<xsl:for-each select="dataPoint[*/AccessDefn='RW']">
				<xsl:if test="@type != 'DataEnum' and @type != 'DateTime32' and @type != 'DataText'">
					<xsl:call-template name="validateLowBoundary"></xsl:call-template>
					<xsl:call-template name="validateNoWarning"></xsl:call-template>
				</xsl:if>
				<xsl:if test="@type = 'DataEnum'">
					<xsl:call-template name="validateEnumFirst"></xsl:call-template>
				</xsl:if>
				<xsl:if test="@type = 'DataText'">
					<xsl:call-template name="validateTextMin"></xsl:call-template>
				</xsl:if>
			</xsl:for-each>
			<Click type="Image">imgMonitor</Click>
			<xsl:for-each select="dataPoint[*/AccessDefn='RW']">
				<xsl:if test="@type != 'DataEnum' and @type != 'DateTime32' and @type != 'DataText'">
					<xsl:call-template name="validateLowBoundaryMonitor"></xsl:call-template>
				</xsl:if>				
				<xsl:if test="@type = 'DataEnum'">
					<xsl:call-template name="validateEnumFirstMonitor"></xsl:call-template>
				</xsl:if>
				<xsl:if test="@type = 'DataText'">
					<xsl:call-template name="validateTextMinMonitor"></xsl:call-template>
				</xsl:if>
			</xsl:for-each>
			<Click type="Image">imgControl</Click>
			<Field nametype="Name" type="Button">editButton</Field>
			<xsl:for-each select="dataPoint[*/AccessDefn='RW']">
				<xsl:if test="@type != 'DataEnum' and @type != 'DateTime32' and @type != 'DataText'">
					<xsl:call-template name="setHighBoundary"></xsl:call-template>
				</xsl:if>				
				<xsl:if test="@type = 'DataEnum'">
					<xsl:call-template name="setEnumLast"></xsl:call-template>
				</xsl:if>
				<xsl:if test="@type = 'DataText'">
					<xsl:call-template name="setTextMax"></xsl:call-template>
				</xsl:if>
			</xsl:for-each>
			<Field nametype="Id" type="Button">submitButton</Field>
			<xsl:for-each select="dataPoint[*/AccessDefn='RW']">
				<xsl:if test="@type != 'DataEnum' and @type != 'DateTime32' and @type != 'DataText'">
					<xsl:call-template name="validateHighBoundary"></xsl:call-template>
					<xsl:call-template name="validateNoWarning"></xsl:call-template>
				</xsl:if>
				<xsl:if test="@type = 'DataEnum'">
					<xsl:call-template name="validateEnumLast"></xsl:call-template>
				</xsl:if>
				<xsl:if test="@type = 'DataText'">
					<xsl:call-template name="validateTextMax"></xsl:call-template>
				</xsl:if>
			</xsl:for-each>
			<Click type="Image">imgMonitor</Click>
			<xsl:for-each select="dataPoint[*/AccessDefn='RW']">
				<xsl:if test="@type != 'DataEnum' and @type != 'DateTime32' and @type != 'DataText'">
					<xsl:call-template name="validateHighBoundaryMonitor"></xsl:call-template>
				</xsl:if>				
				<xsl:if test="@type = 'DataEnum'">
					<xsl:call-template name="validateEnumLastMonitor"></xsl:call-template>
				</xsl:if>
				<xsl:if test="@type = 'DataText'">
					<xsl:call-template name="validateTextMaxMonitor"></xsl:call-template>
				</xsl:if>
			</xsl:for-each>
			<Click type="Image">imgControl</Click>
		</xsl:if>
		<xsl:if test="ReportDescriptor and dataPoint/*/AccessDefn != 'RW'">
			<Click type="Id">report<xsl:value-of select="@id"/>0</Click>
		</xsl:if>
		<xsl:apply-templates select="ReportDescriptor"/>
	</xsl:template>
	<xsl:template match="dataPoint" mode="all">
		<Point>
			<xsl:attribute name="type" select="@type"/>
			<xsl:attribute name="count" select="position()"/>
		</Point>
	</xsl:template>
	<xsl:template match="dataPoint" mode="setOutOfBound">
		<xsl:param name="delta"/>
		<xsl:if test="@type != 'DataEnum' and @type != 'DateTime32' and @type != 'DataText'">
			<Field type="Text">
				<xsl:attribute name="name">num<xsl:value-of select="@id"/>~0</xsl:attribute>
				<xsl:choose>
					<xsl:when test="*/Resolution = 1">
						<xsl:if test="$delta = $DeltaMinus">
							<xsl:value-of select="(*/ValueMin * */DataScaling div (*/Resolution * 10)) + $delta"/>
						</xsl:if>
						<xsl:if test="$delta = $DeltaPlus">
							<xsl:value-of select="(*/ValueMax * */DataScaling div (*/Resolution * 10)) + $delta"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="$delta = $DeltaMinus">
							<xsl:value-of select="*/ValueMin * */DataScaling + $delta"/>
						</xsl:if>
						<xsl:if test="$delta = $DeltaPlus">
							<xsl:value-of select="*/ValueMax * */DataScaling + $delta"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</Field>
		</xsl:if>
	</xsl:template>
	<xsl:template match="dataPoint" mode="validateOutOfBound">
		<xsl:param name="delta"/>
		<xsl:if test="@type != 'DataEnum' and @type != 'DateTime32' and @type != 'DataText'">
			<TableCell frameindex="2" tableindex="2" colindex="4">
				<xsl:attribute name="rowindex" select="position()"/>
				<xsl:choose>
					<xsl:when test="*/Resolution = 1">
						<xsl:if test="$delta = $DeltaMinus">
							<xsl:text>Min: </xsl:text>
							<xsl:value-of select="format-number(*/ValueMin * */DataScaling div (*/Resolution * 10), '0.0')"/>
						</xsl:if>
						<xsl:if test="$delta = $DeltaPlus">
							<xsl:text>Max: </xsl:text>
							<xsl:value-of select="format-number(*/ValueMax * */DataScaling div (*/Resolution * 10), '0.0')"/>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="$delta = $DeltaMinus">
							<xsl:text>Min: </xsl:text>
							<xsl:value-of select="*/ValueMin * */DataScaling"/>
						</xsl:if>
						<xsl:if test="$delta = $DeltaPlus">
							<xsl:text>Max: </xsl:text>
							<xsl:value-of select="*/ValueMax * */DataScaling"/>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
			</TableCell>
		</xsl:if>
	</xsl:template>
	<xsl:template match="dataPoint" mode="setNormal">
		<xsl:if test="@type != 'DataEnum' and @type != 'DateTime32' and @type != 'DataText'">
			<Field type="Text">
				<xsl:attribute name="name">num<xsl:value-of select="@id"/>~0</xsl:attribute>
				<xsl:choose>
					<xsl:when test="*/Resolution = 1">
						<xsl:value-of select="round(((*/ValueMin + */ValueMax) div 2)* */DataScaling div (*/Resolution * 10))"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="round(((*/ValueMin + */ValueMax) div 2)* */DataScaling)"/>
					</xsl:otherwise>
				</xsl:choose>
			</Field>
		</xsl:if>
	</xsl:template>
	<xsl:template match="dataPoint" mode="validateNormal">
		<xsl:if test="@type != 'DataEnum' and @type != 'DateTime32' and @type != 'DataText'">
			<TableCell frameindex="2" tableindex="2" colindex="2">
				<xsl:attribute name="rowindex" select="position()"/>
				<xsl:choose>
					<xsl:when test="*/Resolution = 1">
						<xsl:value-of select="format-number(round(((*/ValueMin + */ValueMax) div 2)* */DataScaling div (*/Resolution * 10)),'0.0')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="round(((*/ValueMin + */ValueMax) div 2) * */DataScaling)"/>
					</xsl:otherwise>
				</xsl:choose>
			</TableCell>
		</xsl:if>
	</xsl:template>
	<xsl:template name="setLowBoundary">
		<Field type="Text">
				<xsl:attribute name="name">num<xsl:value-of select="@id"/>~0</xsl:attribute>
				<xsl:choose>
					<xsl:when test="*/Resolution = 1">
						<xsl:value-of select="format-number(*/ValueMin * */DataScaling div (*/Resolution * 10),'0.0')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="*/ValueMin * */DataScaling"/>
					</xsl:otherwise>
				</xsl:choose>
			</Field>
	</xsl:template>
	<xsl:template name="validateLowBoundary">
		<TableCell frameindex="2" tableindex="2" colindex="2">
			<xsl:attribute name="rowindex" select="position()"/>
			<xsl:choose>
				<xsl:when test="*/Resolution = 1">
					<xsl:value-of select="format-number(*/ValueMin * */DataScaling div (*/Resolution * 10),'0.0')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="*/ValueMin * */DataScaling"/>
				</xsl:otherwise>
			</xsl:choose>
		</TableCell>
	</xsl:template>
	<xsl:template name="setHighBoundary">
		<Field type="Text">
			<xsl:attribute name="name">num<xsl:value-of select="@id"/>~0</xsl:attribute>
			<xsl:choose>
				<xsl:when test="*/Resolution = 1">
					<xsl:value-of select="format-number(*/ValueMax * */DataScaling div (*/Resolution * 10), '0.0')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="*/ValueMax * */DataScaling"/>
				</xsl:otherwise>
			</xsl:choose>
		</Field>
	</xsl:template>
	<xsl:template name="validateHighBoundary">
		<TableCell frameindex="2" tableindex="2" colindex="2">
			<xsl:attribute name="rowindex" select="position()"/>
			<xsl:choose>
				<xsl:when test="*/Resolution = 1">
					<xsl:value-of select="format-number(*/ValueMax * */DataScaling div (*/Resolution * 10),'0.0')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="*/ValueMax * */DataScaling"/>
				</xsl:otherwise>
			</xsl:choose>
		</TableCell>
	</xsl:template>
	<xsl:template name="validateNoWarning">
		<TableCell frameindex="2" tableindex="2" colindex="4">
			<xsl:attribute name="rowindex" select="position()"/>
			<xsl:text/>
		</TableCell>
	</xsl:template>
	<xsl:template name="validateLowBoundaryMonitor">
		<TableCell frameindex="2" colindex="2">
			<xsl:attribute name="rowindex" select="position()"/>
			<xsl:attribute name="tableindex"><xsl:call-template name="getControlTableIndex"/></xsl:attribute>
			<xsl:choose>
				<xsl:when test="*/Resolution = 1">
					<xsl:value-of select="format-number(*/ValueMin * */DataScaling div (*/Resolution * 10),'0.0')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="*/ValueMin * */DataScaling"/>
				</xsl:otherwise>
			</xsl:choose>
		</TableCell>
	</xsl:template>
	<xsl:template name="validateHighBoundaryMonitor">
		<TableCell frameindex="2" colindex="2">
			<xsl:attribute name="rowindex" select="position()"/>
			<xsl:attribute name="tableindex"><xsl:call-template name="getControlTableIndex"/></xsl:attribute>
			<xsl:choose>
				<xsl:when test="*/Resolution = 1">
					<xsl:value-of select="format-number(*/ValueMax * */DataScaling div (*/Resolution * 10),'0.0')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="*/ValueMax * */DataScaling"/>
				</xsl:otherwise>
			</xsl:choose>
		</TableCell>
	</xsl:template>
	<xsl:template name="setEnumFirst">
		<Field type="Select">
				<xsl:attribute name="name">enum<xsl:value-of select="@id"/>~0</xsl:attribute>
				<xsl:variable name="enumdefnid" select="*/EnumStateDefnID"/>
				<xsl:value-of select="$FDMEnumDefn[@Id=$enumdefnid]/EnumState[1]/@Value"/>
				<xsl:value-of select="$GDDEnumDefn[@Id=$enumdefnid]/EnumState[1]/@Value"/>
			</Field>
	</xsl:template>
	<xsl:template name="validateEnumFirst">
		<TableCell frameindex="2" tableindex="2" colindex="2">
			<xsl:attribute name="rowindex" select="position()"/>
			<xsl:variable name="enumdefnid" select="*/EnumStateDefnID"/>
			<xsl:value-of select="$FDMEnumDefn[@Id=$enumdefnid]/EnumState[1]/@Value"/>
			<xsl:value-of select="$GDDEnumDefn[@Id=$enumdefnid]/EnumState[1]/@Value"/>
		</TableCell>
	</xsl:template>
	<xsl:template name="validateEnumFirstMonitor">
		<TableCell frameindex="2" colindex="2">
			<xsl:attribute name="rowindex" select="position()"/>
			<xsl:attribute name="tableindex"><xsl:call-template name="getControlTableIndex"/></xsl:attribute>
			<xsl:variable name="enumdefnid" select="*/EnumStateDefnID"/>
			<xsl:choose>
				<xsl:when test="$FDMEnumDefn[@Id=$enumdefnid]">
					<xsl:value-of select="$FDMStringDefn[@Id = $FDMEnumDefn[@Id=$enumdefnid]/EnumState[1]]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$GDDStringDefn[@Id=$GDDEnumDefn[@Id=$enumdefnid]/EnumState[1]]"/>
				</xsl:otherwise>
			</xsl:choose>
		</TableCell>
	</xsl:template>
	<xsl:template name="setEnumLast">
		<Field type="Select">
			<xsl:attribute name="name">enum<xsl:value-of select="@id"/>~0</xsl:attribute>
			<xsl:variable name="enumdefnid" select="*/EnumStateDefnID"/>
			<xsl:value-of select="$FDMEnumDefn[@Id=$enumdefnid]/EnumState[last()]/@Value"/>
			<xsl:value-of select="$GDDEnumDefn[@Id=$enumdefnid]/EnumState[last()]/@Value"/>
		</Field>
	</xsl:template>
	<xsl:template name="validateEnumLast">
		<TableCell frameindex="2" tableindex="2" colindex="2">
			<xsl:attribute name="rowindex" select="position()"/>
			<xsl:variable name="enumdefnid" select="*/EnumStateDefnID"/>
			<xsl:value-of select="$FDMEnumDefn[@Id=$enumdefnid]/EnumState[last()]/@Value"/>
			<xsl:value-of select="$GDDEnumDefn[@Id=$enumdefnid]/EnumState[last()]/@Value"/>
		</TableCell>
	</xsl:template>
	<xsl:template name="validateEnumLastMonitor">
		<TableCell frameindex="2" colindex="2">
			<xsl:attribute name="rowindex" select="position()"/>
			<xsl:attribute name="tableindex"><xsl:call-template name="getControlTableIndex"/></xsl:attribute>
			<xsl:variable name="enumdefnid" select="*/EnumStateDefnID"/>
			<xsl:choose>
				<xsl:when test="$FDMEnumDefn[@Id=$enumdefnid]">
					<xsl:value-of select="$FDMStringDefn[@Id = $FDMEnumDefn[@Id=$enumdefnid]/EnumState[last()]]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$GDDStringDefn[@Id=$GDDEnumDefn[@Id=$enumdefnid]/EnumState[last()]]"/>
				</xsl:otherwise>
			</xsl:choose>
		</TableCell>
	</xsl:template>
	<xsl:template name="setTextMin">
		<Field type="Text">
				<xsl:attribute name="name">str<xsl:value-of select="@id"/>~0</xsl:attribute>
				<xsl:value-of select="$TextMin"/>
		</Field>
	</xsl:template>
	<xsl:template name="validateTextMin">
		<TableCell frameindex="2" tableindex="2" colindex="2">
			<xsl:attribute name="rowindex" select="position()"/>
			<xsl:variable name="enumdefnid" select="*/EnumStateDefnID"/>
			<xsl:value-of select="$TextMin"/>
		</TableCell>
	</xsl:template>
	<xsl:template name="setTextMax">
		<Field type="Text">
			<xsl:attribute name="name">str<xsl:value-of select="@id"/>~0</xsl:attribute>
			<xsl:call-template name="mathpower">
				<xsl:with-param name="base" select="10"/>
				<xsl:with-param name="power" select="*/DataWidth - 1"/>
			</xsl:call-template>
		</Field>
	</xsl:template>
	<xsl:template name="validateTextMax">
		<TableCell frameindex="2" tableindex="2" colindex="2">
			<xsl:attribute name="rowindex" select="position()"/>
			<xsl:variable name="enumdefnid" select="*/EnumStateDefnID"/>
			<xsl:call-template name="mathpower">
				<xsl:with-param name="base" select="10"/>
				<xsl:with-param name="power" select="*/DataWidth - 1"/>
			</xsl:call-template>
		</TableCell>
	</xsl:template>
	<xsl:template name="validateTextMinMonitor">
		<TableCell frameindex="2" colindex="2">
			<xsl:attribute name="rowindex" select="position()"/>
			<xsl:attribute name="tableindex"><xsl:call-template name="getControlTableIndex"/></xsl:attribute>
			<xsl:value-of select="$TextMin"/>
		</TableCell>
	</xsl:template>
	<xsl:template name="validateTextMaxMonitor">
		<TableCell frameindex="2" colindex="2">
			<xsl:attribute name="rowindex" select="position()"/>
			<xsl:attribute name="tableindex"><xsl:call-template name="getControlTableIndex"/></xsl:attribute>
			<xsl:call-template name="mathpower">
				<xsl:with-param name="base" select="10"/>
				<xsl:with-param name="power" select="*/DataWidth - 1"/>
			</xsl:call-template>
		</TableCell>
	</xsl:template>
	<xsl:template match="dataPoint" mode="validateAllMonitor">
		<TableCell frameindex="2" colindex="2">
			<xsl:attribute name="rowindex" select="position()"/>
			<xsl:attribute name="tableindex"><xsl:call-template name="getControlTableIndex"/></xsl:attribute>
			<xsl:choose>
				<xsl:when test="@type = 'DataText'">
					<xsl:value-of select="*/DataWidth * 10 - 1"/>
				</xsl:when>
			</xsl:choose>
		</TableCell>
	</xsl:template>
	<xsl:template name="getControlTableIndex">
		<xsl:choose>
			<xsl:when test="../dataPoint/*/AccessDefn = 'RD' and (../dataPoint/@type='DataEvent16' or ../dataPoint/@type='DataEvent32')">
				<xsl:text>3</xsl:text>
			</xsl:when>
			<xsl:when test="../dataPoint/*/AccessDefn = 'RD'">
				<xsl:text>2</xsl:text>
			</xsl:when>
			<xsl:when test="@type='DataEvent16' or @type='DataEvent32'">
				<xsl:text>2</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>1</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="mathpower">
		<xsl:param name="base" select="0"/>
		<xsl:param name="power" select="1"/>
		<xsl:choose>
			<xsl:when test="$power &lt; 0 or contains(string($power), '.')">
				<xsl:message terminate="yes">
        The XSLT template math:power doesn't support negative or
        fractional arguments.
      </xsl:message>
				<xsl:text>NaN</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="math_power">
					<xsl:with-param name="base" select="$base"/>
					<xsl:with-param name="power" select="$power"/>
					<xsl:with-param name="result" select="1"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="math_power">
		<xsl:param name="base" select="0"/>
		<xsl:param name="power" select="1"/>
		<xsl:param name="result" select="1"/>
		<xsl:choose>
			<xsl:when test="$power = 0">
				<xsl:value-of select="$result"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="math_power">
					<xsl:with-param name="base" select="$base"/>
					<xsl:with-param name="power" select="$power - 1"/>
					<xsl:with-param name="result" select="$result * $base"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="configSetC">
		<Click type="Image">imgConfigure</Click>
		<Click type="Id">dOptions</Click>
		<Field nametype="Name" type="Button">editButton</Field>
		<Field name="webTempDispMode" type="Select">00000000</Field>
		<Field nametype="Name" type="Button">Submit</Field>
	</xsl:template>
</xsl:stylesheet>
