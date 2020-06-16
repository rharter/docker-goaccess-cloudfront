# Change Log

## Version 0.5.0 *(2020-06-16)*

* New: Adds support for pruning old log files.
* New: Adds support for executing scripts or commands once the processing is complete.
* New: Adds support for using .aws credential stores instead of environment variables.
* Fix: Fixes duplicated log entries by removing the database persistence and relying on log file pruning to clean things up.
* Fix: Fixes permissions on generated logs directory.

## Version 0.2.0 *(2020-06-12)*

* New: Adds support for one-off execution to simply process log files and generate static html reports. 
* New: Adds support for processing logs without serving them via nginx (for multi-site support).
* Fix: Permissions are now set appropriately on generated directories and files.

## Version 0.1.0 *(2020-06-11)*

Initial Release
