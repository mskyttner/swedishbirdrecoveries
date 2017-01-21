# swedishbirdrecoveries 0.1.0

* Added a `NEWS.md` file to track changes to the package.

# swedishbirdrecoveries 0.1.1

* Improve datasets - more descriptive column names based on discussions with stakeholders, better documentation covering metadata for column names, removal of duplicated dataset and procedures to update datasets from data dump at Internet Archive
* I18N - internationalization/translations - the ui now uses translations.csv, exposed as dataset birdrecoveries_i18n and a function is used to translate ui strings in that dataset
* Improve shiny app - can now switch between two languages, add clustered map view using leaflet, can search on source, lat, lon, recovery country, species name...

# swedishbirdrecoveries 0.1.2

* Fixed column names and translation of ui strings
* Added search on months and years in shiny app
* Added data-raw transformation script based on public dataset at https://archive.org/download/swedishbirdrecoveries/recoveries.xlsx
* Rewrote vignette and updated docs

# swedishbirdrecoveries 0.1.3

* Simplified UI
* Enable deployment as root context shiny app using Docker image extending the official r-base:latest in "sbr-docker" project, using something like the following command to deploy to shiny in root context: "cd /srv/shiny-server && ln -s /usr/local/lib/R/site-library/swedishbirdrecoveries/shiny-apps/birdrecoveries/* ."
* To deploy, in the mirroreum project, build the "raquamaps/shiny:v0" image using the Makefile target "build-shiny" then release with "docker login && docker push raquamaps/shiny:v0"

# swedishbirdrecoveries 0.1.4

* Using shinydashboards in the UI
