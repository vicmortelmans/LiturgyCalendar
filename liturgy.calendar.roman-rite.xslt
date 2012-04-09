<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">

  <xsl:strip-space elements="*"/>
 
  <xsl:include href="liturgy.calendar.lib.xslt"/>
  <xsl:include href="liturgy.calendar.cache.xslt"/>
  <xsl:include href="liturgy.calendar.roman-rite.d2c.xslt"/>
  <xsl:include href="liturgy.calendar.roman-rite.c2d.xslt"/>
    
  <xsl:param name="ruleset"/>
  <xsl:param name="mode" select="'d2c'"/>
  <xsl:param name="cache" select="'no'"/>
  
  <!-- d2c -->
  <xsl:param name="date" select="'2011-08-09'"/>
  <xsl:param name="set"/>
  <xsl:param name="score" select="'yes'"/>

  <!-- c2d -->
  <xsl:param name="coordinates" select="'A011'"/>
  <xsl:param name="year" select="'2011'"/>

  <xsl:variable name="ruleset" select="doc($ruleset)"/>

  <xsl:template match="/"><!-- matches the root of the dummy input XML file -->
    <xsl:variable name="context">
      <context>
        <xsl:if test="$mode = 'd2c'">
          <date><xsl:value-of select="$date"/></date>
          <year>
            <xsl:call-template name="liturgical-year">
              <xsl:with-param name="date" select="$date"/>
            </xsl:call-template>
          </year>          
        </xsl:if>
        <xsl:if test="$mode = 'c2d'">
          <coordinates><xsl:value-of select="$coordinates"/></coordinates>
          <year><xsl:value-of select="$year"/></year>
        </xsl:if>
        <xsl:copy-of select="$ruleset"/>
      </context>
    </xsl:variable>
    <xsl:apply-templates select="$context" mode="$mode"/>
  </xsl:template>

  <xsl:template name="calendar">
    <xsl:param name="mode" select="'d2c'"/>
    <!-- d2c -->
    <xsl:param name="date" select="'2011-08-09'"/>
    <xsl:param name="set"/>
    <xsl:param name="score" select="'yes'"/>
    <!-- c2d -->
    <xsl:param name="coordinates" select="'A011'"/>
    <xsl:param name="year" select="'2011'"/>
    <xsl:variable name="context">
      <context>
        <xsl:if test="$mode = 'd2c'">
          <date><xsl:value-of select="$date"/></date>
          <year>
            <xsl:call-template name="liturgical-year">
              <xsl:with-param name="date" select="$date"/>
            </xsl:call-template>
          </year>          
        </xsl:if>
        <xsl:if test="$mode = 'c2d'">
          <coordinates><xsl:value-of select="$coordinates"/></coordinates>
          <year><xsl:value-of select="$year"/></year>
        </xsl:if>
        <xsl:copy-of select="$ruleset"/>
      </context>
    </xsl:variable>
    <xsl:apply-templates select="$context" mode="$mode"/>
  </xsl:template>

  <xsl:template name="liturgical-year">
    <xsl:param name="date"/>
    <xsl:variable name="sameyear" select="year-from-date(xs:date($date))"/>
    <xsl:variable name="same0101" select="concat($sameyear,'-01-01')"/>
    <xsl:variable name="same1127" select="concat($sameyear,'-11-27')"/>
    <xsl:variable name="same1203" select="concat($sameyear,'-12-03')"/>
    <xsl:variable name="same1231" select="concat($sameyear,'-12-31')"/>
    <xsl:choose>
      <xsl:when test="xs:date($date) &gt;= xs:date($same0101) and
                      xs:date($date) &lt;  xs:date($same1127)">
        <xsl:value-of select="$sameyear"/>
      </xsl:when>
      <xsl:when test="xs:date($date) &gt;  xs:date($same1203) and
                      xs:date($date) &lt;= xs:date($same1231)">
        <xsl:value-of select="$sameyear + 1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="startnextyear">
          <xsl:variable name="rest">
            <xsl:text>http://xslt.childrensmissal.appspot.com/getDate2?output=xml&amp;year=</xsl:text>
            <xsl:value-of select="$sameyear + 1"/>
            <xsl:text>&amp;coordinates=A011&amp;options=</xsl:text>
            <xsl:value-of select="$options"/>
            <xsl:text>&amp;form=</xsl:text>
            <xsl:value-of select="$form"/>
          </xsl:variable>
          <xsl:variable name="cachedrest">
            <xsl:call-template name="cache">
              <xsl:with-param name="rest" select="$rest"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:value-of select="$cachedrest"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="xs:date($date) &lt; xs:date($startnextyear)">
             <xsl:value-of select="$sameyear"/>
          </xsl:when>
          <xsl:otherwise>
             <xsl:value-of select="$sameyear + 1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
</xsl:stylesheet>