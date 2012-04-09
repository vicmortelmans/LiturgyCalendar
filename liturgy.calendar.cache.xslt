<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">
    
  <xsl:template name="cache">
    <xsl:param name="mode" select="'d2c'"/>
    <!-- d2c -->
    <xsl:param name="date" select="'2011-08-09'"/>
    <xsl:param name="set"/>
    <xsl:param name="score" select="'yes'"/>
    <!-- c2d -->
    <xsl:param name="coordinates" select="'A011'"/>
    <xsl:param name="year" select="'2011'"/>
    <xsl:choose>
      <xsl:when test="$cache = 'no'">
        <xsl:call-template name="calendar">
          <xsl:if test="$mode"><xsl:with-param name="mode" select="$mode"/></xsl:if>
          <xsl:if test="$date"><xsl:with-param name="date" select="$date"/></xsl:if>
          <xsl:if test="$set"><xsl:with-param name="set" select="$set"/></xsl:if>
          <xsl:if test="$score"><xsl:with-param name="score" select="$score"/></xsl:if>
          <xsl:if test="$coordinates"><xsl:with-param name="coordinates" select="$coordinates"/></xsl:if>
          <xsl:if test="$year"><xsl:with-param name="year" select="$year"/></xsl:if>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="url">
          <xsl:text>http://xslt.childrensmissal.appspot.com/getCoordinates?output=xml&amp;set=</xsl:text>
          <xsl:value-of select="encode-for-uri(@set)"/>
          <xsl:text>&amp;date=</xsl:text> 
      <xsl:value-of select="$date"/>
      <xsl:text>&amp;options=</xsl:text>
      <xsl:value-of select="$options"/>
      <xsl:text>&amp;form=</xsl:text>
      <xsl:value-of select="$form"/>

        </xsl:variable>
        <xsl:variable name="cacheurl">
          <xsl:choose>
            <xsl:when test="$cache = 'eXist'">
              <xsl:text>http://ec2-46-137-56-166.eu-west-1.compute.amazonaws.com:8080/exist/rest//db/cache/cache-m-light.xq?url=</xsl:text>
	        </xsl:when>
	        <xsl:otherwise> 
              <xsl:text>http://prentenmissaal.my28msec.com/cache/cache?url=</xsl:text>
            </xsl:otherwise>
          </xsl:choose>

        </xsl:variable>
        
      </xsl:otherwise>

<xsl:variable name="cachedrest">
      <xsl:choose>
    <xsl:when test="$cache = 'yes'">
          <xsl:choose>
        <xsl:when test="$cacheserver = '28msec'">
	      <xsl:text>http://prentenmissaal.my28msec.com/cache/cache?url=</xsl:text>
	    </xsl:when>
	    <xsl:otherwise> 
	      <xsl:text>http://ec2-46-137-56-166.eu-west-1.compute.amazonaws.com:8080/exist/rest//db/cache/cache-m-light.xq?url=</xsl:text>
	    </xsl:otherwise>
          </xsl:choose>
	  <xsl:value-of select="encode-for-uri($rest)"/>
	  <xsl:text>&amp;expiration=0</xsl:text>
	  <xsl:text>&amp;doc=</xsl:text>
          <xsl:value-of select="$form"/>
	  <xsl:text>&amp;cacheserver=</xsl:text>
          <xsl:value-of select="$cacheserver"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$rest"/>
	  <xsl:text>&amp;cache=no</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="cachedrestdata">
      <xsl:value-of select="document($cachedrest)"/>
    </xsl:variable>
    <xsl:copy-of select="$cachedrestdata"/>
    <xsl:message>REST call to <xsl:value-of select="$cachedrest"/> (cache = <xsl:value-of select="$cache"/>)</xsl:message>
    <xsl:message><xsl:copy-of select="$cachedrestdata"/></xsl:message>
  </xsl:template>

</xsl:stylesheet>