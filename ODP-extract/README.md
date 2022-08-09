# ARS ODP extract

This directory contains data and transforms to create ARS 5.0 OSCAL catalog and profiles.

## ODP extract

`ARS-5.0.xml` was created by converting the 
[ARS 5.0 spreadsheet](https://dkanreserve.prod.acquia-sites.com/sites/default/files/Main%20Library%20Documents/ARS%20Full%20Element%20Principle_Single_Assessment_Current%20V5.01.xlsx) to XML.
This was a manual process: remove the first row and then invoke an MS Excel to XML import in OxygenXML Editor.

The XML import was then manually edited to remove a few errors resulting in `ARS-5.01-01.xml`.

`ODP-example.xsl` can be used to produce the ODP extract as an OSCAL profile using `ARS-5.01-01.xml` as input. (The profile cannot be created and used in the same transformation.)

There are two parameters which should be used in three sequential transforms:
1. `generate-odp-profile` set to boolean true to produce the ODP profile..
1. `generate-ars-profiles` set to boolean true to produce the baseline profiles.
1. Transform with the above set to boolean false (the default) to produce the report.

## ARS OSCAL profile generation

`ODP-extract.xlsx` was received 2022-07-26 and contains values for all ODPs in baselined controls. It was copied and modified to become `ODP-extract (modified).xlsx` which was then imported to become `ODP-extract.xml`. A manual process was used to alter the received file (using LibreOffice) and converting the result to XML using the XML import in OxygenXML Editor.

After finding 49 ODP values ending in a period, a small transform `ODP-extract-cleanup.xsl` was created to produce `ODP-extract-edited.xml` using `ODP-extract.xml` as input.

`java -cp ~/saxon/saxon-he-11.3.jar net.sf.saxon.Transform -xsl:ODP-extract-cleanup.xsl -s:ODP-extract.xml -o:ODP-extract-edited.xml`

To create  the ARS OSCAL profiles using `generate-profiles.xsl` as the transform and  `ODP-extract-edited.xml` as input, the following command would be used:

`java -cp ~/saxon/saxon-he-11.3.jar net.sf.saxon.Transform -xsl:generate-profiles.xsl -s:ODP-extract-edited.xml`.

## ARS OSCAL catalog generation

The XSL transform `ars-5.0-catalog.xsl` creates the catalog `ars-5.0-catalog.xml` using `https://raw.githubusercontent.com/usnistgov/oscal-content/main/nist.gov/SP800-53/rev5/xml/NIST_SP-800-53_rev5_catalog.xml` as input.

This catalog is quite preliminary; SP 800-53A information is deliberately omitted.

## ARS OSCAL catalog rendition

The XSL transform `catalog2html.xsl` (with a companion `catalog2html.css`) produces an HTML rendition of the ARS OSCAL catalog and profiles.

## Running XSL Transformations (XSLT)

The supplied transforms (`.xsl` documents) require the use of an XSLT 3.0/XPath 3.1 implementation.

The use of [SaxonJ-HE](https://www.saxonica.com/html/documentation11/about/gettingstarted/gettingstartedjava.html) is one method. This can be used on any platform which accommodates Java.

SaxonJ-HE is typically employed in the operating system terminal application.
Using an alias such as `alias xslt='java -cp ~/saxon/saxon-he-11.3.jar net.sf.saxon.Transform'` simplifies command specification.

As an exaample, when creating the ARS OSCAL profiles using `generate-profiles.xsl` as the transform and  `ODP-extract.xml` as input, the following command would be used:

`xslt -xsl:generate-profiles.xsl -s:ODP-extract.xml` (no output file need be identified - the transform generates three).

The command without the alias would be

`java -cp ~/saxon/saxon-he-11.3.jar net.sf.saxon.Transform -xsl:generate-profiles.xsl -s:ODP-extract.xml`.