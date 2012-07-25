<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:saxon="http://saxon.sf.net/" extension-element-prefixes="saxon">
  <xsl:output name="xml" method="xml" indent="yes"/>
  <xsl:output method="xml" indent="yes"/>
  <xsl:template name="cache">
    <xsl:param name="cache" select="'no'" tunnel="yes"/>
    <xsl:choose>
      <xsl:when test="$cache = 'web'">
        <xsl:variable name="url">
          <xsl:call-template name="url"/>
        </xsl:variable>
        <xsl:copy-of select="document($url)"/>
        <xsl:message>REST call to <xsl:value-of select="$url"/></xsl:message>
      </xsl:when>
      <xsl:when test="$cache = 'file'">
        <xsl:variable name="url">
          <xsl:call-template name="url"/>
        </xsl:variable>
        <xsl:variable name="collection">
          <xsl:call-template name="collection"/>
        </xsl:variable>
        <xsl:variable name="file">
          <xsl:call-template name="file"/>
        </xsl:variable>
        <xsl:variable name="cache">
          <xsl:copy-of select="collection(iri-to-uri($collection))"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$cache/item[@url = $url]">
            <xsl:copy-of select="$cache/item[@url = $url]/*"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="result">
              <xsl:call-template name="router"/>
            </xsl:variable>
            <saxon:try>
              <xsl:result-document href="{$file}" format="xml">
                <item url="{$url}">
                  <xsl:copy-of select="$result"/>
                </item>
              </xsl:result-document>
              <saxon:catch errors="*">
                <xsl:message>Error caught while trying to write to <xsl:value-of select="$url"
                  /></xsl:message>
              </saxon:catch>
            </saxon:try>
            <xsl:copy-of select="$result"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- $cache = 'no' or 'webskip' -->
        <xsl:call-template name="router"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="url">
    <xsl:call-template name="replace">
      <xsl:with-param name="encode" select="'yes'"/>
      <xsl:with-param name="string" select="$rsp/cacheservice"/>
      <xsl:with-param name="parametergroup">
        <url>
          <xsl:call-template name="replace">
            <xsl:with-param name="encode" select="'yes'"/>
            <xsl:with-param name="string" select="$rsp/restservice"/>
            <xsl:with-param name="parametergroup">
              <xsl:call-template name="parametergroup"/>
            </xsl:with-param>
          </xsl:call-template>
        </url>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="collection">
    <xsl:param name="mode" tunnel="yes"/>
    <xsl:variable name="pcollection">
      <xsl:if test="$mode = 'd2c'"
        >$cachefolder/?select=$ruleset-$cache-$mode-$date-$set-$score-$minrankprecedence.xml</xsl:if>
      <xsl:if test="$mode = 'c2d'"
        >$cachefolder/?select=$ruleset-$cache-$mode-$year-$coordinates.xml</xsl:if>
      <xsl:if test="$mode = 'ruleset'">$cachefolder/?select=$ruleset-$cache.xml</xsl:if>
    </xsl:variable>
    <xsl:call-template name="replace">
      <xsl:with-param name="encode" select="'no'"/>
      <xsl:with-param name="string" select="$pcollection"/>
      <xsl:with-param name="parametergroup">
        <cachefolder>
          <xsl:value-of select="$rsp/cachefolder"/>
        </cachefolder>
        <xsl:call-template name="parametergroup"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="file">
    <xsl:param name="mode" tunnel="yes"/>
    <xsl:variable name="pfile">
      <xsl:if test="$mode = 'd2c'"
        >$cachefolder/$ruleset-$cache-$mode-$date-$set-$score-$minrankprecedence.xml</xsl:if>
      <xsl:if test="$mode = 'c2d'"
        >$cachefolder/$ruleset-$cache-$mode-$year-$coordinates.xml</xsl:if>
      <xsl:if test="$mode = 'ruleset'">$cachefolder/$ruleset-$cache.xml</xsl:if>
    </xsl:variable>
    <xsl:call-template name="replace">
      <xsl:with-param name="encode" select="'no'"/>
      <xsl:with-param name="string" select="$pfile"/>
      <xsl:with-param name="parametergroup">
        <cachefolder>
          <xsl:value-of select="$rsp/cachefolder"/>
        </cachefolder>
        <xsl:call-template name="parametergroup"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="parametergroup">
    <xsl:param name="mode" tunnel="yes"/>
    <xsl:param name="cache" tunnel="yes"/>
    <xsl:param name="date" tunnel="yes"/>
    <xsl:param name="set" tunnel="yes"/>
    <xsl:param name="score" tunnel="yes"/>
    <xsl:param name="minrankprecedence" tunnel="yes"/>
    <xsl:param name="coordinates" tunnel="yes"/>
    <xsl:param name="year" tunnel="yes"/>
    <ruleset>
      <xsl:value-of select="$ruleset"/>
    </ruleset>
    <mode>
      <xsl:value-of select="$mode"/>
    </mode>
    <cache>
      <xsl:choose>
        <xsl:when test="$cache = 'web'">webskip</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$cache"/>
        </xsl:otherwise>
      </xsl:choose>
    </cache>
    <date>
      <xsl:if test="$date">
        <xsl:value-of select="normalize-space($date)"/>
      </xsl:if>
    </date>
    <set>
      <xsl:if test="$set">
        <xsl:value-of select="$set"/>
      </xsl:if>
    </set>
    <score>
      <xsl:if test="$score">
        <xsl:value-of select="$score"/>
      </xsl:if>
    </score>
    <minrankprecedence>
      <xsl:if test="$minrankprecedence">
        <xsl:value-of select="$minrankprecedence"/>
      </xsl:if>
    </minrankprecedence>
    <coordinates>
      <xsl:if test="$coordinates">
        <xsl:value-of select="$coordinates"/>
      </xsl:if>
    </coordinates>
    <year>
      <xsl:if test="$year">
        <xsl:value-of select="$year"/>
      </xsl:if>
    </year>
  </xsl:template>

  <xsl:template name="replace">
    <!-- copied from liturgical.calendar.build-ruleset.xslt and added encoding func -->
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
        <xsl:variable name="replace"
          select="replace($string,concat('\$',local-name($parametergroup/*[1])),$replacement)"/>
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
