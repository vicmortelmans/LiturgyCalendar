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

  <xsl:variable name="rsp_option"><!-- contains the parametrized ruleset file as provided in the 'ruleset' param -->
    <xsl:copy-of select="doc($ruleset)"/>
  </xsl:variable>

  <xsl:variable name="rsl"><!-- contains the location of the parametrized ruleset file -->
    <xsl:choose>
      <xsl:when test="$ruleset">
        <xsl:value-of select="$rsp_option//ruleset"/>
        <xsl:message>Reading ruleset from <xsl:value-of select="$rsp_option//ruleset"/></xsl:message>
        <xsl:message>Cache calls will use settings in <xsl:value-of select="$rsp_option//ruleset"/></xsl:message>
        <xsl:message>Input file is ignored</xsl:message>
        <xsl:if test="$ruleset != $rsp_option//ruleset">
          <xsl:message>Param file is ignored (<xsl:value-of select="$ruleset"/>)</xsl:message>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise><!-- actually not supported to provide rulest on stdin when using cache -->
        <xsl:value-of select="//ruleset"/>
        <xsl:message>Reading ruleset from <xsl:value-of select="//ruleset"/> (cf. input file &lt;ruleset&gt; element)</xsl:message>
        <xsl:message>Cache calls will use settings in <xsl:value-of select="//ruleset"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="rsp"><!-- contains the parametrized ruleset file -->
    <xsl:choose>
      <xsl:when test="$cache = 'yes' or $cache = 'no-rs'">
        <xsl:copy-of select="document(replace($rsl,'#.*$',''))"/>
      </xsl:when>
      <xsl:otherwise><!-- cache = 'no' -->
        <xsl:copy-of select="/"/>
        <xsl:message>Reading ruleset from input file</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="rs"><!-- contains the un-parametrized ruleset file -->
    <xsl:choose>
      <xsl:when test="$cache = 'no' or $cache = 'no-rs'">
        <xsl:apply-templates select="$rsp/liturgicaldays" mode="build"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="url">
          <xsl:call-template name="replace">
	    <xsl:with-param name="encode" select="'yes'"/>
            <xsl:with-param name="string" select="$rsp//cacheservice"/>
            <xsl:with-param name="parametergroup">
	      <url>
		<xsl:call-template name="replace">
		  <xsl:with-param name="encode" select="'yes'"/>
		  <xsl:with-param name="string" select="$rsp//restservice"/>
		  <xsl:with-param name="parametergroup">
		    <mode>b</mode>
		    <cache>no-rs</cache>
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
          <xsl:copy-of select="document(replace($url,'#.*$',''))"/>
        </xsl:variable>
        <xsl:copy-of select="$data"/>
        <xsl:message>REST call to <xsl:value-of select="$url"/></xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="*" mode="paste">
    <xsl:param name="paste"/>
    <xsl:copy>
      <xsl:copy-of select="$paste"/>
      <xsl:copy-of select="*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/"><!-- matches the root of the input XML file -->
    <xsl:choose>
      <xsl:when test="$mode = 'b'">
        <xsl:copy-of select="$rs"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="context">
          <xsl:apply-templates select="$rs" mode="paste">
            <xsl:with-param name="paste">
	      <xsl:if test="$mode = 'd2c'">
		<date><xsl:value-of select="$date"/></date>
		<set><xsl:value-of select="$set"/></set>
		<score><xsl:value-of select="$score"/></score>
		<minrankprecedence>
		  <xsl:choose>
		    <xsl:when test="string($minrankprecedence) = ''">0<xsl:message>DEBUG minrankprecedence fallback to 0</xsl:message></xsl:when>
		    <xsl:otherwise><xsl:value-of select="$minrankprecedence"/></xsl:otherwise>
		  </xsl:choose>
		</minrankprecedence>
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
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$mode = 'd2c'">
            <xsl:message>DATE TO COORDINATES (root template)</xsl:message>
            <xsl:message>context : <xsl:copy-of select="$context/*[not(*)]"/></xsl:message>
            <xsl:apply-templates select="$context/liturgicaldays" mode="d2c"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>COORDINATES TO DATE (root template)</xsl:message>
            <xsl:message>context : <xsl:copy-of select="$context/*[not(*)]"/></xsl:message>
            <xsl:apply-templates select="$context/liturgicaldays" mode="c2d"/>
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
      <xsl:apply-templates select="$rs" mode="paste">
	<xsl:with-param name="paste">
	  <xsl:if test="$mode = 'd2c'">
	    <date><xsl:value-of select="$date"/></date>
	    <set><xsl:value-of select="$set"/></set>
	    <score><xsl:value-of select="$score"/></score>
	    <minrankprecedence>
	      <xsl:choose>
		<xsl:when test="string($minrankprecedence) = ''">0<xsl:message>DEBUG minrankprecedence fallback to 0</xsl:message></xsl:when>
		<xsl:otherwise><xsl:value-of select="$minrankprecedence"/></xsl:otherwise>
	      </xsl:choose>
	    </minrankprecedence>
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
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$mode = 'd2c'">
	<xsl:message>DATE TO COORDINATES (root template)</xsl:message>
	<xsl:message>context : <xsl:copy-of select="$context/*[not(*)]"/></xsl:message>
	<xsl:apply-templates select="$context/liturgicaldays" mode="d2c"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message>COORDINATES TO DATE (root template)</xsl:message>
	<xsl:message>context : <xsl:copy-of select="$context/*[not(*)]"/></xsl:message>
	<xsl:apply-templates select="$context/liturgicaldays" mode="c2d"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:message>/calendar</xsl:message>
  </xsl:template>

  <!-- a note on accessing the parameters and variables:
       
       $mode, $cache, 
       /liturgicaldays/date, /liturgicaldays/set, /liturgicaldays/score, /liturgicaldays/minrankprecedence, /liturgicaldays/year, /liturgicaldays/coordinates 
       /liturgicaldays/options

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
              <xsl:with-param name="ruleset" select="$rsl"/>
	      <xsl:with-param name="mode" select="'c2d'"/>
	      <xsl:with-param name="year" select="$sameyear + 1"/>
	      <xsl:with-param name="coordinates" select="'A011'"/>
              <xsl:with-param name="cacheservice" select="$rsp//cacheservice"/>
              <xsl:with-param name="restservice" select="$rsp//restservice"/>
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
