# swedishbirdrecoveries 0.1.0

* Added a `NEWS.md` file to track changes to the package.

# swedishbirdrecoveries 0.1.1

* Improve datasets - more descriptive column names based on discussions with stakeholders, better documentation covering metadata for column names, removal of duplicated dataset and procedures to update datasets from data dump at Internet Archive
* I18N - internationalization/translations - the ui now uses translations.csv, exposed as dataset birdrecoveries_i18n and a function is used to translate ui strings in that dataset
* Improve shiny app - can now switch between two languages, add clustered map view using leaflet, can search on source, lat, lon, recovery country, species name...
