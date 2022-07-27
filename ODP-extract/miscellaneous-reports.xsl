<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" exclude-result-prefixes="xs math" version="3.0"
    xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0" xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0" expand-text="true">

    <!-- This transform expects -->
    <!-- https://raw.githubusercontent.com/usnistgov/oscal-content/main/nist.gov/SP800-53/rev5/xml/NIST_SP-800-53_rev5_catalog.xml -->
    <!-- or the equivalent as input -->

    <xsl:include href="UTC.xsl" />

    <xsl:param name="generate-profile" as="xs:boolean" required="false" select="false()" />

    <xsl:param name="show-all-withdrawn" as="xs:boolean" required="false" select="true()" />

    <xsl:param name="show-ODP-id" as="xs:boolean" required="false" select="true()" />

    <xsl:param name="compare-ODP" as="xs:boolean" required="false" select="false()" />

    <xsl:param name="show-tailored-ODPs" as="xs:boolean" required="false" select="true()" />

    <xsl:param name="show-guidance" as="xs:boolean" required="false" select="false()" />


    <xsl:mode on-no-match="shallow-skip" />

    <xsl:output method="html" version="5" include-content-type="false" indent="false" />

    <xsl:variable name="nbl" as="document-node()"
        select="doc('https://raw.githubusercontent.com/usnistgov/oscal-content/main/nist.gov/SP800-53/rev5/xml/NIST_SP-800-53_rev5_LOW-baseline_profile.xml')" />
    <xsl:variable name="nbm" as="document-node()"
        select="doc('https://raw.githubusercontent.com/usnistgov/oscal-content/main/nist.gov/SP800-53/rev5/xml/NIST_SP-800-53_rev5_MODERATE-baseline_profile.xml')" />
    <xsl:variable name="nbh" as="document-node()"
        select="doc('https://raw.githubusercontent.com/usnistgov/oscal-content/main/nist.gov/SP800-53/rev5/xml/NIST_SP-800-53_rev5_HIGH-baseline_profile.xml')" />
    <xsl:variable name="nb" as="xs:string*" xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0"
        select="distinct-values(($nbl//with-id, $nbm//with-id, $nbh//with-id))" />

    <xsl:variable name="ARS" as="document-node()" select="doc('ARS-5.01-01.xml')" />

    <xsl:variable name="document-title" as="xs:string">NIST SP 800-53r5 Controls</xsl:variable>

    <xsl:variable name="NIST" as="document-node()" select="/" />

    <xsl:template match="/">
        <html lang="en">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
                <title>{$document-title}</title>
                <xsl:variable name="css" select="unparsed-text(replace(static-base-uri(), '\.xsl$', '.css'))" />
                <style><xsl:value-of disable-output-escaping="true" select="replace($css, '\s+', ' ')" /></style>
            </head>
            <body>

                <p>This document was produced {format-dateTime($UTC-datetime, '[F] [MNn] [D1] [Y] at [H01]:[m01]:[s01]Z')}.</p>
                <p>The transform used to produce the report was <code>{static-base-uri() ! tokenize(., '/')[last()]}</code>.</p>
                <p>Input to the transform was <code>{base-uri()}</code>.</p>

                <!--<xsl:call-template name="SP800-53-a-b-match" />-->
                <!--<xsl:call-template name="title-mismatch-2" />-->
                <!--<xsl:call-template name="title-mismatch-1" />-->
                <xsl:call-template name="identifiers" />
            </body>
        </html>
    </xsl:template>

    <xsl:template name="SP800-53-a-b-match">
        <xsl:variable name="ssc" as="document-node()" select="doc('sp800-53r5-control-catalog.xml')" />
        <xsl:variable name="ssa" as="document-node()" select="doc('sp800-53ar5-assessment-procedures.xml')" />
        <xsl:variable name="ssb" as="document-node()" select="doc('sp800-53b-control-baselines.xml')" />
        <h2>800-53 rev5 Control Title Mismatches</h2>
        <p>This is a comparison of control and control enhancement titles found in</p>
        <ul>
            <li>NIST SP 800-53 revision 5 OSCAL control catalog (found <a target="_blank"
                    href="https://github.com/usnistgov/oscal-content/blob/main/nist.gov/SP800-53/rev5/xml/NIST_SP-800-53_rev5_catalog.xml"
                    title="link to OSCAL content">here</a>) version {//metadata/version}</li>
            <li>NIST SP 800-53 revision 5 control catalog spreadsheet (found <a target="_blank"
                    href="https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final" title="link to 800-53 rev5 page">here</a>)</li>
            <li>NIST SP 800-53b (revision 5) control baselines spreadsheet (found <a target="_blank"
                    href="https://csrc.nist.gov/publications/detail/sp/800-53b/final" title="link to 800-53B rev5 page">here</a>)</li>
        </ul>
        <p>The OSCAL control enhancement titles are synthesized to match those found in the spreadsheets.</p>
        <table>
            <thead>
                <tr>
                    <th>Control</th>
                    <th>Various 800-53 Titles</th>
                </tr>
            </thead>
            <tbody>
                <xsl:for-each select="//control[not(prop[@name eq 'status' and @value eq 'withdrawn'])]">
                    <xsl:variable name="o" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="parent::control">
                                <xsl:text>{parent::control/title} | {title}</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>{title}</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="c" as="xs:string" select="
                            $ssc//*:row[*:Control_Identifier eq current()/prop[@name eq 'label' and
                            not(@class)]/@value]/*:Control__or_Control_Enhancement__Name" />
                    <xsl:variable name="b" as="xs:string" select="
                            $ssb//*:row[*:Control_Identifier eq current()/prop[@name eq 'label' and
                            not(@class)]/@value]/*:Control__or_Control_Enhancement__Name" />
                    <xsl:variable name="m" as="xs:boolean" select="not($o eq $b and $o eq $c)" />
                    <xsl:if test="$m">
                        <tr>
                            <td>{prop[@name eq 'label' and not(@class)]/@value}</td>
                            <td>
                                <table>
                                    <xsl:if test="$m">
                                        <caption style="text-align: left;">Mismatch</caption>
                                    </xsl:if>
                                    <tbody>
                                        <tr>
                                            <td>OSCAL catalog</td>
                                            <td>{$o}</td>
                                        </tr>
                                        <tr>
                                            <td>800-53 spreadsheet</td>
                                            <td>{$c}</td>
                                        </tr>
                                        <tr>
                                            <td>800-53b spreadsheet</td>
                                            <td>{$b}</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                    </xsl:if>
                </xsl:for-each>
            </tbody>
        </table>

    </xsl:template>

    <xsl:template name="title-mismatch-2">
        <h2>ARS Control "Spreadsheet"</h2>
        <p>The following table shows ARS controls in "spreadsheet" fashion. Row numbers correspond to those in the ARS 5.01 xlsx document.</p>
        <p>Control titles which do not match those in NIST SP 800-53 rev5 OSCAL catalog are highlighted <span class="title-mismatch">thus</span>.</p>
        <p><strong>There is no need to apply manual corrections to the ARS 5.01 spreadsheet!</strong> Such errors will be removed during ARS OSCAL
            content generation.</p>
        <p><strong>NB</strong>: There are some NIST OSCAL catalog which are patently incorrect. SR-2(1) is an example. These errors have been reported
                <a target="blank" title="Link to issue" href="https://github.com/usnistgov/oscal-content/issues/112">here</a>.</p>
        <table>
            <colgroup>
                <col />
                <col />
                <col style="width:6em;" />
                <col />
                <col />
            </colgroup>
            <thead>
                <tr>
                    <th colspan="4">ARS Control</th>
                    <th>NIST</th>
                </tr>
                <tr>
                    <th>Row</th>
                    <th>Family</th>
                    <th>Number</th>
                    <th>Name</th>
                    <th>Title</th>
                </tr>
            </thead>
            <tbody>
                <xsl:for-each xpath-default-namespace="" select="$ARS//row">
                    <xsl:variable name="cn" as="xs:string" select="replace(Control_Number, '^(.+)[a-z]$?', '$1')" />
                    <xsl:variable name="nc" as="element()*" select="$NIST//*:control[*:prop[@name eq 'label' and @class]/@value eq $cn]" />
                    <tr>
                        <td>{2 + position()}</td>
                        <td>{Control_Family}</td>
                        <td>{Control_Number}</td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="not(Control_Name)" />
                                <xsl:when test="Control_Name eq $nc/*:title">
                                    <div>{Control_Name}</div>
                                </xsl:when>
                                <xsl:otherwise>
                                    <div>
                                        <span class="title-mismatch">{Control_Name}</span>
                                        <xsl:choose>
                                            <xsl:when test="lower-case(Control_Name) eq lower-case(title)">
                                                <span> (upper-lower case mismatch)</span>
                                            </xsl:when>
                                            <xsl:when test="matches(Control_Name, '\s+$')">
                                                <span> (trailing space in title)</span>
                                            </xsl:when>
                                            <xsl:when test="matches(Control_Name, '&#xa0;+$')">
                                                <span> (trailing non-breaking space in title)</span>
                                            </xsl:when>

                                        </xsl:choose>
                                    </div>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td>{$nc/*:title}</td>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>

    <xsl:template name="title-mismatch-1">
        <p>Control title mismatches are highlighted <span class="title-mismatch">thus</span>.</p>
        <table>
            <thead>
                <tr>
                    <th>800-53<br />Control<br />ID</th>
                    <th>Title</th>
                    <th>ARS<br />Control<br />ID</th>
                    <th>Responsibility</th>
                    <th>Statement<br>IDs</br></th>
                    <!--<th>800-53<br />Label</th>
                <th>800-53A<br />Label</th>
                <th>Title</th>
                <th>Baselines</th>-->
                </tr>
            </thead>
            <tbody>
                <xsl:for-each select="//control[not(prop[@name eq 'status' and @value eq 'withdrawn'])]">
                    <xsl:variable name="ars-xref" as="node()*"
                        select="$ARS//*:row[*:Control_Number eq current()/prop[@name eq 'label' and @class]/@value]" />
                    <tr>
                        <td>{@id}</td>
                        <td>
                            <div>{title}</div>
                            <xsl:if test="$ars-xref">
                                <xsl:if test="$ars-xref/*:Control_Name ne current()/title">
                                    <div>
                                        <span>ARS mismatch «</span>
                                        <span class="title-mismatch">{$ars-xref/*:Control_Name}</span>
                                        <span>»</span>
                                        <xsl:choose>
                                            <xsl:when test="matches($ars-xref/*:Control_Name, '\s+$')">
                                                <span> (trailing space in title)</span>
                                            </xsl:when>
                                            <xsl:when test="matches($ars-xref/*:Control_Name, '&#xa0;+$')">
                                                <span> (trailing non-breaking space in title)</span>
                                            </xsl:when>
                                            <xsl:when test="lower-case($ars-xref/*:Control_Name) eq lower-case(title)">
                                                <span> (upper-lower case mismatch)</span>
                                            </xsl:when>
                                        </xsl:choose>
                                    </div>
                                </xsl:if>
                            </xsl:if>
                        </td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="$ars-xref">{prop[@name eq 'label' and @class]/@value}</xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>missing</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td>
                            <xsl:if test="$ars-xref">
                                <xsl:message xpath-default-namespace="">{@id} {$ars-xref/Control_Number}</xsl:message>
                            </xsl:if>

                            <xsl:choose>
                                <xsl:when test="$ars-xref">
                                    <xsl:for-each xpath-default-namespace="" select="tokenize($ars-xref/Responsibility, '\n')">
                                        <div>{.}</div>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>missing</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="part[@name eq 'statement']/p">
                                    <xsl:text>{part[@name eq 'statement']/@id}</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="part[@name eq 'statement']/part">
                                        <div>{@id}</div>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </xsl:for-each>
            </tbody>
        </table>
    </xsl:template>

    <xsl:template name="identifiers">

        <h2 id="identifiers">Control, Statement, and ODP identifiers</h2>

        <table>
            <thead>
                <tr>
                    <th>Control<br />ID</th>
                    <th>800-53<br />Label</th>
                    <th>800-53A<br />Label</th>
                    <th>Title</th>
                    <th>Baselines</th>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates />
            </tbody>
        </table>

    </xsl:template>

    <xsl:template match="control[not(prop[@name eq 'status' and @value eq 'withdrawn'])]">
        <xsl:variable name="ars-xref" as="node()*" select="$ARS//*:row[*:Control_Number eq current()/prop[@name eq 'label' and @class]/@value]" />
        <tr>
            <td rowspan="2">{@id}</td>
            <td>{prop[@name eq 'label' and not(@class)]/@value}</td>
            <td>{prop[@name eq 'label' and @class]/@value}</td>
            <td>
                <xsl:choose>
                    <xsl:when test="parent::control">
                        <xsl:text>{parent::control/title} | {title}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>{title}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
            <td>
                <div>
                    <xsl:text>800-53B:</xsl:text>
                    <xsl:choose>
                        <xsl:when test="@id = $nb">
                            <xsl:if test="exists($nbl//with-id[. eq current()/@id])">
                                <xsl:text> Low</xsl:text>
                            </xsl:if>
                            <xsl:if test="exists($nbm//with-id[. eq current()/@id])">
                                <xsl:text> Moderate</xsl:text>
                            </xsl:if>
                            <xsl:if test="exists($nbh//with-id[. eq current()/@id])">
                                <xsl:text> High</xsl:text>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text> not specified</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
                <div>
                    <xsl:text>ARS: </xsl:text>
                    <xsl:choose>
                        <xsl:when test="$ars-xref">
                            <xsl:text>{$ars-xref/*:CMS_Baseline}</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="anomaly">
                                <xsl:text>not specified</xsl:text>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </td>
        </tr>
        <tr>
            <td colspan="4">
                <xsl:apply-templates mode="statement" select="part[@name eq 'statement']" />
            </td>
        </tr>
        <xsl:apply-templates mode="#current" />
    </xsl:template>



    <xsl:template mode="statement" match="part[@name eq 'statement']">
        <xsl:param name="tag-with-id" as="xs:boolean" tunnel="true" required="false" select="true()" />
        <xsl:variable name="content" as="node()*">
            <div class="statement">
                <xsl:if test="starts-with(root(.)/catalog/metadata/title, 'NIST Special Publication 800-53 Revision 5') and $tag-with-id">
                    <xsl:attribute name="id" select="@id" />
                </xsl:if>
                <span class="subscript-identifier">{@id}</span>
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
            <span class="subscript-identifier">{@id}</span>
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
        <xsl:message>{@id-ref}</xsl:message>
        <xsl:choose>
            <xsl:when test="@type eq 'param'">
                <span>
                    <xsl:attribute name="title">
                        <xsl:text>{@id-ref}</xsl:text>
                        <xsl:variable name="p" as="element()" select="//param[@id eq current()/@id-ref]" />
                        <xsl:if test="$p/label">
                            <xsl:text>&#x0a;{$p/label}</xsl:text>
                        </xsl:if>
                        <xsl:if test="
                                (: 'guidance' were guidance and not an ODP 'assessment objective' :)
                                false() and $p/guideline">
                            <xsl:text>&#x0a;{normalize-space($p/guideline)}</xsl:text>
                        </xsl:if>
                    </xsl:attribute>
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

                    <xsl:copy-of select="$insert" />

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
        <!-- TODO -->
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

</xsl:stylesheet>
