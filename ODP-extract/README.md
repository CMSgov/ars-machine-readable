# ARS ODP extract

`ARS-5.0.xml` was created by converting the 
[ARS 5.0 spreadsheet](https://dkanreserve.prod.acquia-sites.com/sites/default/files/Main%20Library%20Documents/ARS%20Full%20Element%20Principle_Single_Assessment_Current%20V5.01.xlsx) to XML.
This was a manual process: remove the first row and then invoke an MS Excel to XML import in OxygenXML Editor.

`ODP-example.xsl` can be used to produce the ODP extract as an OSCAL profile.
(The profile cannot be created and used in the same transformation.)

By default `ODP-example.xsl` will produce a report of extracted ODPs.
