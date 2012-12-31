<?xml version="1.0"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">

  <xsl:include href="liturgy.calendar.build-ruleset.xslt"/>
  <xsl:include href="liturgy.calendar.lib.xslt"/>
  <xsl:include href="liturgy.calendar.cache.xslt"/>

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

  <!-- process ruleset file -->
  <xsl:variable name="rsp">
    <!-- contains the parametrized ruleset file -->
    <xsl:choose>
      <xsl:when test="matches($ruleset,'#')">
        <xsl:copy-of select="document(substring-before($ruleset,'#'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="document($ruleset)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="rsversion">
    <xsl:value-of select="string($rsp/liturgicaldays/@rsversion)"/>
  </xsl:variable>

  <xsl:variable name="rs">
    <!-- contains the un-parametrized ruleset file -->
    <xsl:call-template name="cache">
      <xsl:with-param name="mode" select="'ruleset'" tunnel="yes"/>
      <xsl:with-param name="cache" select="$cache" tunnel="yes"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:template match="*" mode="paste">
    <xsl:param name="paste"/>
    <xsl:copy>
      <xsl:copy-of select="$paste"/>
      <xsl:copy-of select="*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/">
    <!-- *main* - matches the root of the dummy input XML file -->
    <xsl:call-template name="cache">
      <xsl:with-param name="mode" select="$mode" tunnel="yes"/>
      <xsl:with-param name="cache" select="$cache" tunnel="yes"/>
      <xsl:with-param name="cachecalling" select="'yes'">
        <!-- any external call is assumed to be coming from the cache -->
      </xsl:with-param>
      <xsl:with-param name="date" select="$date" tunnel="yes"/>
      <xsl:with-param name="set" select="$set" tunnel="yes"/>
      <xsl:with-param name="score" select="$score" tunnel="yes"/>
      <xsl:with-param name="minrankprecedence" select="$minrankprecedence" tunnel="yes"/>
      <xsl:with-param name="coordinates" select="$coordinates" tunnel="yes"/>
      <xsl:with-param name="year" select="$year" tunnel="yes"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="router">
    <xsl:param name="mode" tunnel="yes"/>
    <xsl:if test="$mode = 'ruleset'">
      <xsl:apply-templates select="$rsp" mode="build"/>
    </xsl:if>
    <xsl:if test="$mode = 'd2c' or $mode = 'c2d'">
      <xsl:call-template name="calendar"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="calendar">
    <xsl:param name="mode" select="'d2c'" tunnel="yes"/>
    <xsl:param name="cache" select="'no'" tunnel="yes"/>
    <!-- d2c -->
    <xsl:param name="date" select="'2011-08-09'" tunnel="yes"/>
    <xsl:param name="set" tunnel="yes"/>
    <xsl:param name="score" select="'yes'" tunnel="yes"/>
    <xsl:param name="minrankprecedence" select="0" tunnel="yes"/>
    <!-- c2d -->
    <xsl:param name="coordinates" select="'A011'" tunnel="yes"/>
    <xsl:param name="year" select="'2011'" tunnel="yes"/>
    <xsl:variable name="context">
      <xsl:copy-of select="$rs/liturgicaldays/*"/>
      <mode>
        <xsl:value-of select="$mode"/>
      </mode>
      <cache>
        <xsl:choose>
          <xsl:when test="$cache = 'webskip'">web</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$cache"/>
          </xsl:otherwise>
        </xsl:choose>
      </cache>
      <xsl:if test="$mode = 'd2c'">
        <date>
          <xsl:value-of select="$date"/>
        </date>
        <set>
          <xsl:value-of select="$set"/>
        </set>
        <score>
          <xsl:value-of select="$score"/>
        </score>
        <minrankprecedence>
          <xsl:choose>
            <xsl:when test="string($minrankprecedence) = ''">0</xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$minrankprecedence"/>
            </xsl:otherwise>
          </xsl:choose>
        </minrankprecedence>
        <year>
          <xsl:call-template name="liturgical-year">
            <xsl:with-param name="date" select="$date"/>
          </xsl:call-template>
        </year>
      </xsl:if>
      <xsl:if test="$mode = 'c2d'">
        <coordinates>
          <xsl:value-of select="$coordinates"/>
        </coordinates>
        <year>
          <xsl:value-of select="$year"/>
        </year>
      </xsl:if>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$mode = 'd2c'">
        <xsl:message>DATE TO COORDINATES (root template)</xsl:message>
        <xsl:message>context : <xsl:copy-of select="$context/*[not(*)]"/></xsl:message>
        <xsl:variable name="calendardate" select="format-date(xs:date($context/date),'[M01]-[D01]')"/>
        <xsl:variable name="results">
          <xsl:for-each
            select="$context/coordinaterules
            [$context/set = '' or $context/set = @set] 
            [@start-date &lt;= $calendardate]
            [$calendardate &lt;= @stop-date]">
            <xsl:message>checking coordinaterules for <xsl:value-of select="@set"/> on <xsl:value-of
                select="$calendardate"/></xsl:message>
            <xsl:if
              test="(@start-date &lt;= $calendardate) and
              ($calendardate &lt;= @stop-date)">
              <xsl:variable name="coordinates">
                <xsl:apply-templates/>
                <!-- liturgy.calendar.lib.xslt kicking in -->
              </xsl:variable>
              <xsl:if test="$coordinates != ''">
                <xsl:message>got <xsl:value-of select="@set"/> coordinates within date range:
                    <xsl:value-of select="$coordinates"/></xsl:message>
                <xsl:variable name="liturgicalday"
                  select="$context/liturgicalday[coordinates = $coordinates][set = current()/@set][1]"/>
                <!-- multiple <liturgicaldays> may have the same @coordinates -->
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
                  <xsl:variable name="rankprecedence" select="100 * $rank + $precedence"/>
                  <xsl:if test="number($rankprecedence) &gt; number(/minrankprecedence)">
                    <xsl:variable name="overlap-priority"
                      select="$context/coordinaterules[@set = current()/@set]/@overlap-priority"/>
                    <xsl:message>overlap-priority = <xsl:value-of select="$overlap-priority"
                      /></xsl:message>
                    <xsl:variable name="score"
                      select="format-number(10000 * $rank + 100 * $precedence + $overlap-priority,'000000')"/>
                    <coordinates set="{@set}" liturgicalday="{$liturgicalday/name}" rank="{$rank}"
                      precedence="{$precedence}" overlap-priority="{$overlap-priority}"
                      score="{$score}" coincideswith="{$liturgicalday/coincideswith}">
                      <xsl:value-of select="replace($coordinates,'X','Y')"/>
                    </coordinates>
                  </xsl:if>
                </xsl:if>
              </xsl:if>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="this-cycle-sundays">
          <xsl:value-of select="$cycle-sundays/map[@number = $context/year mod 3]/@cycle"/>
        </xsl:variable>
        <xsl:variable name="this-cycle-weekdays">
          <xsl:value-of select="$cycle-weekdays/map[@number = $context/year mod 2]/@cycle"/>
        </xsl:variable>
        <results>
          <xsl:choose>
            <xsl:when test="$context/score = 'yes'">
              <!-- there's no other result with higher score OR this result's
          coincides with matches another result-->
              <xsl:variable name="winner"
                select="$results/coordinates
                [not(../coordinates/@score &lt; @score)]"/>
              <xsl:message>Scoring - highest score for <xsl:value-of select="$winner"/>
              </xsl:message>
              <coordinates cycle="{$this-cycle-sundays}">
                <xsl:copy-of select="$winner/@*"/>
                <xsl:value-of select="$winner"/>
              </coordinates>
              <xsl:for-each select="$results/coordinates">
                <xsl:if test="not(@coincideswith = '')">
                  <xsl:message>Scoring - coinciding candidate is <xsl:value-of select="."/>
                  </xsl:message>
                  <xsl:if test="matches(@coincideswith,$winner/text())">
                    <xsl:message>Scoring - coinciding with <xsl:value-of select="."/>
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
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>COORDINATES TO DATE (root template)</xsl:message>
        <xsl:message>context : <xsl:copy-of select="$context/*[not(*)]"/></xsl:message>
        <date>
          <xsl:apply-templates select="$context/liturgicalday[coordinates = $coordinates]/daterules"
          />
        </date>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="liturgical-year">
    <xsl:param name="date"/>
    <xsl:variable name="sameyear" select="year-from-date(xs:date($date))"/>
    <xsl:variable name="same0101" select="concat($sameyear,'-01-01')"/>
    <xsl:variable name="same1127" select="concat($sameyear,'-11-27')"/>
    <xsl:variable name="same1203" select="concat($sameyear,'-12-03')"/>
    <xsl:variable name="same1231" select="concat($sameyear,'-12-31')"/>
    <xsl:variable name="result">
      <xsl:choose>
        <xsl:when
          test="xs:date($date) &gt;= xs:date($same0101) and
			xs:date($date) &lt;  xs:date($same1127)">
          <xsl:value-of select="$sameyear"/>
        </xsl:when>
        <xsl:when
          test="xs:date($date) &gt;  xs:date($same1203) and
			xs:date($date) &lt;= xs:date($same1231)">
          <xsl:value-of select="$sameyear + 1"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="startnextyear">
            <xsl:call-template name="cache">
              <xsl:with-param name="mode" select="'c2d'" tunnel="yes"/>
              <xsl:with-param name="year" select="$sameyear + 1" tunnel="yes"/>
              <xsl:with-param name="coordinates" select="'A011'" tunnel="yes"/>
              <xsl:with-param name="cacheservice" select="$rsp/liturgicaldays/cacheservice"
                tunnel="yes"/>
              <xsl:with-param name="restservice" select="$rsp/liturgicaldays/restservice"
                tunnel="yes"/>
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
    <xsl:message>liturgical-year of <xsl:value-of select="$date"/> is <xsl:value-of select="$result"
      /></xsl:message>
    <xsl:value-of select="$result"/>
  </xsl:template>

  <xsl:variable name="cycle-sundays">
    <map number="1" cycle="A"/>
    <map number="2" cycle="B"/>
    <map number="0" cycle="C"/>
  </xsl:variable>

  <xsl:variable name="cycle-weekdays">
    <map number="1" cycle="I"/>
    <map number="0" cycle="II"/>
  </xsl:variable>

</xsl:stylesheet>
