<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">

  <xsl:strip-space elements="*"/>
 
  <xsl:include href="liturgy.calendar.build-ruleset.xslt"/>
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
  <xsl:param name="minrankprecedence" select="0"/>

  <!-- c2d -->
  <xsl:param name="coordinates" select="'A011'"/>
  <xsl:param name="year" select="'2011'"/>

  <xsl:variable name="rsp">
    <xsl:choose>
      <xsl:when test="$cache = 'yes'">
        <xsl:copy-of select="doc($rsl)"/>
      </xsl:when>
      <xsl:otherwise><!-- cache = 'no' -->
        <xsl:copy-of select="/"/>
        <xsl:message>Reading ruleset from input file</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="rsl">
    <xsl:choose>
      <xsl:when test="$ruleset">
        <xsl:value-of select="$ruleset"/>
        <xsl:message>Reading ruleset from <xsl:value-of select="$ruleset"/></xsl:message>
        <xsl:message>Cache calls will use settings in <xsl:value-of select="$ruleset"/></xsl:message>
        <xsl:message>Input file is ignored</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="//ruleset"/>
        <xsl:message>Reading ruleset from <xsl:value-of select="//ruleset"/> (cf. input file &lt;ruleset&gt; element)</xsl:message>
        <xsl:message>Cache calls will use settings in <xsl:value-of select="//ruleset"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="rs">
    <xsl:choose>
      <xsl:when test="$cache = 'no'">
        <xsl:apply-templates select="$rsp/liturgicaldays" mode="build"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="url">
          <xsl:call-template name="replace">
            <xsl:with-param name="string" select="$rsp//cacheservice"/>
            <xsl:with-param name="parametergroup">
	      <url>
		<xsl:call-template name="replace">
		  <xsl:with-param name="encode" select="yes"/>
		  <xsl:with-param name="string" select="$rsp//restservice"/>
		  <xsl:with-param name="parametergroup">
		    <mode><xsl:value-of select="$mode"/></mode>
		    <cache>no</cache>
		    <ruleset><xsl:value-of select="$rsl"/></ruleset>
                    <date></date>    
                    <set></set>    
                    <score></score>     
                    <minrankprecedence></minrankprecedence>     
                    <coordinates></coordinates>     
                    <year></year>
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
  </xsl:variable>

  <xsl:template match="/"><!-- matches the root of the input XML file -->
    <xsl:choose>
      <xsl:when test="$mode = 'b'">
        <xsl:copy-of select="$rs"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="context">
          <context>
            <xsl:if test="$mode = 'd2c'">
              <date><xsl:value-of select="$date"/></date>
              <set><xsl:value-of select="$set"/></set>
              <score><xsl:value-of select="$score"/></score>
              <minrankprecedence><xsl:value-of select="$minrankprecedence"/></minrankprecedence>
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
            <xsl:copy-of select="$rs"/>
          </context>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$mode = 'd2c'">
            <xsl:message>DATE TO COORDINATES (root template)</xsl:message>
            <xsl:message>date: <xsl:value-of select="$context/context/date"/></xsl:message>
            <xsl:message>set: <xsl:value-of select="$context/context/set"/></xsl:message>
            <xsl:message>score: <xsl:value-of select="$context/context/score"/></xsl:message>
            <xsl:message>minrankprecedence: <xsl:value-of select="$context/context/minrankprecedence"/></xsl:message>
            <xsl:message>year: <xsl:value-of select="$context/context/year"/></xsl:message> 
            <xsl:apply-templates select="$context" mode="d2c"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>COORDINATES TO DATE (root template)</xsl:message>
            <xsl:message>coordinates: <xsl:value-of select="$context/context/coordinates"/></xsl:message>
            <xsl:message>year: <xsl:value-of select="$context/context/year"/></xsl:message> 
            <xsl:apply-templates select="$context" mode="c2d"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="calendar">
    <xsl:param name="mode" select="'d2c'"/>
    <!-- d2c -->
    <xsl:param name="date" select="'2011-08-09'"/>
    <xsl:param name="set"/>
    <xsl:param name="score" select="'yes'"/>
    <xsl:param name="minrankprecedence" select="0"/>
    <!-- c2d -->
    <xsl:param name="coordinates" select="'A011'"/>
    <xsl:param name="year" select="'2011'"/>
    <xsl:message>calendar</xsl:message>
    <xsl:variable name="context">
      <context>
        <xsl:if test="$mode = 'd2c'">
          <date><xsl:value-of select="$date"/></date>
          <set><xsl:value-of select="$set"/></set>
          <score><xsl:value-of select="$score"/></score>
          <minrankprecedence><xsl:value-of select="$minrankprecedence"/></minrankprecedence>
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
        <xsl:copy-of select="$rs"/>
      </context>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$mode = 'd2c'">
        <xsl:message>DATE TO COORDINATES (calendar template)</xsl:message>
        <xsl:message>date: <xsl:value-of select="$context/context/date"/></xsl:message>
        <xsl:message>set: <xsl:value-of select="$context/context/set"/></xsl:message>
        <xsl:message>score: <xsl:value-of select="$context/context/score"/></xsl:message>
        <xsl:message>minrankprecedence: <xsl:value-of select="$context/context/minrankprecedence"/></xsl:message>
        <xsl:message>year: <xsl:value-of select="$context/context/year"/></xsl:message> 
	<xsl:apply-templates select="$context" mode="d2c"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>COORDINATES TO DATE (calendar template)</xsl:message>
        <xsl:message>coordinates: <xsl:value-of select="$context/context/coordinates"/></xsl:message>
        <xsl:message>year: <xsl:value-of select="$context/context/year"/></xsl:message> 
	<xsl:apply-templates select="$context" mode="c2d"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:message>/calendar</xsl:message>
  </xsl:template>

  <!-- a note on accessing the parameters and variables:
       
       $mode, $cache, 
       /context/date, /context/set, /context/score, /context/minrankprecedence, /context/year, /context/coordinates 
       /context/liturgicaldays/options

    -->

  <xsl:template name="liturgical-year">
    <xsl:param name="date"/>
    <xsl:variable name="sameyear" select="year-from-date(xs:date($date))"/>
    <xsl:variable name="same0101" select="concat($sameyear,'-01-01')"/>
    <xsl:variable name="same1127" select="concat($sameyear,'-11-27')"/>
    <xsl:variable name="same1203" select="concat($sameyear,'-12-03')"/>
    <xsl:variable name="same1231" select="concat($sameyear,'-12-31')"/>
    <xsl:variable name="result">
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
	    <xsl:call-template name="cache">
	      <xsl:with-param name="mode" select="'c2d'"/>
	      <xsl:with-param name="year" select="$sameyear + 1"/>
	      <xsl:with-param name="coordinates" select="'A011'"/>
	    </xsl:call-template>
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
    </xsl:variable>
    <xsl:message>liturgical-year of <xsl:value-of select="$date"/> is <xsl:value-of select="$result"/></xsl:message>
    <xsl:value-of select="$result"/>
  </xsl:template>
  
</xsl:stylesheet>
