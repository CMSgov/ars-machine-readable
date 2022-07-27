# ARS ODP extract

`ARS-5.0.xml` was created by converting the 
[ARS 5.0 spreadsheet](https://dkanreserve.prod.acquia-sites.com/sites/default/files/Main%20Library%20Documents/ARS%20Full%20Element%20Principle_Single_Assessment_Current%20V5.01.xlsx) to XML.
This was a manual process: remove the first row and then invoke an MS Excel to XML import in OxygenXML Editor.

The XML import was then manually edited to remove a few errors resulting in `ARS-5.01-01.xml`.

`ODP-example.xsl` can be used to produce the ODP extract as an OSCAL profile using `ARS-5.01-01.xml` as input. (The profile cannot be created and used in the same transformation.)

There are two parameters which should be used in three sequential transforms:
1. `generate-odp-profile` set to boolean true to produce the ODP profile..
1. `generate-ars-profiles` set to boolean true to produce the baseline profiles.
1. Transform with the above set to boolean false (the default) to produce the report.

`ODP-extract.xlsx` was received 2022-07-26 and contains values for all ODPs in baselined controls. It was copied and modified to become `ODP-extract (modified).xlsx` which was then imported to become `ODP-extract.xml`. It will be used to create the OSCAL catalog and profile documents.

