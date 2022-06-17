<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs fn oscal"
    version="3.0" xmlns:fn="local-function" xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0"
    xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0" expand-text="true">

    <xsl:param name="generate-profile" as="xs:boolean" required="false" select="false()" />

    <xsl:param name="show-all-withdrawn" as="xs:boolean" required="false" select="true()" />

    <xsl:param name="show-ODP-id" as="xs:boolean" required="false" select="true()" />

    <xsl:param name="compare-ODP" as="xs:boolean" required="false" select="false()" />

    <xsl:param name="show-tailored-ODPs" as="xs:boolean" required="false" select="true()" />

    <xsl:param name="show-guidance" as="xs:boolean" required="false" select="false()" />

    <xsl:mode on-no-match="shallow-skip" />

    <xsl:output method="html" version="5.0" include-content-type="false" />

    <xsl:output indent="false" />

    <xsl:strip-space elements="*" />

    <xsl:function name="fn:withdrawn" as="xs:boolean">
        <xsl:param name="control" as="element()" required="true" />
        <xsl:sequence select="$control/prop[@name eq 'status']/@value = ('Withdrawn', 'withdrawn')" />
    </xsl:function>

    <xsl:function name="fn:parameter-text" as="xs:string">
        <xsl:param name="parameter" as="element()" required="true" />
        <xsl:value-of select="$parameter" />
    </xsl:function>

    <xsl:function name="fn:control-title" as="xs:string">
        <xsl:param name="control" as="element()" required="true" />
        <xsl:variable name="control-title" as="xs:string*">
            <xsl:if test="$control/parent::control">
                <xsl:value-of select="$control/parent::control/title" />
                <xsl:text> | </xsl:text>
            </xsl:if>
            <xsl:value-of select="$control/title" />
        </xsl:variable>
        <xsl:value-of select="string-join($control-title)" />
    </xsl:function>

    <xsl:variable name="UTC" as="xs:duration" select="xs:dayTimeDuration('PT0H')" />
    <xsl:variable name="UTC-date" as="xs:date" select="adjust-date-to-timezone(current-date(), $UTC)" />
    <xsl:variable name="UTC-datetime" as="xs:dateTime" select="adjust-dateTime-to-timezone(current-dateTime(), $UTC)" />

    <xsl:variable name="LF" as="xs:string" select="'&#x0a;'" />

    <xsl:variable name="BL" as="xs:string" select="'Ⓛ'" />
    <xsl:variable name="BM" as="xs:string" select="'Ⓜ'" />
    <xsl:variable name="BH" as="xs:string" select="'Ⓗ'" />

    <xsl:variable name="ODP-low" as="document-node()" select="doc('ars-5.0-low-profile.xml')" />
    <xsl:variable name="ODP-moderate" as="document-node()" select="doc('ars-5.0-moderate-profile.xml')" />
    <xsl:variable name="ODP-high" as="document-node()" select="doc('ars-5.0-high-profile.xml')" />

    <xsl:variable name="ARS" as="document-node()" select="doc('file:ARS-5.0.xml')" />

    <xsl:variable name="document-title" as="xs:string">CMS ARS 5.0 and NIST SP 800-53r5 ODP example</xsl:variable>

    <xsl:template match="/">

        <html lang="en">
            <xsl:choose>
                
                <xsl:when test="$generate-profile">
                    <xsl:call-template name="generate-profile" />
                </xsl:when>
                
                <xsl:otherwise>

                    <head>
                        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
                        <title>{$document-title}</title>
                        <xsl:variable name="css" select="unparsed-text(replace(static-base-uri(), '\.xsl$', '.css'))" />
                        <style><xsl:value-of disable-output-escaping="true" select="replace($css, '\s+', ' ')" /></style>
                    </head>

                    <body>

                        <h1>{$document-title}</h1>

                        <p>This example does not yet have FIPS 199 low, moderate, and high ODPs, nor are all ODPs represented.</p>

                        <p>This document will be frequently updated. This update was produced {format-dateTime($UTC-datetime, '[F] [MNn] [D1] [Y] at
                            [H01]:[m01]:[s01]Z')}.</p>

                        <p>The version of the <a
                                href="https://github.com/usnistgov/oscal-content/blob/main/nist.gov/SP800-53/rev5/xml/NIST_SP-800-53_rev5_catalog.xml"
                                >NIST SP 800-53rev5 OSCAL catalog</a> used is {//metadata/version}.</p>
                        
                        <xsl:call-template name="extracted-ODPs"/>
                        
                        <!--<xsl:call-template name="supplied-odps"/>-->

                        <!--<xsl:call-template name="ODP-detail"/>-->

                        <div class="trailer">
                            <hr />
                            <p>Revised <xsl:value-of select="$UTC-datetime" /></p>
                        </div>

                    </body>

                </xsl:otherwise>
            </xsl:choose>


        </html>

    </xsl:template>

    <xsl:template name="extracted-ODPs">

        <xsl:variable name="extract" as="document-node()" select="doc('ODP-example-profile.xml')" />

        <h2>Extracted ODPs</h2>

        <p>The label and guideline texts are from the NIST SP 800-53rev5 OSCAL catalog. Note that not all parameters enjoy such attention.</p>
        <p>The control and parameter identifiers are those used in the NIST SP 800-53rev5 OSCAL catalog.</p>
        <p>The value text was (when possible) extracted from the ARS 5.01_0 spreadsheet. Only successful extractions (about ~50% of all parameters)
            appear. Extraction details appear <a href="#ODP-detail">here</a>.</p>

        <table>
            <caption>ODPs extracted from ARS 5.01_0 spreadsheet</caption>

            <colgroup>
                <col style="width: 4%;" />
                <col style="width: 5%;" />
                <col style="width: 20%;" />
                <col style="width: 20%;" />
            </colgroup>

            <thead>
                <tr>
                    <th class="center">Control</th>
                    <th class="center">ODP</th>
                    <th>Label</th>
                    <th>Guideline</th>
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
                                            <xsl:when test="label">
                                                <xsl:text>{label}</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="$control/param[@id eq current()/@param-id]/select">
                                                <xsl:apply-templates mode="insert" select="$control/param[@id eq current()/@param-id]/select" />
                                            </xsl:when>
                                        </xsl:choose>
                                    </td>
                                    <td>{guideline}</td>
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
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>

                </xsl:for-each>

            </tbody>

        </table>

    </xsl:template>

    <xsl:template name="ODP-detail">

        <h2 id="ODP-detail">ODPs In Situ</h2>

        <p>The following table shows ODP mapping to SP 800-53 control statements.<!-- Controls associated with FIPS 199/SP 800-53B
                <strong><i>High</i></strong> are included.--></p>

        <p>ODPs can be displayed in situ by clicking on the ⬇ symbol. <strong>NB: Most ODPs are not yet isolated and defined.</strong></p>

        <p>ARS control labels are incorrect (do not match those used by NIST SP 800-53) and are ignored for statement analysis (they'll have to be
            fixed up though).</p>

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
                            <xsl:variable name="ars-label" as="xs:string" select="prop[@class eq 'sp800-53a' and @name eq 'label']/@value" />

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
                                        <xsl:apply-templates mode="statement" select="part[@name eq 'statement']" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>

                            <!--<br/>
                            <xsl:call-template name="regex"/>
                            <pre><xsl:copy-of select="serialize($statement-regexes, map {'indent': true()})"/></pre>-->

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

    <xsl:template mode="statement" match="p">
        <xsl:apply-templates mode="statement" select="node()" />
    </xsl:template>

    <xsl:template mode="statement" match="em | strong | ol | li | b">
        <xsl:element name="span">
            <xsl:attribute name="class">semantic-error</xsl:attribute>
            <xsl:attribute name="title">The input catalog contained a faux HTML &lt;{local-name()}&gt; element</xsl:attribute>
            <xsl:apply-templates mode="statement" select="node()" />
        </xsl:element>
    </xsl:template>

    <xsl:template mode="statement" match="a">
        <a href="{@href}">
            <xsl:value-of select="." />
        </a>
    </xsl:template>

    <xsl:template mode="statement" match="prop[not(@class) and @name eq 'label']">
        <xsl:text>{@value} </xsl:text>
    </xsl:template>

    <xsl:template mode="statement" match="insert">
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
                        <xsl:apply-templates mode="insert" select="ancestor::control/param[@id eq current()/@id-ref]" />
                    </xsl:variable>
                    <!--<xsl:message select="$insert"/>-->

                    <xsl:choose>
                        <xsl:when test="$show-tailored-ODPs">
                            <!--<xsl:message>{current()/@id-ref} {$ODP-low//set-parameter[@param-id eq current()/@id-ref]}</xsl:message>-->
                            <details class="ODPs">
                                <!-- open="open" -->
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
                    </xsl:choose>

                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">Life must end</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="insert" match="param">
        <xsl:apply-templates mode="#current" />
    </xsl:template>

    <xsl:template mode="insert" match="prop[@name eq 'aggregates']">
        <!--  -->
    </xsl:template>

    <xsl:template mode="insert" match="label">
        <xsl:text>[</xsl:text>
        <span class="label">
            <xsl:text>Assignment: </xsl:text>
            <xsl:value-of select="." />
        </span>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template mode="insert" match="select">
        <xsl:variable name="choices" as="node()*">
            <xsl:for-each select="choice">
                <xsl:choose>
                    <xsl:when test="*">
                        <xsl:variable name="substrings" as="node()*">
                            <xsl:apply-templates mode="#current" select="node()" />
                        </xsl:variable>
                        <xsl:copy-of select="$substrings" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="." />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:text>[</xsl:text>
        <span class="select">
            <xsl:choose>
                <xsl:when test="@how-many eq 'one-or-more'">
                    <xsl:text>Selection (one or more): </xsl:text>
                    <xsl:for-each select="$choices">
                        <xsl:if test="position() ne 1">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                        <xsl:copy-of select="." />
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Selection: </xsl:text>
                    <xsl:for-each select="$choices">
                        <xsl:if test="position() ne 1">
                            <span class="boolean"> or </span>
                        </xsl:if>
                        <xsl:copy-of select="." />
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </span>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template mode="insert" match="text()" />

    <xsl:template mode="statement" match="remarks"><!-- ignore for now --></xsl:template>

    <xsl:template mode="statement" match="text()">
        <xsl:copy-of select="." />
    </xsl:template>



    <xsl:template name="generate-profile">

        <xsl:result-document href="ODP-example-profile.xml" method="xml" output-version="1.0" indent="true">

            <xsl:processing-instruction name="xml-model">
                <xsl:text expand-text="false">href="https://github.com/usnistgov/OSCAL/raw/v1.0.4/xml/schema/oscal_complete_schema.xsd" schematypens="http://www.w3.org/2001/XMLSchema" title="OSCAL complete schema" </xsl:text>
            </xsl:processing-instruction>
            <profile xmlns="http://csrc.nist.gov/ns/oscal/1.0" uuid="8e100170-0808-4ea9-a82c-4bb88eaa0ee5">
                <metadata>
                    <title>CMS ARS 5.0 ODP Profile</title>
                    <last-modified>{current-dateTime()}</last-modified>
                    <version>{current-dateTime()}</version>
                    <oscal-version>1.0.4</oscal-version>
                </metadata>
                <import
                    href="https://raw.githubusercontent.com/usnistgov/oscal-content/main/nist.gov/SP800-53/rev5/xml/NIST_SP-800-53_rev5_catalog.xml">
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

                        <xsl:variable name="ars-label" as="xs:string" select="prop[@class eq 'sp800-53a' and @name eq 'label']/@value" />

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
                                                            <xsl:if test="$param/label">
                                                                <xsl:copy-of select="$param/label" />
                                                            </xsl:if>
                                                            <xsl:if test="$param/guideline">
                                                                <xsl:copy-of select="$param/guideline" />
                                                            </xsl:if>
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

</xsl:stylesheet>
