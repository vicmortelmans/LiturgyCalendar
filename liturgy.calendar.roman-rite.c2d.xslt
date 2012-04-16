<?xml version="1.0"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions">

  <xsl:template match="context" mode="c2d">
    <xsl:message>context</xsl:message>
    <xsl:apply-templates mode="c2d"/>
    <xsl:message>/context</xsl:message>
  </xsl:template>

  <xsl:template match="liturgicaldays" mode="c2d">
    <xsl:apply-templates mode="c2d"/>
  </xsl:template>

  <xsl:template match="liturgicalday[coordinates = $coordinates]" mode="c2d">
    <xsl:message>liturgicalday</xsl:message>
    <date>
        <xsl:apply-templates select="daterules"/><!-- liturgy.calendar.lib.xslt kicking in -->
    </date>
    <xsl:message>/liturgicalday</xsl:message>
  </xsl:template>
  
  <xsl:template match="*|text()" mode="c2d"/>
  <xsl:template match="coordinaterules" mode="c2d"/>
  <xsl:template match="liturgicalday" mode="c2d"/>
</xsl:stylesheet>
