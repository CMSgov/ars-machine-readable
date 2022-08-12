import click

from complianceio.oscal.catalogio import Catalog


@click.command()
@click.argument(
    "catalog",
    type=click.Path(exists=True, dir_okay=False, file_okay=True, resolve_path=True),
    required=True,
)
@click.option(
    "-i",
    "--impact_level",
    default="Moderate",
    show_default=True,
    help="FISMA impact level "
)
@click.option(
    "-s",
    "--supplemental",
    is_flag=True,
    help="Include supplemental (non-mandatory) controls.",
)
def main(catalog, impact_level, supplemental):
    """
    Perform operations on OSCAL Catalog.
    """
    catalog = Catalog(catalog)
    metadata = catalog.oscal.get("metadata", {})
    metadata["title"] += f'_{impact_level}'
    print(metadata)
    print(f'group_ids = {catalog.get_group_ids()}')
    for control in catalog.get_controls():
        control_id = control["id"]
        control_class = control["class"]
        if "Mandatory" in control_class:
            control_baseline = catalog.get_control_property_by_name(control, "baseline")
            if impact_level not in control_baseline:
                continue
        elif not supplemental:
            continue
        print(f'{control_id} - {control_class} - {control["title"]}')
        quit()




if __name__ == "__main__":
    main()
