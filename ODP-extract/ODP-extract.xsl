<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="xs fn map r oscal" version="3.0" xmlns:fn="local-function" xmlns:r="http://csrc.nist.gov/ns/random"
    xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0" xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0" expand-text="true">

    <!-- This transform expects -->
    <!-- https://raw.githubusercontent.com/usnistgov/oscal-content/v1.0.0/nist.gov/SP800-53/rev5/xml/NIST_SP-800-53_rev5_catalog.xml -->
    <!-- or the equivalent as input -->

    <xsl:param name="generate-odp-profile" as="xs:boolean" required="false" select="false()" />

    <xsl:param name="generate-ars-profiles" as="xs:boolean" required="false" select="false()" />

    <xsl:param name="show-ODP-id" as="xs:boolean" required="false" select="true()" />

    <xsl:param name="compare-ODP" as="xs:boolean" required="false" select="false()" />

    <xsl:param name="show-tailored-ODPs" as="xs:boolean" required="false" select="false()" />

    <xsl:mode on-no-match="shallow-skip" />

    <xsl:output method="html" version="5.0" include-content-type="false" />

    <xsl:output indent="false" />

    <xsl:strip-space elements="*" />

    <xsl:function name="fn:withdrawn" as="xs:boolean">
        <xsl:param name="control" as="element()" required="true" />
        <xsl:sequence select="$control/prop[@name eq 'status']/@value = ('Withdrawn', 'withdrawn')" />
    </xsl:function>

    <xsl:import href="UTC.xsl" />
    
    <xsl:import href="random-util.xsl"/>

    <xsl:variable name="LF" as="xs:string" select="'&#x0a;'" />

    <xsl:variable name="BL" as="xs:string" select="'Ⓛ'" />
    <xsl:variable name="BM" as="xs:string" select="'Ⓜ'" />
    <xsl:variable name="BH" as="xs:string" select="'Ⓗ'" />

    <!-- input oscal-content catalog -->
    <xsl:variable name="input-catalog" as="document-node()" select="/" />

    <!-- damaged SP 800-53 oscal-content -->
    <xsl:variable name="sp800-53-alt" as="document-node()"
        select="doc('https://raw.githubusercontent.com/usnistgov/oscal-content/main/nist.gov/SP800-53/rev5/xml/NIST_SP-800-53_rev5_catalog.xml')" />

    <xsl:variable name="odp-profile-href" as="xs:string" select="'ars-5.0-odp-profile.xml'" />

    <xsl:variable name="ARS" as="document-node()" select="doc('file:ARS-5.01-01.xml')" />

    <xsl:variable name="ODP-low" as="document-node()" select="doc('ars-5.0-low-profile.xml')" />
    <xsl:variable name="ODP-moderate" as="document-node()" select="doc('ars-5.0-moderate-profile.xml')" />
    <xsl:variable name="ODP-high" as="document-node()" select="doc('ars-5.0-high-profile.xml')" />
    <xsl:variable name="baselines-control-ids" as="xs:string*"
        select="distinct-values(($ODP-high//with-id, $ODP-moderate//with-id, $ODP-low//with-id))" />
    
    <xsl:variable name="rng" select="random-number-generator($UTC-datetime)"/>

    <xsl:variable name="document-title" as="xs:string">CMS ARS 5.0 ODP extract</xsl:variable>

    <xsl:template match="/">

        <xsl:choose>

            <xsl:when test="$generate-odp-profile">
                <xsl:call-template name="generate-odp-profile" />
            </xsl:when>

            <xsl:when test="$generate-ars-profiles">
                <xsl:call-template name="generate-profiles" />
            </xsl:when>

            <xsl:when test="not($generate-odp-profile or $generate-ars-profiles)">

                <html lang="en">
                    <head>
                        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
                        <title>{$document-title}</title>
                        <xsl:variable name="css" select="unparsed-text(replace(static-base-uri(), '\.xsl$', '.css'))" />
                        <style><xsl:value-of disable-output-escaping="true" select="replace($css, '\s+', ' ')" /></style>
                    </head>

                    <body>

                        <h1>{$document-title}</h1>

                        <p>This document will be frequently updated. This update was produced {format-dateTime($UTC-datetime, '[F] [MNn] [D1] [Y] at
                            [H01]:[m01]:[s01]Z')}. The transform used to produce the report was <code>{static-base-uri() ! tokenize(.,
                                '/')[last()]}</code>.</p>

                        <p>The version of the <a href="{base-uri()}" target="_blank">NIST SP 800-53rev5 OSCAL catalog</a> used is
                            {//metadata/version}.</p>

                        <p>The version of the ARS XML conversion (subsequently edited) used was <code>{document-uri($ARS)}</code>.</p>
                   
                        <xsl:call-template name="ODP-template" />

                        <!--<xsl:call-template name="extracted-ODPs" />-->

                        <!--<xsl:call-template name="supplied-odps"/>-->

                        <xsl:call-template name="ODP-detail" />

                        <div class="trailer">
                            <hr />
                            <p>Revised <xsl:value-of select="$UTC-datetime" /></p>
                        </div>

                    </body>
                </html>

            </xsl:when>

        </xsl:choose>


    </xsl:template>

    <xsl:template name="ODP-template">

        <xsl:variable name="extract" as="document-node()" select="doc($odp-profile-href)" />

        <h2>ODP Template</h2>

        <p>The following table has all SP 800-53rev5 ODPs <strong>which appear in SP 800-53B low, moderate, and high baselines</strong>
            ({count($baselines-control-ids)} controls).</p>

        <p>The control labels, ODP identifiers, and ODP labels are those used in the NIST SP 800-53rev5 OSCAL catalog.</p>

        <p>The value text was (when possible) extracted from the ARS 5.01 spreadsheet. Extraction details appear <a href="#ODP-detail">here</a>. Note
            that there were no discernible per-baseline values: only one value per ODP serves for all baselines. That will likely require manual
            discovery and correction. Missing values (i.e., ones which could not be extracted) have white cells in the table.</p>

        <p>The baseline (low, moderate, high) columns have white cells when applicable and have the ARS 5.01 value placed there.</p>

        <p>Controls which do not appear in any baseline show all grey cells in the baseline columns.</p>

        <p>
            <strong>If this presentation is not handy in its current form it can easily be tweaked. Please advise.</strong>
        </p>

        <table class="template">
            <caption>ODPs extracted from ARS 5.01_0 spreadsheet</caption>

            <colgroup>
                <col style="width: 4%;" />
                <col style="width: 6%;" />
                <col style="width: 20%;" />
                <col style="width: 25%;" />
                <col style="width: 15%;" />
                <col style="width: 15%;" />
                <col style="width: 15%;" />
            </colgroup>

            <thead>
                <tr>
                    <th colspan="3" class="center">NIST NIST SP 800-53rev5 OSCAL Catalog Origin</th>
                    <th colspan="1" class="center">ARS Origin</th>
                    <th colspan="3" class="center">Chosen Baseline Values</th>
                </tr>
                <tr>
                    <th class="center">Control<br>Label</br></th>
                    <th class="center">ODP ID</th>
                    <th class="center">ODP Label</th>
                    <th class="center">ARS 5.01 Value</th>
                    <th class="center">Low</th>
                    <th class="center">Moderate</th>
                    <th class="center">High</th>
                </tr>
            </thead>

            <tbody>
                <xsl:for-each select="//control[not(fn:withdrawn(.))][@id = $baselines-control-ids]">
                    <xsl:sort order="ascending" select="current()/prop[@name eq sort-id]/@value" />

                    <xsl:variable name="control" as="element()" select="." />

                    <xsl:for-each select="param">
                        <tr>
                            <td class="center">{$control/prop[@name eq 'label'][not(@class)]/@value}</td>
                            <td class="center">
                                <a href="#{@id}">
                                    <span class="id">{@id}</span>
                                </a>
                            </td>
                            <td>
                                <xsl:apply-templates mode="param" select="." />
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test="exists($extract//set-parameter[@param-id = current()/@id])">
                                        <xsl:text>{$extract//set-parameter[@param-id = current()/@id]/value}</xsl:text>

                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="class">fillin</xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td>
                                <xsl:if test="exists($ODP-low//with-id[. eq $control/@id])">
                                    <xsl:attribute name="class">fillin</xsl:attribute>
                                    <xsl:if test="exists($extract//set-parameter[@param-id = current()/@id])">
                                        <xsl:text>{$extract//set-parameter[@param-id = current()/@id]/value}</xsl:text>
                                    </xsl:if>
                                </xsl:if>
                            </td>
                            <td>
                                <xsl:if test="exists($ODP-moderate//with-id[. eq $control/@id])">
                                    <xsl:attribute name="class">fillin</xsl:attribute>
                                    <xsl:if test="exists($extract//set-parameter[@param-id = current()/@id])">
                                        <xsl:text>{$extract//set-parameter[@param-id = current()/@id]/value}</xsl:text>
                                    </xsl:if>
                                </xsl:if>
                            </td>
                            <td>
                                <xsl:if test="exists($ODP-high//with-id[. eq $control/@id])">
                                    <xsl:attribute name="class">fillin</xsl:attribute>
                                    <xsl:if test="exists($extract//set-parameter[@param-id = current()/@id])">
                                        <xsl:text>{$extract//set-parameter[@param-id = current()/@id]/value}</xsl:text>
                                    </xsl:if>
                                </xsl:if>
                            </td>
                        </tr>
                    </xsl:for-each>

                </xsl:for-each>
            </tbody>

        </table>

    </xsl:template>

    <xsl:template name="extracted-ODPs">

        <xsl:variable name="extract" as="document-node()" select="doc($odp-profile-href)" />

        <h2>Extracted ODPs</h2>

        <p>The control labels, parameter identifiers, and parameter labels are those used in the NIST SP 800-53rev5 OSCAL catalog.</p>

        <p>The value text was (when possible) extracted from the ARS 5.01 spreadsheet. Only <strong>successful extractions</strong>
            ({count($extract//set-parameter)} ODPs, or about {xs:decimal(count($extract//set-parameter) div count(//param)) ! format-number(.,
            '09.99%')} of all {count(//param)} ODPs) appear. Extraction details appear <a href="#ODP-detail">here</a>.</p>

        <table>
            <caption>ODPs extracted from ARS 5.01_0 spreadsheet</caption>

            <colgroup>
                <col style="width: 4%;" />
                <col style="width: 6%;" />
                <col style="width: 20%;" />
                <col style="width: 70%;" />
            </colgroup>

            <thead>
                <tr>
                    <th colspan="3">NIST NIST SP 800-53rev5 OSCAL catalog Origin</th>
                    <th>ARS Origin</th>
                </tr>
                <tr>
                    <th class="center">Control<br>Label</br></th>
                    <th class="center">ODP ID</th>
                    <th>ODP Label</th>
                    <th>ARS 5.0 Value</th>
                </tr>
            </thead>

            <tbody>
                <xsl:for-each select="//control[not(fn:withdrawn(.))]">
                    <xsl:sort order="ascending" select="current()/prop[@name eq sort-id]/@value" />

                    <xsl:variable name="control" as="element()" select="." />

                    <xsl:choose>
                        <xsl:when test="$extract//set-parameter[@param-id = $control/param/@id]">
                            <xsl:for-each select="$extract//set-parameter[@param-id = $control/param/@id]">
                                <tr>
                                    <td class="center">{$control/prop[@name eq 'label'][not(@class)]/@value}</td>
                                    <td class="center">
                                        <a href="#{@param-id}">
                                            <span class="id">{@param-id}</span>
                                        </a>
                                    </td>
                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="$control/param[@id eq current()/@param-id]/label">
                                                <xsl:text>{$control/param[@id eq current()/@param-id]/label}</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$control/param[@id eq current()/@param-id]/select">
                                                <xsl:apply-templates mode="param" select="$control/param[@id eq current()/@param-id]/select" />
                                            </xsl:when>
                                        </xsl:choose>
                                    </td>
                                    <td>{value}</td>
                                </tr>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>

                </xsl:for-each>
            </tbody>

        </table>

    </xsl:template>

    <xsl:template name="words">

        <xsl:apply-templates mode="words" select="part[@name eq 'statement']" />

    </xsl:template>

    <xsl:template match="part[@name eq 'statement']">

        <xsl:apply-templates mode="#current" select="node()" />

    </xsl:template>

    <xsl:template mode="words" match="part">

        <div class="statement">
            <xsl:apply-templates mode="#current" />
        </div>

    </xsl:template>

    <xsl:template mode="words" match="p">

        <span class="label">{preceding-sibling::prop[@name eq 'label']/@value} </span>

        <xsl:apply-templates mode="#current" select="node()" />

    </xsl:template>

    <xsl:template mode="words" match="insert">

        <span class="insert">[{@id-ref}]</span>

    </xsl:template>

    <xsl:template mode="words" match="text()">

        <span class="text">{.}</span>

    </xsl:template>

    <xsl:template name="regex">
        <xsl:apply-templates mode="regex" select="part[@name eq 'statement']" />
    </xsl:template>

    <xsl:template mode="regex" match="part">
        <xsl:choose>
            <xsl:when test="p">
                <xsl:variable name="strings" as="xs:string*">
                    <xsl:apply-templates mode="regex" select="p/(text() | insert)" />
                </xsl:variable>
                <xsl:variable name="string" as="xs:string" select="string-join($strings)" />
                <xsl:copy-of select="
                        $string
                        ! normalize-space()
                        ! replace(., '\s+', ' ')
                        ! replace(., '( [:;.])', '$1')
                        ! replace(., '([.()\[\]])', '\\$1')
                        ! replace(., '(\w)⎀(\w)', '$1 ⎀ $2')
                        ! replace(., '⎀', '(.+)')
                        " />
                <xsl:apply-templates mode="regex" select="part" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="regex" select="part" />
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template mode="regex" match="insert">
        <xsl:text>⎀</xsl:text>
    </xsl:template>

    <xsl:template mode="regex" match="text()">
        <xsl:value-of select="normalize-space(.)" />
    </xsl:template>

    <xsl:template name="supplied-odps">

        <h2>Supplied ODPs</h2>

        <p>Supplied ODPs did not have explicit (i.e., columnarized) FIPS 199 stratification, so there was only a single value for all FIPS 199
            levels.</p>

        <xsl:variable name="check" as="xs:string" select="'✓'" />

        <p>Only controls for which ODPs were supplied, appear in a profile, <em>and</em> have ODPs are shown (some controls found in profiles have no
            parameters).</p>

        <p>Control inclusion in a profile is denoted by {$check}.</p>

        <table>

            <caption>Supplied ODPs</caption>

            <colgroup>
                <col style="width: 4%;" />
                <col style="width: 6%;" />
                <col style="width: 30%;" />
                <col style="width: 30%;" />
                <col style="width: 30%;" />
            </colgroup>

            <thead>
                <tr>
                    <th class="center">Control</th>
                    <th class="center">ODP</th>
                    <th class="center">{$ODP-low/profile/metadata/title}</th>
                    <th class="center">{$ODP-moderate/profile/metadata/title}</th>
                    <th class="center">{$ODP-high/profile/metadata/title}</th>
                </tr>
            </thead>

            <tbody>

                <xsl:variable name="supplied" as="xs:NMTOKEN*" select="$ODP-low//set-parameter/@param-id" />

                <xsl:for-each select="//control[@id = $ODP-high//with-id][param][param/@id = $supplied]">

                    <xsl:for-each select="param">
                        <!--<xsl:message>{position()}</xsl:message>-->
                        <xsl:choose>
                            <xsl:when test="position() eq 1">
                                <tr class="center">
                                    <td class="center" rowspan="{count(parent::control/param)}">
                                        <a title="link to control detail" href="#{parent::control/@id}">{parent::control/prop[not(@class) and @name eq
                                            'label']/@value}</a>
                                    </td>
                                    <td class="center">
                                        <div>
                                            <span class="id">{upper-case(@id)}</span>
                                        </div>
                                        <xsl:if test="label">
                                            <div>
                                                <span class="guideline">{label}</span>
                                            </div>
                                        </xsl:if>
                                        <!--<xsl:if test="guideline">
                                            <div>
                                                <span class="guideline">{guideline}</span>
                                            </div>
                                        </xsl:if>-->
                                    </td>
                                    <td>
                                        <xsl:if test="$ODP-low//with-id[. eq current()/parent::control/@id]">
                                            <span class="check">{$check}</span>
                                            <div>{$ODP-low//set-parameter[@param-id eq current()/@id]/value}</div>
                                        </xsl:if>

                                    </td>
                                    <td>
                                        <xsl:if test="$ODP-moderate//with-id[. eq current()/parent::control/@id]">
                                            <span class="check">{$check}</span>
                                            <div>{$ODP-moderate//set-parameter[@param-id eq current()/@id]/value}</div>
                                        </xsl:if>
                                    </td>
                                    <td>
                                        <xsl:if test="$ODP-high//with-id[. eq current()/parent::control/@id]">
                                            <span class="check">{$check}</span>
                                            <div>{$ODP-high//set-parameter[@param-id eq current()/@id]/value}</div>
                                        </xsl:if>
                                    </td>
                                </tr>
                            </xsl:when>
                            <xsl:otherwise>
                                <tr class="center">
                                    <!--<td class="center" rowspan="{count(parent::control/param)}">
                                        <a title="link to control detail" href="#{parent::control/@id}">{parent::control/prop[not(@class) and @name eq
                                            'label']/@value}</a>
                                    </td>-->
                                    <td class="center">
                                        <div>
                                            <span class="id">{upper-case(@id)}</span>
                                        </div>
                                        <xsl:if test="label">
                                            <div>
                                                <span class="guideline">{label}</span>
                                            </div>
                                        </xsl:if>
                                        <!--<xsl:if test="guideline">
                                            <div>
                                                <span class="guideline">{guideline}</span>
                                            </div>
                                        </xsl:if>-->
                                    </td>
                                    <td>
                                        <xsl:if test="$ODP-low//with-id[. eq current()/parent::control/@id]">
                                            <!--<span class="check">{$check}</span>-->
                                            <div>{$ODP-low//set-parameter[@param-id eq current()/@id]/value}</div>
                                        </xsl:if>

                                    </td>
                                    <td>
                                        <xsl:if test="$ODP-moderate//with-id[. eq current()/parent::control/@id]">
                                            <!--<span class="check">{$check}</span>-->
                                            <div>{$ODP-moderate//set-parameter[@param-id eq current()/@id]/value}</div>
                                        </xsl:if>
                                    </td>
                                    <td>
                                        <xsl:if test="$ODP-high//with-id[. eq current()/parent::control/@id]">
                                            <!--<span class="check">{$check}</span>-->
                                            <div>{$ODP-high//set-parameter[@param-id eq current()/@id]/value}</div>
                                        </xsl:if>
                                    </td>
                                </tr>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>

                </xsl:for-each>

            </tbody>

        </table>

    </xsl:template>

    <xsl:template name="ODP-detail">

        <h2 id="ODP-detail">ARS ODPs In Situ</h2>

        <p>The following table shows ARS ODP mapping to SP 800-53 control statements.All {count(//control[not(fn:withdrawn(.))])} active (i.e., not
            withdrawn) SP 800-53 rev5 controls are shown.</p>

        <!--<p>Defined (extracted) ODPs can be displayed in situ by clicking on the ⬇ symbol. <strong>NB: Not all ODPs are isolated and
            defined.</strong></p>-->

        <p>ARS control labels are incorrect (do not match those used by NIST SP 800-53) and are ignored for statement analysis.</p>

        <p>✅ indicates a match from ARS 5.0 to NIST SP 800-53rev5; ❌ indicates a mismatch.</p>

        <table class="tr-hover">

            <caption>ODPs in situ</caption>

            <colgroup>
                <col style="width: 4%;" />
                <col style="width: 45%;" />
                <col style="width: 45%;" />
            </colgroup>

            <thead>
                <tr>
                    <th style="text-align:center;">Control</th>
                    <th>ARS 5.01_0 Statements</th>
                    <th>NIST 800-53 Statements</th>
                </tr>
            </thead>

            <tbody>

                <xsl:for-each select="//control[not(fn:withdrawn(.))]">
                    <xsl:sort order="ascending" select="current()/prop[@name eq sort-id]/@value" />

                    <xsl:variable name="control" as="element()" select="." />

                    <xsl:variable name="statement-regexes" as="xs:string*">
                        <xsl:call-template name="regex" />
                    </xsl:variable>

                    <xsl:variable name="stmts" as="element()*" select="part[@name eq 'statement']/descendant::p" />
                    <!--<xsl:message>{@id} {count($stmts)} {count($stmts/insert)} ODPs</xsl:message>-->

                    <tr>
                        <xsl:attribute name="id" select="@id" />

                        <td class="center">
                            <div>
                                <xsl:value-of select="prop[not(@class) and @name eq 'label']/@value" />
                            </div>
                        </td>

                        <td>

                            <xsl:variable name="ars-label" as="xs:string"
                                select="$sp800-53-alt//control[@id eq current()/@id]/prop[@class eq 'sp800-53a' and @name eq 'label']/@value" />

                            <!--<xsl:message>{@id} {$ars-label}</xsl:message>-->

                            <xsl:choose>

                                <xsl:when test="exists($ARS//*:row[*:Control_Number eq $ars-label])">

                                    <div>{$ARS//*:row[*:Control_Number eq $ars-label]/*:Control_Name}</div>

                                    <xsl:variable name="ars-statements" as="xs:string*"
                                        select="tokenize($ARS//*:row[*:Control_Number eq $ars-label]/*:CMS_ARS_5.0_Control, '&#x0a;')" />

                                    <xsl:choose>
                                        <xsl:when test="count($ars-statements) ne 0">

                                            <xsl:for-each select="$ars-statements">

                                                <xsl:variable name="p" as="xs:positiveInteger" select="xs:positiveInteger(position())" />

                                                <xsl:if test="exists($statement-regexes[$p])">

                                                    <div class="statement">

                                                        <xsl:variable name="ars-statement" as="xs:string" select="
                                                                normalize-space(.)
                                                                ! replace(., '^[()a-z1-9.]+\s*', '') (: statement labels :)
                                                                ! replace(., '[\[\]]', '') (: brackets :)
                                                                " />

                                                        <xsl:variable name="regex" as="xs:string"
                                                            select="$statement-regexes[$p] ! replace(., ' :', ':')" />

                                                        <xsl:variable name="a" as="element()" select="
                                                                analyze-string(
                                                                $ars-statement,
                                                                $regex)" />

                                                        <div>
                                                            <xsl:text>{normalize-space(.)}</xsl:text>

                                                            <xsl:choose>
                                                                <xsl:when test="$a//*:match">
                                                                    <xsl:text> ✅</xsl:text>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <xsl:text> ❌</xsl:text>
                                                                    <table class="analysis">
                                                                        <tbody>
                                                                           <tr>
                                                                           <td>analysis string</td>
                                                                           <td>
                                                                           <span class="analysis-string">{$ars-statement}</span>
                                                                           </td>
                                                                           </tr>
                                                                           <tr>
                                                                           <td>analysis regex</td>
                                                                           <td>
                                                                           <span class="regex-group">{$regex}</span>
                                                                           </td>
                                                                           </tr>
                                                                        </tbody>
                                                                    </table>
                                                                </xsl:otherwise>
                                                            </xsl:choose>

                                                        </div>

                                                        <!--<pre>{serialize($a,map { 'indent': true() })}</pre>-->

                                                        <xsl:variable name="s" as="xs:positiveInteger" select="xs:positiveInteger(position())" />

                                                        <xsl:if test="$a//*:group">
                                                            <ul class="statement-odp-list">
                                                                <xsl:for-each select="$a//*:group">
                                                                    <xsl:variable name="insert" as="xs:string*" select="$stmts[$s]/insert/@id-ref" />
                                                                    <!--<xsl:message>{$control/@id} statement {$s} ODPs {count($insert)}</xsl:message>-->
                                                                    <xsl:variable name="i" as="xs:integer" select="position()" />
                                                                    <li>
                                                                        <span class="ODP" param-id="{$insert[$i]}">{normalize-space()}</span>
                                                                        <xsl:text> </xsl:text>
                                                                        <span class="id">{$insert[$i]}</span>
                                                                    </li>
                                                                </xsl:for-each>
                                                            </ul>
                                                        </xsl:if>

                                                    </div>

                                                </xsl:if>

                                            </xsl:for-each>

                                        </xsl:when>

                                        <xsl:otherwise>
                                            <div class="anomaly">This ARS control has no control statement(s).</div>
                                        </xsl:otherwise>

                                    </xsl:choose>

                                </xsl:when>
                                <xsl:otherwise>
                                    <div class="missing">Missing control</div>
                                </xsl:otherwise>
                            </xsl:choose>

                        </td>

                        <td>

                            <div>
                                <xsl:if test="fn:withdrawn(.)">
                                    <xsl:attribute name="class">withdrawn</xsl:attribute>
                                </xsl:if>
                                <xsl:if test="parent::control">
                                    <xsl:value-of select="parent::control/title" />
                                    <xsl:text> | </xsl:text>
                                </xsl:if>
                                <xsl:value-of select="title" />
                            </div>

                            <div>
                                <xsl:choose>
                                    <xsl:when test="fn:withdrawn(.)">
                                        <xsl:call-template name="withdrawn">
                                            <xsl:with-param name="control" select="current()" />
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates mode="statement" select="part[@name eq 'statement']">
                                            <xsl:with-param name="tag-with-id" as="xs:boolean" tunnel="true" select="true()" />
                                        </xsl:apply-templates>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>

                        </td>

                    </tr>

                </xsl:for-each>

            </tbody>

        </table>

    </xsl:template>

    <xsl:template name="withdrawn">
        <xsl:param name="control" />
        <xsl:param name="bullet" as="xs:string*" required="false" />
        <div class="statement">
            <xsl:copy-of select="$bullet" />
            <xsl:for-each select="link[@rel = ('incorporated-into')]">
                <xsl:if test="position() eq 1">
                    <xsl:text>Withdrawn — {translate(@rel, '-', ' ')} </xsl:text>
                </xsl:if>
                <xsl:if test="position() ne 1">
                    <xsl:text>, </xsl:text>
                </xsl:if>
                <xsl:if test="position() eq last() and last() ne 1">
                    <xsl:text> and </xsl:text>
                </xsl:if>
                <a href="{@href}">
                    <xsl:variable name="target" as="xs:string" select="substring-after(@href, '#')" />
                    <xsl:choose>
                        <xsl:when test="matches($target, 'smt')">
                            <xsl:value-of select="$target" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="//control[@id eq $target]/prop[@name eq 'label']/@value" />
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
            </xsl:for-each>
            <xsl:text>.</xsl:text>
        </div>
    </xsl:template>

    <!-- sample 
        <part name="statement" id="ac-7_smt">
            <part name="item" id="ac-7_smt.a">
                <prop name="label" value="a."/>
                <p>Enforce a limit of  <insert type="param" id-ref="ac-07_odp.01"/>  consecutive invalid logon attempts by a user during a  <insert type="param" id-ref="ac-07_odp.02"/> ; and</p>
            </part>
            <part name="item" id="ac-7_smt.b">
                <prop name="label" value="b."/>
                <p>Automatically  <insert type="param" id-ref="ac-07_odp.03"/>  when the maximum number of unsuccessful attempts is exceeded.</p>
            </part>
        </part>
    -->

    <xsl:template mode="statement" match="part[@name eq 'statement']">
        <xsl:param name="tag-with-id" as="xs:boolean" tunnel="true" required="false" select="true()" />
        <xsl:variable name="content" as="node()*">
            <div class="statement">
                <xsl:if test="starts-with(root(.)/catalog/metadata/title, 'NIST Special Publication 800-53 Revision 5') and $tag-with-id">
                    <xsl:attribute name="id" select="@id" />
                </xsl:if>
                <xsl:apply-templates mode="statement" select="node()" />
            </div>
        </xsl:variable>
        <xsl:copy-of select="$content" />
    </xsl:template>

    <xsl:template mode="statement" match="part[@name eq 'item']">
        <xsl:param name="tag-with-id" as="xs:boolean" tunnel="true" required="false" select="true()" />
        <div class="item">
            <xsl:if test="starts-with(root(.)/catalog/metadata/title, 'NIST Special Publication 800-53 Revision 5') and $tag-with-id">
                <xsl:attribute name="id" select="@id" />
            </xsl:if>
            <xsl:variable name="content" as="node()*">
                <xsl:apply-templates mode="statement" select="node()" />
            </xsl:variable>
            <xsl:copy-of select="$content" />
        </div>
    </xsl:template>

    <xsl:template mode="statement" match="prop[not(@class) and @name eq 'label']">
        <xsl:text>{@value} </xsl:text>
    </xsl:template>

    <xsl:template mode="statement" match="p">
        <xsl:apply-templates mode="statement" select="node()" />
    </xsl:template>

    <xsl:template mode="statement" match="text()">
        <xsl:copy-of select="." />
    </xsl:template>

    <xsl:template mode="statement" match="a">
        <a href="{@href}">
            <xsl:value-of select="." />
        </a>
    </xsl:template>

    <xsl:template mode="statement" match="em | strong | ol | li | b">
        <xsl:element name="span">
            <xsl:attribute name="class">oscal-{local-name()}</xsl:attribute>
            <xsl:apply-templates mode="statement" select="node()" />
        </xsl:element>
    </xsl:template>

    <xsl:template mode="statement2" match="insert">
        <xsl:param name="tag-with-id" as="xs:boolean" tunnel="true" required="false" select="true()" />
        <xsl:choose>
            <xsl:when test="@type eq 'param'">
                <span>
                    <xsl:attribute name="title" select="@id-ref" />
                    <xsl:attribute name="id" select="@id-ref" />
                    <xsl:if test="$show-ODP-id">
                        <span class="superscript-identifier">
                            <xsl:value-of select="@id-ref" />
                        </span>
                    </xsl:if>

                    <xsl:variable name="insert" as="node()*">
                        <xsl:apply-templates mode="param" select="ancestor::control/param[@id eq current()/@id-ref]" />
                    </xsl:variable>
                    <xsl:message select="$insert" />

                    <!--<xsl:choose>
                        <xsl:when test="$show-tailored-ODPs">
                            <!-\-<xsl:message>{current()/@id-ref} {$ODP-low//set-parameter[@param-id eq current()/@id-ref]}</xsl:message>-\->
                            <details class="ODPs">
                                <!-\- open="open" -\->
                                <summary>
                                    <xsl:copy-of select="$insert" />
                                </summary>
                                <xsl:variable name="ODPs" as="xs:string*">
                                    <xsl:choose>
                                        <xsl:when test="$ODP-low//set-parameter[@param-id eq current()/@id-ref]">
                                            <xsl:text>{$BL}: {$ODP-low//set-parameter[@param-id eq current()/@id-ref]/value}</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>{$BL}: (Not defined)</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:choose>
                                        <xsl:when test="$ODP-moderate//set-parameter[@param-id eq current()/@id-ref]">
                                            <xsl:text>{$BM}: {$ODP-moderate//set-parameter[@param-id eq current()/@id-ref]/value}</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>{$BM}: (Not defined)</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <xsl:choose>
                                        <xsl:when test="$ODP-high//set-parameter[@param-id eq current()/@id-ref]">
                                            <xsl:text>{$BH}: {$ODP-high//set-parameter[@param-id eq current()/@id-ref]/value}</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>{$BH}: (Not defined)</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:for-each select="$ODPs">
                                    <xsl:if test="position() ne 1">
                                        <br />
                                    </xsl:if>
                                    <xsl:copy-of select="." />
                                </xsl:for-each>
                            </details>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$insert" />
                        </xsl:otherwise>
                    </xsl:choose>-->

                    <xsl:copy-of select="$insert" />

                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">Unsupported insert type {@typoe}.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="statement" match="insert">
        <xsl:param name="tag-with-id" as="xs:boolean" tunnel="true" required="false" select="true()" />
        <xsl:choose>
            <xsl:when test="@type eq 'param'">
                <xsl:apply-templates mode="param" select="ancestor::control/param[@id eq current()/@id-ref]" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">Unsupported insert type {@typoe}.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="param" match="param">
        <xsl:param name="tag-with-id" as="xs:boolean" tunnel="true" required="false" select="false()" />
        <span>
            <xsl:if test="$tag-with-id">
                <xsl:attribute name="id" select="@id" />
            </xsl:if>

            <xsl:choose>
                <xsl:when test="label">
                    <xsl:attribute name="class">label</xsl:attribute>
                </xsl:when>
                <xsl:when test="select">
                    <xsl:attribute name="class">select</xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="$show-ODP-id">
                <span class="superscript-identifier">
                    <xsl:value-of select="@id" />
                </span>
            </xsl:if>
            <xsl:text>[</xsl:text>
            <xsl:apply-templates mode="param" />
            <xsl:text>]</xsl:text>
        </span>
    </xsl:template>

    <xsl:template mode="param" match="label">
        <xsl:text>Assignment: {.}</xsl:text>
    </xsl:template>

    <xsl:template mode="param" match="insert">
        <xsl:apply-templates mode="param" select="ancestor::control/param[@id eq current()/@id-ref]" />
    </xsl:template>

    <xsl:template mode="param" match="select">
        <xsl:choose>
            <xsl:when test="@how-many eq 'one-or-more'">
                <xsl:text>Selection (one or more): </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Selection: </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates mode="#current" select="node()" />
    </xsl:template>

    <xsl:template mode="param" match="choice">
        <xsl:if test="position() ne 1">
            <xsl:choose>
                <xsl:when test="parent::select/@how-many eq 'one-or-more'">
                    <xsl:text>; </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <span class="boolean"> or </span>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:apply-templates mode="#current" select="node()" />
    </xsl:template>

    <xsl:template mode="param" match="text()">
        <xsl:copy-of select="." />
    </xsl:template>

    <xsl:template mode="param" match="node()" priority="-1" />

    <xsl:template mode="statement" match="remarks"><!-- ignore for now --></xsl:template>

    <xsl:template name="generate-odp-profile">

        <xsl:result-document href="{$odp-profile-href}" method="xml" output-version="1.0" indent="true">

            <xsl:processing-instruction name="xml-model">
                <xsl:text expand-text="false">href="https://github.com/usnistgov/OSCAL/raw/v1.0.4/xml/schema/oscal_complete_schema.xsd" schematypens="http://www.w3.org/2001/XMLSchema" title="OSCAL complete schema" </xsl:text>
            </xsl:processing-instruction>

            <profile xmlns="http://csrc.nist.gov/ns/oscal/1.0" uuid="{r:make-uuid(generate-id())}">
                <metadata>
                    <title>CMS ARS 5.0 ODP Profile</title>
                    <last-modified>{$UTC-datetime}</last-modified>
                    <version>{$UTC-datetime}</version>
                    <oscal-version>1.0.4</oscal-version>
                </metadata>
                <import
                    href="https://raw.githubusercontent.com/usnistgov/oscal-content/v1.0.0/nist.gov/SP800-53/rev5/xml/NIST_SP-800-53_rev5_catalog.xml">
                    <include-all />
                </import>
                <modify>

                    <xsl:for-each select="//control[not(fn:withdrawn(.))]">
                        <xsl:sort order="ascending" select="current()/prop[@name eq sort-id]/@value" />

                        <xsl:variable name="control" as="element()" select="." />

                        <xsl:variable name="statement-regexes" as="xs:string*">
                            <xsl:call-template name="regex" />
                        </xsl:variable>

                        <xsl:variable name="stmts" as="element()*" select="part[@name eq 'statement']/descendant::p" />
                        <!--<xsl:message>{@id} {count($stmts)} {count($stmts/insert)} ODPs</xsl:message>-->

                        <xsl:variable name="ars-label" as="xs:string"
                            select="$sp800-53-alt//control[@id eq current()/@id]/prop[@class eq 'sp800-53a' and @name eq 'label']/@value" />

                        <xsl:choose>

                            <xsl:when test="exists($ARS//*:row[*:Control_Number eq $ars-label])">

                                <xsl:variable name="ars-statements" as="xs:string*"
                                    select="tokenize($ARS//*:row[*:Control_Number eq $ars-label]/*:CMS_ARS_5.0_Control, '&#x0a;')" />

                                <xsl:choose>
                                    <xsl:when test="count($ars-statements) ne 0">

                                        <xsl:for-each select="$ars-statements">

                                            <xsl:variable name="p" as="xs:positiveInteger" select="xs:positiveInteger(position())" />

                                            <xsl:if test="exists($statement-regexes[$p])">

                                                <xsl:variable name="ars-statement" as="xs:string" select="
                                                        normalize-space(.)
                                                        ! replace(., '^[()a-z1-9.]+\s*', '') (: statement labels :)
                                                        ! replace(., '[\[\]]', '') (: brackets :)
                                                        " />

                                                <xsl:variable name="regex" as="xs:string" select="$statement-regexes[$p] ! replace(., ' :', ':')" />

                                                <xsl:variable name="a" as="element()" select="
                                                        analyze-string(
                                                        $ars-statement,
                                                        $regex)" />

                                                <xsl:variable name="s" as="xs:positiveInteger" select="xs:positiveInteger(position())" />

                                                <xsl:if test="$a//*:group">
                                                    <xsl:for-each select="$a//*:group">
                                                        <xsl:variable name="insert" as="xs:string*" select="$stmts[$s]/insert/@id-ref" />
                                                        <!--<xsl:message>{$control/@id} statement {$s} ODPs {count($insert)}</xsl:message>-->
                                                        <xsl:variable name="i" as="xs:integer" select="position()" />
                                                        <xsl:variable name="param-id" as="xs:string" select="$insert[$i]" />
                                                        <xsl:variable name="param" as="element()" select="$control/param[@id eq $param-id]" />
                                                        <set-parameter class="ODP" param-id="{$param-id}">
                                                            <value>{normalize-space()}</value>
                                                        </set-parameter>

                                                    </xsl:for-each>
                                                </xsl:if>

                                            </xsl:if>

                                        </xsl:for-each>

                                    </xsl:when>

                                </xsl:choose>

                            </xsl:when>

                        </xsl:choose>

                    </xsl:for-each>

                </modify>

            </profile>

        </xsl:result-document>

    </xsl:template>

    <xsl:template name="generate-profiles">

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

        <xsl:variable name="odp-profile" as="document-node()" select="doc($odp-profile-href)" />

        <xsl:for-each select="map:keys($ars-profile-names)">

            <xsl:variable name="nb" as="document-node()" select="doc(map:get($nist-profile-names, current()))" />

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
                    <import href="{base-uri($input-catalog)}">
                        <xsl:copy-of select="$nb//include-controls" />
                    </import>

                    <xsl:copy-of select="$odp-profile//modify" />

                </profile>

            </xsl:result-document>
        </xsl:for-each>

    </xsl:template>

</xsl:stylesheet>
