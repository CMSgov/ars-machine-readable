<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2" xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:oscal="http://csrc.nist.gov/ns/oscal/1.0">

    <sch:ns prefix="array" uri="http://www.w3.org/2005/xpath-functions/array" />
    <sch:ns prefix="map" uri="http://www.w3.org/2005/xpath-functions/map" />
    <sch:ns prefix="oscal" uri="http://csrc.nist.gov/ns/oscal/1.0" />

    <sch:pattern>

        <sch:let name="catalog" value="doc(//oscal:import/@href)" />

        <sch:rule context="/">

            <sch:report test="true()" role="information"><sch:value-of select="//oscal:import/@href" /></sch:report>

        </sch:rule>

        <sch:rule context="oscal:with-id">

            <sch:assert test="exists($catalog//oscal:control[@id eq current()/text()])" role="error" diagnostics="missing-control">with-id target
                control exists in catalog.</sch:assert>

        </sch:rule>

        <sch:rule context="oscal:set-parameter">

            <sch:assert test="exists($catalog//oscal:param[@id eq current()/@param-id])" role="error" diagnostics="missing-parameter">set-parameter target param exists in
                catalog.</sch:assert>

        </sch:rule>

    </sch:pattern>

    <sch:diagnostics>

        <sch:diagnostic id="missing-control">Control <sch:value-of select="current()" /> does not exist in the catalog. (<sch:value-of
                select="$catalog//control/@id" />).</sch:diagnostic>


        <sch:diagnostic id="missing-parameter">set-parameter target <sch:value-of select="current()/@param-id" /> does not exist in the catalog.</sch:diagnostic>

    </sch:diagnostics>

</sch:schema>
