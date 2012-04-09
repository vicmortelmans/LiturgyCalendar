<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">
   
  <xsl:variable name="cycle-sundays">
    <map number="1" cycle="A"/>
    <map number="2" cycle="B"/>
    <map number="0" cycle="C"/>
  </xsl:variable>

  <xsl:variable name="cycle-weekdays">
    <map number="1" cycle="I"/>
    <map number="0" cycle="II"/>
  </xsl:variable>

  <xsl:template match="liturgicaldays" mode="d2c">
    <xsl:variable name="results">
      <xsl:apply-templates mode="d2c"/>
    </xsl:variable>
    <xsl:variable name="this-cycle-sundays">
      <xsl:value-of select="$cycle-sundays/map[@number = $year mod 3]/@cycle"/>
    </xsl:variable>
    <xsl:variable name="this-cycle-weekdays">
      <xsl:value-of select="$cycle-weekdays/map[@number = $year mod 2]/@cycle"/>
    </xsl:variable>
    <results>
      <xsl:choose>
        <xsl:when test="$score = 'yes'">
          <!-- there's no other result with higher score OR this result's
          coincides with matches another result-->
          <xsl:variable name="winner" 
            select="$results/coordinates
            [not(../coordinates/@score &lt; @score)]"/>
          <xsl:message>Scoring - highest score for 
            <xsl:value-of select="$winner"/>
          </xsl:message>
          <coordinates cycle="{$this-cycle-sundays}">
            <xsl:copy-of select="$winner/@*"/>
            <xsl:value-of select="$winner"/>
          </coordinates>
          <xsl:for-each select="$results/coordinates">
            <xsl:if test="not(@coincideswith = '')">
              <xsl:message>Scoring - coinciding candidate is 
                <xsl:value-of select="."/>
              </xsl:message>
              <xsl:if test="matches(@coincideswith,$winner/text())">
                <xsl:message>Scoring - coinciding with 
                  <xsl:value-of select="."/>
                </xsl:message>
                <coordinates cycle="{$this-cycle-sundays}">
                  <xsl:copy-of select="@*"/>
                  <xsl:value-of select="."/>
                </coordinates>
              </xsl:if>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="$results/coordinates">
            <coordinates cycle="{$this-cycle-sundays}">
              <xsl:copy-of select="@*"/>
              <xsl:value-of select="."/>
            </coordinates>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </results>
  </xsl:template>

  <xsl:template match="coordinaterules[not($set) or @set = $set]" mode="d2c">
    <xsl:variable name="calendardate" select="format-date(xs:date($date),'[M01]-[D01]')"/>
    <xsl:message>checking coordinaterules for <xsl:value-of select="@set"/> on <xsl:value-of select="$calendardate"/></xsl:message>
    <xsl:if test="(@start-date &lt;= $calendardate) and
                  ($calendardate &lt;= @stop-date)">
      <xsl:variable name="coordinates">
        <xsl:apply-templates/><!-- liturgy.calendar.lib.xslt kicking in -->
      </xsl:variable>
      <xsl:if test="$coordinates != ''">
        <xsl:message>got <xsl:value-of select="@set"/> coordinates within date range: <xsl:value-of select="$coordinates"/></xsl:message>
        <xsl:variable name="liturgicalday" select="//liturgicalday[coordinates = $coordinates][set = current()/@set][1]"/><!-- multiple <liturgicaldays> may have the same @coordinates -->
        <xsl:if test="$liturgicalday">
          <xsl:variable name="rank" select="$liturgicalday/rank/@nr"/>
          <xsl:message>rank = <xsl:value-of select="$rank"/></xsl:message>
          <xsl:variable name="precedence">
            <xsl:choose>
              <xsl:when test="$liturgicalday/precedence castable as xs:integer">
                <xsl:value-of select="xs:integer($liturgicalday/precedence)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="0"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:message>precedence = <xsl:value-of select="$precedence"/></xsl:message>
          <xsl:variable name="overlap-priority" select="//coordinaterules[@set = current()/@set]/@overlap-priority"/>
          <xsl:message>overlap-priority = <xsl:value-of select="$overlap-priority"/></xsl:message>
          <xsl:variable name="score" select="format-number(10000 * $rank + 100 * $precedence + $overlap-priority,'000000')"/>
          <coordinates set="{@set}" liturgicalday="{$liturgicalday/name}" rank="{$rank}" precedence="{$precedence}" overlap-priority="{$overlap-priority}" score="{$score}" coincideswith="{$liturgicalday/coincideswith}">
             <xsl:value-of select="replace($coordinates,'X','Y')"/>
          </coordinates>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>
    
  <xsl:template match="coordinaterules" mode="d2c"/>
  <xsl:template match="liturgicalday" mode="d2c"/>
  
</xsl:stylesheet>
