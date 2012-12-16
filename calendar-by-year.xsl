<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0">
    <xsl:param name="years" select="'2012'"/><!-- comma separated list of years -->
    <!-- you also have to provide 'ruleset' as a parameter and it must be a plain filename in your active folder, no relative filename or URL !! -->

    <xsl:include href="liturgy.calendar.roman-rite.xslt"/>

    <xsl:template match="/" priority="1">
        <xsl:message>Processor: <xsl:value-of select="system-property('xsl:product-name')"/> <xsl:value-of select="system-property('xsl:product-version')"/></xsl:message>
        <calendar>
            <!-- matches root of dummy input file -->
            <xsl:for-each select="tokenize($years,',')">
                <year value="{.}">
                    <xsl:variable name="first" select="xs:date(concat(.,'-01-01'))"/>
                    <xsl:variable name="last" select="xs:date(concat(.,'-12-31'))"/>
                    <xsl:call-template name="day">
                        <xsl:with-param name="date" select="$first"/>
                        <xsl:with-param name="last" select="$last"/>
                    </xsl:call-template>
                </year>
            </xsl:for-each>
        </calendar>
    </xsl:template>

    <xsl:template name="day">
        <xsl:param name="date"/>
        <xsl:param name="last"/>
        <xsl:if test="$date &lt;= $last">
            <xsl:variable name="result">
                <xsl:call-template name="cache">
                    <xsl:with-param name="mode" select="'d2c'" tunnel="yes"/>
                    <xsl:with-param name="cache" select="'file'" tunnel="yes"/>
                    <xsl:with-param name="date" select="string($date)" tunnel="yes"/>
                    <xsl:with-param name="minrankprecedence" select="0" tunnel="yes"/>
                </xsl:call-template>
            </xsl:variable>
            <day>
                <coordinates>
                    <xsl:value-of select="normalize-space($result)"/>
                </coordinates>
                <date>
                    <xsl:value-of select="$date"/>
                </date>
                <form>
                    <xsl:value-of select="$rsp//form"/>
                </form>
                <cycle>
                    <xsl:copy-of select="string($result//coordinates[1]/@cycle)"/>
                </cycle>
                <rank>
                    <xsl:value-of select="string($result//coordinates[1]/@rank)"/>
                </rank>
            </day>
            <xsl:call-template name="day">
                <xsl:with-param name="date" select="$date + xs:dayTimeDuration('P1D')"/>
                <xsl:with-param name="last" select="$last"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
