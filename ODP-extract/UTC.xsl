<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:variable name="UTC" as="xs:duration" select="xs:dayTimeDuration('PT0H')" />
    <xsl:variable name="UTC-date" as="xs:date" select="adjust-date-to-timezone(current-date(), $UTC)" />
    <xsl:variable name="UTC-datetime" as="xs:dateTime" select="adjust-dateTime-to-timezone(current-dateTime(), $UTC)" />
    
</xsl:stylesheet>