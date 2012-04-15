<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">
    
  <xsl:template name="cache">
    <xsl:param name="ruleset"/>
    <xsl:param name="mode" select="'d2c'"/>
    <!-- d2c -->
    <xsl:param name="date"/>
    <xsl:param name="set"/>
    <xsl:param name="score" select="'yes'"/>
    <xsl:param name="minrankprecedence" select="0"/>
    <!-- c2d -->
    <xsl:param name="coordinates" select="'A011'"/>
    <xsl:param name="year" select="'2011'"/>
    <xsl:message>cache(ruleset : <xsl:value-of select="$ruleset"/>;mode : <xsl:value-of select="$mode"/>;date : <xsl:value-of select="$date"/>;set : <xsl:value-of select="$set"/>;score : <xsl:value-of select="$score"/>;coordinates : <xsl:value-of select="$coordinates"/>;year : <xsl:value-of select="$year"/>;cacheservice : <xsl:value-of select="//cacheservice"/>;restservice : <xsl:value-of select="//restservice"/> )</xsl:message>
    <xsl:choose>
      <xsl:when test="$cache = 'no'">
        <xsl:call-template name="calendar">
          <xsl:with-param name="mode" select="$mode"/>
          <xsl:with-param name="date" select="$date"/>
          <xsl:with-param name="set" select="$set"/>
          <xsl:with-param name="score" select="$score"/>
          <xsl:with-param name="minrankprecedence" select="$minrankprecedence"/>
          <xsl:with-param name="coordinates" select="$coordinates"/>
          <xsl:with-param name="year" select="$year"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="url">
          <xsl:call-template name="replace">
            <xsl:with-param name="encode" select="'yes'"/>
            <xsl:with-param name="string" select="//cacheservice"/>
            <xsl:with-param name="parametergroup">
	      <doc>calendar</doc>
	      <expiration>1</expiration>
	      <url>
		<xsl:call-template name="replace">
		  <xsl:with-param name="encode" select="'yes'"/>
		  <xsl:with-param name="string" select="//restservice"/>
		  <xsl:with-param name="parametergroup">
		    <ruleset><xsl:value-of select="$ruleset"/></ruleset>
		    <mode><xsl:value-of select="$mode"/></mode>
		    <cache><xsl:value-of select="$cache"/></cache>
		    <date><xsl:if test="$date"><xsl:value-of select="$date"/></xsl:if></date>
		    <set><xsl:if test="$set"><xsl:value-of select="$set"/></xsl:if></set>
		    <score><xsl:if test="$score"><xsl:value-of select="$score"/></xsl:if></score>
		    <minrankprecedence><xsl:if test="$minrankprecedence"><xsl:value-of select="$minrankprecedence"/></xsl:if></minrankprecedence>
		    <coordinates><xsl:if test="$coordinates"><xsl:value-of select="$coordinates"/></xsl:if></coordinates>
		    <year><xsl:if test="$year"><xsl:value-of select="$year"/></xsl:if></year>
		  </xsl:with-param>
		</xsl:call-template>
	      </url>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="data">
          <xsl:value-of select="document($url)"/>
        </xsl:variable>
        <xsl:copy-of select="$data"/>
        <xsl:message>REST call to <xsl:value-of select="$url"/></xsl:message>
        <xsl:message>Result: <xsl:copy-of select="$data"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:message>/cache</xsl:message>
  </xsl:template>

  <xsl:template name="replace"><!-- copied from liturgical.calendar.build-ruleset.xslt and added encoding func -->
    <xsl:param name="string"/>
    <xsl:param name="parametergroup"/>
    <xsl:param name="encode" select="'no'"/>
    <xsl:choose>
      <xsl:when test="not(matches($string,'\$'))">
	<xsl:value-of select="$string"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="replacement">
	  <xsl:choose>
	    <xsl:when test="$encode = 'yes'">
	      <xsl:value-of select="encode-for-uri($parametergroup/*[1])"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$parametergroup/*[1]"/>
	    </xsl:otherwise>
	  </xsl:choose>
        </xsl:variable>
        <xsl:variable name="replace" select="replace($string,concat('\$',local-name($parametergroup/*[1])),$replacement)"/>
        <xsl:call-template name="replace">
          <xsl:with-param name="string" select="$replace"/>
          <xsl:with-param name="parametergroup">
            <xsl:copy-of select="$parametergroup/*[position() &gt; 1]"/>
          </xsl:with-param>
          <xsl:with-param name="encode" select="$encode"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


</xsl:stylesheet>
