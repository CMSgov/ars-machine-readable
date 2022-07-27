<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:uuid="java.util.UUID" xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
    exclude-result-prefixes="xs math uuid oscal" version="3.0" xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0" expand-text="true">

    <!-- Derive an OSCAL catalog for ARS -->
    <!-- ARS specifies all SP 800-53 rev5 controls (not all appear in baselines) -->

    <!-- This transform expects -->
    <!-- https://raw.githubusercontent.com/usnistgov/oscal-content/main/nist.gov/SP800-53/rev5/xml/NIST_SP-800-53_rev5_catalog.xml -->
    <!-- or the equivalent as input -->

    <xsl:include href="UTC.xsl" />

    <xsl:mode on-no-match="shallow-copy" />

    <xsl:output method="xml" indent="true" />

    <xsl:variable name="LF" as="xs:string" select="'&#x0a;'" />

    <xsl:template match="/">
        <xsl:processing-instruction name="xml-model">
            <xsl:text expand-text="false">href="https://github.com/usnistgov/OSCAL/raw/v1.0.4/xml/schema/oscal_complete_schema.xsd" schematypens="http://www.w3.org/2001/XMLSchema" title="OSCAL complete schema" </xsl:text>
        </xsl:processing-instruction>
        <xsl:copy-of select="$LF" />
        <xsl:comment> Input document was {document-uri()} </xsl:comment>
        <xsl:copy-of select="$LF" />
        <xsl:comment> Input document version was {//metadata/version} </xsl:comment>
        <xsl:copy-of select="$LF" />
        <xsl:comment> Input document last-modified was {//metadata/last-modified} </xsl:comment>
        <xsl:copy-of select="$LF" />
        <xsl:comment> Transform document was {static-base-uri()} </xsl:comment>
        <xsl:copy-of select="$LF" />
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="catalog">
        <xsl:copy>
            <xsl:attribute name="uuid" select="uuid:randomUUID()" />
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="metadata">
        <metadata xmlns="http://csrc.nist.gov/ns/oscal/1.0">
            <title>>CMS ARS 5.0 Catalog</title>
            <last-modified>{$UTC-datetime}</last-modified>
            <version>{$UTC-datetime}</version>
            <oscal-version>1.0.4</oscal-version>
            <link rel="derivation-of" href="{base-uri()}" />
        </metadata>
    </xsl:template>

    <xsl:template match="param[not(@id = parent::control/part[@name eq 'statement']//insert/@id-ref)]"><!-- useless faux ODPs --></xsl:template>

    <xsl:template match="param" priority="-1">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="prop[@name eq 'alt-identifier']">
                    <xsl:attribute name="id"
                        select="prop[@name eq 'alt-identifier'] (: use the first - oscal-content has duplicates/errors :)[1]/@value" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="attribute::id" />
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="guideline"><!-- NIST oscal-content catalog param guidelines are not guidelines --></xsl:template>

    <xsl:template match="param/prop[@name eq 'aggregates']"><!-- ignore --></xsl:template>

    <xsl:template match="param/prop[@name eq 'alt-identifier']"><!-- ignore --></xsl:template>

    <xsl:template match="param/prop[@class eq 'sp800-53' and @name eq 'alt-label']">
        <!-- ??? -->
        <xsl:message>{parent::param/@id}</xsl:message>
    </xsl:template>

    <xsl:template match="prop[@class eq 'sp800-53a']"><!-- ignore --></xsl:template>

    <xsl:template match="insert">
        <xsl:variable name="p" as="element()" select="//param[@id eq current()/@id-ref]" />

        <xsl:copy>
            <xsl:copy-of select="attribute::type" />
            <xsl:choose>
                <xsl:when test="$p/prop[@name eq 'alt-identifier']">
                    <xsl:attribute name="id-ref"
                        select="$p/prop[@name eq 'alt-identifier'] (: use the first - oscal-content has duplicates/errors :)[1]/@value" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="attribute::id-ref" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="part[@name eq 'assessment-objective']"><!-- toss for now --></xsl:template>

    <xsl:template match="part[@name eq 'assessment-method']"><!-- toss for now --></xsl:template>

</xsl:stylesheet>
