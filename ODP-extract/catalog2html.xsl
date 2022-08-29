<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="xs fn map oscal" version="3.0" xmlns:fn="local-function"
    xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0" xpath-default-namespace="http://csrc.nist.gov/ns/oscal/1.0" expand-text="true">

    <xsl:param name="show-ODP-id" as="xs:boolean" required="false" select="true()" />

    <xsl:param name="show-tailored-ODPs" as="xs:boolean" required="false" select="true()" />

    <xsl:param name="open-details" as="xs:boolean" required="false" select="false()" />

    <!--<xsl:mode on-no-match="shallow-skip" />-->

    <xsl:output method="html" version="5.0" include-content-type="false" />

    <xsl:output indent="false" />

    <xsl:strip-space elements="*" />

    <xsl:import href="UTC.xsl" />

    <xsl:variable name="LF" as="xs:string" select="'&#x0a;'" />

    <xsl:variable name="BL" as="xs:string" select="'🄻'" />
    <xsl:variable name="BM" as="xs:string" select="'🄼'" />
    <xsl:variable name="BH" as="xs:string" select="'🄷'" />
    <xsl:variable name="BV" as="xs:string" select="'🅅'" />

    <!-- input oscal-content catalog -->
    <xsl:variable name="input-catalog" as="document-node()" select="/" />

    <xsl:variable name="ODP-low" as="document-node()" select="doc('ars-5.0-low-profile.xml')" />
    <xsl:variable name="ODP-moderate" as="document-node()" select="doc('ars-5.0-moderate-profile.xml')" />
    <xsl:variable name="ODP-high" as="document-node()" select="doc('ars-5.0-high-profile.xml')" />
    <xsl:variable name="ODP-hva" as="document-node()" select="doc('ars-5.0-hva-profile.xml')" />

    <xsl:variable name="rng" select="random-number-generator($UTC-datetime)" />

    <xsl:variable name="document-title" as="xs:string">CMS ARS 5.0 control catalog</xsl:variable>

    <xsl:template match="/">

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

                <p>The version of the ARS OSCAL catalog used is {//metadata/version}.</p>
                <p>The version of the {$ODP-low//metadata/title} used is {$ODP-low//metadata/version}.</p>
                <p>The version of the {$ODP-moderate//metadata/title} used is {$ODP-moderate//metadata/version}.</p>
                <p>The version of the {$ODP-high//metadata/title} used is {$ODP-high//metadata/version}.</p>
                <p>The version of the {$ODP-hva//metadata/title} used is {$ODP-hva//metadata/version}.</p>

                <xsl:call-template name="ODP-template" />

                <xsl:call-template name="ODP-detail" />

                <div class="trailer">
                    <hr />
                    <p>Revised <xsl:value-of select="$UTC-datetime" /></p>
                </div>

            </body>
        </html>

    </xsl:template>

    <xsl:template name="ODP-template">

        <h2>ODP Template</h2>

        <p>The following table shows ODP values for Low {$BL}, Moderate {$BM}, High {$BH}, and HVA {$BV} baselines.</p>

        <p>Control details are <a href="#ODP-detail">here</a>.</p>

        <table class="template">
            <caption>ODPs from ARS profiles</caption>

            <colgroup>
                <col style="width: 4%;" />
                <col style="width: 4%;" />
                <col style="width: 4%;" />
                <col style="width: 20%;" />
                <col style="width: 15%;" />
                <col style="width: 15%;" />
                <col style="width: 15%;" />
                <col style="width: 15%;" />
            </colgroup>

            <thead>
                <tr>
                    <th colspan="4" class="center">NIST SP 800-53rev5 OSCAL Catalog Origin</th>
                    <th colspan="4" class="center">Defined Baseline Values</th>
                </tr>
                <tr>
                    <th class="center">Control<br>Label</br></th>
                    <th class="center">Baselines</th>
                    <th class="center">ODP ID</th>
                    <th class="center">ODP "Label"</th>
                    <th class="center">Low</th>
                    <th class="center">Moderate</th>
                    <th class="center">High</th>
                    <th class="center">HVA</th>
                </tr>
            </thead>

            <tbody>
                <xsl:for-each select="//control[@id = ($ODP-low//with-id, $ODP-moderate//with-id, $ODP-high//with-id, $ODP-hva//with-id)]">
                    <xsl:sort order="ascending" select="current()/prop[@name eq sort-id]/@value" />

                    <xsl:variable name="control" as="element()" select="." />

                    <xsl:for-each select="param">
                        <xsl:choose>
                            <xsl:when test="position() eq 1">
                                <tr>
                                    <td class="center" rowspan="{last()}">
                                        <a href="#{$control/@id}">{$control/prop[@name eq 'label'][not(@class)]/@value}</a>
                                    </td>
                                    <td class="center" rowspan="{last()}">
                                        <div>
                                            <xsl:if test="parent::control/@id = $ODP-low//with-id">{$BL}</xsl:if>
                                            <xsl:if test="parent::control/@id = $ODP-moderate//with-id">{$BM}</xsl:if>
                                            <xsl:if test="parent::control/@id = $ODP-high//with-id">{$BH}</xsl:if>
                                            <xsl:if test="parent::control/@id = $ODP-hva//with-id">{$BV}</xsl:if>
                                        </div>
                                    </td>
                                    <td class="center">
                                        <span class="id">{@id}</span>
                                    </td>
                                    <td>
                                        <xsl:apply-templates mode="param" select="." />
                                    </td>
                                    <td>{$ODP-low//set-parameter[@param-id eq current()/@id]/value}</td>
                                    <td>{$ODP-moderate//set-parameter[@param-id eq current()/@id]/value}</td>
                                    <td>{$ODP-high//set-parameter[@param-id eq current()/@id]/value}</td>
                                    <td>{$ODP-hva//set-parameter[@param-id eq current()/@id]/value}</td>
                                </tr>
                            </xsl:when>
                            <xsl:otherwise>
                                <tr>
                                    <td class="center">
                                        <span class="id">{@id}</span>
                                    </td>
                                    <td>
                                        <xsl:apply-templates mode="param" select="." />
                                    </td>
                                    <td>{$ODP-low//set-parameter[@param-id eq current()/@id]/value}</td>
                                    <td>{$ODP-moderate//set-parameter[@param-id eq current()/@id]/value}</td>
                                    <td>{$ODP-high//set-parameter[@param-id eq current()/@id]/value}</td>
                                    <td>{$ODP-hva//set-parameter[@param-id eq current()/@id]/value}</td>
                                </tr>
                            </xsl:otherwise>
                        </xsl:choose>

                    </xsl:for-each>

                </xsl:for-each>
            </tbody>

        </table>

    </xsl:template>

    <xsl:template name="ODP-detail">

        <h2 id="ODP-detail">ARS ODPs in situ</h2>

        <p>The following table shows ARS OSCAL catalog controls which appear in baselines (there are {count(//control[@id = $ODP-high//with-id])}
            controls and control enhancements).</p>

        <p>The ⬇ symbol appears when ODPs lack definition or vary by baseline. Click on the ODP too see the baseline values.</p>

        <p>A single value is displayed when all baseline values are
            identical.<!--The ≡ symbol appears when ODP values are invariant within the baselines.--></p>

        <p>➤ denotes a top-level control statement (<i>element</i>) - one for which an individual control implementation response is required. The Low
            {$BL}, Moderate {$BM}, High {$BH}, and HVA {$BV} baselines have {count(//control[@id = $ODP-low//with-id]/part[@name eq
            'statement']//prop[@class eq 'ARS' and @name eq 'label'])}, {count(//control[@id = $ODP-moderate//with-id]/part[@name eq
            'statement']//prop[@class eq 'ARS' and @name eq 'label'])}, {count(//control[@id = $ODP-high//with-id]/part[@name eq
            'statement']//prop[@class eq 'ARS' and @name eq 'label'])}, and {count(//control[@id = $ODP-hva//with-id]/part[@name eq
            'statement']//prop[@class eq 'ARS' and @name eq 'label'])} elements respectively.</p>

        <table class="tr-hover">

            <caption>ODPs in situ</caption>

            <colgroup>
                <col style="width: 4%;" />
                <col style="width: 95%;" />

            </colgroup>

            <thead>
                <tr>
                    <th style="text-align:center;">Control</th>
                    <th>NIST 800-53 Statements</th>
                </tr>
            </thead>

            <tbody>

                <xsl:for-each select="//control[@id = ($ODP-low//with-id, $ODP-moderate//with-id, $ODP-high//with-id, $ODP-hva//with-id)]">
                    <xsl:sort order="ascending" select="current()/prop[@name eq sort-id]/@value" />

                    <xsl:variable name="control" as="element()" select="." />

                    <tr>
                        <xsl:attribute name="id" select="@id" />

                        <td class="center">
                            <div>
                                <xsl:value-of select="prop[not(@class) and @name eq 'label']/@value" />
                            </div>
                            <div>
                                <xsl:if test="@id = $ODP-low//with-id">{$BL}</xsl:if>
                                <xsl:if test="@id = $ODP-moderate//with-id">{$BM}</xsl:if>
                                <xsl:if test="@id = $ODP-high//with-id">{$BH}</xsl:if>
                                <xsl:if test="@id = $ODP-hva//with-id">{$BV}</xsl:if>
                            </div>
                        </td>

                        <td>

                            <div>
                                <xsl:if test="parent::control">
                                    <xsl:value-of select="parent::control/title" />
                                    <xsl:text> | </xsl:text>
                                </xsl:if>
                                <xsl:value-of select="title" />
                            </div>

                            <div>
                                <xsl:apply-templates mode="statement" select="part[@name eq 'statement']">
                                    <xsl:with-param name="tag-with-id" as="xs:boolean" tunnel="true" select="true()" />
                                </xsl:apply-templates>
                            </div>

                        </td>

                    </tr>

                </xsl:for-each>

            </tbody>

        </table>

    </xsl:template>

    <xsl:template mode="statement" match="part[@name eq 'statement']">
        <xsl:param name="tag-with-id" as="xs:boolean" tunnel="true" required="false" select="true()" />
        <xsl:variable name="content" as="node()*">
            <div class="statement {if (not(part)) then 'element' else ''}">
                <xsl:if test="$tag-with-id">
                    <xsl:attribute name="id" select="@id" />
                </xsl:if>
                <xsl:apply-templates mode="statement" select="node()" />
            </div>
        </xsl:variable>
        <xsl:copy-of select="$content" />
    </xsl:template>

    <xsl:template mode="statement" match="part[@name eq 'item']">
        <xsl:param name="tag-with-id" as="xs:boolean" tunnel="true" required="false" select="true()" />
        <div class="item {if (parent::part[@name eq 'statement']) then 'element' else ''}">
            <xsl:if test="$tag-with-id">
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

    <xsl:template mode="statement" match="insert">
        <xsl:param name="tag-with-id" as="xs:boolean" tunnel="true" required="false" select="true()" />

        <xsl:variable name="id" as="xs:string" select="@id-ref" />

        <xsl:variable name="vl" as="xs:string*" select="$ODP-low//set-parameter[@param-id eq $id]" />
        <xsl:variable name="vm" as="xs:string*" select="$ODP-moderate//set-parameter[@param-id eq $id]" />
        <xsl:variable name="vh" as="xs:string*" select="$ODP-high//set-parameter[@param-id eq $id]" />
        <xsl:variable name="vv" as="xs:string*" select="$ODP-hva//set-parameter[@param-id eq $id]" />

        <xsl:choose>
            <xsl:when test="@type eq 'param'">

                <xsl:variable name="insert" as="node()*">
                    <xsl:apply-templates mode="param" select="ancestor::control/param[@id eq current()/@id-ref]" />
                </xsl:variable>

                <xsl:choose>
                    <xsl:when test="$show-tailored-ODPs">

                        <xsl:choose>
                            <xsl:when test="$vl and $vm and $vh and $vv and ($vm eq $vl and $vh eq $vl and $vv eq $vl)">
                                <!--<xsl:text>≡</xsl:text>-->
                                <xsl:if test="$show-ODP-id">
                                    <span class="superscript-identifier">
                                        <xsl:value-of select="@id-ref" />
                                    </span>
                                </xsl:if>
                                <span class="ODP">{$vl}</span>
                            </xsl:when>
                            <xsl:when test="not($vl) and $vm and $vh and $vv and ($vh eq $vm and $vv eq $vm)">
                                <xsl:if test="$show-ODP-id">
                                    <span class="superscript-identifier">
                                        <xsl:value-of select="@id-ref" />
                                    </span>
                                </xsl:if>
                                <span class="ODP">{$vm}</span>
                            </xsl:when>
                            <xsl:when test="not($vl) and not($vm) and $vh and ($vv eq $vh)">
                                <xsl:if test="$show-ODP-id">
                                    <span class="superscript-identifier">
                                        <xsl:value-of select="@id-ref" />
                                    </span>
                                </xsl:if>
                                <span class="ODP">{$vh}</span>
                            </xsl:when>
                            <xsl:when test="not($vl) and not($vm) and not($vh) and ($vv)">
                                <xsl:if test="$show-ODP-id">
                                    <span class="superscript-identifier">
                                        <xsl:value-of select="@id-ref" />
                                    </span>
                                </xsl:if>
                                <span class="ODP">{$vv}</span>
                            </xsl:when>
                            <xsl:otherwise>
                                <details class="ODPs">
                                    <xsl:if test="$open-details">
                                        <xsl:attribute name="open">true</xsl:attribute>
                                    </xsl:if>
                                    <summary>
                                        <xsl:copy-of select="$insert" />
                                    </summary>
                                    <xsl:variable name="ODPs" as="xs:string*">
                                        <xsl:choose>
                                            <xsl:when test="$ODP-low//set-parameter[@param-id eq $id]">
                                                <xsl:text>{$BL}: {$ODP-low//set-parameter[@param-id eq $id]/value}</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>{$BL}: (Not defined)</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:choose>
                                            <xsl:when test="$ODP-moderate//set-parameter[@param-id eq $id]">
                                                <xsl:text>{$BM}: {$ODP-moderate//set-parameter[@param-id eq $id]/value}</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>{$BM}: (Not defined)</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:choose>
                                            <xsl:when test="$ODP-high//set-parameter[@param-id eq $id]">
                                                <xsl:text>{$BH}: {$ODP-high//set-parameter[@param-id eq $id]/value}</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>{$BH}: (Not defined)</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:choose>
                                            <xsl:when test="$ODP-hva//set-parameter[@param-id eq $id]">
                                                <xsl:text>{$BV}: {$ODP-hva//set-parameter[@param-id eq $id]/value}</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:text>{$BV}: (Not defined)</xsl:text>
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
                            </xsl:otherwise>
                        </xsl:choose>


                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:copy-of select="$insert" />
                    </xsl:otherwise>

                </xsl:choose>

            </xsl:when>

            <xsl:otherwise>
                <xsl:message terminate="yes">Unsupported insert type {@type}.</xsl:message>
            </xsl:otherwise>

        </xsl:choose>

    </xsl:template>

    <xsl:template mode="statement1" match="insert">
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

    <xsl:template mode="param" match="insert">
        <xsl:apply-templates mode="param" select="ancestor::control/param[@id eq current()/@id-ref]" />
    </xsl:template>

    <xsl:template mode="param" match="node()" priority="-1" />

    <xsl:template mode="statement" match="remarks"><!-- ignore for now --></xsl:template>

</xsl:stylesheet>
