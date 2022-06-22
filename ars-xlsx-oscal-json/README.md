# Convert ARS Spreadsheets to OSCAL (JSON)

Parse an ARS spreadsheet and output JSON formatted OSCAL Catalog.

## Source files

From: https://security.cms.gov/library/cms-acceptable-risk-safeguards-ars

* ARS_3-1_Excel_Export.xlsx (deprecated)
* [ARS Full Element Principle_Single_Assessment_Current V5.01.xlsx](https://dkanreserve.prod.acquia-sites.com/sites/default/files/Main%20Library%20Documents/ARS%20Full%20Element%20Principle_Single_Assessment_Current%20V5.01.xlsx)

## Signature

```bash
$ poetry run python catalog50.py --help
Usage: catalog50.py [OPTIONS] SOURCE

  Create an OSCAL Catalog from Excel (.xlsx) spreadsheet. Source:
  https://security.cms.gov/library/cms-acceptable-risk-safeguards-ars

Options:
  -t, --title TEXT          [required]
  -a, --ars_version TEXT    ARS version   [default: 5.01]
  -o, --oscal_version TEXT  OSCAL version   [default: 1.0.2]
  -m, --minimize            Minimize output: no PII or HVA overlays.
  --help                    Show this message and exit.
```

## Example run

```bash
$ poetry run python catalog50.py -t CMS_ARS_5_01_catalog ../../ARS\ Full\ Element\ Principle_Single_Assessment_Current\ V5.01.xlsx > ../5.0/oscal/CMS_ARS_5_01_catalog.json
```

## To do

* Some errors in the spreadsheet can't be automatically corrected:
   * line 332 : column J should be blank (now contains "HVA")
   * line 833 : `CP-09(07)` should be `CP-09(08)`
   * _There may be others..._
* May need to manually add a `T` separator to the `"last-modified"` value on line 6 of the output JSON catalog.
