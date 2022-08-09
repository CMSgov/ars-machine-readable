<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="xs fn map r oscal" version="3.0" xmlns:fn="local-function"
    xmlns:r="http://csrc.nist.gov/ns/random" xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0" expand-text="true">

    <xsl:import href="UTC.xsl" />

    <xsl:import href="random-util.xsl" />

    <xsl:template match="/">
        <xsl:call-template name="generate-profiles" />
    </xsl:template>

    <xsl:template name="generate-profiles">

        <xsl:variable name="template" as="document-node()" select="/" />

        <xsl:variable name="ars-profile-names" as="map(xs:string, xs:string)" select="
                map {
                    'Low': 'ars-5.0-low-profile.xml',
                    'Moderate': 'ars-5.0-moderate-profile.xml',
                    'High': 'ars-5.0-high-profile.xml'
                }" />
        <xsl:variable name="nist-profile-names" as="map(xs:string, xs:string)" select="
                map {
                    'Low': 'https://raw.githubusercontent.com/usnistgov/oscal-content/v1.0.0/nist.gov/SP800-53/rev5/xml/NIST_SP-800-53_rev5_LOW-baseline_profile.xml',
                    'Moderate': 'https://raw.githubusercontent.com/usnistgov/oscal-content/v1.0.0/nist.gov/SP800-53/rev5/xml/NIST_SP-800-53_rev5_MODERATE-baseline_profile.xml',
                    'High': 'https://raw.githubusercontent.com/usnistgov/oscal-content/v1.0.0/nist.gov/SP800-53/rev5/xml/NIST_SP-800-53_rev5_HIGH-baseline_profile.xml'
                }" />

        <xsl:for-each select="map:keys($ars-profile-names)">

            <xsl:variable name="c" as="xs:string" select="." />

            <xsl:variable name="nb" as="document-node()" select="doc(map:get($nist-profile-names, $c))" />

            <xsl:result-document href="{map:get($ars-profile-names,current())}" method="xml" output-version="1.0" indent="true">

                <xsl:processing-instruction name="xml-model">
                    <xsl:text expand-text="false">href="https://github.com/usnistgov/OSCAL/raw/v1.0.4/xml/schema/oscal_complete_schema.xsd" schematypens="http://www.w3.org/2001/XMLSchema" title="OSCAL complete schema" </xsl:text>
                </xsl:processing-instruction>

                <profile xmlns="http://csrc.nist.gov/ns/oscal/1.0" uuid="{r:make-uuid(xs:string(.))}">
                    <metadata>
                        <title>CMS ARS 5.0 {current()} Profile</title>
                        <last-modified>{$UTC-datetime}</last-modified>
                        <version>{$UTC-datetime}</version>
                        <oscal-version>1.0.4</oscal-version>
                    </metadata>
                    <import href="ars-5.0-catalog.xml">
                        <xsl:comment xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"> {count($nb//include-controls/with-id)} controls</xsl:comment>
                        <xsl:copy-of xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0" select="$nb//include-controls" />
                    </import>
                    <modify>
                        <xsl:for-each select="$template//row">
                            <xsl:choose>
                                <xsl:when test="$c eq 'Low'">
                                    <!--<xsl:message>{ODP_ID}</xsl:message>-->
                                    <xsl:if test="Low ne ''">
                                        <set-parameter class="ODP" param-id="{ODP_ID}">
                                            <value>{normalize-space(Low)}</value>
                                        </set-parameter>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$c eq 'Moderate'">
                                    <!--<xsl:message>{ODP_ID}</xsl:message>-->
                                    <xsl:if test="Moderate ne ''">
                                        <set-parameter class="ODP" param-id="{ODP_ID}">
                                            <value>{normalize-space(Moderate)}</value>
                                        </set-parameter>
                                    </xsl:if>
                                </xsl:when>
                                <xsl:when test="$c eq 'High'">
                                    <!--<xsl:message>{ODP_ID}</xsl:message>-->
                                    <xsl:if test="High ne ''">
                                        <set-parameter class="ODP" param-id="{ODP_ID}">
                                            <value>{normalize-space(High)}</value>
                                        </set-parameter>
                                    </xsl:if>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                    </modify>

                </profile>

            </xsl:result-document>
        </xsl:for-each>

    </xsl:template>

</xsl:stylesheet>
