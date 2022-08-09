<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" exclude-result-prefixes="xs math" version="3.0">
    <xsl:mode on-no-match="shallow-copy" />
    <xsl:template match="Low | Moderate | High">
        <xsl:choose>
            <xsl:when test="matches(normalize-space(),'\.$')">
                <!-- remove trailing period -->
                <xsl:copy>
                    <xsl:value-of select="replace(normalize-space(), '\.$', '')" />
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="." />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
