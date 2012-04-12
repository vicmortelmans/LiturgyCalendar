<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">
    
  <!--
       RENDERERS
                 -->
  <xsl:template match="daterules">
    <xsl:choose>
    <xsl:when test="not(@option) or (@option and matches(/context/liturgicaldays/options,@option))">
        <xsl:message>daterules for <xsl:value-of select="../name"/> (year : <xsl:value-of select="/context/year"/>)</xsl:message>
        <xsl:apply-templates/>
        <xsl:message>/daterules</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>daterules option mismatch(option : <xsl:value-of select="@option"/>, options : <xsl:value-of select="/context/liturgicaldays/options"/>)</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--
       DATE OPERATORS
                      -->
                           
  <xsl:template match="this-date">
    <!-- INPUT $date : yyyy-mm-dd
         OUTPUT yyyy-mm-dd -->
    <xsl:message>this-date(date : <xsl:value-of select="normalize-space(/context/date)"/>)</xsl:message>
    <xsl:value-of select="normalize-space(/context/date)"/>
    <xsl:message>/this-date</xsl:message>
  </xsl:template>
    
  <xsl:template match="date">
    <!-- INPUT /context/year, e.g. '2011', interpreted as liturgical year 2010-2011
               @day, @month, @year-1
         OUTPUT yyyy-mm-dd
         NOTE: if a date is meant in the first part of the liturgical year
               before 1/01, the attribute @year-1 must be set ! -->
    <xsl:message>date(year : <xsl:value-of select="/context/year"/>, day : <xsl:value-of select="@day"/>, month : <xsl:value-of select="@month"/>, before 01/1 : <xsl:value-of select="@year-1"/>)</xsl:message>
    <xsl:choose>
      <xsl:when test="@*">
        <date>
          <xsl:choose>
            <xsl:when test="@year-1 = 'yes'">
              <xsl:number value="number(/context/year) - 1" format="0001"/> 
            </xsl:when>
            <xsl:otherwise>
              <xsl:number value="number(/context/year)" format="0001"/>          
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>-</xsl:text>
          <xsl:number value="@month" format="01"/>
          <xsl:text>-</xsl:text>
          <xsl:number value="@day" format="01"/>
        </date>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:message>/date</xsl:message>
  </xsl:template>
  
  <xsl:template match="easterdate">
    <!-- INPUT /context/year
         OUTPUT yyyy-mm-dd
         NOTE: using /context/year is OK, easter never falls before 1/1 -->
    <xsl:message>easterdate(year : <xsl:value-of select="/context/year"/>)</xsl:message>
    <xsl:variable name="easterdate" select="document('https://raw.github.com/vicmortelmans/BibleConfiguration/master/liturgy.calendar.roman-rite.easterdates.xml')/easterdates/easterdate"/>
    <xsl:variable name="year" select="/context/year"/>
    <xsl:number value="number($year)" format="0001"/>
    <xsl:text>-</xsl:text>
    <xsl:number value="$easterdate[year = $year]/month" format="01"/>
    <xsl:text>-</xsl:text>
    <xsl:number value="$easterdate[year = $year]/day" format="01"/>
    <xsl:message>/easterdate</xsl:message>
  </xsl:template>
  
  <xsl:template match="weekday-after">
    <!-- INPUT @day : weekday string, e.g. "Sunday"
         OUTPUT yyyy-mm-dd -->
    <xsl:message>weekday-after(day : <xsl:value-of select="@day"/>, date to be evaluated)</xsl:message>
    <xsl:variable name="date">
      <xsl:apply-templates/>
    </xsl:variable>
    <!--1/ get weekdayindex of reference date (r) and weekdayindex of target day (t)
        2/ get difference between t and r, d = (max(r,t)-min(r,t))
        3/ add d days to the reference date-->
    <xsl:variable name="weekdayindex">
      <day name="Sunday" index="1"/>
      <day name="Monday" index="2"/>
      <day name="Tuesday" index="3"/>
      <day name="Wednesday" index="4"/>
      <day name="Thursday" index="5"/>
      <day name="Friday" index="6"/>
      <day name="Saturday" index="7"/>
    </xsl:variable>
    <xsl:variable name="r">
      <xsl:value-of select="$weekdayindex/day[matches(replace(format-date(xs:date($date),'[F]'),'(\[.*\])?(.+)','$2'),@name)]/@index"/>
    </xsl:variable>
    <xsl:variable name="t">
      <xsl:value-of select="$weekdayindex/day[matches(current()/@day,@name)]/@index"/>
    </xsl:variable>
    <xsl:variable name="d">
      <xsl:choose>
        <xsl:when test="$r &gt; $t">
          <xsl:value-of select="$t - $r + 7"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$t - $r"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="daysDuration">
      <xsl:text>P</xsl:text>
      <xsl:number value="$d"/>
      <xsl:text>D</xsl:text>
    </xsl:variable>
    <!--xsl:message><xsl:value-of select="concat($t,'|',$r,'|',$d)"/></xsl:message-->
    <date>
      <xsl:value-of select="replace(format-date(xs:date($date) + xs:dayTimeDuration($daysDuration), '[Y0001]-[M01]-[D01]'),'(\[.*\])?(.+)','$2')"/>
    </date>
    <xsl:message>/weekday-after</xsl:message>
  </xsl:template>
  
  <xsl:template match="weekday-before">
    <!-- INPUT @day : weekday string, e.g. "Sunday"
         OUTPUT yyyy-mm-dd -->
    <xsl:message>weekday-before(day : <xsl:value-of select="@day"/>, date to be evaluated)</xsl:message>
    <xsl:variable name="daterules">
      <weekday-after day="{@day}">
        <weeks-before nr="1">
          <xsl:apply-templates/>
        </weeks-before>
      </weekday-after>
    </xsl:variable>
    <xsl:apply-templates select="$daterules/*"/>
    <xsl:message>/weekday-before</xsl:message>
  </xsl:template>
  
  <xsl:template match="weekday-before-or-self">
    <!-- INPUT @day : weekday string, e.g. "Sunday"
         OUTPUT yyyy-mm-dd -->
    <xsl:message>weekday-before-or-self(day : <xsl:value-of select="@day"/>, date to be evaluated)</xsl:message>
    <xsl:variable name="daterules">
      <weekday-after day="{@day}">
        <days-before nr="6">
          <xsl:apply-templates/>
        </days-before>
      </weekday-after>
    </xsl:variable>
    <xsl:apply-templates select="$daterules/*"/>
    <xsl:message>/weekday-before-or-self</xsl:message>
  </xsl:template>

  <xsl:template match="days-before">
    <!-- INPUT @nr : number, e.g. '2'
         OUTPUT yyyy-mm-dd -->
    <xsl:message>days-before(nr : <xsl:value-of select="@nr"/>, date to be evaluated)</xsl:message>
    <xsl:variable name="date">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="daysDuration">
      <xsl:text>P</xsl:text>
      <xsl:value-of select="@nr"/>
      <xsl:text>D</xsl:text>
    </xsl:variable>
    <date>
      <xsl:value-of select="replace(format-date(xs:date($date) - xs:dayTimeDuration($daysDuration), '[Y0001]-[M01]-[D01]'),'(\[.*\])?(.+)','$2')"/>
    </date>
    <xsl:message>/days-before</xsl:message>
  </xsl:template>

  <xsl:template match="days-after">
    <!-- INPUT @nr : number, e.g. '2'
         OUTPUT yyyy-mm-dd -->
    <xsl:message>days-after(nr : <xsl:value-of select="@nr"/>, date to be evaluated)</xsl:message>
    <xsl:variable name="date">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="daysDuration">
      <xsl:text>P</xsl:text>
      <xsl:value-of select="@nr"/>
      <xsl:text>D</xsl:text>
    </xsl:variable>
    <date>
      <xsl:value-of select="replace(format-date(xs:date($date) + xs:dayTimeDuration($daysDuration), '[Y0001]-[M01]-[D01]'),'(\[.*\])?(.+)','$2')"/>
    </date>
    <xsl:message>/days-after</xsl:message>
  </xsl:template>

  <xsl:template match="weeks-before">
    <!-- INPUT @nr : number, e.g. '2'
         OUTPUT yyyy-mm-dd -->
    <xsl:message>weeks-before(nr : <xsl:value-of select="@nr"/>, date to be evaluated)</xsl:message>
    <xsl:variable name="date">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="daysDuration">
      <xsl:text>P</xsl:text>
      <xsl:value-of select="7 * @nr"/>
      <xsl:text>D</xsl:text>
    </xsl:variable>
    <date>
      <xsl:value-of select="replace(format-date(xs:date($date) - xs:dayTimeDuration($daysDuration), '[Y0001]-[M01]-[D01]'),'(\[.*\])?(.+)','$2')"/>
    </date>
    <xsl:message>/weeks-before</xsl:message>
  </xsl:template>

  <xsl:template match="weeks-after">
    <!-- INPUT @nr : number, e.g. '2'
         OUTPUT yyyy-mm-dd -->
    <xsl:message>weeks-after(nr : <xsl:value-of select="@nr"/>, date to be evaluated)</xsl:message>
    <xsl:variable name="date">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="daysDuration">
      <xsl:text>P</xsl:text>
      <xsl:value-of select="7 * @nr"/>
      <xsl:text>D</xsl:text>
    </xsl:variable>
    <date>
      <xsl:value-of select="replace(format-date(xs:date($date) + xs:dayTimeDuration($daysDuration), '[Y0001]-[M01]-[D01]'),'(\[.*\])?(.+)','$2')"/>
    </date>
    <xsl:message>/weeks-after</xsl:message>
  </xsl:template>


  <xsl:template match="relative-to">
    <!-- INPUT /context/year
               @name : liturgical day name
         OUTPUT yyyy-mm-dd : the date returned by rendering @name's daterules -->
    <xsl:message>relative-to(name : <xsl:value-of select="@name"/>)</xsl:message>
    <xsl:variable name="coordinates" select="//liturgicalday[name = current()/@name]/coordinates"/>
    <xsl:call-template name="cache">
      <xsl:with-param name="mode" select="'c2d'"/>
      <xsl:with-param name="year" select="/context/year"/>
      <xsl:with-param name="coordinates" select="$coordinates"/>
    </xsl:call-template>
    <xsl:message>/relative-to</xsl:message>
  </xsl:template>

  <xsl:template match="relative-to-next-years">
    <!-- INPUT /context/year
               @name : liturgical day name
         OUTPUT yyyy-mm-dd : the date returned by rendering @name's daterules in next year-->
    <xsl:message>relative-to-next-years(name : <xsl:value-of select="@name"/>)</xsl:message>
    <xsl:variable name="coordinates" select="//liturgicalday[name = current()/@name]/coordinates"/>
    <xsl:call-template name="cache">
      <xsl:with-param name="mode" select="'c2d'"/>
      <xsl:with-param name="year" select="/context/year + 1"/>
      <xsl:with-param name="coordinates" select="$coordinates"/>
    </xsl:call-template>
    <xsl:message>/relative-to-next-years</xsl:message>
  </xsl:template>
  
  <xsl:template match="transfer">
    <!-- INPUT @sets : the sets to be investigated
               @rank : the rank of the current day
               * : a date
         Checks all @sets for the given date, and if they have a day of rank higher than @rank,
         Returns the day after.
         OUTPUT yyyy-mm-dd : a date -->
    <xsl:message>transfer(sets : <xsl:value-of select="@sets"/>, rank : <xsl:value-of select="@rank"/>)</xsl:message>
    <xsl:variable name="rank" select="@rank"/>
    <xsl:variable name="sets" select="@sets"/>
    <!-- render the investigated date -->
    <xsl:variable name="date">
            <xsl:apply-templates/>
    </xsl:variable>
    <!-- render the coordinates in the specified sets -->
    <xsl:variable name="coordinates">
      <xsl:for-each select="//coordinaterules[matches($sets,@set)]">
	<xsl:variable name="rankprecedence">
	  <xsl:choose>
	    <xsl:when test="ancestor::liturgicalday/precedence">
	      <xsl:value-of select="100 * ancestor::liturgicalday/rank/@nr + ancestor::liturgicalday/precedence"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="100 * ancestor::liturgicalday/rank/@nr"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
        <xsl:variable name="ruleset">
          <!-- to avoid endless looping, the set-coordinates template should only return coordinates for days with minimum rank and precedence
               and even more: it should avoid executing the daterules for days with lesser rank and precedence -->
          <xsl:message>transfer - finding overlap with minrankprecedence <xsl:value-of select="$rankprecedence"/></xsl:message>
	  <set-coordinates set="{@set}" minrankprecedence="{$rankprecedence}">
            <xsl:value-of select="$date"/>
          </set-coordinates>
        </xsl:variable>
<xsl:message>DEBUG start <xsl:copy-of select="$ruleset"/></xsl:message>
        <xsl:apply-templates select="$ruleset/*"/>
<xsl:message>DEBUG stop </xsl:message>
      </xsl:for-each>
    </xsl:variable>
    <xsl:message>transfer - coordinates: <xsl:copy-of select="$coordinates"/></xsl:message>
    <xsl:variable name="overlapping-liturgicaldays" select="//liturgicalday[matches($coordinates,coordinates)]"/>
    <xsl:message>overlapping-liturgicaldays: <xsl:copy-of select="$overlapping-liturgicaldays"/></xsl:message>
    <xsl:variable name="overlapping-liturgicaldays-of-higher-rank" select="$overlapping-liturgicaldays[number(rank/@nr) &lt; number($rank)]"/>
    <xsl:message>overlapping-liturgicaldays-of-higher-rank: <xsl:copy-of select="$overlapping-liturgicaldays-of-higher-rank"/></xsl:message>
    <xsl:choose>
      <xsl:when test="$overlapping-liturgicaldays-of-higher-rank">
        <xsl:message>TRANSFERRING from <xsl:value-of select="$date"/> for <xsl:value-of select="$overlapping-liturgicaldays/coordinates"/></xsl:message>
        <xsl:variable name="ruleset">
          <transfer set="{$sets}" rank="{$rank}">
            <days-after nr="1">
               <xsl:value-of select="$date"/>
            </days-after>
          </transfer>
        </xsl:variable>
        <!-- recursive call -->
        <xsl:apply-templates select="$ruleset/*"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$date"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:message>/transfer</xsl:message>
  </xsl:template>


	<!-- 
	COORDINATES OPERATORS
	-->

  <xsl:template match="coordinates">
    <!-- INPUT /context/year : yyyy (contains liturgical year)
         @set : name of a set of liturgical days
         @day : dd
         @month : mm
         @year-1 : yes (or absent)
         OUTPUT evaluation of the coordinaterules for @set for $date = yyyy-mm-dd -->
    <xsl:message>coordinates(year : <xsl:value-of select="/context/year"/>, set : <xsl:value-of select="@set"/>, day : <xsl:value-of select="@day"/>, month : <xsl:value-of select="@month"/>, before 01/1 : <xsl:value-of select="@year-1"/>)</xsl:message>
    <xsl:variable name="date">
      <xsl:choose>
        <xsl:when test="@year-1">
          <xsl:value-of select="xs:date(concat(/context/year - 1,'-01-01')) + xs:yearMonthDuration(concat('P',@month - 1,'M')) + xs:dayTimeDuration(concat('P',@day - 1,'D'))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>DEBUG <xsl:copy-of select="."/></xsl:message>
          <xsl:value-of select="xs:date(concat(/context/year,'-01-01')) + xs:yearMonthDuration(concat('P',@month - 1,'M')) + xs:dayTimeDuration(concat('P',@day - 1,'D'))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="cache">
      <xsl:with-param name="mode" select="'d2c'"/>
      <xsl:with-param name="set" select="@set"/>
      <xsl:with-param name="date" select="$date"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="set-coordinates">
    <!-- INPUT @set : name of a set of liturgical days
               @minrankprecedence : value for minimum rank (* 100) + precedence
         * : a date
         OUTPUT evaluation of the coordinaterules for all sets -->
    <xsl:message>set-coordinates (set : <xsl:value-of select="@set"/>; minrankprecedence : <xsl:value-of select="@minrankprecedence"/>; date is to be evaluated)</xsl:message>
    <xsl:variable name="date">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:call-template name="cache">
      <xsl:with-param name="mode" select="'d2c'"/>
      <xsl:with-param name="date" select="$date"/>
      <xsl:with-param name="set" select="@set"/>
      <xsl:with-param name="minrankprecedence" select="@minrankprecedence"/>
    </xsl:call-template>
    <xsl:message>/set-coordinates</xsl:message>
  </xsl:template>

  <xsl:template match="query-set">
  <!-- INPUT $date : yyyy-mm-dd
       @set : name of a set of liturgical days
       OUTPUT for each liturgical day in @set, that has higher rankprecedence than /context/minrankprecedence, the daterules are applied and
       if the date matches $date, 
       the <coordinates> for that liturgical day are returned.
       If @anydate is specified all matching coordinates are returned concatenated. -->
    <xsl:message>query-set(date : <xsl:value-of select="normalize-space(/context/date)"/>, set : <xsl:value-of select="@set"/>)</xsl:message>
    <xsl:for-each select="//liturgicalday[set = current()/@set]">
      <xsl:variable name="rankprecedence">
        <xsl:choose>
          <xsl:when test="precedence">
            <xsl:value-of select="100 * rank/@nr + precedence"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="100 * rank/@nr"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:message>querying <xsl:value-of select="set"/>; <xsl:value-of select="/context/minrankprecedence"/> &gt; <xsl:value-of select="$rankprecedence"/></xsl:message>
      <xsl:if test="number(/context/minrankprecedence) = 0 or number(/context/minrankprecedence) &gt; number($rankprecedence)">
	<xsl:variable name="candidate">
	  <xsl:apply-templates select="daterules"/>
	</xsl:variable>
	<xsl:if test="not(normalize-space($candidate) = '') and ($candidate = /context/date or @anydate)">
	  <xsl:value-of select="coordinates"/>
	</xsl:if>
      </xsl:if>
    </xsl:for-each>
    <xsl:message>/query-set</xsl:message>
  </xsl:template>

  <xsl:template match="query-coordinates">
  <!-- INPUT $date : yyyy-mm-dd
       @set : name of a set of liturgical days
       coordinates : specific coordinates
       OUTPUT for the liturgical day(s) in @set that match @coordinates, and that have higher rankprecedence than /context/minrankprecedence, 
       the daterules are applied and if the date matches $date, 
       the <coordinates> for that liturgical day are returned.
       If anydate is specified all matching coordinates are returned concatenated. -->
    <xsl:message>query-coordinates(date : <xsl:value-of select="normalize-space(/context/date)"/>, set : <xsl:value-of select="@set"/>, coordinates to be evaluated)</xsl:message>
    <xsl:variable name="coordinates">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:for-each select="//liturgicalday[set=current()/@set and coordinates=$coordinates]">
      <xsl:message>querying <xsl:value-of select="coordinates"/> in <xsl:value-of select="set"/></xsl:message>
      <xsl:if test="number(/context/minrankprecedence) = 0 or number(/context/minrankprecedence) &gt; 100 * number(rank/@nr) + number(precedence)">
	<xsl:variable name="candidate">
	  <xsl:apply-templates select="daterules"/>
	</xsl:variable>
	<xsl:message>testing if <xsl:value-of select="$candidate"/> equals <xsl:value-of select="/context/date"/></xsl:message>
	<xsl:if test="not(normalize-space($candidate) = '') and ($candidate = /context/date or @anydate)">
	  <xsl:value-of select="coordinates"/>
	</xsl:if>
      </xsl:if>
    </xsl:for-each>
    <xsl:message>/query-coordinates</xsl:message>
  </xsl:template>

  <!--
        GENERIC OPERATORS 
      -->

  <xsl:template match="if">
    <!-- INPUT $* 
         not : negation of the 'test'
         test : logical operator
         then : anything that can be applied
         else : anything that can be applied
         OUTPUT whatever the 'then' or 'else' returns -->
    <xsl:message>if(test to be evaluated)</xsl:message>
    <xsl:variable name="test">
      <xsl:apply-templates select="test/*"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="(not(not) and $test='true') or (not and not($test='true'))">
        <xsl:variable name="then">
          <xsl:apply-templates select="then/*"/>
        </xsl:variable>
        <xsl:message>then(<xsl:value-of select="$then"/>)</xsl:message>
        <xsl:value-of select="$then"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="else">
          <xsl:apply-templates select="else/*"/>
        </xsl:variable>
        <xsl:message>else(<xsl:value-of select="$else"/>)</xsl:message>
        <xsl:value-of select="$else"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:message>/if(<xsl:value-of select="$test"/>)</xsl:message>
  </xsl:template>
  
  <!-- 
       NUMBER OPRATORS
                       -->
  
  <xsl:template match="count-days-between">
    <!-- INPUT : *[1] : date operator or literal date string <xsl:text>yyyy-mm-dd</xsl:text>
                 *[2] : date operator or literal date string <xsl:text>yyyy-mm-dd</xsl:text>
         OUTPUT : number of days between the two dates -->
    <xsl:message>count-days-between(date1 and date2 to be evaluated)</xsl:message>
    <xsl:variable name="date1">
      <xsl:apply-templates select="*[1]"/>
    </xsl:variable>
    <xsl:variable name="date2">
      <xsl:apply-templates select="*[2]"/>
    </xsl:variable>
    <xsl:value-of select="fn:days-from-duration(xs:date($date2) - xs:date($date1))"/>
    <xsl:message>/count-days-between</xsl:message>
  </xsl:template>

  <xsl:template match="count-weeks-between">
    <!-- INPUT : *[1] : date operator or literal date string <xsl:text>yyyy-mm-dd</xsl:text>
                 *[2] : date operator or literal date string <xsl:text>yyyy-mm-dd</xsl:text>
         OUTPUT : number of (full) weeks between the two dates -->
    <xsl:message>count-weeks-between(date1 and date2 to be evaluated)</xsl:message>
    <xsl:variable name="date1">
      <xsl:apply-templates select="*[1]"/>
    </xsl:variable>
    <xsl:variable name="date2">
      <xsl:apply-templates select="*[2]"/>
    </xsl:variable>
    <xsl:value-of select="(floor(fn:days-from-duration(xs:date($date2) - xs:date($date1)) div 7))"/>
    <xsl:message>/count-weeks-between</xsl:message>
  </xsl:template>

  <xsl:template match="day-number">
    <!-- INPUT : * : date operator or literal date string  <xsl:text>yyyy-mm-dd</xsl:text>
         OUTPUT : weekday number, Sunday is 1 -->
    <xsl:message>day-number(date to be evaluated)</xsl:message>
    <xsl:variable name="date">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="weekdayindex">
      <day name="Sunday" index="1"/>
      <day name="Monday" index="2"/>
      <day name="Tuesday" index="3"/>
      <day name="Wednesday" index="4"/>
      <day name="Thursday" index="5"/>
      <day name="Friday" index="6"/>
      <day name="Saturday" index="7"/>
    </xsl:variable>
    <xsl:value-of select="$weekdayindex/day[matches(replace(format-date(xs:date($date),'[F]'),'(\[.*\])?(.+)','$2'),@name)]/@index"/>
    <xsl:message>/day-number</xsl:message>
  </xsl:template>

  <!-- 
       LOGICAL OPERATORS 
                        -->

  <xsl:template match="test-day">
    <!-- INPUT * : date operator or literal date string  <xsl:text>yyyy-mm-dd</xsl:text>
               @day : weekday string, e.g. "Sunday"
         OUTPUT "true" if the date is a '@day'; else nothing -->
    <!-- tricky: day can be a list of multiple days, e.g. "Saturday Friday Thursday Wednesday"
         and format-date()'s output is contaminated like this: "[Language: en]Wednesday" 
         so a regex is needed to remove the [...]-part from the format-date()-output -->
    <xsl:message>test-day(day to be evaluated, date : <xsl:value-of select="normalize-space(/context/date)"/>)</xsl:message>
    <xsl:variable name="date">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="day">
      <xsl:value-of select="replace(format-date(xs:date(/context/date),'[F]'),'(\[.*\])?(.+)','$2')"/>
    </xsl:variable>
    <xsl:if test="matches(@day,$day)">true</xsl:if>
    <xsl:message>/test-day</xsl:message>
  </xsl:template>
  
  <xsl:template match="before">
    <!-- INPUT *[1] : date operator or literal date string <xsl:text>yyyy-mm-dd</xsl:text>
               *[2] : date operator or literal date string <xsl:text>yyyy-mm-dd</xsl:text>
         OUTPUT "true" if date one is before date two; else nothing -->
    <xsl:message>before(date1 and date2 to be evaluated)</xsl:message>
    <xsl:variable name="date1">
      <xsl:apply-templates select="*[1]"/>
    </xsl:variable>
    <xsl:variable name="date2">
      <xsl:apply-templates select="*[2]"/>
    </xsl:variable>
    <xsl:if test="xs:date($date1) &lt; xs:date($date2)">true</xsl:if>
    <xsl:message>/before</xsl:message>
  </xsl:template>
  
  <xsl:template match="not-after">
    <!-- INPUT *[1] : date operator or literal date string <xsl:text>yyyy-mm-dd</xsl:text>
               *[2] : date operator or literal date string <xsl:text>yyyy-mm-dd</xsl:text>
         OUTPUT "true" if date one is before date two; else nothing -->
    <xsl:message>not-after(date1 and date2 to be evaluated)</xsl:message>
    <xsl:variable name="date1">
      <xsl:apply-templates select="*[1]"/>
    </xsl:variable>
    <xsl:variable name="date2">
      <xsl:apply-templates select="*[2]"/>
    </xsl:variable>
    <xsl:if test="xs:date($date1) &lt;= xs:date($date2)">true</xsl:if>
    <xsl:message>/not-after(date1 : <xsl:value-of select="$date1"/>, date2 : <xsl:value-of select="$date2"/>)</xsl:message>
  </xsl:template>
  
  <xsl:template match="matches">
    <!-- INPUT *[1] : string operator or literal string
               *[2] : string operator or literal string
         OUTPUT "true" if the first string can be found in the second -->
    <xsl:message>matches(string1 and string2 to be evaluated)</xsl:message>
    <xsl:variable name="string1">
      <xsl:apply-templates select="*[1]"/>
    </xsl:variable>
    <xsl:variable name="string2">
      <xsl:apply-templates select="*[2]"/>
    </xsl:variable>
    <xsl:if test="$string1 != '' and matches($string2,$string1)">true</xsl:if>
    <xsl:message>/matches(string1 : <xsl:value-of select="$string1"/>, string2 : <xsl:value-of select="$string2"/>)</xsl:message>
  </xsl:template>
   
  <xsl:template match="equals">
    <!-- INPUT *[1] : date operator or literal date string <xsl:text>yyyy-mm-dd</xsl:text>
               *[2] : date operator or literal date string <xsl:text>yyyy-mm-dd</xsl:text>
         OUTPUT "true" if the two dates are identical; else nothing -->
    <xsl:message>equals(string1 and string2 to be evaluated)</xsl:message>
    <xsl:variable name="string1">
      <xsl:apply-templates select="*[1]"/>
    </xsl:variable>
    <xsl:variable name="string2">
      <xsl:apply-templates select="*[2]"/>
    </xsl:variable>
    <xsl:if test="$string2=$string1">true</xsl:if>
    <xsl:message>/equals(string1 : <xsl:value-of select="$string1"/>, string2 : <xsl:value-of select="$string2"/>)</xsl:message>
  </xsl:template>
  
  <xsl:template match="exists">
    <!-- INPUT * : any operator
         OUTPUT : "true" unless the normalized result string is empty -->
    <xsl:message>exists(string to be evaluated)</xsl:message>
    <xsl:variable name="string">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:if test="not(normalize-space($string) = '')">true</xsl:if>
    <xsl:message>/exists(string : <xsl:value-of select="$string"/>)</xsl:message>
  </xsl:template>

  <xsl:template match="or">
    <!-- INPUT *[1..n] : logical operators 
         OUTPUT : "true" if any of the arguments are true -->
    <xsl:message>or()</xsl:message>
    <xsl:variable name="output">
      <xsl:for-each select="*">
        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="matches($output,'true')">true</xsl:if>
    <xsl:message>/or</xsl:message>
  </xsl:template>
   
  <!-- 
       STRING OPERATORS
                        -->

  <xsl:template match="format">
    <!-- INPUT * : number operator or literal number
               @template : formatting template, e.g. "01"
         OUTPUT : the formatted number -->
    <xsl:message>format(template : <xsl:value-of select="@template"/>, number to be evaluated)</xsl:message>
    <xsl:variable name="number">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:value-of select="format-number($number,@template)"/>
    <xsl:message>/format(template : <xsl:value-of select="@template"/>, number : <xsl:value-of select="$number"/>)</xsl:message>
  </xsl:template>

  <xsl:template match="text">
    <!-- INPUT * : text node
         OUTPUT : text node -->
    <xsl:message>text(text : <xsl:value-of select="text()"/>)</xsl:message>
    <xsl:value-of select="text()"/>
    <xsl:message>/text</xsl:message>
  </xsl:template>
  
  <xsl:template match="mmdd">
    <!-- INPUT * : date operator or literal date <xsl:text>yyyy-mm-dd</xsl:text>
         OUTPUT string "mmdd" -->
    <xsl:message>mmdd(date to be evaluated)</xsl:message>
    <xsl:variable name="date">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:value-of select="concat(format-number(fn:month-from-date(xs:date($date)),'00'),format-number(fn:day-from-date(xs:date($date)),'00'))"/>
    <xsl:message>mmdd(date : <xsl:value-of select="normalize-space($date)"/>)</xsl:message>
  </xsl:template>
  
  <xsl:template match="yyyy">
    <!-- INPUT * : date operator or literal date <xsl:text>yyyy-mm-dd</xsl:text>
         OUTPUT string "yyyy" of the *liturgical year* the date is falling in 
                (e.g. 2010-12-25 falls in liturgical year 2011) -->
    <xsl:message>yyyy(date to be evaluated)</xsl:message>
    <xsl:variable name="date">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="year" select="fn:year-from-date(xs:date($date))"/>
    <xsl:variable name="startDayRules">
      <weeks-before nr="3">
        <weekday-before day="Sunday">
          <date>
            <xsl:number value="number(/context/year)" format="0001"/>
            <xsl:text>-</xsl:text>
            <xsl:number value="12"/>
            <xsl:text>-</xsl:text>
            <xsl:number value="25"/>
          </date>
        </weekday-before>
      </weeks-before>
    </xsl:variable>
    <xsl:variable name="startDay">
      <xsl:apply-templates select="$startDayRules/*"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="xs:date($date) &lt; xs:date($startDay)">
        <xsl:value-of select="format-number(number(/context/year),'0000')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="format-number(number(/context/year) + 1,'0000')"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:message>/yyyy</xsl:message>
  </xsl:template>

</xsl:stylesheet>
